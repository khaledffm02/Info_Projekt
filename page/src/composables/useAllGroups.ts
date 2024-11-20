import { createGlobalState } from "@vueuse/core";
import { useFirestore } from "@vueuse/firebase";
import { collection, query, where, onSnapshot } from "firebase/firestore";
import { firestore } from "../firebase/firestore";
import { computed } from "vue";
import { user } from "../firebase/auth";

export const useAllGroups = createGlobalState(() => {
    const myGroups = computed(() => query(collection(firestore, 'groups'), where(`memberIDs.${user.value?.uid}`, '==', true)))
    const rawGroups = useFirestore(myGroups)
    return {rawGroups}
})