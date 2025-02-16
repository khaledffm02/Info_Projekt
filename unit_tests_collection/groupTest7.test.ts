import {test,expect} from "bun:test"
import {Transaction} from "../functions/src/models/Transaction"
import {Group} from "../functions/src/models/Group"

// Test to handle transactions with multiple zero values correctly

// Create a transaction where both users have contributed zero
test('handles transactions with zero values correctly', () => {
  const transaction = new Transaction(
    { title: 'Zero Transaction', timestamp: Date.now(), category: 'Misc', storageURL: undefined },
    { userID: 'user1', value: 0 }, // User1 pays 0
    { user2: { value: 0, isConfirmed: true } } // User2 pays 0
  );

  // Create a group and add the zero-value transactions
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Zero Group',
    groupCode: 'ZERO123',
    memberIDs: { user1: true, user2: true },
    currency: 'USD',
    transactions: { txn1: transaction }
  });

  const balances = group.getBalances();

  // Because no money was exchanged, balances should remain at 0
  expect(balances['user1']).toBe(0);
  expect(balances['user2']).toBe(0);
});
