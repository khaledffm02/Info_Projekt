import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const createTransaction = onRequest(
    {cors: true},
    async (request, response) => {
      const parameters = decodeURIComponent(request.query.request as string);
      const {userID} = await getUserID(request);
      if (!parameters || !userID) {
        response.send({success: false});
        return;
      }
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
      if (!groupID || !title || !user || !friends) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {groupID, title, category, user, friends},
        });
        return;
      }
      const payed = user.value;
      const spend = friends.reduce((acc, f) => acc + f.value, 0);
      if (payed !== spend) {
        response.send({
          success: false,
          message: "Sum of friends' values must be equal to user's value",
          detailedMessage: {payed, spend},
        });
        return;
      }
      const id = await groupManager.createTransaction(
        groupID,
        {title, category, storageURL},
        user,
        friends
      );
      await groupManager.setGroupReminder(groupID);
      response.send({success: true, transactionID: id});
      return;
    }
  );