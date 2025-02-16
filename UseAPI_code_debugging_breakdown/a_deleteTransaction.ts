import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const deleteTransaction = async (groupID: string, transactionID: string) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("deletetransaction", { groupID, transactionID, idToken }));
  return res.json();
};
