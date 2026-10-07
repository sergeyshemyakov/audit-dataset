import { TypedDataDomain } from '@ethersproject/abstract-signer';
import { TransactionReceipt } from '@ethersproject/abstract-provider';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { BigNumber, ContractTransaction } from 'ethers';
import { _TypedDataEncoder } from 'ethers/lib/utils';
import { deployments, ethers, network } from 'hardhat';

import { getMainchainGatewayDomain, getReceiptHash, ReceiptTypes } from '../../../src/scripts/gateway';
import {
  gatewayThreshold,
  mainnetChainId,
  mainchainMappedToken,
  roninChainId,
  validatorThreshold,
} from '../../../src/configs';
import { mapByteSigToSigStruct } from '../../../src/utils';
import {
  GovernanceAdmin,
  GovernanceAdmin__factory,
  ERC20Mintable,
  ERC20Mintable__factory,
  MainchainGatewayV2,
  MainchainGatewayV2__factory,
  MockERC721,
  MockERC721__factory,
  RoninValidator,
  RoninValidator__factory,
  TransparentUpgradeableProxyV2__factory,
  WETH,
  WETH__factory,
} from '../../../src/types';
import { InfoStruct, ReceiptStruct } from '../../../src/types/IMainchainGatewayV2';
import { accountSet, namedAddresses, Network, validatorSet } from '../../../src/addresses';
import { ProposalDetailStruct } from '../../../src/types/GovernanceAdmin';
import { SignatureStruct } from '../../../src/types/MainchainGatewayV2';
import { BallotTypes, getProposalHash, VoteType } from '../../../src/scripts/proposal';
import { getGovernanceAdminDomain } from '../../../src/scripts/governance';

let governanceAdmin: GovernanceAdmin;
let gateway: MainchainGatewayV2;
let validatorContract: RoninValidator;
let gatewayDomain: TypedDataDomain;
let governanceAdminDomain: TypedDataDomain;

let weth: WETH;
let erc20: ERC20Mintable;
let erc721: MockERC721;

let deployer: SignerWithAddress;
let normalUser: SignerWithAddress;
let relayer: SignerWithAddress;
let withdrawalUnlocker: SignerWithAddress;
let validators: SignerWithAddress[];
let governors: SignerWithAddress[];

const nativeToken = '0x0000000000000000000000000000000000000000';
const validateDepositRequestedEvent = (
  receipt: TransactionReceipt,
  expectedReceiptHash: string,
  expectedTransferReceipt: ReceiptStruct
) => {
  let counter = 0;
  const topic = gateway.interface.getEventTopic('DepositRequested');
  for (let i = 0; i < receipt.logs.length; i++) {
    const eventLog = receipt.logs[i];
    if (eventLog.topics[0] == topic) {
      counter++;
      const emittedReceipt = gateway.interface.parseLog(eventLog);
      expect(emittedReceipt.args[1][0], 'invalid id').eq(expectedTransferReceipt.id);
      expect(emittedReceipt.args[1][1], 'invalid kind').eq(expectedTransferReceipt.kind);
      expect(emittedReceipt.args[1][2], 'invalid mainchain field').to.have.deep.members(
        Object.values(expectedTransferReceipt.mainchain)
      );
      expect(emittedReceipt.args[1][3], 'invalid ronin field').to.have.deep.members(
        Object.values(expectedTransferReceipt.ronin)
      );
      expect(emittedReceipt.args[1][4], 'invalid info field').to.have.deep.members(
        Object.values(expectedTransferReceipt.info)
      );
      expect(emittedReceipt.args[0], 'invalid hash').eq(expectedReceiptHash);
    }
  }

  expect(counter).eq(1);
};

