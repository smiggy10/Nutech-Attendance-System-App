# Claude / n8n prompt: Daily attendance drill-down arrays

Copy everything below the line into Claude (or your n8n assistant) to adjust the workflow.

---

## Context

The Flutter admin app calls:

`GET /webhook/admin/daily-attendance?date=YYYY-MM-DD`

The JSON body should wrap the payload in a `data` object (the app already supports that). The app shows **Present**, **Late**, **Absent**, and **Overtime** counts and a main `rows` table. Tapping each stat opens a **drill-down list** for that category using the **same response** (no extra API call).

## Required (existing) fields in `data`

- `date` — string `YYYY-MM-DD` (same as query)
- `present`, `late`, `absent`, `overtime` — integers (counts)
- `rows` — array of attendance rows for the table, each with at least:
  - `employee` (or `fullName` in drill-down arrays)
  - `userId`
  - `timeIn`, `timeOut` — ISO 8601 strings (UTC or with offset; app displays **Asia/Manila PHT**)
  - `hours` — number
  - `status` — string (e.g. on-time, late, absent, overtime) — used as **fallback** to split lists if optional arrays are missing

### Profile photos (optional)

The app shows a **circular avatar** on each drill-down list row. You may include a public image URL on any row object using one of these keys (first non-empty wins): `profileImageUrl`, `profilePicture`, `avatar`, `photo`, `imageUrl`, `picture`, `profilePhoto`, `avatarUrl`.

- Put the same field on **`rows`** items so absent-only lists can still resolve the photo by matching `userId` to a row when possible.
- Or put it on each object in `presentEntries`, `lateEntries`, `absentEntries`, `overtimeEntries`.

## New optional arrays (recommended for accuracy)

Add these **inside `data`** next to `rows`:

### 1. `presentEntries`

Employees counted as **present** for that `date`.

Each item:

```json
{
  "fullName": "JUAN DELA CRUZ",
  "userId": "EMP001",
  "timeIn": "2025-03-17T01:00:00.000Z",
  "timeOut": "2025-03-17T09:30:00.000Z",
  "hours": 8.5
}
```

- `fullName` (or `employee` / `name`)
- `userId`
- `timeIn`, `timeOut` optional strings
- `hours` optional number

### 2. `lateEntries`

Each item:

```json
{
  "fullName": "JUAN DELA CRUZ",
  "userId": "EMP001",
  "timeIn": "2025-03-17T01:15:00.000Z",
  "timeOut": "2025-03-17T09:00:00.000Z",
  "lateBy": 15,
  "lateDescription": "15 min late"
}
```

- `lateBy` — **integer minutes late** (optional if `lateDescription` is set)
- `lateDescription` — human-readable (optional if `lateBy` is set; app can show `"N min late"` from `lateBy`)

### 3. `absentEntries`

**Important:** Absent employees often **do not** appear in `rows`. This array should list everyone **absent** that day.

Each item:

```json
{
  "fullName": "JUAN DELA CRUZ",
  "userId": "EMP001"
}
```

### 4. `overtimeEntries`

Each item:

```json
{
  "fullName": "JUAN DELA CRUZ",
  "userId": "EMP001",
  "timeIn": "2025-03-17T01:00:00.000Z",
  "timeOut": "2025-03-17T11:00:00.000Z",
  "hours": 10.0,
  "overtimeHours": 2.0
}
```

(`hours` and/or `overtimeHours` optional; app shows `hours` when present.)

## Fallback behavior (if arrays omitted)

If `presentEntries`, `lateEntries`, `absentEntries`, and `overtimeEntries` are **empty or missing**, the app **derives** lists by filtering `rows` using `status` (case-insensitive):

- **Late:** status contains `"late"` or `"missed"`
- **Absent:** status contains `"absent"`
- **Overtime:** status contains `"overtime"`
- **Present:** everyone else in `rows` (not late / absent / overtime)

So **true absences** must be in `absentEntries` if they are not in `rows`.

## Task for the workflow

1. Keep the existing webhook path and query param `date`.
2. Ensure `data` includes accurate counts `present`, `late`, `absent`, `overtime` aligned with the lists.
3. Populate `presentEntries`, `lateEntries`, `absentEntries`, and `overtimeEntries` from your attendance source (Airtable / DB) for the requested calendar date in **Philippines (PHT)** business logic.
4. Use ISO 8601 for all `timeIn` / `timeOut` values (prefer UTC with `Z` or explicit offset).
5. Return empty arrays `[]` when a category has no people.

---

_End of prompt._
