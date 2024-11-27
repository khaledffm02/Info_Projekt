<script setup lang="ts">
import { isAuthenticated } from "./firebase/auth";
import AppHeader from "./components/app-header.vue";
import AppFrame from "./components/app-frame.vue";
import LoginPage from "./components/LoginPage.vue";
</script>

<template>
  <div>
    <AppHeader />
    <AppFrame v-if="isAuthenticated" />
    <LoginPage v-else />
  </div>
</template>
