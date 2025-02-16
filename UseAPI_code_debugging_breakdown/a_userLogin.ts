import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const userLogin = async () => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("userlogin", { idToken }));
  return res.json();
};
