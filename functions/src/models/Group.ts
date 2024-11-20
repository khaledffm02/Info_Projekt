export type GroupJSON = {
    creatorID: string
    creationTimestamp: number
    groupCode: string
    memberIDs: Record<string, boolean>
    currency: string
}

export class Group {
  constructor(readonly id: string, readonly data: GroupJSON) {}

  getBalanceForUser(userID: string): number {
    console.log(userID);
    return 0;
  }
}
