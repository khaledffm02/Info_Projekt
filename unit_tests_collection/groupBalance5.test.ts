import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"

// Test when all friends confirm their shares

test('calculates balances correctly when all friends are confirmed', () => {
  const transaction = new Transaction(
    { title: 'Test Transaction', timestamp: Date.now(), category: 'Test', storageURL: undefined },
    { userID: 'user1', value: 100 }, // Main user starts with 100 payment
    { friend1: { value: 50, isConfirmed: true },// Confirmed friend1 pays 50 
    friend2: { value: 30, isConfirmed: true } } // Confirmed friend2 pays 30
  );

  const balances = transaction.getUserBalances();

  expect(balances['user1']).toBe(-100); // User's value only
  expect(balances['friend1']).toBe(50); // Confirmed friend1 value of 50
  expect(balances['friend2']).toBe(30); // Confirmed friend2 value of 30
});
