<template>
    <div class="flex flex-col">
        Forgot Password
        <input type="text" v-model="email" placeholder="e-mail" class="border">
        <button @click="loginClicked()">Send reset</button>
    </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import {sendPassword} from '../firebase/auth';

const email = ref('');

function loginClicked() {
    sendPassword(email.value)
}
</script>