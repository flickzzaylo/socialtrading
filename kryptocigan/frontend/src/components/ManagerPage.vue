<template>
  <div class="container mt-5">
    <div class="row justify-content-center">
      <!-- Карточка с менеджером (по центру) -->
      <div class="col-md-6">
        <div class="card shadow">
          <div class="card-header" style="background-color: #007bff;">
            <h1 class="card-title text-md-center" style="color: antiquewhite">Страница менеджера</h1>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <label class="form-label">Доверенные токены</label>
              <ul class="list-group">
                <li v-for="(token, index) in entrustedTokensList" :key="index" class="list-group-item">
                  <div class="form-check">
                    <input
                        type="radio"
                        :id="'tokenRadio' + index"
                        :value="token.address"
                        v-model="selectedTokenAddress"
                        class="form-check-input bg-primary"
                    />
                    <label :for="'tokenRadio' + index" class="form-check-label">
                      <strong>{{ token.name }}</strong>: {{ token.amount }}
                    </label>
                  </div>
                </li>
              </ul>
            </div>

            <div class="mb-3">
              <label for="tradeTokenOut" class="form-label">Токен для получения (Out)</label>
              <select
                  id="tradeTokenOut"
                  v-model="tradeTokenOut"
                  class="form-select"
              >
                <option disabled value="">Токен</option>
                <option
                    v-for="token in tokensForOut"
                    :key="token.address"
                    :value="token.address">
                  {{ token.name }}
                </option>
              </select>
            </div>

            <div class="mb-3">
              <label for="tradeAmount" class="form-label">Сумма</label>
              <input
                  id="tradeAmount"
                  v-model="tradeAmount"
                  type="text"
                  class="form-control"
                  placeholder="Введите сумму для обмена"
              />
            </div>

            <button @click="executeTrade" class="btn btn-primary w-100">
              Выполнить обмен
            </button>
          </div>
        </div>
      </div>

      <!-- Карточка с курсами криптовалют (справа) -->
      <div class="col-md-4">
        <div class="crypto-card shadow">
          <div class="card-header">
            <img src="https://cryptologos.cc/logos/bitcoin-btc-logo.png" alt="Bitcoin" class="crypto-logo">
            <h1 class="card-title">Курсы криптовалют</h1>
          </div>
          <div class="card-body">
            <ul>
              <li v-for="(crypto, index) in topCryptos" :key="index">
                <strong>{{ crypto.name }}:</strong> {{ crypto.current_price }} $USD
              </li>
            </ul>
            <div v-if="loading" class="text-center">
              <p class="spinner-border"></p>
            </div>
            <div v-if="error" class="text-center text-danger">
              <p>Ошибка загрузки данных.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers';
import LockArtifact from '../../../artifacts/contracts/Lock.sol/Lock.json';

