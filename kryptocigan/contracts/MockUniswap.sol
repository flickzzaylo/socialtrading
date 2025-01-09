// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockUniswap {






    // Function to withdraw tokens from the contract (for admin purposes)
    function withdrawToken(address token, uint256 amount) external {
        require(
            IERC20(token).transfer(msg.sender, amount),
            "Withdrawal failed"
        );
    }
}