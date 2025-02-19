// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ECDSAServiceManagerBase} from
    "@eigenlayer-middleware/src/unaudited/ECDSAServiceManagerBase.sol";
import {ECDSAStakeRegistry} from "@eigenlayer-middleware/src/unaudited/ECDSAStakeRegistry.sol";
import {IServiceManager} from "@eigenlayer-middleware/src/interfaces/IServiceManager.sol";
import {ECDSAUpgradeable} from
    "@openzeppelin-upgrades/contracts/utils/cryptography/ECDSAUpgradeable.sol";
import {IERC1271Upgradeable} from "@openzeppelin-upgrades/contracts/interfaces/IERC1271Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@eigenlayer/contracts/interfaces/IRewardsCoordinator.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IAllocationManager} from "./IAllocationManager.sol";
import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";

contract EthgasVisionAvsManager is ECDSAServiceManagerBase {
    using ECDSAUpgradeable for bytes32;
    address public immutable allocationManager;

    modifier onlyOperator() {
        require(
            ECDSAStakeRegistry(stakeRegistry).operatorRegistered(msg.sender),
            "Operator must be the caller"
        );
        _;
    }

    constructor(
        address _avsDirectory,
        address _stakeRegistry,
        address _rewardsCoordinator,
        address _delegationManager,
        address _allocationManager

    )
        ECDSAServiceManagerBase(
            _avsDirectory,
            _stakeRegistry,
            _rewardsCoordinator,
            _delegationManager
        )
    {
        allocationManager = _allocationManager;
    }

    function initialize(address _owner, address _rewardsInitiator) external initializer {
         __ServiceManagerBase_init(_owner, _rewardsInitiator);
    }

    function slash(
        address operator,
        uint32 operatorSetId,
        IStrategy[] memory strategies,
        uint256[] memory wadsToSlash,
        string memory description
    ) external onlyOwner {
        IAllocationManager(allocationManager).slashOperator(
            address(this), 
            IAllocationManager.SlashingParams(
                operator,
                operatorSetId,
                strategies,
                wadsToSlash,
                description
            )
        );
    }

    function createOperatorSets(
        IAllocationManager.CreateSetParams[] memory createSetParams
    ) external onlyOwner {
        IAllocationManager(allocationManager).createOperatorSets(
            address(this), 
            createSetParams
        );
    }

    function registerOperator(
        address operator,
        uint32[] memory operatorSetIds,
        bytes memory data
    ) external {
        (bytes memory signature, bytes32 salt, uint256 expiry) = abi.decode(data, (bytes, bytes32, uint256));
        _registerOperatorToAVS(operator, ISignatureUtils.SignatureWithSaltAndExpiry(signature, salt, expiry));
    }
}