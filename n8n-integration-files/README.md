# n8n Webhook Integration — File Reference

This folder lists and contains **reference copies** of all app files used for webhooking to n8n (registration, OTP verification, and login). Use these when you need to paste relevant code into chat or share with n8n workflow setup.

**Source of truth:** the real implementation lives under `lib/`. These copies are for reference only and may go out of date.

---

## File list

| File | Path in project | Purpose |
|------|-----------------|--------|
| **Registration (signup) screen** | `lib/screens/auth/signup_screen.dart` | Collects full name, email, address, contact number, birthdate, profile photo; on "Continue" passes data to password screen (no webhook here). |
| **Register password screen** | `lib/screens/auth/register_password_screen.dart` | After user sets password, calls **n8n register webhook** with `fullName`, `email`, `address`, `contactNumber`, `birthdate`, `password`; on success navigates to OTP screen. |
| **OTP (verify email) screen** | `lib/screens/auth/verify_email_screen.dart` | User enters 4-digit OTP; calls **n8n verify OTP webhook** with `email` and `otp`; on success redirects to login. |
| **Login screen** | `lib/screens/auth/login_screen.dart` | User ID + password; calls **n8n login webhook** with `userId` and `password`; on success navigates to home. |
| **n8n API / webhook URLs** | `lib/services/n8n_api.dart` | Base URL, webhook paths, and `N8nApi` methods: `registerUser()`, `verifyOtp()`, `login()`. |

---

## Webhook endpoints (from `n8n_api.dart`)

- **Register:** `POST {baseUrl}/webhook/register/user`  
  Body: `fullName`, `email`, `address`, `contactNumber`, `birthdate`, `password` (optional: `profileImage`).

- **Verify OTP:** `POST {baseUrl}/webhook/verify/otp`  
  Body: `email`, `otp`.

- **Login:** `POST {baseUrl}/webhook/login/user`  
  Body: `userId`, `password`.

Base URL default: `http://localhost:5678` (override with Dart define `N8N_BASE_URL`).

---

## Contents of this folder

- `README.md` — this file (list + endpoints).
- `signup_screen.dart` — registration form screen (reference copy).
- `register_password_screen.dart` — password step + register webhook call (reference copy).
- `verify_email_screen.dart` — OTP entry + verify OTP webhook call (reference copy).
- `login_screen.dart` — login form + login webhook call (reference copy).
- `n8n_api.dart` — webhook base URL, paths, and API helpers (reference copy).

For the latest code, always refer to the paths under `lib/` in the project root.
