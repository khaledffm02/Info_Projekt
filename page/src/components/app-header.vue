<script setup lang="ts">
import { isAuthenticated, signIn, user, signOut } from "../firebase/auth";
import CurrencySwitch from "./currency-switch.vue";
</script>

<template>
  <div class="flex w-full border-b p-2">
    <div v-if="isAuthenticated" class="ml-auto">
      <CurrencySwitch />
      You are {{ user.displayName }}
      <button @click="signOut()">Logout</button>
    </div>
    <div v-else class="ml-auto">
      You are not in
      <button @click="signIn()">Sign in</button>
    </div>
  </div>
</template>
