import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test when no friend confirms their amount

test('calculates balances correctly when all friends are unconfirmed', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 }, // Main user starts with paying 100
    { friend1: { value: 50, isConfirmed: false }, // Friend1, not confirmed for 50
    friend2: { value: 30, isConfirmed: false } } // Friend2, not confirmed for 30
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-20); // User's value + all unconfirmed values
});
