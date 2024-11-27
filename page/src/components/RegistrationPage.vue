<template>
    <div class="flex flex-col">
        Registration
        <input type="text" v-model="email" placeholder="e-mail" class="border">
        <input type="password" v-model="password" placeholder="password" class="border">
        <button @click="registerClicked()">Register</button>
    </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

import {registerWithPasswordAndEmail} from '../firebase/auth';

const email = ref('');
const password = ref('');

function registerClicked() {
    registerWithPasswordAndEmail(email.value, password.value)
}
</script>