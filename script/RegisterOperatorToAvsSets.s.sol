// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {console2} from "forge-std/Test.sol";
import {IAllocationManager} from "../src/IAllocationManager.sol";
import {IAVSDirectory} from "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";
import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";
import {IStrategy} from "@eigenlayer/contracts/interfaces/IStrategy.sol";

contract RegisterOperatorSets is Script {

    CoreDeploymentLib.DeploymentData coreDeployment;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;

    function run() external {
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);
        IAVSDirectory avsDirectory = IAVSDirectory(coreDeployment.avsDirectory);
        IAllocationManager allocationManager = IAllocationManager(coreDeployment.allocationManager);
        uint32 operatorSetId = uint32(vm.envUint("OPERATOR_SET_ID"));
        uint32 delay = uint32(vm.envUint("ALLOCATION_DELAY"));
        uint256 operatorPrivateKey = vm.envUint("PRIVATE_KEY");
        address operator = vm.rememberKey(operatorPrivateKey);
        uint32[] memory operatorSetIds = new uint32[](1);
        operatorSetIds[0] = operatorSetId;

        bytes32 salt = bytes32(vm.envUint("RANDOM")); // OS-generated random value
        uint256 expiry = vm.unixTime() + 3600;
        bytes32 digestHash = avsDirectory.calculateOperatorAVSRegistrationDigestHash(
            operator, visionAvsDeployment.ethgasVisionAvsManager, salt, expiry
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operatorPrivateKey, digestHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        IStrategy beaconEthStrat = IStrategy(coreDeployment.strategyBeaconEth);
        IStrategy stethStrat = IStrategy(coreDeployment.strategySteth);
        IStrategy[] memory strategies = new IStrategy[](2);
        uint64[] memory newMagnitudes = new uint64[](2);
        strategies[0] = stethStrat;
        strategies[1] = beaconEthStrat;
        newMagnitudes[0] = 2000;
        newMagnitudes[1] = 1000;
        IAllocationManager.AllocateParams[] memory allocateParams = new IAllocationManager.AllocateParams[](1);
        allocateParams[0] = IAllocationManager.AllocateParams({
            operatorSet: IAllocationManager.OperatorSet({ avs: visionAvsDeployment.ethgasVisionAvsManager, id: operatorSetId }),
            strategies: strategies,
            newMagnitudes: newMagnitudes
        });

        vm.startBroadcast();
        allocationManager.registerForOperatorSets(
            operator,
            IAllocationManager.RegisterParams({
                avs: visionAvsDeployment.ethgasVisionAvsManager,
                operatorSetIds: operatorSetIds,
                data: abi.encode(signature, salt, expiry)
            })
        );
        allocationManager.setAllocationDelay(operator, delay);
        allocationManager.modifyAllocations(operator, allocateParams);
        vm.stopBroadcast();
    }

}
