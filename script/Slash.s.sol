// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {console2} from "forge-std/Test.sol";
import {IStrategy} from "@eigenlayer/contracts/interfaces/IStrategy.sol";

contract Slash is Script {

    EthgasVisionAvsManager public serviceManager;
    CoreDeploymentLib.DeploymentData coreDeployment;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;

    function run() external {
        address owner = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        address operator = vm.envAddress("OPERATOR_ADDRESS");
        uint32 operatorSetId = uint32(vm.envUint("OPERATOR_SET_ID"));
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);
        IStrategy beaconEthStrat = IStrategy(coreDeployment.strategyBeaconEth);
        IStrategy stethStrat = IStrategy(coreDeployment.strategySteth);
        serviceManager = EthgasVisionAvsManager(visionAvsDeployment.ethgasVisionAvsManager);
        
        IStrategy[] memory strategies = new IStrategy[](2);
        uint256[] memory wadsToSlash = new uint256[](2);
        strategies[0] = stethStrat;
        strategies[1] = beaconEthStrat;
        wadsToSlash[0] = 2 * 1e16; // 2%
        wadsToSlash[1] = 1 * 1e16; // 1%

        // actuall slashing amount = stakedAmount * operatorMagnitude / 1e18 * wadsToSlash / 1e18
        vm.startBroadcast(owner);
        serviceManager.slash(
            operator,
            operatorSetId,
            strategies,
            wadsToSlash,
            "temp"
        );
        vm.stopBroadcast();
    }

}
