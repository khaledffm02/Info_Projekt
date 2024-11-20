<template>
  <div class="p-2">
    <!-- App
    <div class="flex flex-col">
      <div v-for="doc in all" :key="doc.id">
        {{ doc.id }} {{ doc.name }} {{ doc.rate }}
      </div>
    </div>
    <div>Set Currency <button @click="setCurrency('yen')">Yen</button></div>
    <div>My Currency: {{ myCurrency }}</div> -->
    <div class="flex gap-4">
      <button @click="api.userLogin()">Login</button>
      <button @click="api.createGroup()">Create Group</button>
      <button @click="join()">Join Group</button>
    </div>
    <div class="flex flex-col" v-for="g in groups">
      <div>{{ g.id }} {{ g.time }} {{ g.code }} Members: {{ g.members }} {{ g.currency }} <button @click="api.deleteGroup(g.id)">Delete</button> <button @click="api.leaveGroup(g.id)">Leave</button></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { user } from "../firebase/auth";
import { useCurrency } from "../composables/useCurrency";
import { useUser } from "../composables/useUser";
import { useAllGroups } from "../composables/useAllGroups";
import { useAPI } from "../composables/useAPI";
import { computed } from "vue";
import { useMember } from "../composables/useMember";

const { all } = useCurrency();
const { setCurrency, myCurrency, all: a, settings } = useUser();

const {rawGroups} = useAllGroups()
const api = useAPI()
const {member: getMember} = useMember()
const groups = computed(() => {
  return rawGroups.value?.map((g) => {
    return {
      id: g.id,
      time: new Date(g.creationTimestamp).toLocaleTimeString(),
      code: g.groupCode,
      members: Object.entries(g.memberIDs).map(([memberID, isMember]) => {
        return {member: getMember(memberID), isMember}
      }),
      currency: g.currency,
    }
  })
})

const join = () => {
  const code = prompt("Please enter code!")
  if (!code) {
    return
  }
  api.joinGroup(code)
}

async function caller() {
  const idToken = await user.value?.getIdToken(true)
  if (!idToken) return
  const url = `https://currencyrate-fblxd33obq-uc.a.run.app?idToken=${idToken}&currencyID=EUR`
  console.log(url)
  const res = await fetch(url)
  console.log(res)
}
</script>
