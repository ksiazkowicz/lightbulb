import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: mainPage
    property string pageName: "Events"

    Connections {
        target: xmppConnectivity
        onNotifyMsgReceived: {
            if (xmppConnectivity.chatJid !== jid)
                eventListModel.appendEvent(xmppConnectivity.getAvatarByJid(jid),true,parseInt(xmppConnectivity.getPropertyByJid(account,"unreadMsg",jid))+1,body,name,true,"message")
        }
        onChatJidChanged:
            eventListModel.findAndRemove(xmppConnectivity.getPropertyByJid(xmppConnectivity.currentAccount,"name",xmppConnectivity.chatJid),"message")
        onPersonalityChanged: {
            vCardHandler.loadVCard(settings.gStr("behavior","personality"))
            avatar.source = xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))
        }
    }

    XmppVCard {
        id: vCardHandler
        Component.onCompleted: loadVCard(settings.gStr("behavior","personality"))
        onVCardChanged: {
            if (fullname !== "")
                name.text = fullname
        }
    }

    ListModel {
        id: eventListModel
        function appendEvent(icon,mark,markCount,text,description,mask,type) {
            var found = find(description,type)
            if (found > -1) {
                set(found,{"eventText": text, "markCount":markCount})
                move(found,0,1)
            } else {
                append({"iconPath": icon, "mark": mark, "markCount": markCount, "eventText": text,"descriptionText": description,"avatarMask":mask,"type":type})
                move(count-1,0,1)
            }
        }
        function find(description,type) {
            for (var i=0;i<count;i++)
                if (get(i).descriptionText === description && get(i).type === type)
                    return i
            return -1;
        }
        function findAndRemove(description,type) {
            var found = find(description,type);
            if (found > -1)
                remove(found);
        }
    }

    Flickable {
        anchors { fill: parent; leftMargin: 5; rightMargin: 5 }
        contentWidth: width
        contentHeight: mainView.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Column {
            id: mainView
            anchors { left: parent.left; right: parent.right }
            spacing: 5

            move: Transition {
                     NumberAnimation {
                         properties: "y"
                         easing.type: Easing.OutBounce
                     }
                 }

            Item {
                id: account
                anchors { left: parent.left; right: parent.right }
                height: 64

                Image {
                    id: avatar
                    width: 64
                    height: 64
                    clip: true
                    smooth: true
                    source: xmppConnectivity.getAvatarByJid(settings.gStr("behavior","personality"))

                    Image {
                        anchors.fill: parent
                        smooth: true
                        source: "qrc:/avatar-mask"
                    }
                }

                Text {
                    id: name
                    width: 215
                    height: 31
                    text: qsTr("Me")
                    anchors { left: avatar.right; leftMargin: 24; top: parent.top}
                    color: platformStyle.colorNormalLight
                    font.pixelSize: 24
                }

                ToolButton {
                    anchors { right: parent.right; verticalCenter: account.verticalCenter }
                    width: 50
                    height: 50
                    iconSource: "toolbar-menu"
                    onClicked: main.pageStack.push( "qrc:/pages/Accounts" )
                }

                GridView {
                    id: accounts
                    interactive: false
                    anchors { right: name.right; left: name.left; top: name.bottom }
                    cellWidth: 48
                    delegate: MouseArea {
                        height: 32
                        width: 48
                        onClicked: {
                            dialog.createWithProperties("qrc:/dialogs/Status/Change", {"accountId": accGRID})
                        }

                        Connections {
                            target: xmppConnectivity
                            onXmppStatusChanged: {
                                if (accountId == accGRID)
                                    accPresence.source = "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
                            }
                        }

                        Image {
                            sourceSize { height: 32; width: 32 }
                            anchors.centerIn: parent
                            smooth: true
                            source: "qrc:/accounts/" + accIcon
                            Image {
                                id: accPresence
                                width: 12; height: width
                                anchors { right: parent.right; bottom: parent.bottom }
                                source: "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
                                smooth: true
                                sourceSize { width: 12; height: 12 }
                            }
                        }
                    }
                    model: settings.accounts
                }

            }

            LineItem {}
            Row {
                anchors { left: parent.left; right: parent.right }
                height: 50
                Text {
                    height: parent.height
                    width: parent.width - clearBtn.width
                    color: "#ffffff"
                    text: qsTr("Events")
                    font { pixelSize: 22; bold: true }
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                    id: clearBtn
                    height: parent.height
                    text: "Clear"
                    onClicked: {
                        eventListModel.clear()
                    }
                }
            }
            Repeater {
                model: eventListModel
                anchors { left: parent.left; right: parent.right }
                delegate: MouseArea {
                    id: notification
                    width: mainView.width
                    height: 64

                    onClicked: {
                        if (type == "message")
                            console.log("Message lol")
                    }

                    Image {
                            id: icon
                            width: parent.height
                            height: parent.height
                            sourceSize { height: height; width: width }
                            smooth: true
                            source: iconPath
                            Image {
                                anchors.fill: parent
                                smooth: true
                                source: "qrc:/avatar-mask"
                                visible: avatarMask
                            }
                            Image {
                                z: 1
                                anchors.fill: parent
                                sourceSize { height: height; width: width }
                                source: "qrc:/unread-count"
                                visible: mark

                                Text {
                                    visible: parent.visible
                                    width: 20; height: width
                                    color: "#ffffff"
                                    text: markCount
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignHCenter
                                    anchors { right: parent.right; bottom: parent.bottom }
                                    font.pixelSize: width*0.72
                                }
                            }
                        }
                    Column {
                            anchors { left: icon.right; leftMargin: 10; verticalCenter: notification.verticalCenter }
                            Text {
                                color: "#ffffff"
                                textFormat: Text.PlainText
                                width: mainPage.width - 25 - 90
                                maximumLineCount: 1
                                font.pixelSize: 20
                                text: eventText
                                wrapMode: Text.WrapAnywhere
                                elide: Text.ElideRight
                            }
                            Text {
                                color: "#b9b9b9"
                                text: descriptionText
                                anchors { left: parent.left; right: parent.right }
                                horizontalAlignment: Text.AlignJustify
                                font.pixelSize: 20
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }
                }
            }
            Item {
                height: eventListModel.count > 0 ? 0 : 64
                anchors { left: parent.left; right: parent.right }
                Text {
                    color: "#ffffff"
                    text: "No unread events ^^"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 21
                    opacity: 0.5
                    visible: parent.height > 0
                }
            }

            LineItem {}
            Row {
                anchors { left: parent.left; right: parent.right }
                height: 50
                Text {
                    height: parent.height
                    width: parent.width - chatBtn.width
                    color: "#ffffff"
                    text: qsTr("Chats")
                    font { pixelSize: 22; bold: true }
                    opacity: 0.7
                    verticalAlignment: Text.AlignVCenter
                }
                ToolButton {
                    id: chatBtn
                    height: parent.height
                    width: height
                    text: ""
                    iconSource: "toolbar-add"
                    onClicked: main.pageStack.push( "qrc:/pages/Roster" )
                }
            }
            Repeater {
                model: xmppConnectivity.chats
                delegate: wrapper
            }
        }
    }

    Component {
        id: wrapper
        Rectangle {
            id: chatElement
            width: parent.width
            height: 56
            gradient: gr_free

            Gradient {
                id: gr_free
                GradientStop { id: gr1; position: 0; color: "transparent" }
                GradientStop { id: gr3; position: 1; color: "transparent" }
            }
            Gradient {
                id: gr_press
                GradientStop { position: 0; color: "#1C87DD" }
                GradientStop { position: 1; color: "#51A8FB" }
            }
            Image {
                id: avatarIcon
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                width: 48
                height: 48
                smooth: true
                source: xmppConnectivity.getAvatarByJid(jid)
                Image {
                    anchors.fill: parent
                    sourceSize { width: 48; height: 48 }
                    smooth: true
                    source: "qrc:/avatar-mask"
                }
            }
            Image {
                id: imgPresence
                source: xmppConnectivity.getPropertyByJid(account,"presence",jid)
                sourceSize { height: 16; width: 16 }
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 5 }
                height: 16
                width: 16
            }
            Text {
                anchors { verticalCenter: parent.verticalCenter; left: avatarIcon.right; right: parent.right; leftMargin: 10 }
                text: name
                font.pixelSize: 22
                clip: true
                color: vars.textColor
                elide: Text.ElideRight
            }
            states: State {
                name: "Current"
                when: jid == xmppConnectivity.chatJid
                PropertyChanges { target: chatElement; gradient: gr_press }
            }
            MouseArea {
                id: maAccItem
                anchors { fill: parent }
                onClicked: {
                    if (index > -1 && xmppConnectivity.chatJid != jid) {
                        xmppConnectivity.chatJid = jid
                        vars.globalUnreadCount = vars.globalUnreadCount - parseInt(xmppConnectivity.getPropertyByJid(account,"unreadMsg",jid))
                        main.openChat(account,jid)
                    }
                }
            }

            Connections {
                target: xmppConnectivity
                onXmppPresenceChanged: {
                    if (m_accountId == account && bareJid == jid)
                        imgPresence.source = picStatus
                }
            }
        }
    }

    tools: ToolBarLayout {
       ToolButton {
           iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
           onClicked: avkon.minimize();
           onPlatformPressAndHold: {
               avkon.hideChatIcon()
               Qt.quit();
           }
       }
       ToolButton {
           iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
           onClicked: dialog.create("qrc:/menus/Roster/Options")
       }
   }

}
