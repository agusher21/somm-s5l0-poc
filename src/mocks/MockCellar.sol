// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { ERC4626 } from "@solmate/tokens/ERC4626.sol";

/// @notice MOCK — minimal ERC4626 vault standing in for a Somm Real Yield
/// cellar share token. 1:1 with the asset (totalAssets == asset balance),
/// 18-decimal shares, so previewRedeem(100 shares) == 100 assets and a
/// correct executionSharePrice is 1e18. Only totalAssets() is implemented;
/// deposit/mint/withdraw/redeem/convert logic is Solmate's stock ERC4626.
/// Not part of the audited code under test.
contract MockCellar is ERC4626 {
    constructor(ERC20 _asset) ERC4626(_asset, "Mock RealYield Share", "mRY") {}

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
