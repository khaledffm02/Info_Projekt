import { useFirestore } from "@vueuse/firebase";
import { doc } from "firebase/firestore";
import { firestore } from "../firebase/firestore";
import { useMemoize } from "@vueuse/core";

export function useMember() {
    const member = useMemoize((userID: string) => useFirestore(doc(firestore, 'users', userID)))
    return {member}
}