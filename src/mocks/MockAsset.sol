// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

import { ERC20 } from "@solmate/tokens/ERC20.sol";

/// @notice MOCK — minimal mintable ERC20 standing in for the cellar's
/// underlying asset (e.g. USDC). 18 decimals so 1 share == 1 asset at
/// executionSharePrice == 1e18. Not part of the audited code under test.
contract MockAsset is ERC20 {
    constructor() ERC20("Mock Asset", "mASSET", 18) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
