// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {ECDSAStakeRegistry} from "../src/ECDSAStakeRegistry.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {IAVSDirectory} from "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";
import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";
import {console2} from "forge-std/Test.sol";

contract RegisterOperatorToAvs is Script {

    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;
    CoreDeploymentLib.DeploymentData coreDeployment;

    function run() external {

        uint256 operatorPrivateKey = vm.envUint("PRIVATE_KEY");
        address operator = vm.rememberKey(operatorPrivateKey);
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);

        ECDSAStakeRegistry stakeRegistry = ECDSAStakeRegistry(visionAvsDeployment.stakeRegistry);

        vm.startBroadcast();
        stakeRegistry.deregisterOperator();
        vm.stopBroadcast();
    }

}
