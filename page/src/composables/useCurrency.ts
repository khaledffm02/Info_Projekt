import { createGlobalState } from "@vueuse/core";
import { currencies } from "../models/currency";
import { computed } from "vue";

type Currency = {
  id: string;
  name: string;
  rate: number;
};

export const useCurrency = createGlobalState(() => {
  const all = computed(() => (currencies.value ?? []) as Currency[]);

  return { all };
});
