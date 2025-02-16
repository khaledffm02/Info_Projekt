import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"


test('calculates balances correctly when all friends are unconfirmed', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 },
    { friend1: { value: 50, isConfirmed: false }, friend2: { value: 30, isConfirmed: false } }
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-20); // User's value + all unconfirmed values
});
