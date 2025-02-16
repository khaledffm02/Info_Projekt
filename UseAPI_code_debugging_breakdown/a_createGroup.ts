import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const createGroup = async () => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("groupcreate", { idToken, currencyID: "EUR" }));
  return res.json();
};
