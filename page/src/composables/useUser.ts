import { createGlobalState } from "@vueuse/core";
import { user } from "../firebase/auth";
import { computed } from "vue";
import { useFirestore } from "@vueuse/firebase";
import { collection, updateDoc, doc } from "firebase/firestore";
import { firestore } from "../firebase/firestore";
import { useCurrency } from "./useCurrency";

type Settings = {
  currencyID: string;
};

const allUsers = useFirestore(collection(firestore, "users"));

export const useUser = createGlobalState(() => {
  const { all } = useCurrency();
  const userID = computed(() => user.value?.uid);
  const settings = computed(() => {
    return (
      allUsers.value?.find((u) => u.id === userID.value) ??
      (all.value[0]
        ? {
            currencyID: all.value[0].id,
          }
        : undefined)
    );
  });
  const setCurrency = async (id: string) => {
    if (!userID.value) return;
    const settingsRef = doc(firestore, "users", userID.value);
    await updateDoc(settingsRef, { currencyID: id });
  };
  return {
    userID,
    all,
    settings,
    myCurrency: computed(() =>
      all.value.find((c) => c.id === settings.value?.currencyID)
    ),
    setCurrency,
  };
});
