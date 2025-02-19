// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Script} from "forge-std/Script.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {EthgasVisionAvsManager} from "../src/EthgasVisionAvsManager.sol";
import {ECDSAStakeRegistry} from "../src/ECDSAStakeRegistry.sol";
import {DelegationManager} from "@eigenlayer/contracts/core/DelegationManager.sol";
import {IAllocationManager} from "../src/IAllocationManager.sol";
import {console2} from "forge-std/Test.sol";

import {
    Quorum,
    StrategyParams,
    IStrategy
} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";

contract GetData is Script {

    EthgasVisionAvsManager public serviceManager;
    ECDSAStakeRegistry public stakeRegistry;
    DelegationManager public delegationManager;
    IAllocationManager public allocationManager;
    CoreDeploymentLib.DeploymentData coreDeployment;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;
    Quorum internal quorum;

    function run() external {
        visionAvsDeployment = VisionAvsDeploymentLib.readDeploymentJson("deployments/vision-avs/", block.chainid);
        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);
        serviceManager = EthgasVisionAvsManager(visionAvsDeployment.ethgasVisionAvsManager);
        stakeRegistry = ECDSAStakeRegistry(visionAvsDeployment.stakeRegistry);
        delegationManager = DelegationManager(coreDeployment.delegationManager);
        allocationManager = IAllocationManager(coreDeployment.allocationManager);
        address operator = vm.envAddress("OPERATOR_ADDRESS");
        uint32 operatorSetId = uint32(vm.envUint("OPERATOR_SET_ID"));

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
        StrategyParams[] memory strategyParams = quorum.strategies;
        for (uint i; i < strategyParams.length; i++) {
            console2.log(address(strategyParams[i].strategy));
        }

        IStrategy beaconEthStrat = IStrategy(coreDeployment.strategyBeaconEth);
        IStrategy stethStrat = IStrategy(coreDeployment.strategySteth);
        IStrategy[] memory strategies = new IStrategy[](2);
        strategies[0] = stethStrat;
        strategies[1] = beaconEthStrat;
        uint256[] memory shares = delegationManager.getOperatorShares(operator, strategies);
        for (uint i; i < shares.length; i++) {
            console2.log("strategy", i, "amount:", shares[i]);
        }
        for (uint i; i < strategies.length; i++) {
            IAllocationManager.Allocation memory allocation = allocationManager.getAllocation(
                operator, 
                IAllocationManager.OperatorSet({ 
                    avs: visionAvsDeployment.ethgasVisionAvsManager, id: operatorSetId
                }),
                strategies[i]
            );
            console2.log("strategy", i, "magnitude:", allocation.currentMagnitude);
        }
    }

}
