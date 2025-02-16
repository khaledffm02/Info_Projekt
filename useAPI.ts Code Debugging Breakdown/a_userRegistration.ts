import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const userRegistration = async (firstName: string, lastName: string) => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  const res = await fetch(createURL("userregistration", { idToken, firstName, lastName }));
  return res.json();
};
