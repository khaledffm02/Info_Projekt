import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test that confirms friends' balances are correctly calculated

test('calculates balances correctly for confirmed friends', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 }, //Main user initiates 100
    { friend1: { value: 50, isConfirmed: true }, // Confirmed friend contributes 50
    friend2: { value: 30, isConfirmed: false } } // Unconfirmed friend contributes 30
  );

  const balances = transaction.getUserBalances();

  expect(balances['friend1']).toBe(50); // Confirmed friend's value
});
