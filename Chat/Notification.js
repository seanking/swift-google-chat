class NotificationOverride extends Notification {
    static get permission() {
        return "granted";
    }
    
    static requestPermission (callback) {
        callback("granted");
    }
    
    constructor(title, options) {
        super(title, options);
        
        const message = {
            title: title,
            subtitle: options.body,
            icon: options.icon,
        };
        
        window.webkit.messageHandlers.notify.postMessage(message);
    }
}

window.Notification = NotificationOverride;
