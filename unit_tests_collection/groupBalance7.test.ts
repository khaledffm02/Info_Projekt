import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test when some friends confirm and others do not

test('calculates balances correctly with a mix of confirmed and unconfirmed friends', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 }, // Main user starts 100 transaction
    { friend1: { value: 50, isConfirmed: true }, // Friend1 is confirmed for 50
     friend2: { value: 30, isConfirmed: false } } // Friend2 in unconfirmed for 30
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-70); // User's value + unconfirmed friend's value
  expect(balances['friend1']).toBe(50); // Confirmed friend's value
});
