import { user } from "../firebase/auth";
import { createURL } from "./createURL";

export const getBalances = async (groupID: string): Promise<any> => {
  const idToken = await user.value?.getIdToken(true);
  if (!idToken) return;
  await fetch(createURL("getgroupbalance", { idToken, groupID }));
};
