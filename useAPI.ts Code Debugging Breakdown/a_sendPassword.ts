import { createURL } from "./createURL";

export const sendPassword = async (email: string) => {
  const res = await fetch(createURL("sendnewpassword", { email }));
  return res.json();
};
