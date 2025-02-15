import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const confirmTransaction = onRequest(
    {cors: true},
    async (request, response) => {
      const groupID = request.query.groupID as string;
      const transactionID = request.query.transactionID as string;
      const {userID} = await getUserID(request);
      if (!groupID || !transactionID || !userID) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, transactionID, userID},
        });
        return;
      }
      await groupManager.confirmTransaction(groupID, transactionID, userID);
      response.send({success: true});
      return;
    }
  );