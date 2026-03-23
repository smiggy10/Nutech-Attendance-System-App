# Claude prompt: Add profile photos to daily / summary attendance webhooks (Airtable)

Copy the block below into Claude when you want **one request** to return names + photos (instead of the app calling `user/profile` per employee).

---

## Prompt for Claude

```
Our Flutter admin app reads two n8n webhooks:

1) GET /webhook/admin/daily-attendance?date=YYYY-MM-DD — JSON under `data` with `rows`, and optional `presentEntries`, `lateEntries`, `absentEntries`, `overtimeEntries`.

2) GET /webhook/admin/weekly-summary?start=…&end=… — JSON under `data` with `employeeRoster`, `presentEntries`, `lateEntries`, `absentEntries`.

Each person row already has at least `userId` and `fullName` (or `employee`). We use Airtable as the source of truth for employees. There is a field for the profile photo — typically either:
- a public HTTPS URL string, OR
- an Airtable attachment (first attachment’s `url`).

Task:
1. In BOTH workflows, when building any array item that represents one employee, add a string field `profileImageUrl` with a **direct, publicly reachable image URL** (same value the app already expects on GET /webhook/user/profile in `data.profileImageUrl`).
2. Join employees by stable key: match webhook `userId` to the Airtable employee record (same identifier the profile webhook uses).
3. If there is no photo, omit `profileImageUrl` or send an empty string — the app will fall back to a placeholder or profile API.

Do not break existing fields; only add `profileImageUrl` (or reuse our existing alternate keys: profilePicture, avatar, photo, imageUrl if already documented).

Return the updated n8n node configuration steps (which nodes to change, formula / expression examples for Airtable lookup and attachment URL).
```

---

## Note

The Flutter app uses `profileImageUrl` from each webhook row **directly** (no extra call). It only calls `GET /webhook/user/profile?identifier=<userId>` when that field is empty or missing, then falls back to the placeholder avatar.
