import { Firestore } from "firebase-admin/firestore";


// Method to update the currency rate with API 

export async function updateCurrencyRates(db: Firestore, apikey: string) {
  // Reference the currencies document in Firestore

  const currencyRef = db.collection("settings").doc("currencies");
  // Ger the currencies document
  const currencyDoc = await currencyRef.get();

  // Check if the currency rates need to be updated
  if (!currencyDoc.exists || !currencyDoc.data()?.timestamp || Date.now() - currencyDoc.data()?.timestamp > 1 * 60 * 1000) {
    const base_currency = "EUR";
    const currencies = "USD,GBP,JPY,CNY,EUR,CHF";
    const url = `https://api.freecurrencyapi.com/v1/latest?apikey=${apikey}&base_currency=${base_currency}&currencies=${currencies}`;
    // Fetch new currency rates
    const result = await fetch(url);
    const { data: newRates } = await result.json();
    // Update the currency rates document
    await currencyRef.set({ ...newRates, timestamp: Date.now() });
    return newRates;
  }
// Return existing rates if they are still valid
  return currencyDoc.data();
}
