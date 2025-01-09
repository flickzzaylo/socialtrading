<template>
  <div>
    <h1>Wallet Management</h1>
    <div v-if="!isConnected">
      <button @click="connect">Connect Wallet</button>
    </div>
    <div v-else>
      <p>Connected as: {{ address }}</p>
      <p>Balance: {{ balance }} GO</p>
      <p>Owner: {{ owner }}</p>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers';

export default {
  name: 'WalletManagement',
  data() {
    return {
      address: '0x...',
      balance: '0',
      owner: '0x...',
      isConnected: false,
      abi: [
        {
          inputs: [
            {
              internalType: 'uint256',
              name: '_unlockTime',
              type: 'uint256',
            },
          ],
          stateMutability: 'payable',
          type: 'constructor',
        },
        {
          anonymous: false,
          inputs: [
            {
              indexed: false,
              internalType: 'uint256',
              name: 'amount',
              type: 'uint256',
            },
            {
              indexed: false,
              internalType: 'uint256',
              name: 'when',
              type: 'uint256',
            },
          ],
          name: 'Withdrawal',
          type: 'event',
        },
        {
          inputs: [],
          name: 'owner',
          outputs: [
            {
              internalType: 'address payable',
              name: '',
              type: 'address',
            },
          ],
          stateMutability: 'view',
          type: 'function',
        },
        {
          inputs: [
            {
              internalType: 'uint256',
              name: 'value',
              type: 'uint256',
            },
          ],
          name: 'setUnlockTime',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
        {
          inputs: [],
          name: 'unlockTime',
          outputs: [
            {
              internalType: 'uint256',
              name: '',
              type: 'uint256',
            },
          ],
          stateMutability: 'view',
          type: 'function',
        },
        {
          inputs: [],
          name: 'withdraw',
          outputs: [],
          stateMutability: 'nonpayable',
          type: 'function',
        },
      ],
      lockAddress: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
    };
  },
  methods: {
    async connect() {
      try {
        if (!window.ethereum) {
          throw new Error('MetaMask is not installed!');
        }
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        this.address = await signer.getAddress();
        this.balance = ethers.formatEther(await provider.getBalance(this.address));
        const lockContract = new ethers.Contract(this.lockAddress, this.abi, signer);
        this.owner = await lockContract.owner();
        this.isConnected = true;
        console.log('Connected as:', this.address);
        console.log('Balance:', this.balance, 'ETH');
        console.log('Owner:', this.owner);
      } catch (error) {
        console.log(error);
      }
    },
  },
  mounted() {
    console.log('nthng')
  },
};
</script>