import { groupManager } from "./groupManager";
import { validateRequestParams } from "./validators";
import { MESSAGES } from "./constants";

export const createTransaction = async (requestQuery: any, userID: string) => {
  const requiredParams = ["groupID", "title", "category", "user", "friends"];
  const validation = validateRequestParams(requestQuery, requiredParams);

  if (!validation.success) {
    return validation;
  }

  const { groupID, title, category, user, friends, storageURL } = requestQuery;
  const payed = user.value;
  const spend = friends.reduce((acc, f) => acc + f.value, 0);

  if (payed !== spend) {
    return {
      success: false,
      message: "Sum of friends' values must be equal to user's value",
      detailedMessage: { payed, spend },
    };
  }

  const id = await groupManager.createTransaction(groupID, { title, category, storageURL }, user, friends);
  return { success: true, transactionID: id };
};
