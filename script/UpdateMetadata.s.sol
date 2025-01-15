// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {console2} from "forge-std/Test.sol";

contract UpdateMetadata is Script {

    EthgasVisionAvsManager public serviceManager;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;

    function run() external {
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        serviceManager = EthgasVisionAvsManager(visionAvsDeployment.ethgasVisionAvsManager);

        console2.log(serviceManager.owner());
        vm.startBroadcast();
        serviceManager.updateAVSMetadataURI("https://raw.githubusercontent.com/ethgas-developer/ethgas-developer.github.io/main/preconf-avs.json");
        vm.stopBroadcast();
    }

}
