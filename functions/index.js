const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Scheduled function that runs every 5 minutes
 * Checks for appointments 55-65 minutes away and sends FCM notifications
 */
exports.sendAppointmentReminders = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    console.log('🔔 Running appointment reminder check...');
    
    const now = admin.firestore.Timestamp.now();
    const nowDate = now.toDate();
    
    // Calculate time window: 55-65 minutes from now
    const reminderStart = new Date(nowDate.getTime() + 55 * 60 * 1000);
    const reminderEnd = new Date(nowDate.getTime() + 65 * 60 * 1000);
    
    console.log(`⏰ Checking appointments between ${reminderStart.toISOString()} and ${reminderEnd.toISOString()}`);
    
    try {
      // Query appointments in the time window that haven't been notified yet
      const appointmentsSnapshot = await admin.firestore()
        .collection('appointments')
        .where('appointmentDate', '>=', admin.firestore.Timestamp.fromDate(reminderStart))
        .where('appointmentDate', '<=', admin.firestore.Timestamp.fromDate(reminderEnd))
        .where('notificationScheduled', '==', false)
        .where('status', '==', 'pending') // Only send for pending appointments
        .get();
      
      if (appointmentsSnapshot.empty) {
        console.log('✅ No appointments found in reminder window');
        return null;
      }
      
      console.log(`📋 Found ${appointmentsSnapshot.size} appointment(s) to notify`);
      
      // Send notification for each appointment
      const promises = appointmentsSnapshot.docs.map(async (doc) => {
        const appointment = doc.data();
        const appointmentId = doc.id;
        
        // Skip if no FCM token
        if (!appointment.fcmToken) {
          console.log(`⚠️ Skipping appointment ${appointmentId} - no FCM token`);
          return null;
        }
        
        const appointmentDate = appointment.appointmentDate.toDate();
        const formattedDate = appointmentDate.toLocaleString('en-US', {
          month: 'short',
          day: 'numeric',
          hour: 'numeric',
          minute: '2-digit',
          hour12: true
        });
        
        // Prepare FCM message
        const message = {
          token: appointment.fcmToken,
          notification: {
            title: '🏥 Upcoming Appointment Reminder',
            body: `You have an appointment with ${appointment.doctorName} in 1 hour (${formattedDate})`
          },
          data: {
            appointmentId: appointmentId,
            doctorName: appointment.doctorName || '',
            appointmentDate: appointmentDate.toISOString()
          },
          android: {
            priority: 'high',
            notification: {
              channelId: 'appointment_reminders',
              priority: 'max',
              sound: 'default'
            }
          }
        };
        
        try {
          // Send FCM notification
          const response = await admin.messaging().send(message);
          console.log(`✅ Notification sent for appointment ${appointmentId}:`, response);
          
          // Mark as notified
          await doc.ref.update({
            notificationScheduled: true,
            notificationSentAt: admin.firestore.FieldValue.serverTimestamp()
          });
          
          return { success: true, appointmentId };
        } catch (error) {
          console.error(`❌ Error sending notification for appointment ${appointmentId}:`, error);
          return { success: false, appointmentId, error: error.message };
        }
      });
      
      const results = await Promise.all(promises);
      const successful = results.filter(r => r && r.success).length;
      const failed = results.filter(r => r && !r.success).length;
      
      console.log(`🎉 Reminder check complete: ${successful} sent, ${failed} failed`);
      return { successful, failed };
      
    } catch (error) {
      console.error('❌ Error in sendAppointmentReminders:', error);
      throw error;
    }
  });

/**
 * Optional: Manual trigger function for testing
 * Call this from Firebase Console to test notifications immediately
 */
exports.testAppointmentReminder = functions.https.onRequest(async (req, res) => {
  console.log('🧪 Manual test trigger called');
  
  try {
    // Get the most recent appointment with FCM token
    const snapshot = await admin.firestore()
      .collection('appointments')
      .where('fcmToken', '!=', null)
      .orderBy('fcmToken')
      .orderBy('appointmentDate', 'desc')
      .limit(1)
      .get();
    
    if (snapshot.empty) {
      res.status(404).send('No appointments with FCM tokens found');
      return;
    }
    
    const doc = snapshot.docs[0];
    const appointment = doc.data();
    const appointmentDate = appointment.appointmentDate.toDate();
    
    const message = {
      token: appointment.fcmToken,
      notification: {
        title: '🧪 Test Appointment Reminder',
        body: `Test notification for appointment with ${appointment.doctorName}`
      },
      data: {
        appointmentId: doc.id,
        test: 'true'
      }
    };
    
    const response = await admin.messaging().send(message);
    console.log('✅ Test notification sent:', response);
    
    res.status(200).json({
      success: true,
      message: 'Test notification sent',
      appointmentId: doc.id,
      response: response
    });
    
  } catch (error) {
    console.error('❌ Test error:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});
