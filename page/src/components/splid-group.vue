<template>
  <div class="border p-4 rounded border-gray-500 flex flex-col">
    <div class="flex gap-4">ID: {{ id }} <span @click="api.getBalances(id)">Balances</span></div>
    <div class="font-mono">Code: {{ data.groupCode }}</div>
    <div class="pl-4 flex flex-col">Members: 
        <div v-for="m in members" :key="m.memberID">{{ m.member.value?.email }} {{ m.isMember ? '✅' : '⛔️' }} {{ m.memberID === data.creatorID ? '🖋️' : '' }}</div>
    </div>
    <div>Transactions 
        <SplidCreateTransaction :groupID="id" :people="members" />
    </div>
    <SplidTransaction v-for="(t, i) in data.transactions" class="py-4" :groupID="data.id" :id="i" :transaction="t"></SplidTransaction>
  </div>
</template>

<script setup lang="ts">
import { computed, watch } from 'vue';
import {transactionToJson} from '../../../functions/src/models/Transaction'
import { useMember } from '../composables/useMember';
import SplidCreateTransaction from './splid-create-transaction.vue'
import SplidTransaction from './splid-transaction.vue'
import { useAPI } from '../composables/useAPI';

const api = useAPI()
const {member: getMember} = useMember()
const props = defineProps<{ id: string, data: {
  id: string;
  creationTimestamp: number;    
  groupCode: string;
  memberIDs: Record<string, boolean>;
  currency: string
  creatorID: string;
  transactions: Record<string, ReturnType<typeof transactionToJson>>
}
}>();

const members = computed(() => Object.entries(props.data.memberIDs).map(([memberID, isMember]) => {
  return {member: getMember(memberID), isMember, memberID}
}))

</script>
