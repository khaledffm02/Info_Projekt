import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const leaveGroup = async (groupID: string) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("groupleave", { idToken, groupID }));
  return res.json();
};
