import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test that the main user's balance is calculated correctly

test('calculates balances correctly for the main user', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined // No storage URL provided },
    { userID: 'user1', value: 100 }, // Main initializes transaction with 100
    { friend1: { value: 50, isConfirmed: true }, friend2: { value: 30, isConfirmed: false } } // Friend1 confirmed for 50, Friend2 unconfirmed for 30
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-70); // User's initial value + unconfirmed friend value (100 - 30)
});
