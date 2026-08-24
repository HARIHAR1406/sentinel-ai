import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";
import { Client, TravelMode } from "@googlemaps/google-maps-services-js";

// Securely define the API key parameter.
// In production, this requires running: firebase functions:secrets:set DIRECTIONS_API_KEY
const directionsApiKey = defineString("DIRECTIONS_API_KEY");

const googleMapsClient = new Client({});

/**
 * Decodes a Google Maps encoded polyline into a list of { lat, lng } coordinates.
 */
function decodePolyline(encoded: string): { lat: number; lng: number }[] {
  if (!encoded) return [];
  const poly: { lat: number; lng: number }[] = [];
  let index = 0,
    len = encoded.length;
  let lat = 0,
    lng = 0;

  while (index < len) {
    let b,
      shift = 0,
      result = 0;
    do {
      b = encoded.charCodeAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    const dlat = result & 1 ? ~(result >> 1) : result >> 1;
    lat += dlat;

    shift = 0;
    result = 0;
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
      throw new HttpsError("internal", `Route API Error: \${response.data.status}`);
    }

    // 3. Normalize Response to internal RouteModel format
    const routes = response.data.routes.map((r, index) => {
      const leg = r.legs[0]; // Assuming single leg for A to B
      const polylinePoints = decodePolyline(r.overview_polyline.points);
      
      return {
        id: `route_\${index}_\${Date.now()}`,
        distanceMeters: leg.distance.value,
        durationSeconds: leg.duration.value,
        routeName: r.summary || `Route \${index + 1}`,
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
