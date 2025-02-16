import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

// Method for user registration method
export const userRegistration = onRequest(
    {cors: true},
    async (request, response) => {
      const {userID} = await getUserID(request);
      // Get firstName and lastName from the request query parameters
      const firstName = request.query.firstName as string;
      const lastName = request.query.lastName as string;
      // Perform user registration eith provided details
      await groupManager.userRegistration(userID, {
        firstName,
        lastName,
        currency: "EUR",
      });
      response.send({success: true}); // Send a success response
    }
  );
  