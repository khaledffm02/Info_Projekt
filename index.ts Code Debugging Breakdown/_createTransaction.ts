import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Method for creating new transaction function
export const createTransaction = onRequest(
    {cors: true},
    async (request, response) => {
      // Get the request parameters from the query and decode them
      const parameters = decodeURIComponent(request.query.request as string);
      // Get the userID from the request
      const {userID} = await getUserID(request);
      if (!parameters || !userID) {
        // Send a failure response if parameters or userID is not provided
        response.send({success: false});
        return;
      }

      // Parse the request parameters
      const {groupID, title, category, user, friends, storageURL} = JSON.parse(
        parameters
      ) as {
        groupID: string;
        title: string;
        category: string;
        storageURL?: string;
        user: { id: string; value: number };
        friends: { id: string; value: number }[];
      };
      // Validate the requires parameters
      if (!groupID || !title || !user || !friends) {
        // Send a failure response if required parametrs are missing
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, title, category, user, friends},
        });
        return;
      }
      // Calculate the total paid and spent values
      const payed = user.value;
      const spend = friends.reduce((acc, f) => acc + f.value, 0);
      // Validate that the paid amount matches the total spent amount
      if (payed !== spend) {
        // Send a failure response if there is a mismatch
        response.send({
          success: false,
          message: "Sum of friends' values must be equal to user's value",
          detailedMessage: {payed, spend},
        });
        return;
      }

      // Create the transaction in the group
      const id = await groupManager.createTransaction(
        groupID,
        {title, category, storageURL},
        user,
        friends
      );
      // Set a reminder for the group
      await groupManager.setGroupReminder(groupID);
      response.send({success: true, transactionID: id});
      return;
    }
  );