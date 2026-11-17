# S5-L0 PoC — fail-to-zero price feed → 0-price withdraw request → solver takes shares for ~0 assets

Foundry PoC proving **only the contract half** of Somm finding S5-L0.
Local Foundry only — no mainnet, no wallet, no signing, no external sends.

## Finding (one line)

The Somm frontend price API returns `"0"` on every failure, the legacy
withdraw form submits that `0` as `executionSharePrice` with no `> 0`
check, and `WithdrawQueue` stores it and pays `shares × 0 = 0` assets
while transferring all shares to the solver.

## What was copied verbatim

From `~/workspace/somm-bug-bounty/repos/cellar-contracts` (HEAD
`07efdfa9ae15beb66d248722cbbd596926b5d55f`, verified by `diff` — no edits):

| File in this PoC | Source |
|---|---|
| `src/modules/withdraw-queue/WithdrawQueue.sol` | `src/modules/withdraw-queue/WithdrawQueue.sol` |
| `src/modules/withdraw-queue/ISolver.sol` | `src/modules/withdraw-queue/ISolver.sol` |
| `src/utils/Math.sol` | `src/utils/Math.sol` |

SHA-256: `WithdrawQueue.sol 9e5243dc…622`, `ISolver.sol 251fc546…ade`,
`Math.sol b15daa72…206` (full hashes in `RUN-LOG.md` header context / `sha256sum`).

**Deployed-vs-repo check:** `~/workspace/somm-bug-bounty/DEPLOYED-VS-REPO.md`
does **not** exist, so per the task the repo-HEAD source above was used.
No Sourcify deployed source was substituted. If that comparison file
appears later and shows a divergence, re-run against the deployed source.

## What was mocked (and only this)

- `src/mocks/MockAsset.sol` — minimal mintable Solmate ERC20 (18 decimals),
  standing in for the cellar's underlying asset.
- `src/mocks/MockCellar.sol` — minimal Solmate ERC4626 vault (1:1 with the
  asset, 18-decimal shares, `totalAssets() == asset balance`), standing in
  for a Real Yield cellar share token. Deposit/mint/withdraw/redeem logic
  is stock Solmate; only `totalAssets()` is implemented.
- `src/mocks/MockSolver.sol` — minimal `ISolver`: on `finishSolve()` it
  approves the queue to pull `assetApprovalAmount` from itself (exactly
  what `SimpleSolver` does, minus its min-shares/max-assets checks — the
  mock performs **no** checks, mirroring that `solve()` itself imposes
  none and any address can be named as `solver`). Pre-funded with assets
  by the test.
- Libraries: Solmate (latest, via `forge install`) + forge-std. Note the
  repo's `lib/` submodules were empty, so Solmate was fetched from GitHub.
  Current Solmate moved `ERC4626.sol` from `mixins/` to `tokens/`; the
  remapping `@solmate/mixins/ERC4626.sol=lib/solmate/src/tokens/ERC4626.sol`
  keeps `WithdrawQueue.sol` verbatim. No contract logic was changed.

## What this PoC does NOT prove

The frontend half is **not** executed here: the price API failing open
to `"0"` and `WithdrawQueueForm.tsx` submitting it are taken as given
(verified line-by-line by the coordinator). The test reproduces exactly
the on-chain call the frontend makes:
`updateWithdrawRequest([cellar, [deadline, 0, shares, false]])`.

## Tests (`test/ZeroPriceWithdraw.t.sol`)

Setup (all tests): user deposits 100 assets → 100 shares, worth
~100 assets (`previewRedeem(100 shares) == 100 assets`, asserted);
user approves the queue; solver pre-funded with 1,000 assets.

| Test | Result |
|---|---|
| **Test 1 — attack:** request with `executionSharePrice = 0`, then `solve()` | ✅ PASS — user receives **0** assets, loses all **100** shares (solver holds them). **Loss = 100% of position.** |
| **Test 2 — control:** same flow, `executionSharePrice = 1e18` (1.0 asset/share) | ✅ PASS — user receives **100** assets. Proves the zero price, not queue mechanics, causes the loss. |
| **Test 3 — guard exists but unused:** `isWithdrawRequestValid()` on the 0-price request | ✅ PASS — returns **false** for price 0 (and **true** at the correct price), yet `updateWithdrawRequest()` stores the 0-price request anyway with no revert. |
| **Test 4 (extra) — solver profit:** solver redeems the stolen shares | ✅ PASS — solver redeems 100 shares for **100** assets. The loss is a real value transfer, not a burn. |

Full output: [`RUN-LOG.md`](RUN-LOG.md) — 4 passed, 0 failed.

## How to run

```bash
export PATH="$HOME/.foundry/bin:$PATH"
cd ~/workspace/somm-bug-bounty/poc/s5l0-zero-price-withdraw
forge test -vvv          # or: rm -rf out cache && forge build && forge test -vvv
```

Requires Foundry (forge 1.9.0 used) and network access on first setup
only, for `forge install` of Solmate/forge-std (already vendored in `lib/`).
No RPC URL, no private key, no deployment — everything runs on the
local in-memory EVM.
