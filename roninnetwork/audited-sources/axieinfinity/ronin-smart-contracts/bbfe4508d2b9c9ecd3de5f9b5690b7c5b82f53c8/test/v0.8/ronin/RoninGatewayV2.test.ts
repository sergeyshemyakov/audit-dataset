import { TransactionReceipt } from '@ethersproject/abstract-provider';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { Result, solidityKeccak256, _TypedDataEncoder } from 'ethers/lib/utils';
import { deployments, ethers, network } from 'hardhat';

import { gatewayThreshold, roninMappedToken, roninChainId, validatorThreshold } from '../../../src/configs';
import {
  ERC20Mintable,
  ERC20Mintable__factory,
  MockERC721,
  MockERC721__factory,
  RoninGatewayV2__factory,
  RoninValidator,
  RoninValidator__factory,
} from '../../../src/types';
import { InfoStruct, ReceiptStruct } from '../../../src/types/IMainchainGatewayV2';
import { accountSet, namedAddresses, Network, validatorSet } from '../../../src/addresses';
import { RoninGatewayV2 } from '../../../src/types/RoninGatewayV2';
import { BigNumber, ContractTransaction } from 'ethers';
import { getReceiptHash } from '../../../src/scripts/gateway';

let gateway: RoninGatewayV2;
let validatorContract: RoninValidator;

let erc20: ERC20Mintable;
let erc721: MockERC721;

let deployer: SignerWithAddress;
let normalUser: SignerWithAddress;
let relayer: SignerWithAddress;
let validators: SignerWithAddress[];
let governors: SignerWithAddress[];

const compareReceipt = (emittedReceipt: Result, expectedReceipt: ReceiptStruct) => {
  expect(emittedReceipt[0], 'invalid id').eq(expectedReceipt.id);
  expect(emittedReceipt[1], 'invalid kind').eq(expectedReceipt.kind);
  expect(emittedReceipt[2], 'invalid mainchain field').to.have.deep.members(Object.values(expectedReceipt.mainchain));
  expect(emittedReceipt[3], 'invalid ronin field').to.have.deep.members(Object.values(expectedReceipt.ronin));
  expect(emittedReceipt[4], 'invalid info field').to.have.deep.members(Object.values(expectedReceipt.info));
};

const validateWithdrawalRequestedEvent = (
  receipt: TransactionReceipt,
  expectedReceiptHash: string,
  expectedReceipt: ReceiptStruct
) => {
  let counter = 0;
  const topic = gateway.interface.getEventTopic('WithdrawalRequested');
  for (let i = 0; i < receipt.logs.length; i++) {
    const eventLog = receipt.logs[i];
    if (eventLog.topics[0] == topic) {
      counter++;
      const emittedReceipt = gateway.interface.parseLog(eventLog);
      compareReceipt(emittedReceipt.args[1], expectedReceipt);
      expect(emittedReceipt.args[0], 'invalid hash').eq(expectedReceiptHash);
    }
  }

  expect(counter).eq(1);
};

