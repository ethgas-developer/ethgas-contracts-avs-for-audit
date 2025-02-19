// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

import {IStrategy} from "@eigenlayer/contracts/interfaces/IStrategy.sol";

interface IAllocationManager {
    struct CreateSetParams {
        uint32 operatorSetId;
        IStrategy[] strategies;
    }
    
    struct RegisterParams {
        address avs;
        uint32[] operatorSetIds;
        bytes data;
    }

    struct SlashingParams {
        address operator;
        uint32 operatorSetId;
        IStrategy[] strategies;
        uint256[] wadsToSlash;
        string description;
    }

    struct OperatorSet {
        address avs;
        uint32 id;
    }

    struct Allocation {
        uint64 currentMagnitude;
        int128 pendingDiff;
        uint32 effectBlock;
    }

    struct AllocateParams {
        OperatorSet operatorSet;
        IStrategy[] strategies;
        uint64[] newMagnitudes;
    }

    function createOperatorSets(address avs, CreateSetParams[] calldata params) external;
    function registerForOperatorSets(address operator, RegisterParams calldata params) external;
    function slashOperator(address avs, SlashingParams calldata params) external;
    function setAllocationDelay(address operator, uint32 delay) external;
    function getAllocation(
        address operator,
        OperatorSet memory operatorSet,
        IStrategy strategy
    ) external view returns (Allocation memory);
    function modifyAllocations(
        address operator,
        AllocateParams[] memory params
    ) external;
}