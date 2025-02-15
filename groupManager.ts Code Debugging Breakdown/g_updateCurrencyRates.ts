import { Firestore } from "firebase-admin/firestore";

export async function updateCurrencyRates(db: Firestore, apikey: string) {
  const currencyRef = db.collection("settings").doc("currencies");
  const currencyDoc = await currencyRef.get();

  if (!currencyDoc.exists || !currencyDoc.data()?.timestamp || Date.now() - currencyDoc.data()?.timestamp > 1 * 60 * 1000) {
    const base_currency = "EUR";
    const currencies = "USD,GBP,JPY,CNY,EUR,CHF";
    const url = `https://api.freecurrencyapi.com/v1/latest?apikey=${apikey}&base_currency=${base_currency}&currencies=${currencies}`;
    const result = await fetch(url);
    const { data: newRates } = await result.json();
    await currencyRef.set({ ...newRates, timestamp: Date.now() });
    return newRates;
  }

  return currencyDoc.data();
}
