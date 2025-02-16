import {test,expect} from "bun:test"
import {Group} from "../functions/src/models/Group"


test('calculates member count correctly', () => {
  const group = new Group('group1', {
    creatorID: 'user1',
    creationTimestamp: Date.now(),
    name: 'Test Group',
    groupCode: 'ABC123',
    memberIDs: { user1: true, user2: true, user3: true },
    currency: 'USD',
    transactions: {},
  });

  expect(group.memberCount).toBe(3);
});
