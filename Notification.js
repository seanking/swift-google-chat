class NotificationOverride {
    static get permission() {
        return "granted";
    }
    
    static requestPermission (callback) {
        callback("granted");
    }
    
    constructor (messageText) {
        window.webkit.messageHandlers.notify.postMessage(messageText);
    }
}

window.Notification = NotificationOverride;
