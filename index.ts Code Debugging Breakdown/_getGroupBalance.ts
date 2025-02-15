import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const getGroupBalance = onRequest(
    {cors: true},
    async (request, response) => {
      const groupID = request.query.groupID as string;
      const {userID} = await getUserID(request);
      if (!groupID || !userID) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, userID},
        });
        return;
      }
  
      const group = await groupManager.getGroup(groupID)
      if (!group) {
        response.send({success: false});
        return
      }
  
      response.send({balances: group.getBalances() ?? {}});
    }
  );
  