importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDH2kbV94TIDY9SUmQjS2HPXi71rkczHWs",
  authDomain: "medilink6928.firebaseapp.com",
  projectId: "medilink6928",
  storageBucket: "medilink6928.appspot.com",
  messagingSenderId: "322192606014",
  appId: "1:322192606014:web:aa0d5917eef97233c8226f",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload
  );
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
