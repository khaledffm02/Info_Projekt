import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const groupJoin = onRequest(
    {cors: true},
    async (request, response) => {
      const groupCode = request.query.groupCode as string;
      if (!groupCode) {
        response.send({success: false});
        return;
      }
      const {userID} = await getUserID(request);
      const group = await groupManager.getGroupByCode(groupCode);
      if (!group) {
        response.send({success: false});
      } else if (group.memberCount >= 10) {
        response.send({success: false, message: "Too many members"});
      } else {
        await groupManager.addMember(group.id, userID);
        response.send({success: true});
      }
    }
  );
  