describe('Mainchain Gateway V2 test', () => {
  before(async () => {
    let signers: SignerWithAddress[];
    [deployer, normalUser, relayer, withdrawalUnlocker, ...signers] = await ethers.getSigners();
    validators = signers.slice(0, signers.length / 2);
    governors = signers.slice(signers.length / 2);
    if (validators.length > governors.length) {
      validators.pop();
    } else if (validators.length < governors.length) {
      governors.pop();
    }

    weth = await new WETH__factory(deployer).deploy();
    erc20 = await new ERC20Mintable__factory(deployer).deploy();
    await erc20.addMinters([deployer.address]);
    erc721 = await new MockERC721__factory(deployer).deploy('ERC721', 'ERC721', '');

    if (network.name == Network.Hardhat) {
      validatorSet[network.name] = validators.map((v, i) => ({
        validator: v.address,
        governor: governors[i].address,
        weight: 1,
      }));
      accountSet['relayers'][network.name] = [relayer.address];
      validatorThreshold[network.name] = { numerator: 1, denominator: validators.length };
      gatewayThreshold[network.name] = { numerator: 1, denominator: validators.length };
      mainchainMappedToken[network.name] = {
        mainchainTokens: [weth.address, erc721.address],
        roninTokens: [weth.address, erc721.address],
        standards: [0, 1],
        fulSigThresholds: [10, 0], // tier-2 withdrawal
        lockedThresholds: [20, 0], // tier-3 withdrawal
        unlockFeePercentages: [100_000, 0], // 10%, 0%
        dailyWithdrawalLimits: [12, 0], // daily limit dont apply for tier-3 withdrawal
      };
      mainnetChainId[network.name] = [network.config.chainId!];
      roninChainId[network.name] = 2020;
      namedAddresses['weth'][network.name] = weth.address;
      namedAddresses['roleSetter'][network.name] = deployer.address;
      namedAddresses['governanceAdminOwner'][network.name] = deployer.address;
      accountSet['withdrawalUnlockers'][network.name] = [withdrawalUnlocker.address];
    }

    await deployments.fixture('MainchainGatewayV2Contract');
    const GovernanceAdminDeployment = await deployments.get('GovernanceAdmin');
    const gatewayDeployment = await deployments.get('MainchainGatewayV2Proxy');
    const validatorContractDeployment = await deployments.get('ValidatorProxy');
    governanceAdmin = GovernanceAdmin__factory.connect(GovernanceAdminDeployment.address, deployer);
    gateway = MainchainGatewayV2__factory.connect(gatewayDeployment.address, deployer);
    validatorContract = RoninValidator__factory.connect(validatorContractDeployment.address, deployer);
    gatewayDomain = getMainchainGatewayDomain(network.config.chainId!, gateway.address);
    governanceAdminDomain = getGovernanceAdminDomain();

    validators = validators.sort((v1, v2) => v1.address.toLowerCase().localeCompare(v2.address.toLowerCase()));
  });

  it('Should able to verify contract storage', async () => {
    expect(await gateway.validatorContract()).eq(validatorContract.address);
    expect(await gateway.getThreshold()).to.have.deep.members([BigNumber.from(1), BigNumber.from(validators.length)]);
    const token = await gateway.getRoninToken(weth.address);
    expect(token[0]).eq(0);
    expect(token[1]).eq(weth.address);
    expect(await gateway.fullSigThreshold(weth.address)).eq(10);
    expect(await gateway.lockedThreshold(weth.address)).eq(20);
    expect(await gateway.dailyWithdrawalLimit(weth.address)).eq(12);
    expect(await gateway.DOMAIN_SEPARATOR()).eq(_TypedDataEncoder.hashDomain(gatewayDomain));
  });

  describe('Deposit test', () => {
    let defaultTransferReceipt: ReceiptStruct;
    let info: InfoStruct;

    before(async () => {
      info = {
        erc: 0,
        id: BigNumber.from(0),
        quantity: BigNumber.from(1),
      };

      defaultTransferReceipt = {
        id: BigNumber.from(0),
        kind: 0,
        mainchain: {
          addr: normalUser.address,
          tokenAddr: erc20.address,
          chainId: BigNumber.from(network.config.chainId!),
        },
        ronin: {
          addr: deployer.address,
          tokenAddr: erc20.address,
          chainId: BigNumber.from(roninChainId[network.name]),
        },
        info,
      };
    });

    it('Should not be able to deposit once insufficient amount', async () => {
      await expect(
        gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: weth.address,
          info,
        })
      ).revertedWith(
        `Token: could not transfer TokenInfo(0x00,0x00,0x01) from ${normalUser.address.toLowerCase()} to ${gateway.address.toLowerCase()} token ${weth.address.toLowerCase()}`
      );
    });

    it('Should not be able to deposit when does not own the ERC721 token', async () => {
      await expect(
        gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: erc721.address,
          info: {
            erc: 1,
            id: BigNumber.from(1),
            quantity: BigNumber.from(0),
          },
        })
      ).revertedWith(
        `Token: could not transfer TokenInfo(0x01,0x01,0x00) from ${normalUser.address.toLowerCase()} to ${gateway.address.toLowerCase()} token ${erc721.address.toLowerCase()}`
      );
    });

    it("Should not be able to deposit token when it's not mapped", async () => {
      await erc20.mint(normalUser.address, 1);
      await erc20.connect(normalUser).approve(gateway.address, 1);
      await expect(
        gateway.connect(normalUser).requestDepositFor({
          recipientAddr: normalUser.address,
          tokenAddr: erc20.address,
          info,
        })
      ).revertedWith('MainchainGatewayV2: unsupported token');
    });

    it('Should be able to deposit the supported token', async () => {
      await expect(gateway.getRoninToken(erc20.address)).to.revertedWith('MainchainGatewayV2: unsupported token');

      // Map tokens by voting
      const proposal: ProposalDetailStruct = {
        chainId: network.config.chainId!,
        nonce: 1,
        targets: [gateway.address],
        values: [0],
        calldatas: [
          new TransparentUpgradeableProxyV2__factory().interface.encodeFunctionData('functionDelegateCall', [
            gateway.interface.encodeFunctionData('mapTokensAndThresholds', [
              [erc20.address],
              [erc20.address],
              [0],
              [[10], [20], [100_000], [12]],
            ]),
          ]),
        ],
      };

      const proposalHash = getProposalHash(proposal);
      const signatures = await Promise.all(
        governors
          .slice(0, 1)
          .map((v) =>
            v
              ._signTypedData(governanceAdminDomain, BallotTypes, { proposalHash, support: VoteType.For })
              .then(mapByteSigToSigStruct)
          )
      );
      await governanceAdmin
        .connect(governors[0])
        .proposeProposalStructAndCastVotes(proposal, [VoteType.For], signatures);
      expect((await gateway.getRoninToken(erc20.address))[1]).eq(erc20.address);

      const receiptHash = getReceiptHash(defaultTransferReceipt);

      let tx: ContractTransaction;
      await expect(async () => {
        tx = await gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: erc20.address,
          info,
        });
        return tx;
      }).to.changeTokenBalances(
        erc20,
        [normalUser, gateway],
        [-defaultTransferReceipt.info.quantity, defaultTransferReceipt.info.quantity]
      );
      const receipt = await tx!.wait();
      validateDepositRequestedEvent(receipt, receiptHash, defaultTransferReceipt);
      expect(receipt.gasUsed).lt(100_000);
    });

    it('Should not be able to deposit with wrong token standard', async () => {
      let info: InfoStruct;

      info = {
        erc: 1,
        id: BigNumber.from(1),
        quantity: BigNumber.from(0),
      };

      await expect(
        gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: erc20.address,
          info,
        })
      ).revertedWith('MainchainGatewayV2: invalid token standard');

      info = {
        erc: 0,
        id: BigNumber.from(0),
        quantity: BigNumber.from(1),
      };

      await expect(
        gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: erc721.address,
          info,
        })
      ).revertedWith('MainchainGatewayV2: invalid token standard');
    });

    it('Should not be able to deposit token with extra ETH', async () => {
      await expect(
        gateway
          .connect(normalUser)
          .requestDepositFor({ recipientAddr: deployer.address, tokenAddr: erc20.address, info }, { value: 1 })
      ).revertedWith('MainchainGatewayV2: invalid request');
      await expect(
        gateway
          .connect(normalUser)
          .requestDepositFor({ recipientAddr: deployer.address, tokenAddr: weth.address, info }, { value: 1 })
      ).revertedWith('MainchainGatewayV2: invalid request');
    });

    it('Should be able to deposit WETH', async () => {
      await weth.connect(normalUser).deposit({ value: 1 });
      await weth.connect(normalUser).approve(gateway.address, 1);

      const transferReceipt: ReceiptStruct = {
        ...defaultTransferReceipt,
        id: BigNumber.from(1),
        mainchain: {
          ...defaultTransferReceipt.mainchain,
          tokenAddr: weth.address,
        },
        ronin: {
          ...defaultTransferReceipt.ronin,
          tokenAddr: weth.address,
        },
      };

      const receiptHash = getReceiptHash(transferReceipt);
      let tx: ContractTransaction;
      await expect(async () => {
        tx = await gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: weth.address,
          info,
        });
        return tx;
      })
        .to.changeTokenBalance(weth, normalUser, -defaultTransferReceipt.info.quantity)
        .to.changeEtherBalance(gateway, defaultTransferReceipt.info.quantity);

      const receipt = await tx!.wait();
      validateDepositRequestedEvent(receipt, receiptHash, transferReceipt);
      expect(receipt.gasUsed).lt(100_000);
    });

    it('Should not be able to deposit ETH with the invalid requested amount', async () => {
      await expect(
        gateway.connect(normalUser).requestDepositFor(
          {
            recipientAddr: normalUser.address,
            tokenAddr: '0x0000000000000000000000000000000000000000',
            info,
          },
          { value: 0 }
        )
      ).revertedWith('MainchainGatewayV2: invalid request');
    });

    it('Should be able to deposit ETH', async () => {
      const transferReceipt: ReceiptStruct = {
        ...defaultTransferReceipt,
        id: BigNumber.from(2),
        mainchain: {
          ...defaultTransferReceipt.mainchain,
          tokenAddr: nativeToken,
        },
        ronin: {
          ...defaultTransferReceipt.ronin,
          tokenAddr: weth.address,
        },
      };

      const receiptHash = getReceiptHash(transferReceipt);
      let tx: ContractTransaction;
      await expect(async () => {
        tx = await gateway.connect(normalUser).requestDepositFor(
          {
            recipientAddr: deployer.address,
            tokenAddr: nativeToken,
            info,
          },
          { value: info.quantity }
        );
        return tx;
      }).to.changeEtherBalances([normalUser, gateway], [-transferReceipt.info.quantity, transferReceipt.info.quantity]);
      const receipt = await tx!.wait();
      validateDepositRequestedEvent(receipt, receiptHash, transferReceipt);
      expect(receipt.gasUsed).lt(60_000);
    });

    it('Should not be able to deposit empty amount', async () => {
      await expect(
        normalUser.sendTransaction({
          to: gateway.address,
          value: 0,
        })
      ).revertedWith('Token: invalid info');
      await expect(
        gateway.connect(normalUser).requestDepositFor({
          recipientAddr: deployer.address,
          tokenAddr: weth.address,
          info: { ...info, quantity: 0 },
        })
      ).revertedWith('Token: invalid info');
    });

    it('Should be able to receive ETH directly to create deposit request', async () => {
      const transferReceipt: ReceiptStruct = {
        ...defaultTransferReceipt,
        id: BigNumber.from(3),
        mainchain: {
          ...defaultTransferReceipt.mainchain,
          tokenAddr: nativeToken,
        },
        ronin: {
          ...defaultTransferReceipt.ronin,
          addr: normalUser.address,
          tokenAddr: weth.address,
        },
      };
      const receiptHash = getReceiptHash(transferReceipt);

      let tx: ContractTransaction;
      await expect(async () => {
        tx = await normalUser.sendTransaction({
          to: gateway.address,
          value: 1,
        });
        return tx;
      }).to.changeEtherBalances(
        [normalUser, gateway],
        [-defaultTransferReceipt.info.quantity, defaultTransferReceipt.info.quantity]
      );
      const receipt = await tx!.wait();
      validateDepositRequestedEvent(receipt, receiptHash, transferReceipt);
      expect(receipt.gasUsed).lt(50_000);
    });

    it('Should be able to deposit ERC721 token', async () => {
      await erc721['mint(address,uint256)'](normalUser.address, 2);
      await erc721.connect(normalUser).approve(gateway.address, 2);

      const transferReceipt: ReceiptStruct = {
        ...defaultTransferReceipt,
        id: BigNumber.from(4),
        mainchain: {
          ...defaultTransferReceipt.mainchain,
          tokenAddr: erc721.address,
        },
        ronin: {
          ...defaultTransferReceipt.ronin,
          tokenAddr: erc721.address,
        },
        info: {
          erc: 1,
          quantity: BigNumber.from(0),
          id: BigNumber.from(2),
        },
      };
      const receiptHash = getReceiptHash(transferReceipt);

      const tx = await gateway.connect(normalUser).requestDepositFor({
        recipientAddr: deployer.address,
        tokenAddr: erc721.address,
        info: transferReceipt.info,
      });
      const receipt = await tx.wait();
      validateDepositRequestedEvent(receipt, receiptHash, transferReceipt);
      expect(receipt.gasUsed).lt(120_000);
    });
  });

  describe('Withdrawal test', () => {
    let defaultWithdrawalReceipt: ReceiptStruct;
    let signatures: SignatureStruct[];

    before(async () => {
      defaultWithdrawalReceipt = {
        id: BigNumber.from(0),
        kind: 1,
        mainchain: {
          addr: normalUser.address,
          tokenAddr: erc20.address,
          chainId: BigNumber.from(network.config.chainId!),
        },
        ronin: {
          addr: normalUser.address,
          tokenAddr: erc20.address,
          chainId: BigNumber.from(network.config.chainId!),
        },
        info: {
          erc: 0,
          id: 0,
          quantity: 1,
        },
      };

      await erc721['mint(address,uint256)'](gateway.address, 1);
      await gateway.receiveEther({ value: 1000 });
    });

    it('Should not be able to submit deposit receipt', async () => {
      const depositReceipt = {
        ...defaultWithdrawalReceipt,
        kind: 0, // Deposit
      };
      const signatures = await Promise.all(
        validators.map((v) => v._signTypedData(gatewayDomain, ReceiptTypes, depositReceipt).then(mapByteSigToSigStruct))
      );
      await expect(gateway.submitWithdrawal(depositReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: invalid receipt kind'
      );
    });

    it('Should not be able to submit withdrawal from other chain', async () => {
      const withdrawalReceipt = {
        ...defaultWithdrawalReceipt,
        mainchain: {
          ...defaultWithdrawalReceipt.mainchain,
          chainId: BigNumber.from(network.config.chainId! + 1),
        },
      };
      signatures = await Promise.all(
        validators.map((v) =>
          v._signTypedData(gatewayDomain, ReceiptTypes, withdrawalReceipt).then(mapByteSigToSigStruct)
        )
      );
      await expect(gateway.submitWithdrawal(withdrawalReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: invalid chain id'
      );
    });

    it('Should be able to submit normal withdrawal with valid signatures', async () => {
      const quantity = (await erc20.balanceOf(gateway.address)).add(1);
      defaultWithdrawalReceipt.info = {
        ...defaultWithdrawalReceipt.info,
        quantity,
      };

      signatures = await Promise.all(
        validators
          .slice(0, 1)
          .map((v) =>
            v._signTypedData(gatewayDomain, ReceiptTypes, defaultWithdrawalReceipt).then(mapByteSigToSigStruct)
          )
      );

      await expect(gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).revertedWith(
        'Token: ERC20 minting failed'
      );
      await erc20.addMinters([gateway.address]);
      await expect(() => gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).to.changeTokenBalances(
        erc20,
        [gateway, normalUser],
        [-quantity.sub(1), quantity]
      );

      expect(await gateway.withdrawalHash(defaultWithdrawalReceipt.id)).eq(getReceiptHash(defaultWithdrawalReceipt));
      expect(await gateway.lastSyncedWithdrawal(defaultWithdrawalReceipt.mainchain.tokenAddr)).eq(quantity);
    });

    it('Should not be able to double withdraw', async () => {
      await expect(gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: query for processed withdrawal'
      );
    });

    it('Should not be able to withdraw with the signatures of the other receipt', async () => {
      const withdrawalReceipt: ReceiptStruct = {
        ...defaultWithdrawalReceipt,
        id: BigNumber.from(1),
        info: {
          ...defaultWithdrawalReceipt.info,
          quantity: BigNumber.from(1).add(defaultWithdrawalReceipt.info.quantity),
        },
      };
      await expect(gateway.submitWithdrawal(withdrawalReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: query for insufficient vote weight'
      );
    });

    it('Should not be able to submit tier-2 withdrawal without enough signatures', async () => {
      defaultWithdrawalReceipt = {
        ...defaultWithdrawalReceipt,
        id: BigNumber.from(1),
        mainchain: {
          ...defaultWithdrawalReceipt.mainchain,
          tokenAddr: weth.address,
        },
        ronin: {
          ...defaultWithdrawalReceipt.ronin,
          tokenAddr: weth.address,
        },
        info: {
          ...defaultWithdrawalReceipt.info,
          quantity: 10,
        },
      };
      signatures = await Promise.all(
        validators
          .slice(0, 1)
          .map((v) =>
            v._signTypedData(gatewayDomain, ReceiptTypes, defaultWithdrawalReceipt).then(mapByteSigToSigStruct)
          )
      );
      await expect(gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: query for insufficient vote weight'
      );
    });

    it('Should be able to submit tier-2 withdrawal with enough signatures', async () => {
      signatures = await Promise.all(
        validators.map((v) =>
          v._signTypedData(gatewayDomain, ReceiptTypes, defaultWithdrawalReceipt).then(mapByteSigToSigStruct)
        )
      );
      await expect(() => gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).to.changeEtherBalances(
        [gateway, normalUser],
        [-10, 10]
      );
      expect(await gateway.withdrawalHash(defaultWithdrawalReceipt.id)).eq(getReceiptHash(defaultWithdrawalReceipt));
      expect(await gateway.lastSyncedWithdrawal(weth.address)).eq(10);
    });

    it('Should not ble able to submit tier-3 withdrawal without enough signatures', async () => {
      defaultWithdrawalReceipt = {
        ...defaultWithdrawalReceipt,
        id: BigNumber.from(2),
        info: {
          ...defaultWithdrawalReceipt.info,
          quantity: 50,
        },
      };
      signatures = await Promise.all(
        validators
          .slice(0, 1)
          .map((v) =>
            v._signTypedData(gatewayDomain, ReceiptTypes, defaultWithdrawalReceipt).then(mapByteSigToSigStruct)
          )
      );
      await expect(gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: query for insufficient vote weight'
      );
    });

    it('Should be able to submit tier-3 withdrawal with enough signatures', async () => {
      signatures = await Promise.all(
        validators.map((v) =>
          v._signTypedData(gatewayDomain, ReceiptTypes, defaultWithdrawalReceipt).then(mapByteSigToSigStruct)
        )
      );
      await expect(() => gateway.submitWithdrawal(defaultWithdrawalReceipt, signatures)).to.changeEtherBalances(
        [gateway, normalUser],
        [0, 0]
      );
      expect(await gateway.withdrawalHash(defaultWithdrawalReceipt.id)).eq(getReceiptHash(defaultWithdrawalReceipt));
    });

    it('Should not be able to unlock tier-3 withdrawal using invalid receipt', async () => {
      const withdrawalReceipt = {
        ...defaultWithdrawalReceipt,
        info: {
          ...defaultWithdrawalReceipt.info,
          quantity: 100,
        },
      };
      await expect(gateway.connect(withdrawalUnlocker).unlockWithdrawal(withdrawalReceipt)).revertedWith(
        'MainchainGatewayV2: invalid receipt'
      );
    });

    it('Should not be able to unlock tier-3 withdrawal by unauthorized sender', async () => {
      const role = await gateway.WITHDRAWAL_UNLOCKER_ROLE();
      await expect(gateway.unlockWithdrawal(defaultWithdrawalReceipt)).revertedWith(
        `AccessControl: account ${deployer.address.toLowerCase()} is missing role ${role}`
      );
    });

    it('Should be able to unlock tier-3 withdrawal', async () => {
      const feeAmount = BigNumber.from(defaultWithdrawalReceipt.info.quantity).div(10);
      await expect(() =>
        gateway.connect(withdrawalUnlocker).unlockWithdrawal(defaultWithdrawalReceipt)
      ).to.changeEtherBalances(
        [gateway, normalUser, withdrawalUnlocker],
        [
          -defaultWithdrawalReceipt.info.quantity,
          BigNumber.from(defaultWithdrawalReceipt.info.quantity).sub(feeAmount),
          feeAmount,
        ]
      );
    });

    it('Should not be able to submit withdrawal once reaching daily withdrawal limit', async () => {
      const withdrawalReceipt = {
        ...defaultWithdrawalReceipt,
        id: BigNumber.from(3),
        info: {
          ...defaultWithdrawalReceipt.info,
          quantity: 2,
        },
      };

      signatures = await Promise.all(
        validators
          .slice(0, 1)
          .map((v) => v._signTypedData(gatewayDomain, ReceiptTypes, withdrawalReceipt).then(mapByteSigToSigStruct))
      );
      await expect(gateway.submitWithdrawal(withdrawalReceipt, signatures)).revertedWith(
        'MainchainGatewayV2: reached daily withdrawal limit'
      );
    });

    it('Should be able to withdraw ERC721 token', async () => {
      const withdrawalReceipt = {
        id: BigNumber.from(3),
        kind: 1,
        mainchain: {
          addr: normalUser.address,
          tokenAddr: erc721.address,
          chainId: BigNumber.from(network.config.chainId!),
        },
        ronin: {
          addr: normalUser.address,
          tokenAddr: erc721.address,
          chainId: BigNumber.from(network.config.chainId!),
        },
        info: {
          erc: 1,
          quantity: 0,
          id: 1,
        },
      };
      signatures = await Promise.all(
        validators
          .slice(0, 1)
          .map((v) => v._signTypedData(gatewayDomain, ReceiptTypes, withdrawalReceipt).then(mapByteSigToSigStruct))
      );
      await gateway.submitWithdrawal(withdrawalReceipt, signatures);
      expect(await erc721.ownerOf(1)).eq(normalUser.address);
    });
  });
});
