Backend Firebase Functions for WE_255 app

API endpoints (HTTP, deployed as Firebase Functions behind `/api` or `api` exports):

1) GET /complaints/:id
- Description: Fetch complaint details by ID, current step/status, authority updates and assigned officer.
- Response: { complaint, currentStep, authorityUpdates: [...], assignedOfficer }

2) POST /quizResult
- Body: { studentId: string, score: number, level?: string, date?: ISOString }
- Description: Save quiz result; updates student aggregate stats.
- Response: { id: string }

3) POST /counselingRequest
- Body: { studentId: string, details?: string }
- Description: Save counseling request for admin review.
- Response: { id: string }

4) GET /progress/:studentId
- Description: Returns quiz count, resources read count, campusSafetyScore (avg score), earned badges and recent activity log.
- Response: { quizCount, resourcesReadCount, campusSafetyScore, badges: [...], recentActivity: [...] }

Firestore collections used (recommended):
- `complaints` (docs store fields: status/currentStep, assignedOfficer, ...)
  - subcollection `authorityUpdates` (timestamped updates with authority messages)
- `quizResults` (studentId, score, level, date)
- `students` (aggregate fields like quizCount, lastScore)
- `counselingRequests` (studentId, details, status, createdAt)
- `resourceReads` (studentId, resourceId, timestamp)
- `earnedBadges` (studentId, badgeId, earnedAt)
- `activityLogs` (studentId, type, details, timestamp)

Local testing and deploy

1) Install deps

```powershell
cd functions
npm install
```

2) Build

```powershell
npm run build
```

3) Emulate functions locally

```powershell
firebase emulators:start --only functions
```

Notes
- `admin.initializeApp()` uses the default service account on Firebase; for local testing configure `GOOGLE_APPLICATION_CREDENTIALS` or use Firebase emulators.
- Add proper input validation, authentication checks, and Firestore security rules before production.
