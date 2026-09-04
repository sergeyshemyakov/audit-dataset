import { TypedDataDomain } from '@ethersproject/abstract-signer';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { _TypedDataEncoder } from 'ethers/lib/utils';
import { deployments, ethers, network } from 'hardhat';

import { accountSet, namedAddresses, Network, validatorSet } from '../../../src/addresses';
import { gatewayThreshold, validatorThreshold } from '../../../src/configs';
import { calculateGovernanceAdminDomainSeparator, getGovernanceAdminDomain } from '../../../src/scripts/governance';
import {
  BallotTypes,
  getGlobalProposalHash,
  getProposalHash,
  VoteStatus,
  VoteType,
} from '../../../src/scripts/proposal';
import {
  GovernanceAdmin,
  GovernanceAdmin__factory,
  MockGatewayV2,
  MockGatewayV2__factory,
  RoninValidator,
  RoninValidator__factory,
  TransparentUpgradeableProxyV2__factory,
} from '../../../src/types';
import { ProposalDetailStruct, GlobalProposalStruct, SignatureStruct } from '../../../src/types/GovernanceAdmin';
import { mapByteSigToSigStruct } from '../../../src/utils';

let governanceAdmin: GovernanceAdmin;
let validatorContract: RoninValidator;
let validatorLogic: RoninValidator;
let gateway: MockGatewayV2;
let gatewayLogic: MockGatewayV2;
let domain: TypedDataDomain;

let deployer: SignerWithAddress;
let normalUser: SignerWithAddress;
let relayer: SignerWithAddress;
let validators: SignerWithAddress[];
let governors: SignerWithAddress[];
let signatures: SignatureStruct[];

const proposals: ProposalDetailStruct[] = [];
const proposalSupports: VoteType[][] = [];
const proposalSignatures: SignatureStruct[][] = [];
const globalProposals: GlobalProposalStruct[] = [];
const globalProposalSupports: VoteType[][] = [];
const globalProposalSignatures: SignatureStruct[][] = [];

