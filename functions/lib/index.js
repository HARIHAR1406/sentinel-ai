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
Object.defineProperty(exports, "__esModule", { value: true });
exports.onIncidentVerified = exports.analyzeIncident = exports.moderateIncident = exports.getSafeRoutes = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const params_1 = require("firebase-functions/params");
const google_maps_services_js_1 = require("@googlemaps/google-maps-services-js");
const genai_1 = require("@google/genai");
admin.initializeApp();
const db = admin.firestore();
// Securely define the API key parameters.
const directionsApiKey = (0, params_1.defineString)("DIRECTIONS_API_KEY");
const geminiApiKey = (0, params_1.defineString)("GEMINI_API_KEY");
const googleMapsClient = new google_maps_services_js_1.Client({});
/**
 * Decodes a Google Maps encoded polyline into a list of { lat, lng } coordinates.
 */
function decodePolyline(encoded) {
    if (!encoded)
        return [];
    const poly = [];
    let index = 0, len = encoded.length;
    let lat = 0, lng = 0;
    while (index < len) {
        let b, shift = 0, result = 0;
        do {
            b = encoded.charCodeAt(index++) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        const dlat = result & 1 ? ~(result >> 1) : result >> 1;
        lat += dlat;
        shift = 0, result = 0;
        do {
            b = encoded.charCodeAt(index++) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        const dlng = result & 1 ? ~(result >> 1) : result >> 1;
        lng += dlng;
        poly.push({ lat: lat / 1e5, lng: lng / 1e5 });
    }
    return poly;
}
exports.getSafeRoutes = (0, https_1.onCall)(async (request) => {
    const { origin, destination } = request.data;
    // 1. Validate Input
    if (!origin || typeof origin.latitude !== "number" || typeof origin.longitude !== "number") {
        throw new https_1.HttpsError("invalid-argument", "Missing or invalid origin coordinates.");
    }
    if (!destination || typeof destination.latitude !== "number" || typeof destination.longitude !== "number") {
        throw new https_1.HttpsError("invalid-argument", "Missing or invalid destination coordinates.");
    }
    // 2. Prepare Google Maps Request
    try {
        const response = await googleMapsClient.directions({
            params: {
                origin: [origin.latitude, origin.longitude],
                destination: [destination.latitude, destination.longitude],
                alternatives: true,
                mode: google_maps_services_js_1.TravelMode.driving,
                key: directionsApiKey.value(),
            },
            timeout: 10000,
        });
        if (response.data.status !== "OK") {
            logger.error("Google Maps API Error", response.data.error_message || response.data.status);
            if (response.data.status === "ZERO_RESULTS") {
                return { routes: [] };
            }
            throw new https_1.HttpsError("internal", `Route API Error: ${response.data.status}`);
        }
        // 3. Normalize Response
        const routes = response.data.routes.map((r, index) => {
            const leg = r.legs[0];
            const polylinePoints = decodePolyline(r.overview_polyline.points);
            return {
                id: `route_${index}_${Date.now()}`,
                distanceMeters: leg.distance.value,
                durationSeconds: leg.duration.value,
                routeName: r.summary || `Route ${index + 1}`,
                polylinePoints: polylinePoints,
                startLocation: {
                    lat: leg.start_location.lat,
                    lng: leg.start_location.lng,
                },
                endLocation: {
                    lat: leg.end_location.lat,
                    lng: leg.end_location.lng,
                },
            };
        });
        return { routes };
    }
    catch (error) {
        logger.error("Error fetching routes:", error);
        if (error instanceof https_1.HttpsError)
            throw error;
        throw new https_1.HttpsError("internal", "Failed to retrieve routes due to a backend error.");
    }
});
/**
 * moderateIncident: Securely perform admin actions on incidents
 */
exports.moderateIncident = (0, https_1.onCall)(async (request) => {
    var _a;
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required to moderate incidents.");
    }
    // Verify Admin Claim (RBAC). If running locally, we can mock or enforce it via claims.
    // For Sentinel AI, checking if role == 'admin' in users collection.
    const userDoc = await db.collection("users").doc(request.auth.uid).get();
    if (!userDoc.exists || ((_a = userDoc.data()) === null || _a === void 0 ? void 0 : _a.role) !== "admin") {
        throw new https_1.HttpsError("permission-denied", "You do not have administrative privileges.");
    }
    const { incidentId, action, reason, duplicateOf } = request.data;
    if (!incidentId || !action) {
        throw new https_1.HttpsError("invalid-argument", "Missing incidentId or action.");
    }
    const incidentRef = db.collection("incidents").doc(incidentId);
    const incidentSnap = await incidentRef.get();
    if (!incidentSnap.exists) {
        throw new https_1.HttpsError("not-found", "Incident not found.");
    }
    const updateData = {
        verifiedBy: request.auth.uid,
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    switch (action) {
        case "verify":
            updateData.verificationStatus = "verified";
            updateData.status = "verified";
            break;
        case "reject":
            updateData.verificationStatus = "rejected";
            updateData.status = "rejected";
            if (reason)
                updateData.rejectionReason = reason;
            break;
        case "duplicate":
            updateData.verificationStatus = "duplicate";
            updateData.status = "rejected";
            updateData.isDuplicate = true;
            if (duplicateOf)
                updateData.duplicateOf = duplicateOf;
            break;
        default:
            throw new https_1.HttpsError("invalid-argument", "Invalid moderation action.");
    }
    await incidentRef.update(updateData);
    return { success: true, incidentId, action };
});
/**
 * analyzeIncident: Calls Gemini to analyze the incident
 */
exports.analyzeIncident = (0, https_1.onCall)(async (request) => {
    const { title, description, category, existingIncidents } = request.data;
    if (!title || !description || !category) {
        throw new https_1.HttpsError("invalid-argument", "Title, description, and category are required.");
    }
    try {
        const apiKey = geminiApiKey.value();
        if (!apiKey) {
            throw new Error("GEMINI_API_KEY is not configured.");
        }
        const ai = new genai_1.GoogleGenAI({ apiKey: apiKey });
        const responseSchema = {
            type: genai_1.Type.OBJECT,
            properties: {
                category: { type: genai_1.Type.STRING },
                subCategory: { type: genai_1.Type.STRING },
                severity: { type: genai_1.Type.STRING, enum: ["low", "medium", "high", "critical"] },
                priority: { type: genai_1.Type.STRING, enum: ["low", "normal", "high", "urgent"] },
                riskLevel: { type: genai_1.Type.INTEGER },
                confidence: { type: genai_1.Type.NUMBER },
                summary: { type: genai_1.Type.STRING },
                duplicateStatus: { type: genai_1.Type.STRING, enum: ["UNIQUE", "POSSIBLY_DUPLICATE", "LIKELY_DUPLICATE"] },
            },
            required: ["category", "subCategory", "severity", "priority", "riskLevel", "confidence", "summary", "duplicateStatus"],
        };
        let existingContext = "";
        if (existingIncidents && existingIncidents.length > 0) {
            existingContext = `\nCompare this against recent incidents to detect duplicates: ${JSON.stringify(existingIncidents)}`;
        }
        const prompt = `Analyze this public safety incident report.
Title: ${title}
Description: ${description}
User-Selected Category: ${category}
${existingContext}
Output a structured analysis JSON.`;
        const response = await ai.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: prompt,
            config: {
                responseMimeType: "application/json",
                responseSchema: responseSchema,
            }
        });
        if (!response.text) {
            throw new Error("Empty response from AI");
        }
        return JSON.parse(response.text);
    }
    catch (error) {
        logger.error("AI Analysis Error:", error);
        // Return a safe fallback instead of throwing an HttpsError so the client can proceed
        return {
            category: category,
            subCategory: "General",
            severity: "medium",
            priority: "normal",
            riskLevel: 3,
            confidence: 0.5,
            summary: "AI Analysis unavailable due to backend error. Human review required.",
            duplicateStatus: "UNIQUE"
        };
    }
});
/**
 * onIncidentVerified: Trigger FCM notifications when an incident is verified
 */
