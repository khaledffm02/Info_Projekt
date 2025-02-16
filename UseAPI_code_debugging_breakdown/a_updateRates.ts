import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const updateRates = async (): Promise<void> => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  await fetch(createURL("updaterates", { idToken }));
};
