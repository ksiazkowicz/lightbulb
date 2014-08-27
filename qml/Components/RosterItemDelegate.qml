// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0

Item {
    id: rosterItemDelegate
    height: txtJid.paintedHeight > 56 ? txtJid.paintedHeight + 22 /*margins*/ : 56

    Row {
        id: row
        width: parent.width-20
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        height: rosterItemDelegate.height
        Image {
            id: avatarIcon
            anchors { top: parent.top; topMargin: 4 }
            sourceSize { width: 48; height: 48 }
            width: 48
            height: 48
            smooth: true
            source: xmppConnectivity.getAvatarByJid(_contactJid)
            Rectangle { anchors.fill: parent; color: "black"; z: -1 }
            Image {
                anchors.fill: parent
                sourceSize { width: 48; height: 48 }
                smooth: true
                source: main.platformInverted ? "qrc:/avatar-mask_inverse" : "qrc:/avatar-mask"
            }

            Connections {
                target: xmppConnectivity
                onAvatarUpdatedForJid: if (bareJid == jid) avatarIcon.source = xmppConnectivity.getAvatarByJid(_contactJid)
            }
        }
        Text {
            id: txtJid
            text: _contactName + ((_statusText !== "") ? (" · <font color='#aaaaaa'><i>" + _statusText + "</i></font>") : "")
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

    Rectangle {
        height: 1
        anchors { top: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: parent.width-10
        color: main.textColor
        opacity: 0.2
    }

    MouseArea {
        anchors.fill: parent
        onClicked: pageStack.replace("qrc:/pages/Conversation",{"accountId": _accountId,"contactName":_contactName,"contactJid":_contactJid,"isInArchiveMode":false})
        onPressAndHold: dialog.createWithProperties("qrc:/menus/Roster/Contact",{"accountId": _accountId,"contactName":_contactName,"contactJid":_contactJid})
    }
}
