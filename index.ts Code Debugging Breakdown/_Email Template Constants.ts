export const EMAIL_TEMPLATES = {
    PASSWORD_RESET: (newPassword: string) =>
      `<b>Your new password is ${newPassword}</b>`,
    PAYMENT_RECEIVED: (name: string, amount: number) =>
      `<b>You have received a payment from ${name} of ${amount} EUR.</b>`,
    BALANCE_REMINDER: (name: string, groupName: string, balance: number, currency: string) =>
      `<b>Hi ${name}, you have open payments to take action on in your group "${groupName}". Open: ${balance} ${currency} EUR</b>`,
    INVITATION: (groupName: string, groupCode: string) =>
      `<b>Hello, you have been invited to join the group "${groupName}". Please enter the invitation code ${groupCode} in the app to join.</b>`,
  };
  