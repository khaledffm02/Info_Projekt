import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const groupDelete = onRequest(
    {cors: true},
    async (request, response) => {
      const groupID = request.query.groupID as string;
      await groupManager.deleteGroup(groupID);
      response.send({success: true});
    }
  );
  