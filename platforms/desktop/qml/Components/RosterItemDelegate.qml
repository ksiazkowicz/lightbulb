// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import lightbulb 1.0
import "."

Item {
    id: rosterItemDelegate
    height: txtJid.paintedHeight > 56 ? txtJid.paintedHeight + 22 /*margins*/ : 56
    property string _contactName: (name === "" ? jid : name)

    property bool shouldBeOpaque: xmppConnectivity.getStatusByIndex(accountId) !== 0

    function favBegin(fav) { return fav === "1" ? "★ <font color='#efb813'>" : ""; }
    function favEnd(fav) { return fav === "1" ? "</font>" : ""; }

    function groupTag(groups) { return (typeof groups !== 'undefined' && groups !== '' && vars.showGroupTag) ? ("<i> (" + groups + ")</i>") : ""; }
    function statusTxt(text) { return (text !== "" && vars.showContactStatusText) ? (" · <font color='"+main.midColor+"'><i>" + text + "</i></font>") : ""; }
    function subTagBegin(type) { return (type == 0) ? "<s>" : ""; }
    function subTagEnd(type) { return (type == 0) ? "</s>" : ""; }

    Row {
        id: row
        width: parent.width-20
        spacing: 10
        anchors.horizontalCenter: parent.horizontalCenter
        height: rosterItemDelegate.height
        Item {
            height: rosterItemDelegate.height
            width: rosterItemDelegate.height
            Rectangle {
                id: avatarContainer
                width: 48; height: parent.height;
                anchors { left: parent.left; top: parent.top; }
                color: "transparent"
            }

            Image {
                id: avatar
                width: 32; height: 32
                source: xmppConnectivity.getAvatarByJid(jid)
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

            opacity: shouldBeOpaque ? 1.0 : 0.5

            /*Connections {
                target: xmppConnectivity
                onAvatarUpdatedForJid: if (bareJid == jid) avatarIcon.source = xmppConnectivity.getAvatarByJid(jid)
                onXmppStatusChanged: shouldBeOpaque = xmppConnectivity.getStatusByIndex(accountId) !== 0
            }*/
        }
        Label {
            id: txtJid
            text: favBegin(favorite) + subTagBegin(subscriptionType) + _contactName + subTagEnd(subscriptionType) + favEnd(favorite) + groupTag(groups) + statusTxt(statusText)
            anchors.verticalCenter: parent.verticalCenter
            onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            clip: true
            width: row.width - mask.width*2 - imgPresence.width - row.spacing*2

            opacity: shouldBeOpaque ? 1.0 : 0.5
        }
        Image {
            id: imgPresence
            source: presence
            sourceSize.height: 16
            sourceSize.width: 16
            anchors { top: parent.top; topMargin: 20 }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mainStack.replace("qrc:/Pages/Conversation",{"accountId": accountId,"contactName":_contactName,"contactJid":jid,"isInArchiveMode":false,"contactResource":resource})
        onPressAndHold: dialog.createWithProperties("qrc:/menus/Roster/Contact",{"accountId": accountId,"contactName":_contactName,"contactJid":jid,"isFavorite":favorite,"contactGroup":groups,"subscriptionType":subscriptionType})
    }
}
