// SPDX-License-Identifier: Frensware

pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {ReentrancyGuard} from "solady/src/utils/ReentrancyGuard.sol";

contract FragGrenadeUtils is ReentrancyGuard {
    using SafeERC20 for IERC20;

    event Swapped(uint256 indexed tokenId, address indexed token);
    event SwappedWithPermit(uint256 indexed tokenId, address indexed token);
    event SwappedWithPermitAndTransferFee(uint256 indexed tokenId, address indexed token);

    /**
     * @dev Execute a batch of fragmented swaps with permit functionality.
     * @param token0s Array of addresses of the tokens to swap from.
     * @param token1s Array of addresses of the tokens to swap to.
     * @param routers Array of addresses of the Uniswap V2 Routers.
     * @param amounts Array of total amounts of token0s to swap.
     * @param sizes Array of sizes for each individual swap.
     * @param deadlines Array of deadlines for the permit signatures.
     * @param vs Array of signature parameters v from the permit signatures.
     * @param rs Array of signature parameters r from the permit signatures.
     * @param ss Array of signature parameters s from the permit signatures.
     */
    function batchSplitSwapWithPermit(
        address[] memory token0s,
        address[] memory token1s,
        address[] memory routers,
        uint256[] memory amounts,
        uint256[] memory sizes,
        uint256[] memory deadlines,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) external nonReentrant {
        require(
            token0s.length == token1s.length &&
            token0s.length == routers.length &&
            token0s.length == amounts.length &&
            token0s.length == sizes.length &&
            token0s.length == deadlines.length &&
            token0s.length == vs.length &&
            token0s.length == rs.length &&
            token0s.length == ss.length,
            "Mismatched input arrays"
        );

        for (uint i = 0; i < token0s.length; i++) {
            IERC20Permit(token0s[i]).permit(
                msg.sender,
                address(this),
                amounts[i],
                deadlines[i],
                vs[i],
                rs[i],
                ss[i]
            );

            IERC20(token0s[i]).transferFrom(msg.sender, address(this), amounts[i]);
            IERC20(token0s[i]).approve(routers[i], amounts[i]);

            address[] memory path = new address[](2);
            path[0] = token0s[i];
            path[1] = token1s[i];

            uint256 amountRemaining = amounts[i];
            while (amountRemaining > 0) {
                uint256 amountIn = amountRemaining < sizes[i] ? amountRemaining : sizes[i];
                IUniswapV2Router02(routers[i]).swapExactTokensForTokens(
                    amountIn,
                    0,  //0 for minimal output, replace w/ real min output if needed
                    path,
                    msg.sender,
                    block.timestamp + 666//adjust as necessary
                );

                amountRemaining -= amountIn;
            }
        }
    }

    /**
     * @dev Execute a batch of fragmented swaps.
     * @param token0s Array of addresses of the tokens to swap from
     * @param token1s Array of addresses of the tokens to swap to
     * @param routers Array of addresses of the Uniswap V2 Routers
     * @param amounts Array of total amounts of token0s to swap
     * @param sizes Array of sizes for each individual swap
     * @param deadlines Array of deadlines
     */
    function batchSplitSwap(
        address[] memory token0s,
        address[] memory token1s,
        address[] memory routers,
        uint256[] memory amounts,
        uint256[] memory sizes,
        uint256[] memory deadlines,
        uint8[] memory vs,
        bytes32[] memory rs,
        bytes32[] memory ss
    ) external nonReentrant {
        require(
            token0s.length == token1s.length &&
            token0s.length == routers.length &&
            token0s.length == amounts.length &&
            token0s.length == sizes.length &&
            token0s.length == deadlines.length &&
            token0s.length == vs.length &&
            token0s.length == rs.length &&
            token0s.length == ss.length,
            "Mismatched input arrays"
        );

        for (uint i = 0; i < token0s.length; i++) {
            IERC20Permit(token0s[i]).permit(
                msg.sender,
                address(this),
                amounts[i],
                deadlines[i],
                vs[i],
                rs[i],
                ss[i]
            );

            IERC20(token0s[i]).transferFrom(msg.sender, address(this), amounts[i]);
            IERC20(token0s[i]).approve(routers[i], amounts[i]);

            address[] memory path = new address[](2);
            path[0] = token0s[i];
            path[1] = token1s[i];

            uint256 amountRemaining = amounts[i];
            while (amountRemaining > 0) {
                uint256 amountIn = amountRemaining < sizes[i] ? amountRemaining : sizes[i];
                IUniswapV2Router02(routers[i]).swapExactTokensForTokens(
                    amountIn,
                    0,  //0 for minimal output, replace w/ real min output if needed
                    path,
                    msg.sender,
                    block.timestamp + 666//adjust as necessary
                );

                amountRemaining -= amountIn;
            }
        }
    }


    /**
     * @dev Execute fragmented swap with permit functionality.
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param router The address of the Uniswap V2 Router
     * @param amount The total amount of token0 to swap
     * @param size The size of each individual swap
     * @param deadline The deadline for the permit signature
     * @param v The signature parameter v from the permit signature
     * @param r The signature parameter r from the permit signature
     * @param s The signature parameter s from the permit signature
     */

    //wow, so nice to write up with robots !!!

    function splitSwapWithPermit(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");
        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20Permit(token0).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );

        IERC20(token0).transferFrom(msg.sender, address(this), amount);
        IERC20(token0).approve(router, amount);

        address[] memory paths = new address[](2);
        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router).swapExactTokensForTokens(
                amountIn,
                0,
                paths,
                msg.sender,
                block.timestamp + 666
            );

            amount -= amountIn;
        }
    }

    /**
     * @dev Execute fragmented swap.
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param router The address of the Uniswap V2 Router
     * @param amount The total amount of token0 to swap
     * @param size The size of each individual swap
     * @param deadline The deadline for the permit signature
     */

    function splitSwap(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size,
        uint256 deadline
    ) external nonReentrant {
        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");
        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20Permit(token0).permit(
            msg.sender,
            address(this),
            amount,
            deadline
        );

        IERC20(token0).transferFrom(msg.sender, address(this), amount);
        IERC20(token0).approve(router, amount);

        address[] memory paths = new address[](2);
        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router).swapExactTokensForTokens(
                amountIn,
                0,
                paths,
                msg.sender,
                block.timestamp + 666
            );

            amount -= amountIn;
        }
    }

    /**
     * @dev Swaps the specified amount of token0 for token1 using the Uniswap V2 Router,
     * while supporting transfer fees.
     * The function requires the user to permit the contract to spend the specified amount of token0.
     *
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param router The address of the Uniswap V2 Router
     * @param amount The total amount of token0 to swap
     * @param size The size of each individual swap
     * @param deadline The deadline for the permit signature
     * @param v The signature parameter v from the permit signature
     * @param r The signature parameter r from the permit signature
     * @param s The signature parameter s from the permit signature
     */
    function splitSwapSupportingTransferFeeWithPermit(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        IERC20Permit(token0).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        IERC20(token0).transferFrom(msg.sender, address(this), amount);

        amount = IERC20(token0).balanceOf(address(this));

        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");
        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20(token0).approve(router, amount);

        address[] memory paths = new address[](2);
        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountIn,
                    0,
                    paths,
                    msg.sender,
                    block.timestamp + 666
                );

            amount -= amountIn;
        }
    }

    /**
     * @dev Swaps the specified amount of token0 for token1 using the Uniswap V2 Router,
     * while supporting transfer fees.
     *
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param router The address of the Uniswap V2 Router
     * @param amount The total amount of token0 to swap
     * @param size The size of each individual swap
     * @param deadline The deadline for the permit signature
     */
    function splitSwapSupportingTransferFee(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size,
        uint256 deadline
    ) external nonReentrant {
        IERC20Permit(token0).permit(
            msg.sender,
            address(this),
            amount,
            deadline
        );
        IERC20(token0).transferFrom(msg.sender, address(this), amount);

        amount = IERC20(token0).balanceOf(address(this));

        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");
        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20(token0).approve(router, amount);

        address[] memory paths = new address[](2);
        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountIn,
                    0,
                    paths,
                    msg.sender,
                    block.timestamp + 666
                );

            amount -= amountIn;
        }
    }

    /**
     * @dev Internal function to execute the fragmented swap logic
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param router The address of the Uniswap V2 Router
     * @param amount The total amount of token0 to swap
     * @param size The size of each individual swap
     */
    function _splitOrderSwap(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size
    ) internal {
        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");
        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20(token0).approve(router, amount);

        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        //uint256 numberOfSwaps = (amount + size - 1) / size;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;
            IUniswapV2Router02(router).swapExactTokensForTokens(
                amountIn,
                0,
                path,
                msg.sender,
                block.timestamp + 666
            );

            amount -= amountIn;
        }
    }

    // swap token0 to token1 by router,
    // the amount of each swap is equal to the size,
    // the amount of the last swap may be less than the size
    function splitOrderSwap(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size
    ) public nonReentrant {
        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");
        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20(token0).transferFrom(msg.sender, address(this), amount);
        IERC20(token0).approve(router, amount);

        address[] memory paths = new address[](2);

        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router).swapExactTokensForTokens(
                amountIn,
                0,
                paths,
                msg.sender,
                block.timestamp + 666
            );

            amount -= amountIn;
        }
    }

    /**
     * @dev Swaps the specified amount of token0 for token1 using the Uniswap V2 Router,
     * while supporting transfer fees.
     * The function requires the user to transfer the specified amount of token0 to the contract before executing the swap.
     *
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param router The address of the Uniswap V2 Router
     * @param amount The total amount of token0 to swap
     * @param size The size of each individual swap
     *
     * Requirements:
     * - The amount to swap must be greater than 0
     * - The size of each individual swap must be greater than 0
     * - The size of each individual swap must be less than or equal to the total amount
     *
     * Emits a {Transfer} event from the caller to the contract for the specified amount of token0.
     * Approves the Uniswap V2 Router to spend the transferred amount of token0.
     * Executes multiple swap transactions until the entire amount is swapped.
     *
     * The swap transactions are executed using the Uniswap V2 Router with support for transfer fees
     * on tokens being swapped. The swap transactions are performed in chunks of size 'size',
     * with the possibility of the last swap having a smaller amount if the remaining amount is less than 'size'.
     */

    function fragSwapTransferFee(
        address token0,
        address token1,
        address router,
        uint256 amount,
        uint256 size
    ) public nonReentrant {
        require(amount > 0, "fragUtils: AMOUNT_IS_ZERO");
        require(size > 0, "fragUtils: SIZE_IS_ZERO");

        IERC20(token0).transferFrom(msg.sender, address(this), amount);

        amount = IERC20(token0).balanceOf(address(this));

        require(size <= amount, "fragUtils: SIZE_IS_MORE_THAN_AMOUNT");

        IERC20(token0).approve(router, amount);

        address[] memory paths = new address[](2);

        paths[0] = token0;
        paths[1] = token1;

        while (amount > 0) {
            uint256 amountIn = amount < size ? amount : size;

            IUniswapV2Router02(router)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountIn,
                    0,
                    paths,
                    msg.sender,
                    block.timestamp + 666
                );

            amount -= amountIn;
        }
    }

    function getEstimatedFragAmountOutMaxSlip(
        address routerAddress,
        address token0,
        address token1,
        uint256 totalAmountIn,
        uint256 fragmentSize,
        uint256 maxSlippagePercent // slippage in percentage pts
    ) public view returns (uint256 totalMinimumAmountOut) {
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        uint256 remainingAmountIn = totalAmountIn;
        totalMinimumAmountOut = 0;

        while (remainingAmountIn > 0) {
            uint256 amountIn = remainingAmountIn < fragmentSize
                ? remainingAmountIn
                : fragmentSize;
            uint256[] memory amountsOut = router.getAmountsOut(amountIn, path);
            uint256 estimatedAmountOut = amountsOut[amountsOut.length - 1];
            uint256 minimumAmountOut = (estimatedAmountOut *
                (100 - maxSlippagePercent)) / 100;

            totalMinimumAmountOut += minimumAmountOut;
            remainingAmountIn -= amountIn;
        }

        return totalMinimumAmountOut;
    }

    /**
     * @dev Returns an array of estimated output amounts for a fragmented swap.
     *
     * This function calculates the estimated output amounts for a fragmented swap
     * with the specified parameters, using the Uniswap V2 Router at the provided address.
     * The total input amount is divided into fragments of the specified size,
     * and the output amount is estimated for each fragment.
     * If there is a remaining amount after all fragments are processed,
     * an additional calculation is performed for the remaining amount.
     *
     * @param routerAddress The address of the Uniswap V2 Router contract
     * @param token0 The address of the token to swap from
     * @param token1 The address of the token to swap to
     * @param totalAmountIn The total amount of token0 to be swapped
     * @param size The size of each individual swap fragment
     *
     * @return amounts An array of estimated output amounts for each swap fragment,
     * including the output amount for any remaining amount after all fragments are processed.
     *
     * Requirements:
     * - The size of each fragment must be greater than 0
     * - The total input amount must be greater than or equal to the fragment size
     *
     * Emits a {view} function call to the Uniswap V2 Router contract to retrieve estimated output amounts,
     * based on the specified input parameters and swap path.
     * Returns an array of output amounts for each swap fragment,
     * including the output amount for any remaining amount after all fragments are processed.
     */
    function getFragmentedEstimates(
        address routerAddress,
        address token0,
        address token1,
        uint256 totalAmountIn,
        uint256 size
    ) public view returns (uint256[] memory amounts) {
        require(size > 0, "Size cannot be zero");
        require(totalAmountIn >= size, "Total amount is less than the size");

        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        uint256 fragments = totalAmountIn / size;
        uint256 remainingAmount = totalAmountIn % size;
        uint256 numCalculations = remainingAmount > 0
            ? fragments + 1
            : fragments;

        amounts = new uint256[](numCalculations);
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        for (uint256 i = 0; i < fragments; i++) {
            uint256[] memory result = router.getAmountsOut(size, path);
            amounts[i] = result[1]; // sssuming result[1] is the output token amount
        }

        if (remainingAmount > 0) {
            uint256[] memory result = router.getAmountsOut(
                remainingAmount,
                path
            );
            amounts[fragments] = result[1];
        }

        return amounts;
    }

    /**
     * @dev Provides an estimate of the total amount of token1 that will be received
     * for a specified amount of token0, using fragmented swaps via Uniswap V2 Router.
     * This function is view-only and does not make any state changes.
     *
     * @param token0 The address of the token to swap from.
     * @param token1 The address of the token to swap to.
     * @param router The address of the Uniswap V2 Router.
     * @param totalAmount The total amount of token0 to swap.
     * @param size The size of each individual swap.
     * @return totalAmountOut Total estimated amount of token1 to be received.
     */
    function getFragmentedEstimatedAmountOut02(
        address token0,
        address token1,
        address router,
        uint256 totalAmount,
        uint256 size
    ) public view returns (uint256 totalAmountOut) {
        require(totalAmount > 0, "Query: TOTAL_AMOUNT_IS_ZERO");
        require(size > 0, "Query: SIZE_IS_ZERO");
        require(size <= totalAmount, "Query: SIZE_IS_MORE_THAN_TOTAL_AMOUNT");

        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;

        uint256 amountRemaining = totalAmount;
        totalAmountOut = 0;

        while (amountRemaining > 0) {
            uint256 amountIn = amountRemaining < size ? amountRemaining : size;
            uint256[] memory amounts = IUniswapV2Router02(router).getAmountsOut(
                amountIn,
                path
            );
            totalAmountOut += amounts[1];
            amountRemaining -= amountIn;
        }

        return totalAmountOut;
    }
}