describe('Governance Admin test', () => {
  it('deployment', async () => {
    let signers: SignerWithAddress[];
    [deployer, normalUser, relayer, ...signers] = await ethers.getSigners();
    validators = signers.slice(0, signers.length / 2);
    governors = signers.slice(signers.length / 2);
    if (validators.length > governors.length) {
      validators.pop();
    } else if (validators.length < governors.length) {
      governors.pop();
    }
    validators = validators.sort((v1, v2) => v1.address.toLowerCase().localeCompare(v2.address.toLowerCase()));
    governors = governors.sort((v1, v2) => v1.address.toLowerCase().localeCompare(v2.address.toLowerCase()));

    if ((network.name = Network.Hardhat)) {
      namedAddresses['governanceAdminOwner'][network.name] = deployer.address;
      validatorSet[network.name] = validators.map((v, i) => ({
        validator: v.address,
        governor: governors[i].address,
        weight: 1,
      }));
      accountSet['relayers'][network.name] = [relayer.address];
      validatorThreshold[network.name] = { numerator: 1, denominator: validators.length };
      gatewayThreshold[network.name] = { numerator: 1, denominator: validators.length };
    }

    await deployments.fixture('ValidatorContract');
    const GovernanceAdminDeployment = await deployments.get('GovernanceAdmin');
    const validatorDeployment = await deployments.get('ValidatorProxy');
    const validatorLogicDeployment = await deployments.get('ValidatorLogic');
    governanceAdmin = GovernanceAdmin__factory.connect(GovernanceAdminDeployment.address, deployer);
    validatorContract = RoninValidator__factory.connect(validatorDeployment.address, deployer);
    validatorLogic = RoninValidator__factory.connect(validatorLogicDeployment.address, deployer);
    domain = getGovernanceAdminDomain();

    const GatewayFactory = new MockGatewayV2__factory(deployer);
    gatewayLogic = await GatewayFactory.deploy();
    await gatewayLogic.deployed();

    const data = GatewayFactory.interface.encodeFunctionData('initialize', [
      gatewayThreshold[network.name]?.numerator,
      gatewayThreshold[network.name]?.denominator,
      validatorContract.address,
    ]);
    const ProxyFactory = new TransparentUpgradeableProxyV2__factory(deployer);
    const proxy = await ProxyFactory.deploy(gatewayLogic.address, governanceAdmin.address, data);
    await proxy.deployed();
    gateway = MockGatewayV2__factory.connect(proxy.address, deployer);
  });

  it('Should not be able to initialize again', async () => {
    const revertMsg = 'Initializable: contract is already initialized';
    await expect(validatorContract.initialize([], 1, 2)).revertedWith(revertMsg);
    await expect(gateway.initialize(1, 2, validatorContract.address)).revertedWith(revertMsg);
  });

  it('Should be able to verify contract variables', async () => {
    expect(await governanceAdmin.DOMAIN_SEPARATOR()).eq(calculateGovernanceAdminDomainSeparator());
    expect(await governanceAdmin.validatorContract()).eq(validatorContract.address);
    expect(await governanceAdmin.gatewayContract()).eq(gateway.address);
    expect(await governanceAdmin.getProxyImplementation(gateway.address)).eq(gatewayLogic.address);
    expect(await governanceAdmin.getProxyImplementation(validatorContract.address)).eq(validatorLogic.address);
    expect(await governanceAdmin.getProxyAdmin(validatorContract.address)).eq(governanceAdmin.address);
    expect(await governanceAdmin.getProxyAdmin(gateway.address)).eq(governanceAdmin.address);
  });

  describe('Proposing and voting', async () => {
    let proposal: ProposalDetailStruct;
    let globalProposal: GlobalProposalStruct;
    before(() => {
      proposal = {
        nonce: 1,
        chainId: ethers.provider.network.chainId,
        targets: [validatorContract.address],
        values: [0],
        calldatas: [
          new TransparentUpgradeableProxyV2__factory().interface.encodeFunctionData('functionDelegateCall', [
            validatorContract.interface.encodeFunctionData('setThreshold', [validators.length, validators.length]),
          ]),
        ],
      };
      globalProposal = {
        nonce: 1,
        targetOptions: [1], // gateway
        values: [0],
        calldatas: [
          new TransparentUpgradeableProxyV2__factory().interface.encodeFunctionData('functionDelegateCall', [
            validatorContract.interface.encodeFunctionData('setThreshold', [2, validators.length]),
          ]),
        ],
      };
    });

    it('Should not be able to propose by unauthorized sender', async () => {
      await expect(
        governanceAdmin.propose(ethers.provider.network.chainId, [gateway.address], [0], ['0x'])
      ).revertedWith('GovernanceAdmin: sender is not governor');
      await expect(
        governanceAdmin.proposeGlobal(
          [1], // gateway
          [0],
          ['0x']
        )
      ).revertedWith('GovernanceAdmin: sender is not governor');
    });

    it('Should not be able to propose by validator account', async () => {
      await expect(
        governanceAdmin.connect(validators[0]).propose(ethers.provider.network.chainId, [gateway.address], [0], ['0x'])
      ).revertedWith('GovernanceAdmin: sender is not governor');
      await expect(governanceAdmin.connect(validators[1]).proposeGlobal([0], [0], ['0x'])).revertedWith(
        'GovernanceAdmin: sender is not governor'
      );
    });

    it('Should be able to propose and cast vote by governor', async () => {
      const proposalHash = getProposalHash(proposal);
      const supports = [VoteType.For];
      signatures = [
        await governors[0]
          ._signTypedData(domain, BallotTypes, { proposalHash, support: VoteType.For })
          .then(mapByteSigToSigStruct),
      ];
      await governanceAdmin.connect(governors[0]).proposeProposalStructAndCastVotes(proposal, supports, signatures);

      const round = await governanceAdmin.round(proposal.chainId);
      expect(round).eq(1);
      const [voteStatus, hash, againstVoteWeight, forVoteWeight] = await governanceAdmin.vote(proposal.chainId, round);
      expect(voteStatus).eq(VoteStatus.Executed);
      expect(hash).eq(proposalHash);
      expect(againstVoteWeight).eq(0);
      expect(forVoteWeight).eq(1);
      const [num, denom] = await validatorContract.getThreshold();
      expect(num).eq(validators.length);
      expect(denom).eq(validators.length);

      proposals.push({ ...proposal });
      proposalSupports.push(supports);
      proposalSignatures.push([...signatures]);
    });

    it('Should not be able to propose invalid proposals', async () => {
      proposal.nonce = 2;
      await expect(
        governanceAdmin.connect(governors[0]).proposeProposalStructAndCastVotes(proposal, [VoteType.For], [])
      ).revertedWith('Governance: invalid signatures');

      await expect(
        governanceAdmin
          .connect(governors[0])
          .proposeProposalStructAndCastVotes({ ...proposal, calldatas: [] }, [VoteType.For], signatures)
      ).revertedWith('Proposal: invalid array length');

      await expect(
        governanceAdmin
          .connect(governors[0])
          .proposeProposalStructAndCastVotes({ ...proposal, nonce: 3 }, [VoteType.For], signatures)
      ).revertedWith('Governance: invalid proposal nonce');

      await expect(
        governanceAdmin
          .connect(governors[0])
          .proposeProposalStructAndCastVotes({ ...proposal, chainId: 0 }, [VoteType.For], signatures)
      ).revertedWith('Governance: invalid chain id');

      await expect(
        governanceAdmin
          .connect(governors[0])
          .proposeGlobalProposalStructAndCastVotes({ ...globalProposal, nonce: 0 }, [VoteType.For], signatures)
      ).revertedWith('Governance: invalid proposal nonce');
    });

    it('Should be able to propose with valid proposal and governor accounts', async () => {
      proposal.targets = [gateway.address];

      await governanceAdmin
        .connect(governors[0])
        .propose(proposal.chainId, proposal.targets, proposal.values, proposal.calldatas);
    });

    it('Should be able to cast for votes and against votes', async () => {
      const supports = [VoteType.For, VoteType.For, VoteType.For, VoteType.Against];
      const proposalHash = getProposalHash(proposal);
      signatures = await Promise.all(
        supports.map((support, i) =>
          governors[i]._signTypedData(domain, BallotTypes, { proposalHash, support }).then(mapByteSigToSigStruct)
        )
      );

      await expect(
        governanceAdmin.castProposalBySignatures({ ...proposal, nonce: 10 }, supports, signatures)
      ).revertedWith('GovernanceAdmin: cast vote for invalid proposal');

      await governanceAdmin.castProposalBySignatures(proposal, supports, signatures);

      await expect(governanceAdmin.castProposalBySignatures(proposal, supports, signatures)).revertedWith(
        'Governance: the vote is finalized'
      );

      const round = await governanceAdmin.round(proposal.chainId);
      expect(round).eq(2);
      const [voteStatus, hash, againstVoteWeight, forVoteWeight] = await governanceAdmin.vote(proposal.chainId, round);
      expect(voteStatus).eq(VoteStatus.Rejected);
      expect(hash).eq(proposalHash);
      expect(againstVoteWeight).eq(1);
      expect(forVoteWeight).eq(3);

      const [num, denom] = await gateway.getThreshold();
      expect(num).eq(1);
      expect(denom).eq(validators.length);

      proposals.push({ ...proposal });
      proposalSupports.push(supports);
      proposalSignatures.push([...signatures]);
    });

    it('Should be able to propose global proposal and cast votes', async () => {
      const supports = governors.map(() => VoteType.For);
      const globalProposalHash = getGlobalProposalHash(globalProposal);
      signatures = await Promise.all(
        supports.map((support, i) =>
          governors[i]
            ._signTypedData(domain, BallotTypes, { proposalHash: globalProposalHash, support })
            .then(mapByteSigToSigStruct)
        )
      );

      await governanceAdmin
        .connect(governors[0])
        .proposeGlobalProposalStructAndCastVotes(globalProposal, supports, signatures);

      const proposal: ProposalDetailStruct = {
        ...globalProposal,
        chainId: 0,
        targets: globalProposal.targetOptions.map((o) => (o == 0 ? validatorContract.address : gateway.address)),
      };

      const round = await governanceAdmin.round(0);
      expect(round).eq(1);
      const [voteStatus, hash, againstVoteWeight, forVoteWeight] = await governanceAdmin.vote(0, round);
      expect(voteStatus).eq(VoteStatus.Executed);
      expect(hash).eq(getProposalHash(proposal));
      expect(againstVoteWeight).eq(0);
      expect(forVoteWeight).eq(governors.length);

      const [num, denom] = await gateway.getThreshold();
      expect(num).eq(2);
      expect(denom).eq(governors.length);

      globalProposals.push({ ...globalProposal });
      globalProposalSupports.push(supports);
      globalProposalSignatures.push([...signatures]);
    });
  });

  describe('Relay test', () => {
    before(async () => {
      await deployments.fixture('ValidatorContract');
      const GatewayFactory = new MockGatewayV2__factory(deployer);
      gatewayLogic = await GatewayFactory.deploy();
      await gatewayLogic.deployed();

      const data = GatewayFactory.interface.encodeFunctionData('initialize', [
        gatewayThreshold[network.name]?.numerator,
        gatewayThreshold[network.name]?.denominator,
        validatorContract.address,
      ]);
      const ProxyFactory = new TransparentUpgradeableProxyV2__factory(deployer);
      const proxy = await ProxyFactory.deploy(gatewayLogic.address, governanceAdmin.address, data);
      await proxy.deployed();
      gateway = MockGatewayV2__factory.connect(proxy.address, deployer);
    });

    it('Should not be able to relay with unauthorized accounts', async () => {
      const RELAYER_ROLE = await governanceAdmin.RELAYER_ROLE();
      await expect(
        governanceAdmin.relayProposal(proposals[0], proposalSupports[0], proposalSignatures[0])
      ).revertedWith(`AccessControl: account ${deployer.address.toLowerCase()} is missing role ${RELAYER_ROLE}`);
    });

    it('Should not be able to relay with invalid orders', async () => {
      const index = proposals.length - 1;
      await expect(
        governanceAdmin
          .connect(relayer)
          .relayProposal(proposals[index], proposalSupports[index], proposalSignatures[index])
      ).revertedWith('Governance: invalid proposal nonce');
    });

    it('Should be able to relay the right orders', async () => {
      for (let i = 0; i < proposals.length; i++) {
        await governanceAdmin.connect(relayer).relayProposal(proposals[i], proposalSupports[i], proposalSignatures[i]);
      }

      for (let i = 0; i < globalProposals.length; i++) {
        await governanceAdmin
          .connect(relayer)
          .relayGlobalProposal(globalProposals[i], globalProposalSupports[i], globalProposalSignatures[i]);
      }

      {
        const { chainId } = await ethers.provider.getNetwork();
        const round = await governanceAdmin.round(chainId);
        expect(round).eq(2);
        const [num, denom] = await validatorContract.getThreshold();
        expect(num).eq(validators.length);
        expect(denom).eq(validators.length);
      }

      {
        const round = await governanceAdmin.round(0);
        expect(round).eq(1);
        const [num, denom] = await gateway.getThreshold();
        expect(num).eq(2);
        expect(denom).eq(governors.length);
      }
    });
  });
});
