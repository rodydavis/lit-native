if('serviceWorker' in navigator) {window.addEventListener('load', () => {navigator.serviceWorker.register('/lit-native/sw.js', { scope: '/lit-native/' })})}