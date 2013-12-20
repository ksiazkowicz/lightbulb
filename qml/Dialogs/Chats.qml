import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

SelectionDialog {
    id: selectionDialog
    titleText: "Chats"
    selectedIndex: -1
    platformInverted: main.platformInverted
    privateCloseIcon: true
    model: xmppClient.chats

    Component.onCompleted: open()

    onSelectedIndexChanged: {
        if (selectedIndex > -1 && xmppClient.chatJid != xmppClient.getPropertyByChatID(selectedIndex, "jid")) {
            xmppClient.chatJid = xmppClient.getPropertyByChatID(selectedIndex, "jid")
            xmppClient.contactName = xmppClient.getPropertyByChatID(selectedIndex, "name")
            main.globalUnreadCount = main.globalUnreadCount - parseInt(xmppClient.getPropertyByChatID(selectedIndex, "unreadMsg"))
            main.openChat()
        }
    }
}
