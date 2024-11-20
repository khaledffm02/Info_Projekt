import { firestore } from "../firebase/firestore";
import { useFirestore } from "@vueuse/firebase";
import { doc } from "firebase/firestore";
import { computed } from "vue";

export const useGroup = (groupID: string) => {
    const groupData = useFirestore(doc(firestore, 'groups', groupID))
    const group = computed(() => groupData.value)
    return {group}
}