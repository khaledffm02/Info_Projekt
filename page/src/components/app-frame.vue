<template>
  <div class="p-2">
    App
    <div class="flex flex-col">
      <div v-for="doc in all" :key="doc.id">
        {{ doc.id }} {{ doc.name }} {{ doc.rate }}
      </div>
    </div>
    <div>Set Currency <button @click="setCurrency('yen')">Yen</button></div>
    <div>My Currency: {{ myCurrency }}</div>
  </div>
</template>

<script setup lang="ts">
import { useCurrency } from "../composables/useCurrency";
import { useUser } from "../composables/useUser";

const { all } = useCurrency();
const { setCurrency, myCurrency, all: a, settings } = useUser();
</script>
