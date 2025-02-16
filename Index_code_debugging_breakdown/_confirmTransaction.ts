import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Endpoint to confirm a transaction within a group
export const confirmTransaction = onRequest(
    {cors: true}, // Enable CORS to the endpoint
    async (request, response) => {
      const groupID = request.query.groupID as string;
      const transactionID = request.query.transactionID as string;
      const {userID} = await getUserID(request); // Fetch user ID from the request
      // Check if parameters are missing
      if (!groupID || !transactionID || !userID) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, transactionID, userID},
        });
        return;
      }
      // Confirm the transaction for the specified group and transaction ID
      await groupManager.confirmTransaction(groupID, transactionID, userID);
      response.send({success: true}); // Send success response
      return;
    }
  );