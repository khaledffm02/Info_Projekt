import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const userLogin = onRequest(
    {cors: true},
    async (request, response) => {
      const {userID} = await getUserID(request);
      await groupManager.userLogin(userID, {preferredCurrency: "EUR"});
      response.send({success: true});
    }
  );
  