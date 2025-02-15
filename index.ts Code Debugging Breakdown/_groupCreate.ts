import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const groupCreate = onRequest(
  { cors: true },
  async (request, response) => {
    const { userID } = await getUserID(request);
    const member = await groupManager.getMember(userID);
    if (!member) {
      response.send({ success: false });
      return;
    }
    const groupName = request.query.groupName as string;
    await groupManager.createGroup(userID, member.currency, groupName);
    response.send({ success: true });
  }
);
