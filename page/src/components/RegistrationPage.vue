<template>
    <div class="flex flex-col">
        Registration
        <input type="text" v-model="email" placeholder="e-mail" class="border">
        <input type="password" v-model="password" placeholder="password" class="border">
        <input type="text" v-model="firstname" placeholder="firstname" class="border">
        <input type="text" v-model="lastname" placeholder="lastname" class="border">
        <button @click="registerClicked()">Register</button>
    </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

import {registerWithPasswordAndEmail} from '../firebase/auth';
import { useAPI } from '../composables/useAPI';

const email = ref('');
const password = ref('');
const firstname = ref('');
const lastname = ref('');

async function registerClicked() {
    await registerWithPasswordAndEmail(email.value, password.value)
    await useAPI().userRegistration(firstname.value, lastname.value)
}
</script>