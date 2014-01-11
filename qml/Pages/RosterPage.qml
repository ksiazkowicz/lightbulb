import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0

Page {
    id: rosterPage
    objectName: "rosterPage"
    tools: toolBarLayout


    Connections {
        target: xmppConnectivity.client
        onErrorHappened: errorText.text = errorString
        onStatusChanged: if (xmppConnectivity.client.status == XmppClient.Offline) errorText.text = ""
    }

    Component.onCompleted: statusBarText.text = "Contacts"

    property bool hideOffline: settings.gBool("ui","hideOffline")
    property bool markUnread: settings.gBool("ui","markUnread")
    property bool showUnreadCount: settings.gBool("ui","showUnreadCount")
    property int  rosterItemHeight: settings.gInt("ui","rosterItemHeight")
    property bool showContactStatusText: settings.gBool("ui","showContactStatusText")
    property bool rosterLayoutAvatar: settings.gBool("ui","rosterLayoutAvatar")
    property string selectedJid: ""

    /*******************************************************************************/

    Rectangle {
        id: accountSwitcher

        height: 46

        gradient: Gradient {
            GradientStop { position: 0; color: "#3c3c3c" }
            GradientStop { position: 0.04; color: "#6c6c6c" }
            GradientStop { position: 0.05; color: "#3c3c3c" }
            GradientStop { position: 0.06; color: "#4c4c4c" }
            GradientStop { position: 1; color: "#191919" }
        }

        z: 1

        anchors { top: parent.top; left: parent.left; right: parent.right }

        ToolButton {
            id: button
            anchors { left: parent.left; leftMargin: platformStyle.paddingSmall; verticalCenter: parent.verticalCenter }
            iconSource: "qrc:/presence/" + notify.getStatusName()
            onClicked: {
                if (settings.accounts.count() > 0) dialog.create("qrc:/dialogs/Status/Change"); else avkon.displayGlobalNote("You have to set-up an account first.",true)
            }
        }
        Text {
            id: titleText
            anchors { verticalCenter: parent.verticalCenter; left: button.right; leftMargin: platformStyle.paddingSmall  }
            text: xmppConnectivity.currentAccountName == "" ? "N/A" : xmppConnectivity.currentAccountName
            color: "white"
            font.pixelSize: 20
        }
        ToolButton {
            iconSource: "toolbar-list"
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: platformStyle.paddingSmall }
            onClicked: dialog.create("qrc:/dialogs/AccountSwitcher")
        }
    }

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
                source: rosterLayoutAvatar ? xmppConnectivity.getAvatarByJid(jid) : presence
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
                    property string contact: (name === "" ? jid : name)
                    anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    width: parent.width
                    maximumLineCount: (rosterItemHeight/22) > 1 ? (rosterItemHeight/22) : 1
                    text: (name === "" ? jid : name) + ((showContactStatusText && statusText != "") ? (" · <font color='#aaaaaa'><i>" + statusText + "</i></font>") : "")
                    onLinkActivated: { vars.url=link; linkContextMenu.open()}
                    wrapMode: Text.WordWrap
                    font.pixelSize: (showContactStatusText ? 16 : 0)
                    color: vars.textColor
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    xmppConnectivity.chatJid = jid
                    vars.contactName = txtJid.contact
                    vars.globalUnreadCount = vars.globalUnreadCount - unreadMsg
                    notify.updateNotifiers()
                    main.pageStack.push( "qrc:/pages/Messages" )
                }

                onPressAndHold: {
                    selectedJid = jid
                    vars.selectedContactStatusText = statusText
                    vars.selectedContactPresence = presence
                    vars.contactName = txtJid.contact
                    vars.dialogName = txtJid.contact
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
                color: vars.textColor
                opacity: 0.2
            }
        } //Rectangle
    }

    Flickable {
        id: rosterView
        anchors { top: accountSwitcher.bottom; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        contentHeight: columnContent.height
        contentWidth: columnContent.width

        flickableDirection: Flickable.VerticalFlick
        Column {
            id: columnContent
            spacing: 0

            Repeater {
                model: xmppConnectivity.roster
                delegate: componentRosterItem
            }


        }
    }

    /********************************( Dialog windows, menus and stuff )************************************/

    Menu {
        id: rosterMenu
        platformInverted: main.platformInverted

        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Settings")
                platformInverted: main.platformInverted
                onClicked: main.pageStack.push( "qrc:/pages/Settings" )
            }
            MenuItem {
                text: qsTr("About...")
                platformInverted: main.platformInverted
                onClicked: main.pageStack.push( "qrc:/pages/About" )
            }
            MenuItem {
                text: qsTr("Maintenance")
                platformInverted: main.platformInverted
                onClicked: main.pageStack.push( "qrc:/pages/Diagnostics" )
            }
            MenuItem {
                text: qsTr("Select Widget Skin")
                platformInverted: main.platformInverted
                onClicked: main.pageStack.push( "qrc:/pages/SkinSelection" )
            }
            MenuItem {
                text: qsTr("Exit")
                platformInverted: main.platformInverted
                onClicked: {
                    rosterMenu.close()
                    if (avkon.displayAvkonQueryDialog("Close", qsTr("Are you sure you want to close the app?"))) Qt.quit()
                }
            }
        }
    }

    Menu {
        id: contactMenu
        platformInverted: main.platformInverted
        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Remove")
                platformInverted: main.platformInverted
                onClicked: {
                    xmppConnectivity.chatJid = selectedJid
                    contactMenu.close()
                    if (avkon.displayAvkonQueryDialog("Remove", qsTr("Are you sure you want to remove ") + vars.dialogName + qsTr(" from your contact list?")))
                        xmppConnectivity.client.removeContact( selectedJid );
                }
            }
            MenuItem {
                text: qsTr("Rename")
                platformInverted: main.platformInverted
                onClicked: { xmppConnectivity.chatJid = selectedJid
                    dialog.create("qrc:/dialogs/Contact/Rename") }
            }
            MenuItem {
                text: qsTr("vCard")
                platformInverted: main.platformInverted
                onClicked: {
                    xmppConnectivity.chatJid = selectedJid
                    main.pageStack.push( "qrc:/pages/VCard" )
                    xmppConnectivity.chatJid = selectedJid
                }
            }
            MenuItem {
                text: qsTr("Subscribe")
                platformInverted: main.platformInverted
                onClicked: {dialogTitle = qsTr("Subscribed")
                    dialogText = qsTr("Sent request to ")+vars.dialogName
                    xmppConnectivity.client.subscribe( selectedJid )
                    notify.postGlobalNote(qsTr("Sent request to ")+vars.dialogName)
                }
            }
            MenuItem {
                text: qsTr("Unsubscribe")
                platformInverted: main.platformInverted
                onClicked: {dialogTitle = qsTr("Unsuscribed")
                    contactMenu.close()
                    dialogText = qsTr("Unsuscribed ")+vars.dialogName
                    xmppConnectivity.client.unsubscribe( selectedJid )
                    notify.postGlobalNote(qsTr("Unsuscribed ")+vars.dialogName)
                }
            }
        }
    }
    /*********************************************************************/

    TextField {
        id: rosterSearch
        height: 0
        width: parent.width
        anchors.bottom: parent.bottom
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
                PropertyChanges { target: vars; inputInProgress: true }
            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; }
                PropertyChanges { target: vars; inputInProgress: false }
            }
        ]
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: avkon.minimize();
            onPlatformPressAndHold: {
                notify.cleanWidget()
                Qt.quit();
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            onClicked: dialog.create("qrc:/dialogs/Contact/Add")
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-search_inverse" : "toolbar-search"
            onClicked: {
                if (rosterSearch.height == 50) {
                    rosterSearch.height = 0;
                    rosterSearch.text = ""; } else rosterSearch.height = 50
            }
        }

        ToolButton {
            id: toolBarButtonChats
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            onClicked: dialog.create("qrc:/dialogs/Chats")

            Image {
                id: imgMarkUnread
                source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                smooth: true
                sourceSize.width: toolBarButtonChats.width
                sourceSize.height: toolBarButtonChats.width
                width: toolBarButtonChats.width
                height: toolBarButtonChats.width
                visible: vars.globalUnreadCount != 0
                anchors.centerIn: parent
            }
            Text {
                id: txtUnreadMsg
                text: vars.globalUnreadCount
                font.pixelSize: 16
                anchors.centerIn: parent
                visible: vars.globalUnreadCount != 0
                z: 1
                color: main.platformInverted ? "white" : "black"
            }
        }
        ToolButton {
            id: toolBarButtonOptions
            iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
            smooth: true
            onClicked: rosterMenu.open()
        }
    }

    Rectangle {

        color: main.platformInverted ? "white" : "black"
        opacity: 0.7
        anchors { top: accountSwitcher.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        NumberAnimation { properties: "visible"; duration: 200 }

        visible: xmppConnectivity.client.status == XmppClient.Offline

        Rectangle {
            anchors.centerIn: parent
            color: "transparent"
            height: sadface.height + 5 + offlineText.height + 10 + errorText.height
            width: offlineText.width
            visible: xmppConnectivity.client.status == XmppClient.Offline
            Text {
                id: sadface
                color: vars.textColor
                anchors { top: parent.top; left: parent.left }
                visible: parent.visible
                text: ":("
                font.pixelSize: 64
            }
            Text {
                id: offlineText
                color: vars.textColor
                anchors { top: sadface.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 5 }
                visible: parent.visible
                text: settings.accounts.count() > 0 ? "You're offline" : "No accounts\navailable"
                font.pixelSize: 32
            }
            Text {
                id: errorText
                color: vars.textColor
                anchors { top: offlineText.bottom; topMargin: 10 }
                visible: parent.visible
                text: ""
                font.pixelSize: 16
            }
        }

    }

}
