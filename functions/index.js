const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Cloud Function: Detect when a bus becomes active and send notifications
 * to users who have that route marked as favorite
 */
exports.onBusActivated = functions.database
    .ref('/buses/{busId}')
    .onUpdate(async (change, context) => {
        const before = change.before.val();
        const after = change.after.val();
        const busId = context.params.busId;

        if (before.isActive === false && after.isActive === true) {
            const routeName = after.routeName;

            console.log(`🚌 Bus ${busId} activated for route: ${routeName}`);

            // OneSignal Configuration
            // TODO: Replace with actual keys if different from announcement keys
            const ONESIGNAL_APP_ID = "f6b90ee4-f9c1-42f6-9168-36e810b5e658";
            const ONESIGNAL_API_KEY = "os_v2_app_624q5zhzyfbpnelig3ubbnpglcl7n54kldeusd4agqevei7t4uy7vd7sm3oxpaliiecdumdwzw2ustfsjdivdyaonqvsnjkpqi2ia7i";

            try {
                // Construct OneSignal notification object
                const notificationBody = {
                    app_id: ONESIGNAL_APP_ID,
                    headings: { "en": `${routeName} en Movimiento` },
                    contents: { "en": "Tu ruta favorita acaba de comenzar su recorrido" },
                    large_icon: "notification_logo", // Ensure this resource exists or use default
                    small_icon: "ic_stat_onesignal_default",
                    // Target users who have "route_ROUTENAME" tag set to "1"
                    filters: [
                        { field: "tag", key: `route_${routeName}`, relation: "=", value: "1" }
                    ],
                    data: {
                        type: 'favorite_route_active',
                        route: routeName,
                        busId: busId,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                };

                // Send request to OneSignal API
                const response = await fetch("https://onesignal.com/api/v1/notifications", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json; charset=utf-8",
                        "Authorization": `Basic ${ONESIGNAL_API_KEY}`
                    },
                    body: JSON.stringify(notificationBody)
                });

                const responseData = await response.json();
                console.log("✅ OneSignal Response (Bus Activation):", responseData);

                return { success: true, oneSignalId: responseData.id };

            } catch (error) {
                console.error("❌ Error sending OneSignal notification:", error);
                return { success: false, error: error.toString() };
            }
        }

        // If bus was not activated, do nothing
        return null;
    });

/**
 * Cloud Function: Clean up invalid FCM tokens
 * Runs daily to remove tokens that are no longer valid
 */
exports.cleanupInvalidTokens = functions.pubsub
    .schedule('every 24 hours')
    .onRun(async (context) => {
        console.log('🧹 Starting FCM token cleanup...');

        try {
            const usersSnapshot = await admin.database()
                .ref('users')
                .once('value');

            let removedCount = 0;

            const promises = [];

            usersSnapshot.forEach((userSnapshot) => {
                const userId = userSnapshot.key;
                const userData = userSnapshot.val();

                if (userData.fcmToken) {
                    // Try to send a dry-run message to validate the token
                    const message = {
                        token: userData.fcmToken,
                        data: { test: 'true' }
                    };

                    const promise = admin.messaging()
                        .send(message, true) // dry run
                        .catch(async (error) => {
                            // If token is invalid, remove it
                            if (error.code === 'messaging/invalid-registration-token' ||
                                error.code === 'messaging/registration-token-not-registered') {
                                console.log(`🗑️ Removing invalid token for user ${userId}`);
                                await admin.database()
                                    .ref(`users/${userId}/fcmToken`)
                                    .remove();
                                removedCount++;
                            }
                        });

                    promises.push(promise);
                }
            });

            await Promise.all(promises);

            console.log(`✅ Cleanup complete. Removed ${removedCount} invalid tokens`);
            return { removedCount };

        } catch (error) {
            return { error: error.message };
        }
    });

/**
 * Cloud Function: Send notification when a driver posts an announcement
 */
exports.onAnnouncementCreated = functions.database
    .ref('/announcements/{announcementId}')
    .onCreate(async (snapshot, context) => {
        const announcement = snapshot.val();
        const routeName = announcement.routeName;
        const subject = announcement.subject;
        const message = announcement.message;

        console.log(`📢 New announcement for route ${routeName}: ${subject}`);

        // OneSignal Configuration
        // TODO: Replace with actual keys
        const ONESIGNAL_APP_ID = "f6b90ee4-f9c1-42f6-9168-36e810b5e658";
        const ONESIGNAL_API_KEY = "os_v2_app_624q5zhzyfbpnelig3ubbnpglcl7n54kldeusd4agqevei7t4uy7vd7sm3oxpaliiecdumdwzw2ustfsjdivdyaonqvsnjkpqi2ia7i";

        try {
            // Construct OneSignal notification object
            const notificationBody = {
                app_id: ONESIGNAL_APP_ID,
                headings: { "en": routeName }, // Header shows just the Route Name
                contents: { "en": subject },   // Body shows the subject/message
                large_icon: "notification_logo", // Use the custom uploaded logo
                small_icon: "ic_stat_onesignal_default", // Use the custom small icon
                // Target users who have "route_ROUTENAME" tag set to "1"
                filters: [
                    { field: "tag", key: `route_${routeName}`, relation: "=", value: "1" }
                ],
                data: {
                    type: 'announcement',
                    route: routeName,
                    announcementId: context.params.announcementId,
                    message: message // Include full message in data payload if needed
                }
            };

            // Send request to OneSignal API
            const response = await fetch("https://onesignal.com/api/v1/notifications", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=utf-8",
                    "Authorization": `Basic ${ONESIGNAL_API_KEY}`
                },
                body: JSON.stringify(notificationBody)
            });

            const responseData = await response.json();
            console.log("✅ OneSignal Response:", responseData);

            return { success: true, oneSignalId: responseData.id };

        } catch (error) {
            console.error("❌ Error sending OneSignal notification:", error);
            return { success: false, error: error.toString() };
        }
    });
