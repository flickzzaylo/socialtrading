<template>
  <div id="app">
    <nav-bar/>
    <router-view/>
  </div>
</template>

<script>
import NavBar from "@/NavBar.vue";
export default {
  name: 'App',
  components: {
    NavBar
  }
};
</script>