"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
admin.initializeApp();
const db = admin.firestore();
const app = (0, express_1.default)();
app.use((0, cors_1.default)({ origin: true }));
app.use(express_1.default.json());
// GET /complaints/:id
app.get('/complaints/:id', async (req, res) => {
    try {
        const id = req.params.id;
        const docRef = db.collection('complaints').doc(id);
        const doc = await docRef.get();
        if (!doc.exists)
            return res.status(404).json({ error: 'Complaint not found' });
        const data = doc.data() || {};
        const authorityUpdatesSnap = await docRef.collection('authorityUpdates').orderBy('timestamp', 'asc').get();
        const authorityUpdates = [];
        authorityUpdatesSnap.forEach(d => authorityUpdates.push({ id: d.id, ...d.data() }));
        const assignedOfficer = data.assignedOfficer || null;
        const currentStep = data.currentStep || data.status || null;
        return res.json({ complaint: data, currentStep, authorityUpdates, assignedOfficer });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal error' });
    }
});
// POST /quizResult
app.post('/quizResult', async (req, res) => {
    try {
        const { studentId, score, level, date } = req.body;
        if (!studentId || score === undefined)
            return res.status(400).json({ error: 'Missing fields' });
        const payload = {
            studentId,
            score: Number(score),
            level: level || null,
            date: date ? admin.firestore.Timestamp.fromDate(new Date(date)) : admin.firestore.FieldValue.serverTimestamp()
        };
        const ref = await db.collection('quizResults').add(payload);
        // Optionally update aggregate stats on student doc
        const studentRef = db.collection('students').doc(studentId);
        await db.runTransaction(async (t) => {
            const snap = await t.get(studentRef);
            const prev = snap.exists ? snap.data() : {};
            const quizCount = (prev && prev.quizCount) ? prev.quizCount + 1 : 1;
            const lastScore = payload.score;
            t.set(studentRef, { quizCount, lastScore }, { merge: true });
        });
        return res.status(201).json({ id: ref.id });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal error' });
    }
});
// POST /counselingRequest
app.post('/counselingRequest', async (req, res) => {
    try {
        const { studentId, details } = req.body;
        if (!studentId)
            return res.status(400).json({ error: 'Missing studentId' });
        const payload = {
            studentId,
            details: details || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            status: 'pending'
        };
        const ref = await db.collection('counselingRequests').add(payload);
        return res.status(201).json({ id: ref.id });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal error' });
    }
});
// GET /progress/:studentId
app.get('/progress/:studentId', async (req, res) => {
    try {
        const studentId = req.params.studentId;
        if (!studentId)
            return res.status(400).json({ error: 'Missing studentId' });
        const quizSnap = await db.collection('quizResults').where('studentId', '==', studentId).get();
        const quizCount = quizSnap.size;
        const scores = [];
        quizSnap.forEach(d => { const data = d.data(); if (data.score !== undefined)
            scores.push(Number(data.score)); });
        const resourcesSnap = await db.collection('resourceReads').where('studentId', '==', studentId).get();
        const resourcesReadCount = resourcesSnap.size;
        // simple campus safety score: average quiz score (0-100) scaled to 0-100
        const campusSafetyScore = scores.length ? Math.round((scores.reduce((a, b) => a + b, 0) / scores.length)) : null;
        const badgesSnap = await db.collection('earnedBadges').where('studentId', '==', studentId).get();
        const badges = [];
        badgesSnap.forEach(d => badges.push({ id: d.id, ...d.data() }));
        const activitySnap = await db.collection('activityLogs').where('studentId', '==', studentId).orderBy('timestamp', 'desc').limit(20).get();
        const recentActivity = [];
        activitySnap.forEach(d => recentActivity.push({ id: d.id, ...d.data() }));
        return res.json({ quizCount, resourcesReadCount, campusSafetyScore, badges, recentActivity });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal error' });
    }
});
// health
app.get('/_health', (_req, res) => res.json({ ok: true }));
exports.api = functions.https.onRequest(app);
//# sourceMappingURL=index.js.map