// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

ToolButton {
    onClicked: dialog.createWithProperties("qrc:/dialogs/Status/Change", {"accountId": accGRID})
    iconSource: "qrc:/accounts/" + accIcon
    platformInverted: main.platformInverted
    width: platformStyle.graphicSizeMedium
    height: platformStyle.graphicSizeMedium
    flat: false
    Connections {
        target: xmppConnectivity
        onXmppStatusChanged: if (accountId == accGRID) accPresence.source = "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
        onXmppConnectingChanged: if (accountId == accGRID && xmppConnectivity.useClient(accGRID).getStateConnect() == 1) accPresence.source = "qrc:/presence/unknown";
    }
    Image {
        id: accPresence
        anchors { right: parent.right; bottom: parent.bottom; margins: platformStyle.paddingMedium }
        source: "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
        smooth: true
        sourceSize { width: platformStyle.graphicSizeSmall/2; height: platformStyle.graphicSizeSmall/2 }
    }
}
