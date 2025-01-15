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

        uint256 ownerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.rememberKey(ownerPrivateKey);
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);

        EthgasVisionAvsManager serviceManager = EthgasVisionAvsManager(visionAvsDeployment.ethgasVisionAvsManager);
        ECDSAStakeRegistry stakeRegistry = ECDSAStakeRegistry(visionAvsDeployment.stakeRegistry);
        IAVSDirectory avsDirectory = IAVSDirectory(coreDeployment.avsDirectory);

        bytes32 salt = bytes32(vm.envUint("RANDOM")); // OS-generated random value
        uint256 expiry = vm.unixTime() + 3600;
        bytes32 digestHash = avsDirectory.calculateOperatorAVSRegistrationDigestHash(
            owner, visionAvsDeployment.ethgasVisionAvsManager, salt, expiry
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digestHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        ISignatureUtils.SignatureWithSaltAndExpiry memory signatureWithSaltAndExpiry = ISignatureUtils.SignatureWithSaltAndExpiry(signature, salt, expiry);

        vm.startBroadcast();
        stakeRegistry.registerOperatorWithSignature(signatureWithSaltAndExpiry, owner);
        vm.stopBroadcast();
    }

}
