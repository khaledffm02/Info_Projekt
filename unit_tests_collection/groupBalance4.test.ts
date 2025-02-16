import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test that when no friends are involved, the user pays the full amount

test('calculates balances correctly when there are no friends', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 }, // Main user starts with 100
    {} // No friends involved
  );

  const balances = transaction.getUserBalances();

  // User has full responsibility for 100
  expect(balances['user1']).toBe(-100); // User's value only
});
