import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const groupLeave = onRequest(
    {cors: true},
    async (request, response) => {
      const groupID = request.query.groupID as string;
      if (!groupID) {
        response.send({success: false});
        return;
      }
      const {userID} = await getUserID(request);
      const group = await groupManager.getGroup(groupID);
  
      if (group.getBalanceForUser(userID) !== 0) {
        response.send({success: false});
      } else {
        await groupManager.removeMember(group.id, userID);
        response.send({success: true});
      }
    }
  );
  