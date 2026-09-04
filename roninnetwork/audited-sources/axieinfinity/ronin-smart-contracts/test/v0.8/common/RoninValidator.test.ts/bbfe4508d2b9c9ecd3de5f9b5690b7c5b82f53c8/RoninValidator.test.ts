import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { expect } from 'chai';
import { _TypedDataEncoder } from 'ethers/lib/utils';
import { ethers } from 'hardhat';

import {
  RoninValidator,
  RoninValidator__factory,
  TransparentUpgradeableProxyV2,
  TransparentUpgradeableProxyV2__factory,
} from '../../../src/types';

let validatorContract: RoninValidator;
let validatorProxy: TransparentUpgradeableProxyV2;

let governanceAdmin: SignerWithAddress;
let firstUser: SignerWithAddress;
let secondUser: SignerWithAddress;
let thirdUser: SignerWithAddress;
let validators: SignerWithAddress[];
let governors: SignerWithAddress[];

const unauthorizedRevertMsg = 'HasProxyAdmin: unauthorized sender';
const adminCannotFallbackRevertMsg = 'TransparentUpgradeableProxy: admin cannot fallback to proxy target';
const invalidWeightRevertMsg = 'RoninValidator: invalid weight';
const invalidThresholdRevertMsg = 'RoninValidator: invalid threshold';

