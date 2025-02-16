import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test that unconfirmed friends' amounts are considered part of the main user's balance

test('calculates balances correctly for unconfirmed friends', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 }, // Main user starts with 100
    { friend1: { value: 50, isConfirmed: false }, // Unconfirmed contribution
     friend2: { value: 30, isConfirmed: false } } // Another unconfirmed contribution
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-20); // User's initial value + all unconfirmed friend values
});
