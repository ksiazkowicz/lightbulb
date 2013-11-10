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
        onErrorHappened: {
            errorText.text = errorString
        }
        onStatusChanged: {
            if (xmppClient.status == XmppClient.Offline) {
                errorText.text = ""
            }
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
    property string selectedJid: ""

  /*******************************************************************************/

    Component {
        id: componentRosterItem
        Rectangle {
            id: wrapper
            width: rosterView.width
            color: "transparent"
            visible: rosterSearch.text !== "" ? (txtJid.contact.substr(0, rosterSearch.text.length) == rosterSearch.text ? true : false ) : presence === "qrc:/presence/offline" ? !hideOffline : true
            height: rosterItemHeight

            Image {
                id: imgPresence
                source: rosterLayoutAvatar ? avatarPath : presence
                sourceSize.height: rosterItemHeight-4
                sourceSize.width: rosterItemHeight-4
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                height: rosterItemHeight-4
                width: rosterItemHeight-4
                Image {
                    id: imgUnreadMsg
                    source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                    sourceSize.height: wrapper.height
                    sourceSize.width: wrapper.height
                    smooth: true
                    visible: markUnread ? unreadMsg != 0 : false
                    anchors.centerIn: parent
                    opacity: unreadMsg != 0 ? 1 : 0
                    Image {
                        id: imgUnreadCount
                        source: "qrc:/unread-count"
                        sourceSize.height: wrapper.height
                        sourceSize.width: wrapper.height
                        smooth: true
                        visible: showUnreadCount ? unreadMsg != 0 : false
                        anchors.centerIn: parent
                        opacity: unreadMsg != 0 ? 1 : 0
                    }
                    Rectangle {
                        color: "transparent"
                        width: wrapper.height * 0.30
                        height: width
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        visible: showUnreadCount ? unreadMsg != 0 : false
                        Text {
                            id: txtUnreadMsg
                            text: unreadMsg
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
                    property string contact: name
                    anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    width: parent.width
                    maximumLineCount: (rosterItemHeight/22) > 1 ? (rosterItemHeight/22) : 1
                    text: (name === "" ? jid : name) + (showContactStatusText ? ("\n" + statusText) : "")
                    onLinkActivated: { main.url=link; linkContextMenu.open()}
                    wrapMode: Text.Wrap
                    font.pixelSize: (showContactStatusText ? 16 : 0)
                    color: main.textColor
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    xmppClient.chatJid = jid
                    xmppClient.contactName = name
                    main.globalUnreadCount = main.globalUnreadCount - unreadMsg
                    notify.postHSWidget()
                    main.pageStack.push( "qrc:/pages/Messages" )
                }

                onPressAndHold: {
                    selectedJid = jid
                    dialogName = name
                    contactMenu.open()
                }
            }
            Image {
                id: imgPresenceR
                source: rosterLayoutAvatar ? presence : ""
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

    Flickable {
        id: rosterView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        contentHeight: columnContent.height
        contentWidth: columnContent.width

        flickableDirection: Flickable.VerticalFlick
        Column {
            id: columnContent
            spacing: 0

            Repeater {
                model: xmppClient.sqlRoster
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
                    dialog.source = "qrc:/dialogs/Status/Change"
                }
            }
            MenuItem {
                text: qsTr("Accounts")
                onClicked: main.pageStack.push( "qrc:/pages/Accounts" )
            }
            MenuItem {
                text: qsTr("First run wizard")
                onClicked: main.pageStack.push( "qrc:/pages/FirstRun" )
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: main.pageStack.push( "qrc:/pages/Settings" )
            }

            MenuItem {
                text: qsTr("My vCard")
                onClicked: {if( xmppClient.stateConnect == XmppClient.Online )
                    {
                        main.requestMyVCard = true
                        main.pageStack.push( "qrc:/pages/VCard" )
                    }}
            }
            MenuItem {
                text: main.notifyHold ? "Unmute notifications (" + main.notifyHoldDuration + " min.)" : "Mute notifications"
                onClicked: {
                    if (main.notifyHold) {
                        main.notifyHold = false
                        main.notifyHoldDuration = 0
                        notifyHoldTimer.running = false
                    } else {
                        dialog.source = ""
                        dialog.source = "qrc:/dialogs/MuteNotifications"
                    }
                }
            }

            MenuItem {
                text: qsTr("About...")
                onClicked: main.pageStack.push( "qrc:/pages/About" )
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
                    xmppClient.chatJid = selectedJid
                    dialog.source = "qrc:/dialogs/Contact/Remove"}
            }
            MenuItem {
                text: qsTr("Rename")
                onClicked: { dialog.source = ""
                    xmppClient.chatJid = selectedJid
                    dialog.source = "qrc:/dialogs/Contact/Rename"}
            }
            MenuItem {
                text: qsTr("vCard")
                onClicked: {
                    main.requestMyVCard = false
                    main.pageStack.push( "qrc:/pages/VCard" )
                    xmppClient.chatJid = selectedJid
                }
            }
            MenuItem {
                text: qsTr("Subscribe")
                onClicked: {dialogTitle = qsTr("Subscribed")
                    dialogText = qsTr("Sent request to ")+dialogName
                    xmppClient.subscribe( selectedJid )
                    notify.postGlobalNote(qsTr("Sent request to ")+dialogName)
                }
            }
            MenuItem {
                text: qsTr("Unsubscribe")
                onClicked: {dialogTitle = qsTr("Unsuscribed")
                    dialogText = qsTr("Unsuscribed ")+dialogName
                    xmppClient.unsubscribe( selectedJid )
                    notify.postGlobalNote(qsTr("Unsuscribed ")+dialogName)
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
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            smooth: true
            onClicked: {
                dialog.source = ""
                dialog.source = "qrc:/dialogs/Close"
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            smooth: true
            onClicked: {
                dialog.source = ""
                dialog.source = "qrc:/dialogs/Contact/Add"
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-search_inverse" : "toolbar-search"
            smooth: true
            onClicked: {
                if (rosterSearch.height == 50) {
                    rosterSearch.height = 0;
                    rosterSearch.text = ""; } else rosterSearch.height = 50
            }
        }

        ToolButton {
            id: toolBarButtonChats
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            smooth: true
            onClicked: {
                dialog.source = ""
                dialog.source = "qrc:/dialogs/Chats"
            }

            Image {
                id: imgMarkUnread
                source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                smooth: true
                sourceSize.width: toolBarButtonChats.width
                sourceSize.height: toolBarButtonChats.width
                width: toolBarButtonChats.width
                height: toolBarButtonChats.width
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
                color: main.platformInverted ? "white" : "black"
            }
        }
        ToolButton {
            id: toolBarButtonOptions
            iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
            smooth: true
            onClicked: {
                rosterMenu.open()
            }
        }
    }

    Rectangle {

        color: main.platformInverted ? "white" : "black"
        opacity: 0.7
        anchors.fill: parent
        NumberAnimation { properties: "visible"; duration: 200 }

        visible: xmppClient.status == XmppClient.Offline

        Rectangle {
            anchors.centerIn: parent
            color: "transparent"
            height: sadface.height + 5 + offlineText.height + 10 + errorText.height
            width: offlineText.width
            visible: xmppClient.status == XmppClient.Offline
            Text {
                id: sadface
                color: main.textColor
                anchors { top: parent.top; left: parent.left }
                visible: parent.visible
                text: ":("
                font.pixelSize: 64
            }
            Text {
                id: offlineText
                color: main.textColor
                anchors { top: sadface.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 5 }
                visible: parent.visible
                text: "You're offline"
                font.pixelSize: 32
            }
            Text {
                id: errorText
                color: "white"
                anchors { top: offlineText.bottom; topMargin: 10 }
                visible: parent.visible
                text: ""
                font.pixelSize: 16
            }
        }

    }

}
