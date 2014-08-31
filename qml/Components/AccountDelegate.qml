// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

ToolButton {
    onClicked: dialog.createWithProperties("qrc:/dialogs/Status/Change", {"accountId": accGRID})
    iconSource: "qrc:/accounts/" + accIcon
    platformInverted: main.platformInverted
    width: 48
    height: 48
    flat: false
    Connections {
        target: xmppConnectivity
        onXmppStatusChanged: {
            if (accountId == accGRID)
                accPresence.source = "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
        }
    }
    Image {
        id: accPresence
        anchors { right: parent.right; bottom: parent.bottom; margins: platformStyle.paddingMedium }
        source: "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
        smooth: true
        sourceSize { width: 12; height: 12 }
    }
}
