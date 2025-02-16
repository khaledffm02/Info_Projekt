import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const addPayment = async (groupID: string, fromID: string, toID: string, amount: number) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(
    createURL("addpayment", { groupID, idToken, fromID, toID, amount: String(amount) })
  );
  return res.json();
};
