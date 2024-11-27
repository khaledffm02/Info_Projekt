<script setup lang="ts">
import { isAuthenticated, deleteUser, signIn, user, signOut } from "../firebase/auth";
import CurrencySwitch from "./currency-switch.vue";
</script>

<template>
  <div class="flex w-full border-b p-2 ">
    <div v-if="isAuthenticated" class="ml-auto flex gap-3">
      <CurrencySwitch />
      You are {{ user?.email }} <span class="font-bold text-red-500">{{ user?.emailVerified ? "verified" : "not verified" }}</span>
      <button @click="signOut()">Logout</button>
      <button @click="deleteUser()">Delete User</button>
    </div>
    <div v-else class="ml-auto">
      You are not in
      <button @click="signIn()">Sign in</button>
    </div>
  </div>
</template>
