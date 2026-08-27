import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";
import { Client, TravelMode } from "@googlemaps/google-maps-services-js";
import { GoogleGenAI, Type, Schema } from "@google/genai";

admin.initializeApp();
const db = admin.firestore();

// Securely define the API key parameters.
const directionsApiKey = defineString("DIRECTIONS_API_KEY");
const geminiApiKey = defineString("GEMINI_API_KEY");

const googleMapsClient = new Client({});

/**
 * Decodes a Google Maps encoded polyline into a list of { lat, lng } coordinates.
 */
function decodePolyline(encoded: string): { lat: number; lng: number }[] {
  if (!encoded) return [];
  const poly: { lat: number; lng: number }[] = [];
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

export const getSafeRoutes = onCall(async (request) => {
  const { origin, destination } = request.data;

  // 1. Validate Input
  if (!origin || typeof origin.latitude !== "number" || typeof origin.longitude !== "number") {
    throw new HttpsError("invalid-argument", "Missing or invalid origin coordinates.");
  }
  if (!destination || typeof destination.latitude !== "number" || typeof destination.longitude !== "number") {
    throw new HttpsError("invalid-argument", "Missing or invalid destination coordinates.");
  }

  // 2. Prepare Google Maps Request
  try {
    const response = await googleMapsClient.directions({
      params: {
        origin: [origin.latitude, origin.longitude],
        destination: [destination.latitude, destination.longitude],
        alternatives: true,
        mode: TravelMode.driving,
        key: directionsApiKey.value(),
      },
      timeout: 10000,
    });

    if (response.data.status !== "OK") {
      logger.error("Google Maps API Error", response.data.error_message || response.data.status);
      if (response.data.status === "ZERO_RESULTS") {
        return { routes: [] };
      }
      throw new HttpsError("internal", `Route API Error: ${response.data.status}`);
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
  } catch (error: any) {
    logger.error("Error fetching routes:", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", "Failed to retrieve routes due to a backend error.");
  }
});

/**
 * moderateIncident: Securely perform admin actions on incidents
 */
export const moderateIncident = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required to moderate incidents.");
  }
  
  // Verify Admin Claim (RBAC). If running locally, we can mock or enforce it via claims.
  // For Sentinel AI, checking if role == 'admin' in users collection.
  const userDoc = await db.collection("users").doc(request.auth.uid).get();
  if (!userDoc.exists || userDoc.data()?.role !== "admin") {
    throw new HttpsError("permission-denied", "You do not have administrative privileges.");
  }

  const { incidentId, action, reason, duplicateOf } = request.data;
  if (!incidentId || !action) {
    throw new HttpsError("invalid-argument", "Missing incidentId or action.");
  }

  const incidentRef = db.collection("incidents").doc(incidentId);
  const incidentSnap = await incidentRef.get();
  if (!incidentSnap.exists) {
    throw new HttpsError("not-found", "Incident not found.");
  }

  const updateData: any = {
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
      if (reason) updateData.rejectionReason = reason;
      break;
    case "duplicate":
      updateData.verificationStatus = "duplicate";
      updateData.status = "rejected";
      updateData.isDuplicate = true;
      if (duplicateOf) updateData.duplicateOf = duplicateOf;
      break;
    default:
      throw new HttpsError("invalid-argument", "Invalid moderation action.");
  }

  await incidentRef.update(updateData);
  return { success: true, incidentId, action };
});

/**
 * analyzeIncident: Calls Gemini to analyze the incident
 */
export const analyzeIncident = onCall(async (request) => {
  const { title, description, category, existingIncidents } = request.data;
  
  if (!title || !description || !category) {
    throw new HttpsError("invalid-argument", "Title, description, and category are required.");
  }

  try {
    const apiKey = geminiApiKey.value();
    if (!apiKey) {
      throw new Error("GEMINI_API_KEY is not configured.");
    }
    
    const ai = new GoogleGenAI({ apiKey: apiKey });
    const responseSchema: Schema = {
      type: Type.OBJECT,
      properties: {
        category: { type: Type.STRING },
        subCategory: { type: Type.STRING },
        severity: { type: Type.STRING, enum: ["low", "medium", "high", "critical"] },
        priority: { type: Type.STRING, enum: ["low", "normal", "high", "urgent"] },
        riskLevel: { type: Type.INTEGER },
        confidence: { type: Type.NUMBER },
        summary: { type: Type.STRING },
        duplicateStatus: { type: Type.STRING, enum: ["UNIQUE", "POSSIBLY_DUPLICATE", "LIKELY_DUPLICATE"] },
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
  } catch (error: any) {
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
export const onIncidentVerified = onDocumentUpdated("incidents/{incidentId}", async (event) => {
  const newValue = event.data?.after.data();
  const previousValue = event.data?.before.data();
  
  if (!newValue || !previousValue) return;

  // Only trigger if verificationStatus changed to 'verified'
  if (newValue.verificationStatus === "verified" && previousValue.verificationStatus !== "verified") {
    const incidentId = event.params.incidentId;
    logger.info(`Incident ${incidentId} verified. Triggering notifications.`);

    try {
      // In a real app with GeoFire, we would query users nearby.
      // For Sentinel AI scope, we fetch users with 'incidentAlertsEnabled' preference.
      const usersSnap = await db.collection("users").get();
      
      const tokens: string[] = [];
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
    } catch (error) {
      logger.error("Error in onIncidentVerified trigger:", error);
    }
  }
});
