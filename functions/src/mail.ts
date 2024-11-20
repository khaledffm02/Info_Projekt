import * as functions from "firebase-functions";
// Account authorization over FIREBASE ENV
// CLI: firebase functions:config:set gmail.account="xxx" gmail.password="xxx"
// https://firebase.google.com/docs/functions/config-env
import * as nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: functions.config().gmail.account,
    pass: functions.config().gmail.password,
  },
});

/**
 * Sends an email using the specified options.
 * @param {Object} options - The email options.
 * @param {string} options.from - The sender's email address.
 * @param {string} options.to - The recipient's email address.
 * @param {string} options.subject - The subject of the email.
 * @param {string} options.text - The plain text body of the email.
 * @param {string} options.html - The HTML body of the email.
 * @return {Promise<string>} - A promise that resolves to the message ID.
 */
export async function sendMail(options: {
  from: string;
  to: string;
  subject: string;
  text: string;
  html: string;
}) {
  return new Promise((res, rej) => {
    // send mail with defined transport object
    transporter.sendMail(options, (error, info) => {
      if (error) {
        rej(error);
        return;
      }
      res(info.messageId);
    });
  });
}
