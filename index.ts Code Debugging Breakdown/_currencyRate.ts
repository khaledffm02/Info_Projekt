import { onRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/logger";
import { getUserID } from "./auth";
import { db, discordApiKey } from "./config";

// Cloud function to update the currency rate
export const currencyRate = onRequest(
  { cors: true, secrets: [discordApiKey] },
  async (request, response) => {
    logger.info("Currency Rate API Hit", { structuredData: true }); // Logging the request
    const { userID } = await getUserID(request); // Get the user ID from the request
    const currencyID = request.query.currencyID; // Get the currency ID from the query parameters
    const currencyDoc = db.doc(`currencies/${currencyID}`); // Reference the currency document
    const currency = await currencyDoc.get(); // Fetch the currency document
    const oldRate = currency.data()?.rate ?? 1; // Get the old rate, defaulting to 1 if not found
    await currencyDoc.update({ rate: oldRate + 1 }); // Update the rate by incrementing it
    response.send(`Currency rate updated. User: ${userID}`); // Send a response back including secrets and userID
  }
);