exports.onIncidentVerified = (0, firestore_1.onDocumentUpdated)("incidents/{incidentId}", async (event) => {
    var _a, _b;
    const newValue = (_a = event.data) === null || _a === void 0 ? void 0 : _a.after.data();
    const previousValue = (_b = event.data) === null || _b === void 0 ? void 0 : _b.before.data();
    if (!newValue || !previousValue)
        return;
    // Only trigger if verificationStatus changed to 'verified'
    if (newValue.verificationStatus === "verified" && previousValue.verificationStatus !== "verified") {
        const incidentId = event.params.incidentId;
        logger.info(`Incident ${incidentId} verified. Triggering notifications.`);
        try {
            // In a real app with GeoFire, we would query users nearby.
            // For Sentinel AI scope, we fetch users with 'incidentAlertsEnabled' preference.
            const usersSnap = await db.collection("users").get();
            const tokens = [];
            const notificationsBatch = db.batch();
            const now = admin.firestore.FieldValue.serverTimestamp();
            for (const userDoc of usersSnap.docs) {
                const userData = userDoc.data();
                const preferences = userData.preferences || {};
                if (preferences.incidentAlertsEnabled !== false) {
                    // Add notification document
                    const notifRef = userDoc.ref.collection("notifications").doc();
                    notificationsBatch.set(notifRef, {
                        id: notifRef.id,
                        title: `Verified Incident: ${newValue.title}`,
                        message: newValue.description,
                        type: "incident_alert",
                        createdAt: now,
                        read: false,
                        data: { incidentId }
                    });
                    // Get user device tokens
                    const tokensSnap = await userDoc.ref.collection("device_tokens").where("enabled", "==", true).get();
                    tokensSnap.forEach(t => {
                        if (t.data().token) {
                            tokens.push(t.data().token);
                        }
                    });
                }
            }
            await notificationsBatch.commit();
            logger.info(`Created notification records for ${usersSnap.size} users.`);
            if (tokens.length > 0) {
                const payload = {
                    notification: {
                        title: `Verified Alert: ${newValue.title}`,
                        body: newValue.description,
                    },
                    data: {
                        incidentId: incidentId,
                        type: "incident_alert"
                    },
                    tokens: tokens
                };
                const response = await admin.messaging().sendEachForMulticast(payload);
                logger.info(`FCM payload sent. Success count: ${response.successCount}, Failure count: ${response.failureCount}`);
            }
        }
        catch (error) {
            logger.error("Error in onIncidentVerified trigger:", error);
        }
    }
});
//# sourceMappingURL=index.js.map