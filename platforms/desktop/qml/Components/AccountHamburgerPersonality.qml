import QtQuick 2.0
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import lightbulb 1.0
import "."

Item {
    Connections {
        target: xmppConnectivity
        onPersonalityChanged: {
            vCardHandler.loadVCard(settings.gStr("behavior","personality"))
            avatar.source = xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))
        }
    }
    XmppVCard {
        id: vCardHandler
        Component.onCompleted: loadVCard(settings.gStr("behavior","personality"))
        onVCardChanged: if (fullname !== "") name.text = fullname
    }

    width: parent.width
    height: 48
    Rectangle {
        id: avatarContainer
        width: 48; height: parent.height;
        anchors { left: parent.left; top: parent.top; }
        color: "transparent"
    }

    Image {
        id: avatar
        width: 32; height: 32
        source: xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Rectangle {
        id: mask
        anchors { fill: parent; leftMargin: 8; rightMargin: 8; topMargin: 8; bottomMargin: 8; }
        color: "black"
        radius: 48
        clip: true
        visible: false
    }

    OpacityMask { anchors.fill: mask; source: avatar; maskSource: mask }

    Label {
        id: name
        anchors { left: avatarContainer.right; right: parent.right; verticalCenter: parent.verticalCenter }
        text: "Me"
    }
}
