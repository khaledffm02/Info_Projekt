<template>
    <div class="flex flex-col">
        Update Password
        <input type="password" v-model="oldPW" placeholder="old password" class="border">
        <input type="password" v-model="newPW" placeholder="new password" class="border">
        <button @click="loginClicked()">Update password</button>
    </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import {changePassword} from '../firebase/auth';

const oldPW = ref('');
const newPW = ref('');

function loginClicked() {
    changePassword(oldPW.value, newPW.value)
}
</script>