import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const userRegistration = onRequest(
    {cors: true},
    async (request, response) => {
      const {userID} = await getUserID(request);
      const firstName = request.query.firstName as string;
      const lastName = request.query.lastName as string;
      await groupManager.userRegistration(userID, {
        firstName,
        lastName,
        currency: "EUR",
      });
      response.send({success: true});
    }
  );
  