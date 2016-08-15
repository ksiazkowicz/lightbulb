import QtQuick 2.0
import QtQuick.Controls 2.0
import "."

Button {
    onClicked: dialog.createWithProperties("qrc:/Dialogs/Status/Change", {"accountId": accGRID})

    contentItem: Image {
        source: "qrc:/accounts/" + accIcon
        sourceSize { width: PlatformStyle.graphicSizeMedium;
            height: PlatformStyle.graphicSizeMedium; }
        width: PlatformStyle.graphicSizeMedium
        height: PlatformStyle.graphicSizeMedium
    }
    width: PlatformStyle.graphicSizeMedium
    height: PlatformStyle.graphicSizeMedium-8
    flat: false
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
