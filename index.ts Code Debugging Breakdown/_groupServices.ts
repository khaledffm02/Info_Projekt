import { groupManager } from "./groupManager";
import { MESSAGES } from "./constants";

export const getGroupByID = async (groupID: string) => {
  const group = await groupManager.getGroup(groupID);
  if (!group) {
    throw new Error(MESSAGES.GROUP_NOT_FOUND);
  }
  return group;
};

export const createGroupForUser = async (userID: string, currency: string, groupName: string) => {
  return await groupManager.createGroup(userID, currency, groupName);
};
