<template>
    <div class="flex flex-col">
        <input type="text" placeholder="Title" v-model="title" class="border border-gray-300"/>
        <div>
            User:
            <select v-model="user">
                <option v-for="m in people" :key="m.memberID">{{ m.member.value?.email }}</option>
            </select>
            <input type="text" v-model="value" placeholder="Amount">
        </div>
        <div class="flex flex-col gap-2">
            Friends:
            <div v-for="(m, idx) in people" :key="m.memberID" class="flex gap-2 items-center">
                <input type="checkbox" v-model="friends[idx].isChecked" />
                <label :for="m.memberID">{{ m.member?.value?.email }}</label>
                <input type="text" v-model="friends[idx].amount" placeholder="Amount">
            </div>
        </div>
        <button @click="create()" class="border rounded-sm border-gray-200 px-4 py-0.5 cursor-pointer">Create New</button>
    </div>
</template>

<script setup lang="ts">
import type { DocumentData } from 'firebase/firestore';
import { useAPI } from '../composables/useAPI';
import { ref, watch, watchEffect, type Ref } from 'vue';

type F = {member: Ref<DocumentData | null | undefined, DocumentData | null | undefined>;
    isMember: boolean;
    memberID: string;}
const props = defineProps<{groupID: string, people:F[]}>()

const title = ref('')
const user = ref('')
const value = ref('')
const friends = ref(props.people.map((m) => {
    return {isChecked: false, amount: 0, id: m.memberID, member: m.member}
}))

watch(() => friends.value, (newVal) => {
    console.log(newVal)
}, {deep: true})

watchEffect(() => {
    console.log(user.value)
    console.log(friends.value)
})

const create = async () => {
    console.log(friends.value)
    const userID = props.people.find((m) => m.member.value?.email === user.value)?.memberID
    const amount = value.value
    const friendsList = friends.value.filter((f) => f.isChecked).map((f) => {
        return {id: f.id!, value: Number(f.amount)}
    })
    const response = await useAPI().createTransaction(props.groupID, title.value, 'category', {id: userID!, value: Number(amount)}, friendsList)
    console.log(response)
}


</script>