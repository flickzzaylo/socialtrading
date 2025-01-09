<template>
  <div class="container mt-5">
    <div class="card shadow">
      <div class="card-header" style="background-color: #007bff;"> <!-- Светло-синий фон -->
        <h1 class="card-title text-md-center" style="color: antiquewhite">Страница пользователя</h1>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label for="managerSelect" class="form-label">Выберите менеджера</label>
          <select
              id="managerSelect"
              v-model="selectedManager"
              class="form-select"
          >
            <option disabled value="">Менеджер</option>
            <option
                v-for="manager in managers"
                :key="manager.address"
                :value="manager.address"
            >
              {{ manager.name }}
            </option>
          </select>
        </div>
        <div class="mb-3">
          <label for="amountInput" class="form-label">Сумма</label>
          <input
              id="amountInput"
              v-model="amount"
              type="text"
              class="form-control"
              placeholder="Введите сумму перевода (ETH)"
          />
        </div>
        <button @click="assignManagerAndDeposit" class="btn btn-primary w-100">
          Перевести
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from "ethers";
import LockArtifact from "../../../artifacts/contracts/Lock.sol/Lock.json";

export default {
  data() {
    return {
      account: "",
      contract: null,
      managers: [
        {
          address: "0x1F0242b62db6eA34F7b7ca2D4326Fd688839642b",
          name: "Dmitry",
        },
        {
          address: "0xf065E0EDf24aae179ff7CD0bfE7FDfB1a3ECc8AA",
          name: "Vadim",
        },
        {
          address: "0x98D08079928FcCB30598c6C6382ABfd7dbFaA1cD",
          name: "test",
        },
      ],
      selectedManager: "",
      amount: "",
      isLoggedIn: localStorage.getItem("LogIn") === "true",
    };
  },
  async mounted() {
    await this.connectWallet();
    if (!this.isLoggedIn) {
      this.$router.push("/"); // Переход, если не авторизован
    }
  },
  methods: {
    async connectWallet() {
      if (window.ethereum) {
        const provider = new ethers.BrowserProvider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        const signer = await provider.getSigner();
        this.account = await signer.getAddress();
        const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Адрес контракта
        this.contract = new ethers.Contract(
            contractAddress,
            LockArtifact.abi,
            signer
        );
      }
    },
    async assignManagerAndDeposit() {
      try {
        const amountInWei = ethers.parseEther(this.amount);  // Конвертируем сумму в Wei
        console.log("Amount in Wei:", amountInWei.toString()); // Для отладки

        const tx = await this.contract.assignManagerAndDeposit(
            this.selectedManager,
            { value: amountInWei }  // Отправляем ETH с транзакцией
        );
        await tx.wait();
        alert("Менеджер назначен и ETH отправлен.");
      } catch (error) {
        console.error("Error during assignManagerAndDeposit:", error);
        alert("Недостаточно средств!");
      }
    }

  },
};
</script>

<style scoped>
/* Дополнительные стили */
.container {
  max-width: 600px;
}

.card {
  border-radius: 10px;
}

.card-header {
  border-radius: 10px 10px 0 0;
}

.btn-success {
  background-color: #28a745;
  border-color: #28a745;
  transition: background-color 0.3s ease, transform 0.3s ease;
}

.btn-success:hover {
  background-color: #218838;
  border-color: #1e7e34;
  transform: scale(1.05);
}

.form-select, .form-control {
  border-radius: 5px;
}

/* Светло-синий фон для всей страницы */
body {
  background-color: #e3f2fd;
}
</style>
