    // SPDX-License-Identifier: UNLICENSED
    pragma solidity ^0.8.27;

    import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
    import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
    import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

    contract Lock {
        using SafeERC20 for IERC20;

        IUniswapV2Router02 public uniswapRouter;
        IERC20 public token;
        address public baseTokenAdress;

        struct TokenBalance {
            uint256 amount; // Количество токенов
            uint256 valueInBaseToken; // Стоимость в базовом токене
            address tokenAddress;
        }


        struct User {
            uint256 balance; // Баланс в базовом токене
            address manager;
            uint256 depositTime;
            uint256 initialBalance; // Начальный баланс в базовом токене
            address[] tokenList; // Список токенов, с которыми работает пользователь
        }

        mapping(address => User) public users;
        mapping(address => uint256) public entrustedBalances;
        mapping(address => uint256) public tradingStartTime;
        mapping(address => TokenBalance) btcBalances; // Балансы других токенов
        mapping(address => TokenBalance) bnbBalances; // Балансы других токенов
        mapping(address => TokenBalance) slnBalances; // Балансы других токенов
        mapping(address => TokenBalance) usdBalances; // Балансы других токенов
        mapping(address => uint256) public tokenPrices;

        event ManagerAssigned(address indexed user, address indexed manager);
        event TokensDeposited(address indexed manager, uint256 amount);
        event TradeExecuted(address indexed manager, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
        event FundsMovedToContract(address indexed user, uint256 amount);
        event TokensSoldAndWithdrawn(address indexed user, uint256 amount);
        event FundsReturnedAfterWeek(address indexed user, uint256 amount);
        event FundsReturnedAfterTwoWeeks(address indexed user, uint256 amount);
        event Swap(address indexed sender, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

        constructor(address _uniswapRouter, address _token) {
            uniswapRouter = IUniswapV2Router02(_uniswapRouter);
            token = IERC20(_token);
            baseTokenAdress = _token;
        }

    //    function setTokenPrice(address token, uint256 price) external {
    //        require(price > 0, "Price must be greater than 0");
    //        tokenPrices[token] = price;
    //    }


        function assignManagerAndDeposit(address manager) external payable {
            require(users[msg.sender].manager == address(0), "Manager already assigned");
            require(msg.value > 0, "Amount must be greater than zero");
            users[msg.sender].manager = manager;
            users[msg.sender].balance += msg.value;
            users[msg.sender].depositTime = block.timestamp;

            btcBalances[manager].amount = 94935;
            usdBalances[manager].amount = 1;
            bnbBalances[manager].amount = 689;
            slnBalances[manager].amount = 197;
            btcBalances[manager].tokenAddress = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
            bnbBalances[manager].tokenAddress = 0xB8c77482e45F1F44dE1745F52C74426C631bDD52;
            slnBalances[manager].tokenAddress = 0x570A5D26f7765Ecb712C0924E4De545B89fD43dF;
            usdBalances[manager].tokenAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
            usdBalances[manager].valueInBaseToken += msg.value;
            btcBalances[manager].valueInBaseToken = 0;
            bnbBalances[manager].valueInBaseToken = 0;
            slnBalances[manager].valueInBaseToken = 0;

            emit ManagerAssigned(msg.sender, manager);
            emit TokensDeposited(manager, msg.value);
        }

//        function swap(
//            address tokenIn,
//            address tokenOut,
//            uint256 amountIn
//        ) external returns (uint256 amountOut) {
//            require(amountIn > 0, "Amount must be greater than 0");
//            uint256 priceIn = tokenPrices[tokenIn];
//            uint256 priceOut = tokenPrices[tokenOut];
//            amountOut = (amountIn * priceIn) / priceOut;
//            require(
//                IERC20(tokenOut).balanceOf(address(this)) >= amountOut,
//                "Insufficient contract balance for tokenOut"
//            );
//            require(
//                IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
//                "TokenIn transfer failed"
//            );
//            require(
//                IERC20(tokenOut).transfer(msg.sender, amountOut),
//                "TokenOut transfer failed"
//            );
//            emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
//            return amountOut;
//        }
        function trade(address tokenIn, address tokenOut, uint256 amountIn, address manager) external {
            uint256 temp = 0;
            if(btcBalances[manager].tokenAddress == tokenIn){
                btcBalances[manager].valueInBaseToken-=amountIn;
                temp = btcBalances[manager].amount;
            }
            if(usdBalances[manager].tokenAddress == tokenIn){
                 usdBalances[manager].valueInBaseToken-=amountIn;
                 temp = usdBalances[manager].amount;
            }
            if(bnbBalances[manager].tokenAddress == tokenIn){
                bnbBalances[manager].valueInBaseToken-=amountIn;
                temp = bnbBalances[manager].amount;
            }
            if(slnBalances[manager].tokenAddress == tokenIn){
                slnBalances[manager].valueInBaseToken-=amountIn;
                temp = slnBalances[manager].amount;
            }

            if(btcBalances[manager].tokenAddress == tokenOut){
                btcBalances[manager].valueInBaseToken+=(temp*amountIn)/btcBalances[manager].amount;
            }
            if(usdBalances[manager].tokenAddress == tokenOut){
                usdBalances[manager].valueInBaseToken+=(temp*amountIn)/usdBalances[manager].amount;
            }
            if(bnbBalances[manager].tokenAddress == tokenOut){
                bnbBalances[manager].valueInBaseToken+=(temp*amountIn)/bnbBalances[manager].amount;
            }
            if(slnBalances[manager].tokenAddress == tokenOut){
                slnBalances[manager].valueInBaseToken+=(temp*amountIn)/slnBalances[manager].amount;
            }


//        IERC20(tokenIn).safeIncreaseAllowance(address(uniswapRouter), amountIn);
//            uint256 amountOut = this.swap(tokenIn, tokenOut, amountIn);
//            users[msg.sender].tokenBalances[tokenOut].amount += amountOut;
//            if (users[msg.sender].tokenBalances[tokenOut].amount == amountOut) {
//                users[msg.sender].tokenList.push(tokenOut);
//            }
//            if (tradingStartTime[msg.sender] == 0) {
//                tradingStartTime[msg.sender] = block.timestamp;
//            }
//            emit TradeExecuted(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
        }

        function getTokenBalances(address user) public view returns (address[] memory, uint256[] memory) {
            // Получаем количество токенов у пользователя
            uint256 tokenCount = 4; // +1 для основного токена

            // Создаем массивы для хранения адресов токенов и их количеств
            address[] memory tokenAddresses = new address[](tokenCount);
            uint256[] memory tokenAmounts = new uint256[](tokenCount);

            // Добавляем основной токен (например, ETH)
            tokenAddresses[0] = btcBalances[user].tokenAddress;
            tokenAddresses[1] = bnbBalances[user].tokenAddress;
            tokenAddresses[2] = slnBalances[user].tokenAddress;
            tokenAddresses[3] = usdBalances[user].tokenAddress;

            tokenAmounts[0] += btcBalances[user].valueInBaseToken;
            tokenAmounts[1] += bnbBalances[user].valueInBaseToken;
            tokenAmounts[2] += slnBalances[user].valueInBaseToken;
            tokenAmounts[3] += usdBalances[user].valueInBaseToken;

            return (tokenAddresses, tokenAmounts);
        }

    //    function sellAndWithdraw() external {
    //        // Проверяем, что функция вызывается пользователем, а не менеджером
    //        require(users[msg.sender].manager != address(0), "Only user can execute this function");
    //
    //        // Проверяем, что прошла хотя бы одна неделя с начала торговли
    //        require(block.timestamp >= tradingStartTime[msg.sender] + 1 weeks, "One week not passed since trading started");
    //
    //        uint256 totalValueInBaseToken = users[msg.sender].balance;
    //
    //        // Конвертируем все токены в базовый токен
    //        for (uint256 i = 0; i < users[msg.sender].tokenList.length; i++) {
    //            address tokenAddress = users[msg.sender].tokenList[i];
    //            TokenBalance storage tokenBalance = users[msg.sender].tokenBalances[tokenAddress];
    //            if (tokenBalance.amount > 0) {
    //                // Конвертируем токен в базовый токен через мок-контракт
    //                IERC20(tokenAddress).safeIncreaseAllowance(address(uniswapRouter), tokenBalance.amount);
    //                uint256 amountOut = this.swap(tokenAddress, address(token), tokenBalance.amount);
    //                totalValueInBaseToken += amountOut;
    //                tokenBalance.amount = 0;
    //            }
    //        }
    //
    //        // Проверяем, что баланс упал на 40%
    //        require(totalValueInBaseToken <= users[msg.sender].initialBalance * 60 / 100, "Balance has not dropped by 40%");
    //
    //        // Переводим базовый токен пользователю
    //        token.safeTransfer(msg.sender, totalValueInBaseToken);
    //
    //        emit TokensSoldAndWithdrawn(msg.sender, totalValueInBaseToken);
    //    }
    //
    //    function checkAndReturnFundsAfterWeek() external {
    //        require(tradingStartTime[msg.sender] != 0, "Trading has not started yet");
    //        require(block.timestamp >= tradingStartTime[msg.sender] + 1 weeks, "One week not passed since trading started");
    //
    //        uint256 totalValueInBaseToken = users[msg.sender].balance;
    //
    //        // Конвертируем все токены в базовый токен
    //        for (uint256 i = 0; i < users[msg.sender].tokenList.length; i++) {
    //            address tokenAddress = users[msg.sender].tokenList[i];
    //            TokenBalance storage tokenBalance = users[msg.sender].tokenBalances[tokenAddress];
    //            if (tokenBalance.amount > 0) {
    //                IERC20(tokenAddress).safeIncreaseAllowance(address(uniswapRouter), tokenBalance.amount);
    //                uint256 amountOut = this.swap(tokenAddress, address(token), tokenBalance.amount);
    //                totalValueInBaseToken += amountOut;
    //                tokenBalance.amount = 0;
    //            }
    //        }
    //
    //        uint256 initialBalance = users[msg.sender].initialBalance;
    //
    //        if (totalValueInBaseToken <= initialBalance) {
    //            // Если баланс не увеличился, возвращаем оставшиеся средства
    //            token.safeTransfer(msg.sender, totalValueInBaseToken);
    //            emit FundsReturnedAfterWeek(msg.sender, totalValueInBaseToken);
    //        } else {
    //            // Если есть прибыль, распределяем её
    //            uint256 profit = totalValueInBaseToken - initialBalance;
    //            uint256 managerShare = profit * 30 / 100;
    //            uint256 userShare = profit - managerShare;
    //
    //            token.safeTransfer(users[msg.sender].manager, managerShare);
    //            token.safeTransfer(msg.sender, userShare + initialBalance);
    //
    //            emit FundsReturnedAfterWeek(msg.sender, userShare + initialBalance);
    //        }
    //    }
    //
    //    function checkAndReturnFundsAfterTwoWeeks() external {
    //        require(block.timestamp >= users[msg.sender].depositTime + 2 weeks, "Two weeks not passed since deposit");
    //        require(tradingStartTime[msg.sender] == 0 || block.timestamp >= tradingStartTime[msg.sender] + 2 weeks, "Two weeks not passed since trading started");
    //        uint256 amountToWithdraw = entrustedBalances[msg.sender];
    //        entrustedBalances[msg.sender] = 0;
    //        token.safeTransfer(msg.sender, amountToWithdraw);
    //        emit FundsReturnedAfterTwoWeeks(msg.sender, amountToWithdraw);
    //    }

        function getEntrustedBalance(address manager) public view returns (uint256) {
            return entrustedBalances[manager];
        }
    }