describe('Ronin Gateway V2 test', () => {
  before(async () => {
    let signers: SignerWithAddress[];
    [deployer, normalUser, relayer, ...signers] = await ethers.getSigners();
    validators = signers.slice(0, signers.length / 2);
    governors = signers.slice(signers.length / 2);
    if (validators.length > governors.length) {
      validators.pop();
    } else if (validators.length < governors.length) {
      governors.pop();
    }

    erc20 = await new ERC20Mintable__factory(deployer).deploy();
    await erc20.addMinters([deployer.address]);
    erc721 = await new MockERC721__factory(deployer).deploy('ERC721', 'ERC721', '');

    if ((network.name = Network.Hardhat)) {
      validatorSet[network.name] = validators.map((v, i) => ({
        validator: v.address,
        governor: governors[i].address,
        weight: 1,
      }));
      accountSet['relayers'][network.name] = [relayer.address];
      validatorThreshold[network.name] = { numerator: 1, denominator: validators.length };
      gatewayThreshold[network.name] = { numerator: 2, denominator: validators.length };
      roninMappedToken[network.name] = {
        mainchainTokens: [erc20.address, erc721.address],
        roninTokens: [erc20.address, erc721.address],
        chainIds: [network.config.chainId!, network.config.chainId!],
        minimumThresholds: [2, 2],
      };
      roninChainId[network.name] = network.config.chainId!;
      accountSet['withdrawalMigrators'][network.name] = [];
      namedAddresses['roleSetter'][network.name] = deployer.address;
      namedAddresses['governanceAdminOwner'][network.name] = deployer.address;
    }

    await deployments.fixture('RoninGatewayV2Contract');
    const gatewayDeployment = await deployments.get('RoninGatewayV2Proxy');
    const validatorContractDeployment = await deployments.get('ValidatorProxy');
    gateway = RoninGatewayV2__factory.connect(gatewayDeployment.address, deployer);
    validatorContract = RoninValidator__factory.connect(validatorContractDeployment.address, deployer);

    validators = validators.sort((v1, v2) => v1.address.toLowerCase().localeCompare(v2.address.toLowerCase()));
  });

  it('Should able to verify contract storage', async () => {
    expect(await gateway.getMainchainToken(erc20.address, network.config.chainId!)).eq(erc20.address);
    expect(await gateway.validatorContract()).eq(validatorContract.address);
    expect(await gateway.getThreshold()).to.have.deep.members([BigNumber.from(2), BigNumber.from(validators.length)]);
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
          addr: deployer.address,
          tokenAddr: erc20.address,
          chainId: BigNumber.from(network.config.chainId!),
        },
        ronin: {
          addr: normalUser.address,
          tokenAddr: erc20.address,
          chainId: BigNumber.from(roninChainId[network.name]),
        },
        info,
      };
      await erc20.mint(gateway.address, defaultTransferReceipt.info.quantity);
    });

    it('Should not be able to deposit by unauthorized user', async () => {
      await expect(gateway.depositFor(defaultTransferReceipt)).revertedWith('RoninGatewayV2: unauthorized sender');
    });

    it('Should not be able to deposit with invalid receipts', async () => {
      await expect(gateway.connect(validators[0]).depositFor({ ...defaultTransferReceipt, kind: 1 })).revertedWith(
        'RoninGatewayV2: invalid receipt'
      );
      await expect(
        gateway.connect(validators[0]).depositFor({ ...defaultTransferReceipt, info: { erc: 0, id: 1, quantity: 1 } })
      ).revertedWith('Token: invalid info');
      await expect(
        gateway.connect(validators[0]).depositFor({ ...defaultTransferReceipt, info: { erc: 0, id: 1, quantity: 0 } })
      ).revertedWith('Token: invalid info');
      await expect(
        gateway.connect(validators[0]).depositFor({ ...defaultTransferReceipt, info: { erc: 1, id: 1, quantity: 1 } })
      ).revertedWith('Token: invalid info');
      await expect(
        gateway.connect(validators[0]).depositFor({
          ...defaultTransferReceipt,
          ronin: { ...defaultTransferReceipt.ronin, chainId: BigNumber.from(roninChainId[network.name]).add(1) },
        })
      ).revertedWith('RoninGatewayV2: invalid chain id');
    });

    it('Should be able to deposit by validator accounts', async () => {
      await gateway.connect(validators[0]).depositFor(defaultTransferReceipt);
      await expect(gateway.connect(validators[0]).depositFor(defaultTransferReceipt)).revertedWith(
        `GatewayGovernance: ${validators[0].address.toLowerCase()} already voted`
      );
      await expect(() => gateway.connect(validators[1]).depositFor(defaultTransferReceipt)).to.changeTokenBalances(
        erc20,
        [normalUser, gateway],
        [defaultTransferReceipt.info.quantity, -defaultTransferReceipt.info.quantity]
      );
    });

    it('Should be able to bulk submit deposits', async () => {
      const initBalance = 500;
      const minterRole = solidityKeccak256(['string'], ['MINTER_ROLE']);
      await erc721.grantRole(minterRole, gateway.address);
      await erc20.mint(gateway.address, initBalance);

      const receipts: ReceiptStruct[] = [
        { ...defaultTransferReceipt, id: BigNumber.from(1) },
        {
          ...defaultTransferReceipt,
          id: BigNumber.from(2),
          info: { erc: 1, quantity: 0, id: 1 },
          ronin: { ...defaultTransferReceipt.ronin, tokenAddr: erc721.address },
          mainchain: { ...defaultTransferReceipt.mainchain, tokenAddr: erc721.address },
        },
        {
          ...defaultTransferReceipt,
          id: BigNumber.from(3),
          info: { erc: 1, quantity: 0, id: 2 },
          ronin: { ...defaultTransferReceipt.ronin, tokenAddr: erc721.address },
          mainchain: { ...defaultTransferReceipt.mainchain, tokenAddr: erc721.address },
        },
        { ...defaultTransferReceipt, id: BigNumber.from(4), info: { erc: 0, quantity: 1000, id: 0 } },
        // duplicated
        { ...defaultTransferReceipt, id: BigNumber.from(4), info: { erc: 0, quantity: 1000, id: 0 } },
      ];
      // check double vote for receipt id = 4
      await expect(gateway.connect(validators[0]).bulkDepositFor(receipts)).revertedWith(
        `GatewayGovernance: ${validators[0].address.toLowerCase()} already voted`
      );
      receipts.pop();

      await gateway.connect(validators[0]).bulkDepositFor(receipts);
      await expect(gateway.connect(validators[1]).bulkDepositFor(receipts)).revertedWith('Token: ERC20 minting failed');
      await erc20.addMinters([gateway.address]);
      await expect(() => gateway.connect(validators[1]).bulkDepositFor(receipts)).to.changeTokenBalances(
        erc20,
        [normalUser, gateway],
        [1001, -initBalance]
      );
      expect(await erc721.ownerOf(1)).eq(normalUser.address);
      expect(await erc721.ownerOf(2)).eq(normalUser.address);
    });

    it('Should be able to deposit once the receipt has been solved', async () => {
      await expect(gateway.connect(validators[3]).depositFor(defaultTransferReceipt)).revertedWith(
        'GatewayGovernance: the vote is finalized'
      );
    });
  });

  describe('Withdrawal test', () => {
    let info: InfoStruct;
    const receipts: ReceiptStruct[] = [];
    const receiptHashes: string[] = [];

    before(async () => {
      info = {
        erc: 0,
        id: BigNumber.from(0),
        quantity: BigNumber.from(2),
      };
    });

    it('Should be able to request withdrawal once insufficient amount', async () => {
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: deployer.address,
            tokenAddr: erc20.address,
            info,
          },
          network.config.chainId!
        )
      ).revertedWith(
        `Token: could not transfer TokenInfo(0x00,0x00,0x02) from ${normalUser.address.toLowerCase()} to ${gateway.address.toLowerCase()} token ${erc20.address.toLowerCase()}`
      );
    });

    it('Should not be able to request withdrawal when does not own the ERC721 token', async () => {
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: deployer.address,
            tokenAddr: erc20.address,
            info: {
              erc: 1,
              id: 1,
              quantity: 0,
            },
          },
          network.config.chainId!
        )
      ).revertedWith(
        `Token: could not transfer TokenInfo(0x01,0x01,0x00) from ${normalUser.address.toLowerCase()} to ${gateway.address.toLowerCase()} token ${erc20.address.toLowerCase()}`
      );
    });

    it('Should not be able to request withdrawal with invalid request', async () => {
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: deployer.address,
            tokenAddr: erc20.address,
            info: {
              erc: 1,
              id: 1,
              quantity: 1,
            },
          },
          network.config.chainId!
        )
      ).revertedWith('Token: invalid info');
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: deployer.address,
            tokenAddr: erc20.address,
            info: {
              erc: 0,
              id: 1,
              quantity: 1,
            },
          },
          network.config.chainId!
        )
      ).revertedWith('Token: invalid info');
    });

    it("Should not be able to request withdrawal token when it's not mapped", async () => {
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: normalUser.address,
            tokenAddr: '0x0000000000000000000000000000000000000000',
            info,
          },
          network.config.chainId!
        )
      ).revertedWith('RoninGatewayV2: unsupported token');
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: normalUser.address,
            tokenAddr: erc20.address,
            info,
          },
          network.config.chainId! + 1
        )
      ).revertedWith('RoninGatewayV2: unsupported token');
    });

    it('Should be able to request withdrawal token', async () => {
      await erc20.mint(normalUser.address, 1000);
      await erc20.connect(normalUser).approve(gateway.address, 1000);

      const transferReceipt: ReceiptStruct = {
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
        info,
      };
      receipts.push(transferReceipt);

      const receiptHash = getReceiptHash(transferReceipt);
      receiptHashes.push(receiptHash);

      let tx: ContractTransaction;
      await expect(async () => {
        tx = await gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: normalUser.address,
            tokenAddr: erc20.address,
            info,
          },
          network.config.chainId!
        );
        return tx;
      }).to.changeTokenBalances(erc20, [gateway, normalUser], [info.quantity, -info.quantity]);
      const receipt = await tx!.wait();
      validateWithdrawalRequestedEvent(receipt, receiptHash, transferReceipt);
    });

    it('Should not be able to request withdrawal with too small amount', async () => {
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: normalUser.address,
            tokenAddr: erc20.address,
            info: {
              erc: 0,
              quantity: 1,
              id: 0,
            },
          },
          network.config.chainId! + 1
        )
      ).revertedWith('MinimumWithdrawal: query for too small quantity');
    });

    it('Should not be able to request withdrawal with empty quantity', async () => {
      await expect(
        gateway.connect(normalUser).requestWithdrawalFor(
          {
            recipientAddr: normalUser.address,
            tokenAddr: erc20.address,
            info: {
              erc: 0,
              quantity: 0,
              id: 0,
            },
          },
          network.config.chainId! + 1
        )
      ).revertedWith('Token: invalid info');
    });

    it('Should be able to request withdrawal for an ERC721 token', async () => {
      await erc721['mint(address,uint256)'](normalUser.address, 10);
      await erc721.connect(normalUser).approve(gateway.address, 10);

      const info: InfoStruct = {
        erc: 1,
        quantity: BigNumber.from(0),
        id: BigNumber.from(10),
      };

      const transferReceipt: ReceiptStruct = {
        id: BigNumber.from(1),
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
        info,
      };
      receipts.push(transferReceipt);

      const receiptHash = getReceiptHash(transferReceipt);
      receiptHashes.push(receiptHash);
      const tx = await gateway.connect(normalUser).requestWithdrawalFor(
        {
          recipientAddr: normalUser.address,
          tokenAddr: erc721.address,
          info,
        },
        network.config.chainId!
      );
      const receipt = await tx.wait();
      expect(await erc721.ownerOf(10)).eq(gateway.address);
      validateWithdrawalRequestedEvent(receipt, receiptHash, transferReceipt);
    });

    it('Should be able to submit signatures for requested withdrawals', async () => {
      await gateway.connect(validators[0]).bulkSubmitWithdrawalSignatures([0, 1], ['0x', '0x']);
      await gateway.connect(validators[1]).bulkSubmitWithdrawalSignatures([0, 1], ['0x', '0x']);
    });

    it('Should be able to request signatures again', async () => {
      const withdrawals = [0, 1];
      const topic = gateway.interface.getEventTopic('WithdrawalSignaturesRequested');

      const txs = await Promise.all(
        withdrawals.map((id) => gateway.connect(normalUser).requestWithdrawalSignatures(id))
      );
      const txReceipts = await Promise.all(txs.map((tx) => tx.wait()));

      for (let i = 0; i < txReceipts.length; i++) {
        for (let j = 0; j < txReceipts[i].logs.length; j++) {
          const eventLog = txReceipts[i].logs[j];
          if (eventLog.topics[0] == topic) {
            const emittedReceipt = gateway.interface.parseLog(eventLog);
            compareReceipt(emittedReceipt.args[1], receipts[i]);
            expect(emittedReceipt.args[0], 'invalid hash').eq(receiptHashes[i]);
            break;
          }
        }
      }
    });

    it('Should be able to acknowledge mainchain withdrawal by authorized validators', async () => {
      await expect(gateway.acknowledgeMainchainWithdrew(0)).revertedWith('RoninGatewayV2: unauthorized sender');
      await gateway.connect(validators[0]).acknowledgeMainchainWithdrew(0);
      expect(await gateway.mainchainWithdrew(0)).to.be.true;
      await expect(gateway.connect(normalUser).requestWithdrawalSignatures(0)).revertedWith(
        'RoninGatewayV2: withdrew on mainchain already'
      );
    });
  });
});