export default {
  data() {
    return {
      account: '',
      mockContract: null,
      contract: null,
      entrustedTokens: '0',
      globalSigner: null,
      tradeTokenIn: '',
      tradeTokenOut: '',
      tradeAmount: '',
      topCryptos: [],
      loading: false,
      error: false,
      entrustedTokensList: [],
      selectedTokenAddress: '', // Для хранения выбранного адреса токена
      isLoggedIn: localStorage.getItem("LogIn") === "true",
      tokensForOut: [
        {
          address: "0xB8c77482e45F1F44dE1745F52C74426C631bDD52",
          name: "BNB",
        },
        {
          address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
          name: "USDT",
        },
        {
          address: "0x570A5D26f7765Ecb712C0924E4De545B89fD43dF",
          name: "Solana",
        },
        {
          address: "0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c",
          name: "Bitcoin",
        }
      ],
    };
  },
  async mounted() {
    if (!this.isLoggedIn) {
      this.$router.push('/');
    }
    await this.connectWallet();
    await this.fetchEntrustedBalance();
    await this.fetchCryptoPrices();
  },
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        const provider = new ethers.BrowserProvider(window.ethereum);
        await provider.send('eth_requestAccounts', []);
        const signer = await provider.getSigner();
        this.account = await signer.getAddress();
        this.globalSigner = signer;
        const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
        this.contract = new ethers.Contract(contractAddress, LockArtifact.abi, signer);
      }
    },
    async fetchEntrustedBalance() {
      try {
        const [tokenAddresses, tokenAmounts] = await this.contract.getTokenBalances(this.account);

        // Преобразуем Proxy в обычные массивы
        const addressesArray = Array.from(tokenAddresses);
        const amountsArray = Array.from(tokenAmounts);

        // Сопоставляем адреса с именами токенов и формируем список
        this.entrustedTokensList = addressesArray.map((address, index) => {
          const tokenInfo = this.tokensForOut.find(token => token.address.toLowerCase() === address.toLowerCase());
          return {
            name: tokenInfo ? tokenInfo.name : 'Unknown Token',
            address: address,
            amount: ethers.formatEther(amountsArray[index].toString()), // Преобразуем из wei в ETH
          };
        });

        // Логирование данных
        console.log("Entrusted Tokens List:", this.entrustedTokensList);
      } catch (error) {
        console.error("Error fetching entrusted balance:", error);
        alert("Failed to fetch entrusted balance. Check the console for details.");
      }
    },
    async executeTrade() {
      try {
        if (!this.selectedTokenAddress) {
          alert("Пожалуйста, выберите токен для обмена.");
          return;
        }

        const provider = new ethers.BrowserProvider(window.ethereum);
        await provider.send('eth_requestAccounts', []);
        const signer = await provider.getSigner();
        const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
        this.contract = new ethers.Contract(contractAddress, LockArtifact.abi, signer);

        const tx = await this.contract.trade(
            this.selectedTokenAddress, // Используем выбранный адрес токена
            this.tradeTokenOut,
            ethers.parseEther(this.tradeAmount),
            this.account,
            { gasLimit: ethers.parseUnits("2000000", "wei") } // Увеличиваем лимит газа
        );

        await tx.wait();
        alert('Trade executed.');
        await this.fetchEntrustedBalance();
      } catch (error) {
        console.error("Error executing trade:", error);
        alert("Failed to execute trade. Check the console for details.");
      }
    },
    async fetchCryptoPrices() {
      this.loading = true;
      this.error = false;
      try {
        // Формируем URL с параметрами
        const url = new URL('https://api.coingecko.com/api/v3/coins/markets');
        const params = {
          vs_currency: 'usd',
          order: 'market_cap_desc',
          per_page: 10,
          page: 1,
        };

        // Добавляем параметры к URL
        Object.keys(params).forEach(key => url.searchParams.append(key, params[key]));

        // Выполняем запрос
        const response = await fetch(url);
        const data = await response.json();

        // Проверяем, если статус ответа не успешен
        if (!response.ok) {
          throw new Error('Failed to fetch crypto prices');
        }

        // Парсим ответ
        console.log(data);
        this.topCryptos = data;
      } catch (error) {
        console.error('Error fetching crypto prices:', error);
        this.error = true;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 1200px;
}

.card {
  border-radius: 10px;
}

.card-header {
  border-radius: 10px 10px 0 0;
}

.crypto-card {
  border-radius: 0;
  background-color: #f8f9fa;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
}

.crypto-card .card-header {
  background-color: #f8f9fa;
  text-align: center;
  padding: 1.5rem;
}

.crypto-logo {
  width: 50px;
  height: 50px;
  margin-right: 10px;
  vertical-align: middle;
}

.card-header h1 {
  display: inline-block;
  font-size: 1.5rem;
  margin-top: 10px;
}

.card-body {
  padding: 20px;
}

.card-header {
  background-color: #007bff;
  border-radius: 10px 10px 0 0;
}

.btn-primary {
  background-color: #007bff;
  border-color: #007bff;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.btn-primary:hover {
  background-color: #0056b3;
  border-color: #004085;
  transform: scale(1.05);
}

.form-select, .form-control {
  border-radius: 5px;
}

body {
  background-color: #e3f2fd;
}

/* Расположение карточек в одну строку, с центровкой */
.row {
  display: flex;
  justify-content: center;
  align-items: flex-start;
}

/* Размеры для карточек */
.col-md-6 {
  max-width: 60%;  /* Карточка с менеджером занимает 60% */
}

.col-md-4 {
  max-width: 30%;  /* Карточка с курсами криптовалют занимает 30% */
}

.crypto-card .card-header {
  background-color: #f8f9fa;
  text-align: center;
  padding: 1rem;
}
</style>