// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0

Item {
    id: rosterItemDelegate
    height: txtJid.paintedHeight > 56 ? txtJid.paintedHeight + 22 /*margins*/ : 56
    property string _contactName: (name === "" ? jid : name)

    Row {
        id: row
        width: parent.width-20
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        height: rosterItemDelegate.height
        Image {
            id: avatarIcon
            anchors { top: parent.top; topMargin: 4 }
            sourceSize { width: platformStyle.graphicSizeMedium; height: platformStyle.graphicSizeMedium }
            smooth: true
            width: platformStyle.graphicSizeMedium; height: platformStyle.graphicSizeMedium
            source: xmppConnectivity.getAvatarByJid(jid)
            Rectangle { anchors.fill: parent; color: "black"; z: -1 }
            Image {
                anchors.fill: parent
                sourceSize { width: platformStyle.graphicSizeMedium; height: platformStyle.graphicSizeMedium }
                width: platformStyle.graphicSizeMedium; height: platformStyle.graphicSizeMedium
                smooth: true
                source: main.platformInverted ? "qrc:/avatar-mask_inverse" : "qrc:/avatar-mask"
            }

            Connections {
                target: xmppConnectivity
                onAvatarUpdatedForJid: if (bareJid == jid) avatarIcon.source = xmppConnectivity.getAvatarByJid(jid)
            }
        }
        Text {
            id: txtJid
            text: _contactName + ((statusText !== "") ? (" · <font color='"+main.midColor+"'><i>" + statusText + "</i></font>") : "")
            anchors.verticalCenter: parent.verticalCenter
            onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            color: main.textColor
            clip: true
            width: row.width - avatarIcon.width - imgPresence.width - row.spacing*2
        }
        Image {
            id: imgPresence
            source: presence
            sourceSize.height: 16
            sourceSize.width: 16
            anchors { top: parent.top; topMargin: 20 }
        }
    }

    LineItem { anchors.bottom: parent.bottom }

    MouseArea {
        anchors.fill: parent
        onClicked: pageStack.replace("qrc:/pages/Conversation",{"accountId": accountId,"contactName":_contactName,"contactJid":jid,"isInArchiveMode":false})
        onPressAndHold: dialog.createWithProperties("qrc:/menus/Roster/Contact",{"accountId": accountId,"contactName":_contactName,"contactJid":jid})
    }
}
