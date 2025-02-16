# BACKEND (Fairshare)
Welcome to the Fairshare Backend Branch!

This TypeScript backend consists of:
- 24 Endpoints (General_Endpoint_Information for more information)
- A collection unit tests used in the production (unit_tests_collection)
- Code isolations for debugging and comments
- Log of Bugs/Issues

# Features include:
- Cloud Function endpoint in Google Cloud for scalebility to potentially millions of users
- Endpoints authenticate, authorize, validate and manipulate the data
- Sanity checks and strong expression error messages help debug potential bugs or help identify API misuse
- Cloud error logging enables tracing a user journey (or if privacy concerns kick in here, error debugging)
- Backend is e-mail sender and composes customized e-mail messages
- Secured handling of user passwords and API keys

The most crucial code can be found using the following paths:
functions -> src -> index.ts
functions -> src -> managers -> GroupManager.ts
