import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"


test('calculates balances correctly with a mix of confirmed and unconfirmed friends', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 },
    { friend1: { value: 50, isConfirmed: true }, friend2: { value: 30, isConfirmed: false } }
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-130); // User's value + unconfirmed friend's value
  expect(balances['friend1']).toBe(50); // Confirmed friend's value
});
