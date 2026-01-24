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

        // Only trigger when a bus goes from inactive to active
        if (before.isActive === false && after.isActive === true) {
            const routeName = after.routeName;

            console.log(`🚌 Bus ${busId} activated for route: ${routeName}`);

            try {
                // Find all users who have this route as favorite
                const usersSnapshot = await admin.database()
                    .ref('users')
                    .once('value');

                const tokens = [];
                const userIds = [];

                usersSnapshot.forEach((userSnapshot) => {
                    const userId = userSnapshot.key;
                    const userData = userSnapshot.val();

                    // Check if user has favoriteRoutes and this specific route
                    if (userData.favoriteRoutes && userData.favoriteRoutes[routeName] === true) {
                        if (userData.fcmToken) {
                            tokens.push(userData.fcmToken);
                            userIds.push(userId);
                            console.log(`📱 Found user ${userId} with favorite route ${routeName}`);
                        }
                    }
                });

                // If no users have this route as favorite, exit early
                if (tokens.length === 0) {
                    console.log(`ℹ️ No users have ${routeName} as favorite`);
                    return null;
                }

                console.log(`📬 Sending notification to ${tokens.length} user(s)`);

                // Prepare the notification message
                const message = {
                    notification: {
                        title: `🚌 ${routeName} en Movimiento`,
                        body: 'Tu ruta favorita acaba de comenzar su recorrido'
                    },
                    data: {
                        routeName: routeName,
                        busId: busId,
                        type: 'favorite_route_active',
                        click_action: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                };

                // Send to multiple devices (max 500 tokens per call)
                const batchSize = 500;
                const promises = [];

                for (let i = 0; i < tokens.length; i += batchSize) {
                    const batch = tokens.slice(i, i + batchSize);
                    const batchMessage = {
                        ...message,
                        tokens: batch
                    };
                    promises.push(admin.messaging().sendEachForMulticast(batchMessage));
                }

                const results = await Promise.all(promises);

                // Log results
                let successCount = 0;
                let failureCount = 0;

                results.forEach((result) => {
                    successCount += result.successCount;
                    failureCount += result.failureCount;

                    // Log failed tokens for cleanup
                    if (result.failureCount > 0) {
                        result.responses.forEach((resp, idx) => {
                            if (!resp.success) {
                                console.error(`❌ Failed to send to token: ${resp.error}`);
                                // TODO: Remove invalid tokens from database
                            }
                        });
                    }
                });

                console.log(`✅ Successfully sent ${successCount} notifications`);
                console.log(`❌ Failed to send ${failureCount} notifications`);

                return {
                    success: true,
                    sent: successCount,
                    failed: failureCount
                };

            } catch (error) {
                console.error('❌ Error sending notifications:', error);
                return {
                    success: false,
                    error: error.message
                };
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
            console.error('❌ Error during token cleanup:', error);
            return { error: error.message };
        }
    });
