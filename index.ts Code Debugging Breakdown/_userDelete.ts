import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const userDelete = onRequest(
    {cors: true},
    async (request, response) => {
      const {userID} = await getUserID(request);
      const groups = await groupManager.getGroupsForUser(userID);
      const hasZeroBalance = groups.every(
        (group) => group.getBalanceForUser(userID) === 0
      );
      if (!hasZeroBalance) {
        response.send({success: false});
        return;
      }
      await groupManager.deleteUser(userID);
      response.send({success: userID});
    }
  );
  