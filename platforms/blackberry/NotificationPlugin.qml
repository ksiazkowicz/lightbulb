import bb.cascades 1.4
import bb.platform 1.0
import bb.system 1.0

Container {
    id: notificationPlugin

    function pushSystemNotification(type,title,description) {
        console.log("XmppConnectivity::onPushedSystemNotification("+type+")")

        if (type === "NotifyConn") {
            systemToast.body = title + " | " + description;
            systemToast.show()
        } else {
            notification.title = title;
            notification.body = description;
            notification.soundUrl = settings.gStr("notifications","sound"+type+"File")
            notification.notify()
        }
    }
    attachedObjects: [
        Notification { id: notification },
        SystemToast { id: systemToast }
    ]
}
