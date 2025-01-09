<template>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container-fluid">
      <!-- Контейнер с фиксированной шириной для ссылок -->
      <div class="d-flex justify-content-center fixed-width-container">
        <div class="mx-4 nav-item">
          <router-link to="/userPage" class="nav-link">Пользователь</router-link>
        </div>
        <div class="mx-4 nav-item">
          <router-link to="/managerPage" class="nav-link">Менеджер</router-link>
        </div>
      </div>
      <div class="d-flex align-items-center">
        <div v-if="!isConnected" class="d-flex align-items-center">
          <img src="@/assets/login.png" @click="connect" alt="Wallet" class="wallet-icon me-2 clickable" style="width: 32px;height: 32px;" />
        </div>
        <div v-else class="d-flex align-items-center">
          <img src="@/assets/wallet.png" alt="Wallet" class="wallet-icon me-2"/>
          <p class="mb-0 me-3 balance-container">{{ address }}</p>
          <img src="@/assets/money.png" alt="Wallet" class="wallet-icon me-2" style="width: 32px;height: 32px;" />
          <p class="mb-0 me-3 balance-container">{{ balance }} USDT</p>
          <img src="@/assets/logout.png" @click="logout" alt="Wallet" class="wallet-icon me-2 clickable" />
        </div>
      </div>
    </div>
  </nav>
</template>

<script>
import { ethers } from "ethers";

export default {
  name: "NavBar",
  data() {
    return {
      address: '0x...',
      balance: '0',
      isConnected: false,
    };
  },
  methods: {
    async connect() {
      try {
        if (!window.ethereum) {
          throw new Error('MetaMask не установлен!');
        }
        const accounts = await window.ethereum.request({method: "eth_requestAccounts"});
        this.address = accounts[0];
        const provider = new ethers.BrowserProvider(window.ethereum);
        const balanceT = await provider.getBalance(this.address);
        this.balance = ethers.formatEther(balanceT);
        this.isConnected = true;
        localStorage.setItem("LogIn", true);
        this.$router.push({path: "/userPage"});
      } catch (e) {
        console.error(e);
      }
    },
    async logout() {
      this.isConnected = false;
      localStorage.setItem("LogIn", false);
      this.$router.push({path: "/"});
    }
  },
  mounted() {
    if (this.address === '0x...') {
      localStorage.setItem("LogIn", false);
    }
  }
};
</script>

<style scoped>
.navbar {
  padding: 1rem;
  font-family: 'Arial', sans-serif;
}

.nav-link {
  font-size: 1.2rem;
  color: #333;
  text-decoration: none !important;
  transition: color 0.3s ease, transform 0.3s ease;
}

.nav-link:hover {
  color: #007bff;
  transform: scale(1.1);
}

.wallet-icon {
  width: 24px;
  height: 24px;
}

.clickable {
  cursor: pointer;
  transition: transform 0.2s ease;
}

.clickable:active {
  transform: scale(0.9);
}

.balance-container {
  display: flex;
  align-items: center;
  white-space: nowrap !important;
}
.fixed-width-container {
  width: 300px;
  justify-content: space-between;
}
</style>