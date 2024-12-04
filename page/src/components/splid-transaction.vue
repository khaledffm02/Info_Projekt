<template>
    <div class="text-blue-500">{{ id }} {{ transaction }}


        <button v-if="!isConfirmed" @click="confirmTransaction()">Confirm</button>
        <button @click="deleteTransaction()">Delete</button>
    </div>
</template>

<script setup lang="ts">
import { useAPI } from '../composables/useAPI';
import {transactionToJson} from '../../../functions/src/models/Transaction'
import { computed } from 'vue';
import { user } from "../firebase/auth";

const props = defineProps<{id: string, groupID: string, transaction: ReturnType<typeof transactionToJson>}>()

const isConfirmed = computed(() => !props.transaction.friends[user.value?.uid!] || props.transaction.friends[user.value?.uid!]?.isConfirmed) 

const confirmTransaction = () => {
    useAPI().confirmTransaction(props.groupID, props.id)
}

const deleteTransaction = () => {
    useAPI().deleteTransaction(props.groupID, props.id)
}
</script>