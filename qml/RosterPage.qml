import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0

Page {
    id: rosterPage
    objectName: "rosterPage"
    tools: toolBarLayout

    Connections {
        target: xmppClient

        onSubscriptionReceived: {
            console.log( "QML: RosterPage: ::onSubscriptionReceived: [" + bareJid + "]" )
        }
    }

    Component.onCompleted: {
        statusBarText.text = "Contacts"
    }

    property bool hideOffline: settings.gBool("ui","hideOffline")
    property bool markUnread: settings.gBool("ui","markUnread")
    property bool showUnreadCount: settings.gBool("ui","showUnreadCount")
    property int  rosterItemHeight: settings.gInt("ui","rosterItemHeight")
    property bool showContactStatusText: settings.gBool("ui","showContactStatusText")
    property bool rosterLayoutAvatar: settings.gBool("ui","rosterLayoutAvatar")

  /*******************************************************************************/

    Component {
        id: componentRosterItem
        Rectangle {
            id: wrapper
            width: rosterView.width
            color: "transparent"
            visible: rosterSearch.text !== "" ? (txtJid.contact.substr(0, rosterSearch.text.length) == rosterSearch.text ? true : false ) : contactPicStatus === "qrc:/qml/images/presence-offline.svg" ? !hideOffline : true
            height: rosterItemHeight

            Image {
                id: imgPresence
                source: rosterLayoutAvatar ? (contactPicAvatar === "" ? "qrc:/qml/images/avatar.png" : contactPicAvatar) : contactPicStatus
                sourceSize.height: rosterItemHeight-4
                sourceSize.width: rosterItemHeight-4
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                height: rosterItemHeight-4
                width: rosterItemHeight-4
                Image {
                    id: imgUnreadMsg
                    source: showUnreadCount ? "images/message_num.png" : "images/message_mark.png"
                    sourceSize.height: wrapper.height
                    sourceSize.width: wrapper.height
                    smooth: true
                    visible: markUnread ? contactUnreadMsg != 0 : false
                    anchors.centerIn: parent
                    opacity: contactUnreadMsg != 0 ? 1 : 0
                    Rectangle {
                        color: "transparent"
                        width: wrapper.height * 0.29
                        height: width
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        visible: showUnreadCount ? contactUnreadMsg != 0 : false
                        Text {
                            id: txtUnreadMsg
                            text: contactUnreadMsg
                            font.pixelSize: 0.72*parent.width
                            anchors.centerIn: parent
                            z: 1
                            color: "white"
                        }
                    }
                }
            } //imgPresence
            Text {
                    id: txtJid
                    property string contact: contactName
                    anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    width: parent.width
                    maximumLineCount: (rosterItemHeight/22) > 1 ? (rosterItemHeight/22) : 1
                    text: (contactName === "" ? contactJid : contactName) + (showContactStatusText ? ("\n" + contactTextStatus) : "")
                    onLinkActivated: { main.url=link; linkContextMenu.open()}
                    wrapMode: Text.Wrap
                    font.pixelSize: (showContactStatusText ? 16 : 0)
                    color: main.textColor
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    xmppClient.chatJid = contactJid
                    xmppClient.contactName = contactName
                    main.globalUnreadCount = main.globalUnreadCount - contactUnreadMsg
                    notify.postHSWidget()
                    main.pageStack.push( "qrc:/qml/MessagesPage.qml" )
                }

                onPressAndHold: {
                    xmppClient.chatJid = contactJid
                    dialogName = contactName
                    contactMenu.open()
                }
            }
            Image {
                id: imgPresenceR
                source: rosterLayoutAvatar ? contactPicStatus : ""
                sourceSize.height: (wrapper.height/3) - 4
                sourceSize.width: (wrapper.height/3) - 4
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: rosterLayoutAvatar ? 10 : 0 }
                height: rosterLayoutAvatar ? (rosterItemHeight/3) - 4 : 0
                width: rosterLayoutAvatar ? (rosterItemHeight/3) - 4 : 0
            }
            Rectangle {
                height: 1
                anchors { top: parent.bottom; left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
                color: main.textColor
                opacity: 0.2
            }
        } //Rectangle
    }

    Rectangle {
        id: limiter
        y: -main.y
        color: "transparent"
        height: 1
        anchors { left: parent.left; right: parent.right }
    }

    Flickable {
        id: rosterView
        anchors { top: limiter.top; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        contentHeight: columnContent.height
        contentWidth: columnContent.width

        flickableDirection: Flickable.VerticalFlick
        Column {
            id: columnContent
            spacing: 0

            Repeater {
                model: xmppClient.roster
                delegate: componentRosterItem
            }


        }
    }

    /********************************( Dialog windows, menus and stuff )************************************/

    Menu {
        id: rosterMenu

        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Status")
                onClicked: {
                    dialog.source = ""
                    dialog.source = "Dialogs/ChangeStatus.qml"
                }
            }
            MenuItem {
                text: qsTr("Accounts")
                onClicked: main.pageStack.push( "qrc:/qml/AccountsPage.qml" )
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: main.pageStack.push( "qrc:/qml/SettingsPage.qml" )
            }

            MenuItem {
                text: qsTr("My vCard")
                onClicked: {if( xmppClient.stateConnect == XmppClient.Online )
                    {
                        main.requestMyVCard = true
                        main.pageStack.push( "qrc:/qml/VCardPage.qml" )
                    }}
            }
            MenuItem {
                text: main.notifyHold ? "Unmute notifications (" + main.notifyHoldDuration + " min.)" : "Mute notifications"
                onClicked: {
                    if (main.notifyHold) {
                        main.notifyHold = false
                        main.notifyHoldDuration = 0
                    } else {
                        muteNotifications.open()
                    }
                }
            }

            MenuItem {
                text: qsTr("About...")
                onClicked: main.pageStack.push( "qrc:/qml/AboutPage.qml" )
            }
        }
    }

    CommonDialog {
        id: muteNotifications
        titleText: qsTr("Mute notifications")

        buttonTexts: [qsTr("OK"), qsTr("Cancel")]

        onButtonClicked: {
            if ((index === 0) && ( notifyHoldDuration.text != "" )) {
                main.notifyHoldDuration = parseInt(notifyHoldDuration.text)
                notifyHold = true
            }
        }

        content: Rectangle {
            width: parent.width-20
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Text {
                id: queryLabel;
                color: "white";
                anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 10 }
                text: qsTr("Mute notifications for...");
            }
            TextField {
                id: notifyHoldDuration
                text: dialogName
                height: 50
                anchors { bottom: parent.bottom; bottomMargin: 5; left: parent.left; right: parent.right }
                placeholderText: qsTr("Time in minutes (ex. 15)")

                onActiveFocusChanged: {
                    splitscreenY = 0
                }
            }
        }
    }



    Menu {
        id: contactMenu
        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Remove")
                onClicked: { dialog.source = ""
                    dialog.source = "Dialogs/RemoveContact.qml"}
            }
            MenuItem {
                text: qsTr("Rename")
                onClicked: { dialog.source = ""
                    dialog.source = "Dialogs/RenameContact.qml"}
            }
            MenuItem {
                text: qsTr("vCard")
                onClicked: {
                    main.requestMyVCard = false
                    main.pageStack.push( "qrc:/qml/VCardPage.qml" )
                }
            }
            MenuItem {
                text: qsTr("Archive")
                onClicked: {
                    main.pageStack.push( "qrc:/qml/ArchivePage.qml" )
                }
            }
            MenuItem {
                text: qsTr("Subscribe")
                onClicked: {dialogTitle = qsTr("Subscribed")
                    dialogText = qsTr("Sent request to ")+dialogName
                    xmppClient.subscribe( xmppClient.chatJid )
                    dialog.source = ""
                    dialog.source = "Dialogs/Info.qml"
                }
            }
            MenuItem {
                text: qsTr("Unsubscribe")
                onClicked: {dialogTitle = qsTr("Unsuscribed")
                    dialogText = qsTr("Unsuscribed ")+dialogName
                    xmppClient.unsubscribe( xmppClient.chatJid )
                    dialog.source = ""
                    dialog.source = "Dialogs/Info.qml"
                }
            }
        }
    }
    /*********************************************************************/

    TextField {
        id: rosterSearch
        height: 0
        width: parent.width
        anchors.bottom: splitViewInput.top
        placeholderText: qsTr("Tap to write")

        Behavior on height { SmoothedAnimation { velocity: 200 } }

        onActiveFocusChanged: {
            main.splitscreenY = 0
            //main.splitscreenY = (main.height - y) > 256 ? (main.height - y) : (main.height - y) + (256 - (main.height - y))
        }
    }

    Item {
        id: splitViewInput

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Behavior on height { PropertyAnimation { duration: 1 } }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height - toolBarLayout.height }
                PropertyChanges { target: main; inputInProgress: true }
            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; }
                PropertyChanges { target: main; inputInProgress: false }
            }
        ]
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: "toolbar-back"
            smooth: true
            onClicked: {
                Qt.quit()
            }
        }
        ToolButton {
            iconSource: "toolbar-add"
            smooth: true
            onClicked: {
                dialog.source = ""
                dialog.source = "Dialogs/AddContact.qml"
            }
        }
        ToolButton {
            iconSource: "toolbar-search"
            smooth: true
            onClicked: {
                if (rosterSearch.height == 50) {
                    rosterSearch.height = 0;
                    rosterSearch.text = ""; } else rosterSearch.height = 50
            }
        }

        ToolButton {
            id: toolBarButtonChats
            iconSource: "images/bar_open_chats.png"
            smooth: true
            onClicked: main.pageStack.push( "qrc:/qml/ChatsPage.qml" )
            Image {
                id: imgMarkUnread
                source: "images/message_mark.png"
                visible: globalUnreadCount != 0
                anchors.centerIn: parent
            }
            Text {
                id: txtUnreadMsg
                text: globalUnreadCount
                font.pixelSize: 16
                anchors.centerIn: parent
                visible: globalUnreadCount != 0
                z: 1
                color: "black"
            }
        }
        ToolButton {
            id: toolBarButtonOptions
            iconSource: "toolbar-menu"
            smooth: true
            onClicked: {
                rosterMenu.open()
            }
        }
    }

}
