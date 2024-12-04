import { createGlobalState } from "@vueuse/core";
import { currencies } from "../models/currency";
import { computed } from "vue";
import { useFirestore } from "@vueuse/firebase";
import { doc } from "firebase/firestore";
import { firestore } from "../firebase/firestore";

type Currency = {
  id: string;
  name: string;
  rate: number;
};

export const useCurrency = createGlobalState(() => {
  const all = useFirestore(doc(firestore, 'settings', 'currencies'))

  // const all = computed(() => (currencies.value ?? []) as Currency[]);

  return { all };
});
