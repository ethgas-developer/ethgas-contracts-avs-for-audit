// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {console2} from "forge-std/Test.sol";
import {IStrategy} from "@eigenlayer/contracts/interfaces/IStrategy.sol";
import {IAllocationManager} from "../src/IAllocationManager.sol";

contract Slash is Script {

    EthgasVisionAvsManager public serviceManager;
    CoreDeploymentLib.DeploymentData coreDeployment;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;

    function run() external {
        uint32 operatorSetId = uint32(vm.envUint("OPERATOR_SET_ID"));
        address owner = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);
        IStrategy beaconEthStrat = IStrategy(coreDeployment.strategyBeaconEth);
        IStrategy stethStrat = IStrategy(coreDeployment.strategySteth);

        serviceManager = EthgasVisionAvsManager(visionAvsDeployment.ethgasVisionAvsManager);

        IStrategy[] memory strategies = new IStrategy[](2);
        strategies[0] = stethStrat;
        strategies[1] = beaconEthStrat;

        IAllocationManager.CreateSetParams[] memory createSetParams = new IAllocationManager.CreateSetParams[](1);
        createSetParams[0] = IAllocationManager.CreateSetParams({
            operatorSetId: operatorSetId,
            strategies: strategies
        });

        vm.startBroadcast(owner);
        serviceManager.createOperatorSets(createSetParams);
        vm.stopBroadcast();
    }

}
