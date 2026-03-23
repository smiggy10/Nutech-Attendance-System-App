# n8n: Summary report (date range) — workflow prompt for Claude / developers

The Flutter app calls:

```http
GET /webhook/admin/weekly-summary?start=YYYY-MM-DD&end=YYYY-MM-DD
```

Return JSON:

```json
{ "success": true, "data": { ... } }
```

On `success: false`, include `message`; the app shows it as an error. The app reads **`data`** for all fields below (legacy top-level-only payloads still work).

---

## Required fields in `data`

| Field | Type | Meaning |
|--------|------|--------|
| `start` | string | Same as query `start` (or `startDate`) |
| `end` | string | Same as query `end` (or `endDate`) |
| `totalEmployees` | int | Headcount in scope for the range (aliases: `employeeCount`, `totalStaff`) |
| `presentCount` | int | Total **present** instances (or people-days) in range (alias: `present`) |
| `lateCount` | int | Total **late** in range (alias: `late`) |
| `absentCount` | int | Total **absent** in range (alias: `absent`) |

These drive the **four tappable stat buttons**. They must be computed from your **database / Airtable** for all calendar days where `start <= date <= end` (use **Philippines business timezone** if needed).

---

## Period summary block (metrics)

Either send **`summaryRows`** **or** the dedicated numeric fields below.

### Option A — Custom rows

`summaryRows`: array of `{ "left": "Label", "right": "Value" }` (shown as-is).

### Option B — Structured metrics (recommended)

If `summaryRows` is **empty or omitted**, the app shows these four lines using your numbers:

| Field | Type | Shown as |
|--------|------|----------|
| `totalAttendanceLogs` | int | Total attendance logs (aliases: `attendanceLogCount`, `totalLogs`) |
| `totalHoursWorked` | number | Total hours worked (aliases: `hoursWorkedTotal`, `totalHours`) |
| `totalOvertimeHours` | number | Sum of **overtime hours in range** — typically hours worked **beyond 8.0** per day (e.g. 1.5 means 9.5h worked that day). Aliases: `overtimeHoursTotal`, `overtimeHours` |
| `missingTimeOutLogs` | int | Missing time-out / incomplete logs (aliases: `missingTimeOut`, `missingTimeoutCount`) |

All should be **sums across the date range** from the same source as daily attendance.

---

## Drill-down lists (same response, no extra call)

The four stat buttons open these arrays **only** (not the main attendance log `rows`).

| Array | Item shape | Notes |
|--------|------------|--------|
| `employeeRoster` | `{ fullName, userId }` | Total employees in scope |
| `presentEntries` | `{ fullName, userId, date }` | Present per day in range |
| `lateEntries` | `{ fullName, userId, date, lateBy, lateDescription? }` | `lateBy` = **integer minutes past 8:15 AM** cutoff (e.g. 25 ⇒ 8:40). `lateDescription` e.g. `"25 min late"` |
| `absentEntries` | `{ fullName, userId, date }` | **Roster employees with no attendance record that workday** — they will **not** appear in log rows; one row per employee per absent day |

### Profile photos (optional)

Drill-down list rows show a **circular avatar** when a URL is available. Use the same optional keys on roster or entry objects: `profileImageUrl`, `profilePicture`, `avatar`, `photo`, `imageUrl`, `picture`, `profilePhoto`, `avatarUrl`.

**Tip:** Put photos on **`employeeRoster`** items; the app will match by `userId` for **Present / Late / Absent** rows if those arrays omit the image field.

---

## Example `data` payload

```json
{
  "start": "2026-03-10",
  "end": "2026-03-20",
  "totalEmployees": 24,
  "presentCount": 180,
  "lateCount": 12,
  "absentCount": 8,
  "totalAttendanceLogs": 192,
  "totalHoursWorked": 1425.5,
  "totalOvertimeHours": 36.0,
  "missingTimeOutLogs": 3,
  "summaryRows": [],
  "employeeRoster": [],
  "presentEntries": [],
  "lateEntries": [],
  "absentEntries": []
}
```

---

## Task for the workflow

1. Webhook receives `start` and `end`.
2. Query attendance / employees for **every day** in that inclusive range.
3. Fill **`totalEmployees`**, **`presentCount`**, **`lateCount`**, **`absentCount`** from those queries.
4. Fill **`totalAttendanceLogs`**, **`totalHoursWorked`**, **`totalOvertimeHours`**, **`missingTimeOutLogs`** from log rows in the same range.
5. Optionally fill **`presentEntries`**, **`lateEntries`**, **`absentEntries`**, **`employeeRoster`** for drill-down screens.
6. Respond with HTTP 200 and JSON body `{ "data": { ... } }` or top-level fields matching the above.

If counts are all **0** and arrays empty, the app still loads but shows a banner that n8n may not be connected to real data.

---

_End of document._
