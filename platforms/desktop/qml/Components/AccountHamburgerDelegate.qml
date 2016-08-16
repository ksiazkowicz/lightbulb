import QtQuick 2.0
import QtQuick.Controls 2.0
import "."
Item {
    height: 48
    width: parent.width
    Button {
        id: btn
        anchors { left: parent.left; leftMargin: 0 }
        onClicked: dialog.createWithProperties("qrc:/Dialogs/Status/Change", {"accountId": accGRID})
        implicitWidth: 48; implicitHeight: 48;

        Image {
            anchors.centerIn: parent
            source: "qrc:/accounts/" + accIcon
            sourceSize { width: PlatformStyle.graphicSizeSmall; height: PlatformStyle.graphicSizeSmall; }
            width: PlatformStyle.graphicSizeSmall
            height: PlatformStyle.graphicSizeSmall
        }
        flat: true
        Connections {
            target: xmppConnectivity
            onXmppStatusChanged: if (accountId == accGRID) accPresence.source = "qrc:/Presence/" + Helper.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
            onXmppConnectingChanged: if (accountId == accGRID && xmppConnectivity.useClient(accGRID).getStateConnect() == 1) accPresence.source = "qrc:/Presence/unknown";
        }
        Image {
            id: accPresence
            anchors { right: parent.right; bottom: parent.bottom; margins: PlatformStyle.paddingMedium }
            source: "qrc:/Presence/" + Helper.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
            smooth: true
            sourceSize { width: PlatformStyle.graphicSizeSmall/2; height: PlatformStyle.graphicSizeSmall/2 }
        }
    }
    Label {
        anchors { left: btn.right; leftMargin: 3; right: parent.right; verticalCenter: parent.verticalCenter }
        text: xmppConnectivity.getAccountName(accGRID)
    }
}