describe('Ronin Validator test', () => {
  it('deployment', async () => {
    let signers: SignerWithAddress[];
    [governanceAdmin, firstUser, secondUser, thirdUser, ...signers] = await ethers.getSigners();
    validators = signers.slice(0, signers.length / 2);
    governors = signers.slice(signers.length / 2);
    if (validators.length > governors.length) {
      validators.pop();
    } else if (validators.length < governors.length) {
      governors.pop();
    }

    const ValidatorFactory = new RoninValidator__factory(governanceAdmin);
    const logic = await ValidatorFactory.deploy();
    await logic.deployed();

    const data = ValidatorFactory.interface.encodeFunctionData('initialize', [
      validators.map((v, i) => ({ validator: v.address, governor: governors[i].address, weight: 1 })),
      1,
      validators.length,
    ]);
    validatorProxy = await new TransparentUpgradeableProxyV2__factory(governanceAdmin).deploy(
      logic.address,
      governanceAdmin.address,
      data
    );
    validatorContract = RoninValidator__factory.connect(validatorProxy.address, firstUser);
  });

  it('Should not be able to initialize again', async () => {
    await expect(validatorContract.initialize([], 1, validators.length)).revertedWith(
      'Initializable: contract is already initialized'
    );
  });

  it('Should be able to verify the initialized contract storage', async () => {
    const weightedValidators = await validatorContract.getValidatorInfo();
    for (let i = 0; i < weightedValidators.length; i++) {
      expect(weightedValidators[i].validator).eq(validators[i].address);
      expect(weightedValidators[i].governor).eq(governors[i].address);
      expect(weightedValidators[i].weight).eq(1);
    }

    const validatorCount = await validatorContract.totalValidators();
    const validatorWeight = await validatorContract.totalWeights();
    expect(validatorCount).eq(weightedValidators.length);
    expect(validatorCount).eq(validators.length);
    expect(validatorCount).eq(validatorWeight);
    for (let i = 0; i < weightedValidators.length; i++) {
      const validator = await validatorContract.validators(i);
      expect(validator.validator).eq(validators[i].address);
      expect(validator.governor).eq(governors[i].address);
      expect(validator.weight).eq(1);
    }
    const [num, denom] = await validatorContract.getThreshold();
    expect(num).eq(1);
    expect(denom).eq(validatorCount);
    expect(await validatorContract.checkThreshold(0)).to.be.false;
    expect(await validatorContract.checkThreshold(1)).to.be.true;

    const governorList = await validatorContract.getGovernors();
    const validatorList = await validatorContract.getValidators();
    expect(governorList.length).eq(validatorList.length);
    for (let i = 0; i < validatorList.length; i++) {
      expect(validatorList[i]).eq(validators[i].address);
      expect(governorList[i]).eq(governors[i].address);
    }
  });

  it('Should not be able to change contract state by unauthorized account', async () => {
    await expect(
      validatorContract
        .connect(firstUser)
        .addValidators([{ validator: firstUser.address, governor: secondUser.address, weight: 1 }])
    ).revertedWith(unauthorizedRevertMsg);
    await expect(
      validatorContract
        .connect(firstUser)
        .updateValidators([{ validator: validators[0].address, governor: validators[0].address, weight: 2 }])
    ).revertedWith(unauthorizedRevertMsg);
    await expect(validatorContract.connect(firstUser).removeValidators([validators[0].address])).revertedWith(
      unauthorizedRevertMsg
    );
    await expect(validatorContract.connect(firstUser).setThreshold(1, 2)).revertedWith(unauthorizedRevertMsg);
  });

  it('Should be able to add new validator with valid weight', async () => {
    // Admin cannot call directly to validator contract
    await expect(
      validatorContract
        .connect(governanceAdmin)
        .addValidators([{ validator: validators[0].address, governor: validators[0].address, weight: 1 }])
    ).revertedWith(adminCannotFallbackRevertMsg);
    await expect(
      validatorProxy
        .connect(governanceAdmin)
        .functionDelegateCall(
          validatorContract.interface.encodeFunctionData('addValidators', [
            [{ validator: validators[0].address, governor: governors[0].address, weight: 1 }],
          ])
        )
    ).revertedWith(`RoninValidator: ${validators[0].address.toLowerCase()} is a validator already`);

    await expect(
      validatorProxy
        .connect(governanceAdmin)
        .functionDelegateCall(
          validatorContract.interface.encodeFunctionData('addValidators', [
            [{ validator: firstUser.address, governor: secondUser.address, weight: 0 }],
          ])
        )
    ).revertedWith(invalidWeightRevertMsg);

    expect(await validatorContract.getValidatorWeight(firstUser.address)).eq(0);
    await validatorProxy.functionDelegateCall(
      validatorContract.interface.encodeFunctionData('addValidators', [
        [{ validator: firstUser.address, governor: secondUser.address, weight: 10 }],
      ])
    );
    expect(await validatorContract.getValidatorWeight(firstUser.address)).eq(10);
    expect(await validatorContract.getValidatorWeight(secondUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(firstUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(secondUser.address)).eq(10);

    validators.push(firstUser);
    governors.push(secondUser);
    const governorList = await validatorContract.getGovernors();
    const validatorList = await validatorContract.getValidators();
    expect(governorList.length).eq(validatorList.length);
    for (let i = 0; i < validatorList.length; i++) {
      expect(validatorList[i]).eq(validators[i].address);
      expect(governorList[i]).eq(governors[i].address);
    }
  });

  it('Should be able to update validator with valid weight', async () => {
    // Cannot update for the address is not validator
    await expect(
      validatorProxy.functionDelegateCall(
        validatorContract.interface.encodeFunctionData('updateValidators', [
          [{ validator: governanceAdmin.address, governor: governanceAdmin.address, weight: 1 }],
        ])
      )
    ).revertedWith(`RoninValidator: ${governanceAdmin.address.toLowerCase()} is not a validator`);
    // Cannot update when the weight is equal to 0
    await expect(
      validatorProxy.functionDelegateCall(
        validatorContract.interface.encodeFunctionData('updateValidators', [
          [{ validator: firstUser.address, governor: firstUser.address, weight: 0 }],
        ])
      )
    ).revertedWith(invalidWeightRevertMsg);

    expect(await validatorContract.getValidatorWeight(firstUser.address)).eq(10);
    expect(await validatorContract.getValidatorWeight(secondUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(firstUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(secondUser.address)).eq(10);
    await validatorProxy.functionDelegateCall(
      validatorContract.interface.encodeFunctionData('updateValidators', [
        [{ validator: firstUser.address, governor: thirdUser.address, weight: 1 }],
      ])
    );
    expect(await validatorContract.getValidatorWeight(firstUser.address)).eq(1);
    expect(await validatorContract.getValidatorWeight(thirdUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(firstUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(thirdUser.address)).eq(1);

    expect(await validatorContract.getValidatorWeight(secondUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(secondUser.address)).eq(0);

    governors.pop();
    governors.push(thirdUser);
    const governorList = await validatorContract.getGovernors();
    const validatorList = await validatorContract.getValidators();
    expect(governorList.length).eq(validatorList.length);
    for (let i = 0; i < validatorList.length; i++) {
      expect(validatorList[i]).eq(validators[i].address);
      expect(governorList[i]).eq(governors[i].address);
    }
  });

  it('Should be able to remove a validator', async () => {
    await expect(
      validatorProxy.functionDelegateCall(
        validatorContract.interface.encodeFunctionData('removeValidators', [[governanceAdmin.address]])
      )
    ).revertedWith(`RoninValidator: ${governanceAdmin.address.toLowerCase()} is not a validator`);

    expect(await validatorContract.getValidatorWeight(firstUser.address)).eq(1);
    expect(await validatorContract.getGovernorWeight(thirdUser.address)).eq(1);
    await validatorProxy.functionDelegateCall(
      validatorContract.interface.encodeFunctionData('removeValidators', [[firstUser.address]])
    );
    expect(await validatorContract.getValidatorWeight(firstUser.address)).eq(0);
    expect(await validatorContract.getGovernorWeight(thirdUser.address)).eq(0);

    validators.pop();
    governors.pop();
    const governorList = await validatorContract.getGovernors();
    const validatorList = await validatorContract.getValidators();
    expect(governorList.length).eq(validatorList.length);
    for (let i = 0; i < validatorList.length; i++) {
      expect(validatorList[i]).eq(validators[i].address);
      expect(governorList[i]).eq(governors[i].address);
    }
  });

  it('Should be able to set to a valid threshold', async () => {
    await expect(
      validatorProxy
        .connect(governanceAdmin)
        .functionDelegateCall(validatorContract.interface.encodeFunctionData('setThreshold', [3, 2]))
    ).revertedWith(invalidThresholdRevertMsg);

    let [num, denom] = await validatorContract.getThreshold();
    expect(num).eq(1);
    expect(denom).eq(validators.length);

    await validatorProxy
      .connect(governanceAdmin)
      .functionDelegateCall(validatorContract.interface.encodeFunctionData('setThreshold', [2, 2]));
    [num, denom] = await validatorContract.getThreshold();
    expect(num).eq(2);
    expect(denom).eq(2);
  });
});
