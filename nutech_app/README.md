# nutech_app

A new Flutter project.

## n8n webhook integration

The app talks to n8n via HTTP webhooks. Configure the n8n base URL with:

- **Build:** `flutter run --dart-define=N8N_BASE_URL=https://your-n8n.com`
- **Default:** `http://localhost:5678`

### Webhook paths (append to base URL)

| Path | Method | Purpose |
|------|--------|---------|
| `/webhook/register/user` | POST | User registration (fullName, email, contactNumber, address, birthdate) |
| `/webhook/verify/otp` | POST | OTP verification (email, otp) |
| `/webhook/login/user` | POST | User login (userId, password) |

### Workflow JSON

- **`n8n_workflow_webhooks.json`** (in this folder) is an n8n workflow you can import. It uses:
  - **Register:** Webhook → duplicate check → generate OTP (stored in workflow static data) → create Airtable records → send OTP email → respond.
  - **Verify OTP:** Webhook → validate OTP from workflow store (no Airtable OTP table) → respond.
  - **Login:** Webhook → lookup user in Airtable → validate password (e.g. `test123`) → respond.

Import the JSON in n8n, set your Airtable and Gmail credentials, then activate the workflow. Use the production webhook URLs in the app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
