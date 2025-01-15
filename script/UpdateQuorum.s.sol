// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {UpgradeableProxyLib} from "./utils/UpgradeableProxyLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {ECDSAStakeRegistry} from "../src/ECDSAStakeRegistry.sol";
import {IDelegationManager} from "@eigenlayer/contracts/interfaces/IDelegationManager.sol";
import {console} from "forge-std/Test.sol";
import {
    Quorum,
    StrategyParams,
    IStrategy
} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";

contract UpdateQuorum is Script {

    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;
    CoreDeploymentLib.DeploymentData coreDeployment;
    Quorum internal quorum;
    address private owner;

    function run() external {
        owner = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        vm.label(owner, "Owner");
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);
        IStrategy lsethStrat = IStrategy(coreDeployment.strategyLseth);
        quorum.strategies.push(
            StrategyParams({strategy: lsethStrat, multiplier: 10_000})
        );
        address[] memory operators;
        ECDSAStakeRegistry stakeRegistry = ECDSAStakeRegistry(visionAvsDeployment.stakeRegistry);
        vm.startBroadcast(owner);
        stakeRegistry.updateQuorumConfig(quorum, operators);
        vm.stopBroadcast();
    }

}
