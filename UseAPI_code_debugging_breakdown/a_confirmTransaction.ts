import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const confirmTransaction = async (groupID: string, transactionID: string) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("confirmtransaction", { idToken, groupID, transactionID }));
  return res.json();
};
