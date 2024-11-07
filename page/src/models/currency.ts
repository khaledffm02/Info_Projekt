import { firestore } from "../firebase/firestore";
import { collection } from "firebase/firestore";
import { useFirestore } from "@vueuse/firebase";

export const currencies = useFirestore(collection(firestore, "currencies"));
