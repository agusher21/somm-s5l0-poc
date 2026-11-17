# S5-L0 PoC — run log

Command: rm -rf out cache && forge build && forge test -vvv
Date (WIB): 2026-11-17 19:01:36 WIB
forge: forge Version: 1.9.0
Repo HEAD (cellar-contracts): 07efdfa9ae15beb66d248722cbbd596926b5d55f

## forge build
```
Compiling 31 files with Solc 0.8.21
Solc 0.8.21 finished in 3.84s
Compiler run successful!
warning[block-timestamp]: usage of `block.timestamp` in a comparison may be manipulated by validators
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:129:13
    │
129 │         if (block.timestamp > userRequest.deadline) return false;
    │             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/block-timestamp

warning[arbitrary-send-erc20]: `transferFrom` uses an arbitrary `from`; require it to equal `msg.sender` or `address(this)`
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:204:13
    │
204 │             share.safeTransferFrom(users[i], solver, request.sharesToWithdraw);
    │             ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/arbitrary-send-erc20

warning[arbitrary-send-erc20]: `transferFrom` uses an arbitrary `from`; require it to equal `msg.sender` or `address(this)`
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:222:17
    │
222 │                 solveData.asset.safeTransferFrom(solver, users[i], assetsToUser);
    │                 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/arbitrary-send-erc20

warning[reentrancy-no-eth]: external call can be reentered before `locked` is updated
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:207:9
    │
207 │         ISolver(solver).finishSolve(runData, msg.sender, sharesToSolver, requiredAssets);
    │         ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/reentrancy-no-eth

warning[uninitialized-local]: local variable is read before being initialized
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:201:13
    │
201 │             sharesToSolver += request.sharesToWithdraw;
    │             ━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/uninitialized-local

warning[uninitialized-local]: local variable is read before being initialized
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:194:13
    │
194 │             requiredAssets += _calculateAssetAmount(
    │             ━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/uninitialized-local

warning[block-timestamp]: usage of `block.timestamp` in a comparison may be manipulated by validators
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:190:17
    │
190 │             if (block.timestamp > request.deadline) revert WithdrawQueue__RequestDeadlineExceeded(users[i]);
    │                 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/block-timestamp

warning[reentrancy-events]: event emitted after an external call; reentrancy can reorder or fabricate logs that off-chain consumers rely on
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:224:17
    │
224 │ ┏                 emit RequestFulfilled(
225 │ ┃                     users[i],
226 │ ┃                     address(share),
227 │ ┃                     request.sharesToWithdraw,
228 │ ┃                     assetsToUser,
229 │ ┃                     block.timestamp
230 │ ┃                 );
    │ ┗━━━━━━━━━━━━━━━━━━┛
    │
    ╰ help: https://getfoundry.sh/forge/linting/reentrancy-events

warning[require-revert-in-loop]: `require` or `revert` inside a loop
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:189:34
    │
189 │             if (request.inSolve) revert WithdrawQueue__UserRepeated(users[i]);
    │                                  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/require-revert-in-loop

warning[require-revert-in-loop]: `require` or `revert` inside a loop
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:190:53
    │
190 │             if (block.timestamp > request.deadline) revert WithdrawQueue__RequestDeadlineExceeded(users[i]);
    │                                                     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/require-revert-in-loop

warning[require-revert-in-loop]: `require` or `revert` inside a loop
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:191:48
    │
191 │             if (request.sharesToWithdraw == 0) revert WithdrawQueue__NoShares(users[i]);
    │                                                ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/require-revert-in-loop

warning[require-revert-in-loop]: `require` or `revert` inside a loop
   ╭▸ src/utils/Math.sol:46:17
   │
46 │                 revert(0, 0)
   │                 ━━━━━━━━━━━━
   │
   ╰ help: https://getfoundry.sh/forge/linting/require-revert-in-loop

warning[require-revert-in-loop]: `require` or `revert` inside a loop
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:235:20
    │
235 │             } else revert WithdrawQueue__UserNotInSolve(users[i]);
    │                    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/require-revert-in-loop

warning[solmate-safe-transfer-lib]: the `SafeTransferLib` from Solmate does not check that the token has code, so a transfer to a token-less address succeeds silently
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:204:13
    │
204 │             share.safeTransferFrom(users[i], solver, request.sharesToWithdraw);
    │             ━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/solmate-safe-transfer-lib

warning[solmate-safe-transfer-lib]: the `SafeTransferLib` from Solmate does not check that the token has code, so a transfer to a token-less address succeeds silently
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:222:17
    │
222 │                 solveData.asset.safeTransferFrom(solver, users[i], assetsToUser);
    │                 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/solmate-safe-transfer-lib

warning[block-timestamp]: usage of `block.timestamp` in a comparison may be manipulated by validators
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:262:17
    │
262 │             if (block.timestamp > request.deadline) {
    │                 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/block-timestamp

warning[calls-loop]: external call inside a loop
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:268:17
    │
268 │             if (share.balanceOf(users[i]) < request.sharesToWithdraw) {
    │                 ━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/calls-loop

warning[calls-loop]: external call inside a loop
    ╭▸ src/modules/withdraw-queue/WithdrawQueue.sol:271:17
    │
271 │             if (share.allowance(users[i], address(this)) < request.sharesToWithdraw) {
    │                 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    │
    ╰ help: https://getfoundry.sh/forge/linting/calls-loop

warning[missing-zero-check]: address parameter is used in a state write or value transfer without a zero-address check
   ╭▸ src/mocks/MockSolver.sol:23:31
   │
23 │     constructor(ERC20 _asset, address _queue) {
   │                               ━━━━━━━━━━━━━━
   │
   ╰ help: https://getfoundry.sh/forge/linting/missing-zero-check

warning[solmate-safe-transfer-lib]: the `SafeTransferLib` from Solmate does not check that the token has code, so a transfer to a token-less address succeeds silently
   ╭▸ src/mocks/MockSolver.sol:37:9
   │
37 │         asset.safeApprove(msg.sender, assetApprovalAmount);
   │         ━━━━━━━━━━━━━━━━━
   │
   ╰ help: https://getfoundry.sh/forge/linting/solmate-safe-transfer-lib

```

## forge test -vvv
```
No files changed, compilation skipped

Ran 4 tests for test/ZeroPriceWithdraw.t.sol:ZeroPriceWithdrawTest
[PASS] test1_ZeroPriceRequest_LosesEverything() (gas: 236694)
Logs:
  attack: user assets received: 0
  attack: user shares after:    0
  attack: solver shares after:  100000000000000000000
  attack: loss % of position:   100

[PASS] test2_CorrectPriceRequest_PaysInFull() (gas: 256325)
Logs:
  control: user assets received: 100000000000000000000
  control: user shares after:    0
  control: solver shares after:  100000000000000000000

[PASS] test3_ValidityGuardFlagsZeroPriceButIsNeverCalled() (gas: 110043)
[PASS] test4_SolverRedeemsStolenSharesForFullValue() (gas: 236361)
Logs:
  extra: solver redeemed assets: 100000000000000000000

Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 18.51ms (13.04ms CPU time)

Ran 1 test suite in 23.20ms (18.51ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
forge test exit code: 0
```
