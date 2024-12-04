type MetaData = {
  title: string;
  timestamp: number;
  category: string;
  storageURL: string | undefined;
};
type Spending = {
  userID: string;
  value: number;
};

export class Transaction {
  constructor(
    readonly meta: MetaData,
    readonly user: Spending,
    readonly friends: Record<string, {value: number, isConfirmed: boolean}>
  ) {}
}

export function transactionToJson(transaction: Transaction) {
  return {
    meta: transaction.meta,
    user: transaction.user,
    friends: transaction.friends,
  };
}

export function transactionFromJson(json: any) {
  return new Transaction(json.meta, json.user, json.friends);
}
