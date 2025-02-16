import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"


test('calculates balances correctly when all friends are confirmed', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 },
    { friend1: { value: 50, isConfirmed: true }, friend2: { value: 30, isConfirmed: true } }
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-100); // User's value only
  expect(balances['friend1']).toBe(50); // Confirmed friend's value
  expect(balances['friend2']).toBe(30); // Confirmed friend's value
});
