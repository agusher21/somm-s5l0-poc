// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { ISolver } from "../modules/withdraw-queue/ISolver.sol";

/// @notice MOCK — minimal ISolver standing in for a real Somm solver
/// (e.g. SimpleSolver). It does the one thing a solver must do in
/// WithdrawQueue.solve(): when the queue calls finishSolve(), it approves
/// the queue to pull `assetApprovalAmount` of the asset from itself, so the
/// queue can then pay the user(s). It holds pre-funded assets and keeps
/// whatever shares the queue transfers to it.
/// @dev Unlike SimpleSolver this mock performs NO checks on min shares /
/// max assets — that mirrors the finding: solve() itself imposes no price
/// check, and any address can be named as `solver` (no allowlist).
contract MockSolver is ISolver {
    using SafeTransferLib for ERC20;

    ERC20 public immutable asset;
    address public immutable queue;

    constructor(ERC20 _asset, address _queue) {
        asset = _asset;
        queue = _queue;
    }

    function finishSolve(
        bytes calldata /* runData */,
        address /* initiator */,
        uint256 /* sharesReceived */,
        uint256 assetApprovalAmount
    ) external override {
        require(msg.sender == queue, "MockSolver: only queue");
        // Approve the queue to pull the assets it owes the user(s).
        // For a 0-price request this is 0, so no approval / no payment.
        asset.safeApprove(msg.sender, assetApprovalAmount);
    }
}
