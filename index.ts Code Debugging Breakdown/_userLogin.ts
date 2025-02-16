import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Method allowing user login function
export const userLogin = onRequest(
    {cors: true},
    async (request, response) => {
      // Get the userID front the request
      const {userID} = await getUserID(request);
      // Perform user login with preferred currency set to EUR
      await groupManager.userLogin(userID, {preferredCurrency: "EUR"});
      // Send a success response
      response.send({success: true});
    }
  );
  