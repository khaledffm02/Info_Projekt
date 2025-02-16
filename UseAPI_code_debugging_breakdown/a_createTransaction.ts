import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const createTransaction = async (
  groupID: string,
  title: string,
  category: string,
  userParam: { id: string; value: number },
  friends: { id: string; value: number }[],
  storageURL?: string
) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const request = encodeURIComponent(
    JSON.stringify({ groupID, title, category, user: userParam, friends, storageURL })
  );
  const res = await fetch(createURL("createtransaction", { idToken, request }));
  return res.json();
};
