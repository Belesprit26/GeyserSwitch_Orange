const functions = require("firebase-functions/v2");
const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationFromESP32 = onRequest(async (req, res) => {
  // Allow only POST requests
  if (req.method !== 'POST') {
    console.log('Invalid request method:', req.method);
    return res.status(405).send('Method Not Allowed');
  }

  const { title, body, data, userId, authKey } = req.body;

  // Validate authKey
  const expectedAuthKey = 'geyserswitch-bloc-orange';
  if (authKey !== expectedAuthKey) {
    console.log('Invalid authKey:', authKey);
    return res.status(400).send('Invalid authKey');
  }

  // Validate required fields
  if (!title || !body || !userId) {
    console.log('Missing required fields. Received:', req.body);
    return res.status(400).send('Missing required fields');
  }

  try {
    // Retrieve the device token(s) for the user from the Realtime Database
    const tokensSnapshot = await admin.database().ref(`/GeyserSwitch/${userId}/ServiceInfo/notificationTokens`).once('value');
    const tokens = tokensSnapshot.val();

    if (!tokens) {
      console.log('No tokens found for userId:', userId);
      return res.status(400).send('No tokens found for userId');
    }

    // Extract device tokens correctly
    const deviceTokens = Object.keys(tokens);
    console.log('Device Tokens:', deviceTokens);

    // Ensure data payload values are strings
    const dataPayload = {};
    if (data) {
      for (const key in data) {
        if (data.hasOwnProperty(key)) {
          dataPayload[key] = String(data[key]);
        }
      }
    }

    // Prepare the notification messages
    const messages = deviceTokens.map(token => ({
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: dataPayload,
      android: {
        notification: {
          channel_id: 'high_importance_channel',
          priority: 'high',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            sound: 'default',
            badge: 1,
          },
        },
      },
      webpush: {
        headers: {
          Urgency: 'high',
        },
        notification: {
          title: title,
          body: body,
        },
      },
    }));

    console.log('Notification Messages:', messages);

    // Send notifications to all tokens using sendAll
    const response = await admin.messaging().sendAll(messages);

    // Log the response from FCM
    console.log('FCM Response:', response);

    // Cleanup invalid tokens
    const tokensToRemove = [];
    response.responses.forEach((result, index) => {
      const error = result.error;
      if (error) {
        const failedToken = deviceTokens[index];
        console.error('Failure sending notification to', failedToken, error);
        // Cleanup the tokens that are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          tokensToRemove.push(failedToken);
        }
      }
    });

    // Remove invalid tokens from the database
    if (tokensToRemove.length > 0) {
      console.log('Removing invalid tokens:', tokensToRemove);
      const removePromises = tokensToRemove.map(token =>
        admin.database().ref(`/GeyserSwitch/${userId}/ServiceInfo/notificationTokens/${token}`).remove()
      );
      await Promise.all(removePromises);
      console.log('Invalid tokens removed successfully');
    }

    res.status(200).send('Notification sent successfully');
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).send(`Internal Server Error: ${error.message}`);
  }
});