import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const joinGroup = async (groupCode: string) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("groupjoin", { idToken, groupCode }));
  return res.json();
};
