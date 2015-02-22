// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0

Item {
    id: rosterItemDelegate
    height: txtJid.paintedHeight > 56 ? txtJid.paintedHeight + 22 /*margins*/ : 56
    property string _contactName: (name === "" ? jid : name)

    property bool shouldBeOpaque: xmppConnectivity.getStatusByIndex(accountId) !== 0

    function favBegin(fav) { return fav === "1" ? "★ <font color='#efb813'>" : ""; }
    function favEnd(fav) { return fav === "1" ? "</font>" : ""; }

    function groupTag(groups) { return (typeof groups !== 'undefined' && groups !== '' && vars.showGroupTag) ? ("<i> (" + groups + ")</i>") : ""; }
    function statusTxt(text) { return (text !== "") ? (" · <font color='"+main.midColor+"'><i>" + text + "</i></font>") : ""; }
    function subTagBegin(type) { return (type == 0) ? "<s>" : ""; }
    function subTagEnd(type) { return (type == 0) ? "</s>" : ""; }

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
                opacity: 1.0
            }

            opacity: shouldBeOpaque ? 1.0 : 0.5

            Connections {
                target: xmppConnectivity
                onAvatarUpdatedForJid: if (bareJid == jid) avatarIcon.source = xmppConnectivity.getAvatarByJid(jid)
                onXmppStatusChanged: shouldBeOpaque = xmppConnectivity.getStatusByIndex(accountId) !== 0
            }
        }
        Text {
            id: txtJid
            text: favBegin(favorite) + subTagBegin(subscriptionType) + _contactName + subTagEnd(subscriptionType) + favEnd(favorite) + groupTag(groups) + statusTxt(statusText)
            anchors.verticalCenter: parent.verticalCenter
            onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
            wrapMode: Text.WordWrap
            font.pixelSize: 16
            color: main.textColor
            clip: true
            width: row.width - avatarIcon.width - imgPresence.width - row.spacing*2

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

    LineItem { anchors.bottom: parent.bottom }

    MouseArea {
        anchors.fill: parent
        onClicked: pageStack.replace("qrc:/pages/Conversation",{"accountId": accountId,"contactName":_contactName,"contactJid":jid,"isInArchiveMode":false,"contactResource":resource})
        onPressAndHold: dialog.createWithProperties("qrc:/menus/Roster/Contact",{"accountId": accountId,"contactName":_contactName,"contactJid":jid,"isFavorite":favorite,"contactGroup":groups})
    }
}
