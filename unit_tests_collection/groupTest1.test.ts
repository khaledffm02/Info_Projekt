import {test,expect} from "bun:test"
import {Group} from "../functions/src/models/Group"

// Initialize a new group with 3 members
test('calculates member count correctly', () => {
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(), // Ensure timestamp is set correctly
    name: 'Test Group',
    groupCode: 'ABC123', // Unique group identifier
    memberIDs: { user1: true, user2: true, user3: true }, // Three members
    currency: 'USD',
    transactions: {}, // No transactions yet
  });

  // Expect member count to match the number of keys in memberIDs object
  expect(group.memberCount).toBe(3);
});
