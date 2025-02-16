import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"
import {Group} from "../functions/src/models/Group"

// Test to retrieve balances correctly for a specified user

// Transaction: user1 pays 80 and user2 contributes 40
test('retrieves balance correctly for a specific user', () => {
  const transaction = new Transaction(
    { title: 'Lunch', timestamp: Date.now(), category: 'Food', storageURL: undefined },
    { userID: 'user1', value: 80 },
    { user2: { value: 40, isConfirmed: true } }
  );

  // Create a group and add the transaction
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Test Group',
    groupCode: 'ABC123',
    memberIDs: { user1: true, user2: true },
    currency: 'USD',
    transactions: { txn1: transaction }
  });

  expect(group.getBalanceForUser('user1')).toBe(-80); // User1 with balance of -80
  expect(group.getBalanceForUser('user2')).toBe(40); // User2 with balance of 40
  expect(group.getBalanceForUser('user3')).toBe(0); // Non-existent user3, so should be zero
});
