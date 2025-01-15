// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/Test.sol";
import {VisionAvsDeploymentLib} from "./utils/VisionAvsDeploymentLib.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {UpgradeableProxyLib} from "./utils/UpgradeableProxyLib.sol";
import {StrategyBase} from "@eigenlayer/contracts/strategies/StrategyBase.sol";
import {TransparentUpgradeableProxy} from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {StrategyFactory} from "@eigenlayer/contracts/strategies/StrategyFactory.sol";
import {StrategyManager} from "@eigenlayer/contracts/core/StrategyManager.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

import {
    Quorum,
    StrategyParams,
    IStrategy
} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";

contract VisionAvsDeployer is Script {
    using CoreDeploymentLib for *;
    using UpgradeableProxyLib for address;

    address private deployer;
    address private owner;
    address proxyAdmin;
    CoreDeploymentLib.DeploymentData coreDeployment;
    VisionAvsDeploymentLib.DeploymentData visionAvsDeployment;
    Quorum internal quorum;
    function setUp() public virtual {
        deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        owner = vm.envAddress("OWNER_ADDRESS");
        vm.label(deployer, "Deployer");

        coreDeployment = CoreDeploymentLib.readDeploymentJson("deployments/core/", block.chainid);
       
        IStrategy lsethStrat = IStrategy(coreDeployment.strategyLseth);
        IStrategy ethxStrat = IStrategy(coreDeployment.strategyEthx);
        IStrategy rethStrat = IStrategy(coreDeployment.strategyReth);
        IStrategy osethStrat = IStrategy(coreDeployment.strategyOseth);
        IStrategy cbethStrat = IStrategy(coreDeployment.strategyCbeth);
        IStrategy ankrethStrat = IStrategy(coreDeployment.strategyAnkreth);
        IStrategy eoStrat = IStrategy(coreDeployment.strategyEo);
        IStrategy stethStrat = IStrategy(coreDeployment.strategySteth);
        IStrategy wethStrat = IStrategy(coreDeployment.strategyWeth);
        IStrategy sfrxethStrat = IStrategy(coreDeployment.strategySfrxeth);
        IStrategy methStrat = IStrategy(coreDeployment.strategyMeth);
        IStrategy realtStrat = IStrategy(coreDeployment.strategyRealt);
        IStrategy beaconEthStrat = IStrategy(coreDeployment.strategyBeaconEth);

        IStrategy[13] memory sortedStrats = [
            lsethStrat,
            ethxStrat,
            rethStrat,
            osethStrat,
            cbethStrat,
            ankrethStrat,
            eoStrat,
            stethStrat,
            wethStrat,
            sfrxethStrat,
            methStrat,
            realtStrat,
            beaconEthStrat
        ];

        uint96 stratMultiplier = 10_000 / uint96(sortedStrats.length);
        uint96 lastStratMultiplier = 10_000 - stratMultiplier * (uint96(sortedStrats.length) - 1);

        for (uint256 i = 0; i < sortedStrats.length; i++) {
            if (i == sortedStrats.length - 1) {
                quorum.strategies.push(
                    StrategyParams({strategy: sortedStrats[i], multiplier: lastStratMultiplier})
                );
                break;
            }
            quorum.strategies.push(
                StrategyParams({strategy: sortedStrats[i], multiplier: stratMultiplier})
            );
        }
        
    }

    function run() external {
        vm.startBroadcast(deployer);
        proxyAdmin = UpgradeableProxyLib.deployProxyAdmin();

        visionAvsDeployment =
            VisionAvsDeploymentLib.deployContracts(proxyAdmin, owner, owner, coreDeployment, quorum);
        ProxyAdmin(proxyAdmin).transferOwnership(owner);
        console2.log("owner of ProxyAdmin:", ProxyAdmin(proxyAdmin).owner());

        vm.stopBroadcast();

        verifyDeployment();
        VisionAvsDeploymentLib.writeDeploymentJson(visionAvsDeployment);
        console2.log("EthgasVisionAvsManager:", visionAvsDeployment.ethgasVisionAvsManager);
        console2.log("ECDSAStakeRegistry:", visionAvsDeployment.stakeRegistry);
    }

    function verifyDeployment() internal view {
        require(
            visionAvsDeployment.stakeRegistry != address(0), "StakeRegistry address cannot be zero"
        );
        require(
            visionAvsDeployment.ethgasVisionAvsManager != address(0),
            "EthgasVisionAvsManager address cannot be zero"
        );
        require(proxyAdmin != address(0), "ProxyAdmin address cannot be zero");
        require(
            coreDeployment.delegationManager != address(0),
            "DelegationManager address cannot be zero"
        );
        require(coreDeployment.avsDirectory != address(0), "AVSDirectory address cannot be zero");
    }
}
