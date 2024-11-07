<template>
  <select v-model="current">
    <option v-for="c in all" :key="c.id" :value="c.id">{{ c.name }}</option>
  </select>
  {{ current }}
</template>

<script setup lang="ts">
import { useUser } from "../composables/useUser";
import { ref, watch } from "vue";

const current = ref("");
watch(current, (value) => {
  setCurrency(value);
});
const { all, setCurrency, myCurrency } = useUser();
</script>
