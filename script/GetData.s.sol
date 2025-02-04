// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {ECDSAStakeRegistry} from "../src/ECDSAStakeRegistry.sol";
import {console2} from "forge-std/Test.sol";

import {
    Quorum,
    StrategyParams,
    IStrategy
} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";

contract GetData is Script {

    EthgasVisionAvsManager public serviceManager;
    ECDSAStakeRegistry public stakeRegistry;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;
    Quorum internal quorum;

    function run() external {
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        serviceManager = EthgasVisionAvsManager(visionAvsDeployment.ethgasVisionAvsManager);
        stakeRegistry = ECDSAStakeRegistry(visionAvsDeployment.stakeRegistry);
        address operator = vm.envAddress("OPERATOR_ADDRESS");

        bool isOperatorRegistered = stakeRegistry.operatorRegistered(operator);
        console2.log("isOperatorRegistered: ", isOperatorRegistered);
        console2.log("EthgasVisionAvsManager restaked strategies for ", operator);
        address[] memory operatorRestakedStrategies = serviceManager.getOperatorRestakedStrategies(operator);
        for (uint i; i < operatorRestakedStrategies.length; i++) {
            console2.log(operatorRestakedStrategies[i]);
        }
        console2.log("EthgasVisionAvsManager all restaked strategies:");
        address[] memory restakedStrategies = serviceManager.getRestakeableStrategies();
        for (uint i; i < restakedStrategies.length; i++) {
            console2.log(restakedStrategies[i]);
        }
        console2.log("ECDSAStakeRegistry strategies:");
        quorum = stakeRegistry.quorum();
        StrategyParams[] memory strategies = quorum.strategies;
        for (uint i; i < strategies.length; i++) {
            console2.log(address(strategies[i].strategy));
        }
    }

}
