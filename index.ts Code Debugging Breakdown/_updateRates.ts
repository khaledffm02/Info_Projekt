import { onRequest } from "firebase-functions/v2/https";
import { getUserID } from "./auth";
import { groupManager } from "./config";

export const updateRates = onRequest(
    {cors: true, secrets: [currencyKey]},
    async (request, response) => {
      const {userID} = await getUserID(request);
      if (!userID) {
        response.send({
          success: false,
          message: "Missing parameters",
          detailedMessage: {userID},
        });
        return;
      }
  
      await groupManager.updateCurrencyRates(currencyKey.value());
      response.send({success: true});
  
      return;
    }
  );