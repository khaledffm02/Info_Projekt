import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const groupChange = onRequest(
    {cors: true},
    async (request, response) => {
      await getUserID(request);
      const groupID = request.query.groupID as string;
      if (!groupID) {
        response.send({success: false, message: "Missing groupID"});
        return;
      }
      const groupName = request.query.groupName as string | undefined;
      const groupCurrency = request.query.groupCurrency as string | undefined;
      const group = await groupManager.getGroup(groupID);
      if (!group) {
        response.send({success: false, message: "Group not found"});
        return;
      }
      await groupManager.changeGroup(groupID, {
        name: groupName,
        currency: groupCurrency,
      });
      response.send({success: true});
    }
  );
  