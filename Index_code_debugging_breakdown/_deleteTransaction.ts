import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Method/endpoint for deleting a transaction
export const deleteTransaction = onRequest(
    {cors: true},
    async (request, response) => {
      const groupID = request.query.groupID as string;
      const transactionID = request.query.transactionID as string;
      //Check if any parameters are missing
      if (!groupID || !transactionID) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, transactionID},
        });
        return;
      }
      // Delete the transaction for the specified group and transaction ID
      await groupManager.deleteTransaction(groupID, transactionID);
      response.send({success: true}); // Respond with success on deletion
      return;
    }
  );