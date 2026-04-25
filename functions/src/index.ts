import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';

admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// GET /complaints/:id
app.get('/complaints/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const docRef = db.collection('complaints').doc(id);
    const doc = await docRef.get();
    if (!doc.exists) return res.status(404).json({ error: 'Complaint not found' });

    const data = doc.data() || {};
    const authorityUpdatesSnap = await docRef.collection('authorityUpdates').orderBy('timestamp', 'asc').get();
    const authorityUpdates: any[] = [];
    authorityUpdatesSnap.forEach(d => authorityUpdates.push({ id: d.id, ...d.data() }));

    const assignedOfficer = data.assignedOfficer || null;
    const currentStep = data.currentStep || data.status || null;

    return res.json({ complaint: data, currentStep, authorityUpdates, assignedOfficer });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal error' });
  }
});

// POST /quizResult
app.post('/quizResult', async (req, res) => {
  try {
    const { studentId, score, level, date } = req.body;
    if (!studentId || score === undefined) return res.status(400).json({ error: 'Missing fields' });

    const payload = {
      studentId,
      score: Number(score),
      level: level || null,
      date: date ? admin.firestore.Timestamp.fromDate(new Date(date)) : admin.firestore.FieldValue.serverTimestamp()
    } as any;

    const ref = await db.collection('quizResults').add(payload);

    // Optionally update aggregate stats on student doc
    const studentRef = db.collection('students').doc(studentId);
    await db.runTransaction(async t => {
      const snap = await t.get(studentRef);
      const prev = snap.exists ? snap.data() : {};
      const quizCount = (prev && prev.quizCount) ? prev.quizCount + 1 : 1;
      const lastScore = payload.score;
      t.set(studentRef, { quizCount, lastScore }, { merge: true });
    });

    return res.status(201).json({ id: ref.id });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal error' });
  }
});

// POST /counselingRequest
app.post('/counselingRequest', async (req, res) => {
  try {
    const { studentId, details } = req.body;
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });

    const payload = {
      studentId,
      details: details || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      status: 'pending'
    };

    const ref = await db.collection('counselingRequests').add(payload);
    return res.status(201).json({ id: ref.id });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal error' });
  }
});

// GET /progress/:studentId
app.get('/progress/:studentId', async (req, res) => {
  try {
    const studentId = req.params.studentId;
    if (!studentId) return res.status(400).json({ error: 'Missing studentId' });

    const quizSnap = await db.collection('quizResults').where('studentId', '==', studentId).get();
    const quizCount = quizSnap.size;
    const scores: number[] = [];
    quizSnap.forEach(d => { const data = d.data(); if (data.score !== undefined) scores.push(Number(data.score)); });

    const resourcesSnap = await db.collection('resourceReads').where('studentId', '==', studentId).get();
    const resourcesReadCount = resourcesSnap.size;

    // simple campus safety score: average quiz score (0-100) scaled to 0-100
    const campusSafetyScore = scores.length ? Math.round((scores.reduce((a,b)=>a+b,0)/scores.length)) : null;

    const badgesSnap = await db.collection('earnedBadges').where('studentId', '==', studentId).get();
    const badges: any[] = [];
    badgesSnap.forEach(d => badges.push({ id: d.id, ...d.data() }));

    const activitySnap = await db.collection('activityLogs').where('studentId', '==', studentId).orderBy('timestamp', 'desc').limit(20).get();
    const recentActivity: any[] = [];
    activitySnap.forEach(d => recentActivity.push({ id: d.id, ...d.data() }));

    return res.json({ quizCount, resourcesReadCount, campusSafetyScore, badges, recentActivity });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal error' });
  }
});

// health
app.get('/_health', (_req, res) => res.json({ ok: true }));

exports.api = functions.https.onRequest(app);
