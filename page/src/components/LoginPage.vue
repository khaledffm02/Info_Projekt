<template>
    <div class="flex flex-col">
        Login
        <input type="text" v-model="email" placeholder="e-mail" class="border">
        <input type="password" v-model="password" placeholder="password" class="border">
        <button @click="loginClicked()">Login</button>
    </div>
    <RegisterPage />
    <ForgotPassword />
    <button @click="sendNewPassword()">Send new password</button>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import RegisterPage from './RegistrationPage.vue'
import ForgotPassword from './ForgotPassword.vue'

import {signInWithPasswordAndEmail} from '../firebase/auth';
import { useAPI } from '../composables/useAPI';

const email = ref('');
const password = ref('');

async function loginClicked() {
    await signInWithPasswordAndEmail(email.value, password.value)
    useAPI().userLogin()
}

function sendNewPassword() {
   useAPI().sendPassword(email.value)
}
</script>