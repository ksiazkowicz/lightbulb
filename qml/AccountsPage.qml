import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: accountsPage
    tools: toolBarAccounts

    /********************************************************************************/

    Component {
        id: componentAccountItem
        Rectangle {
            id: wrapper
            clip: true
            width: listViewAccounts.width
            height: 64
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
            Text {
                id: txtAcc
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: switch1.left
                anchors.rightMargin: 10
                text: accJid
                font.pixelSize: 18
                clip: true
                color: main.textColor
            }
            Switch {
                id: switch1
                anchors.right: parent.right; anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                checked: accDefault

                onClicked: {
                    settings.setAccount( accJid, accPasswd, switch1.checked, accResource, accHost, accPort, accManualHostPort )
                }
            }
            states: State {
                name: "Current"
                when: (wrapper.ListView.isCurrentItem && (main.accJid != "") )
                //PropertyChanges { target: wrapper; color: "lightblue" }
                PropertyChanges { target: wrapper; gradient: gr_press }
            }

            transitions: Transition {
                //NumberAnimation { properties: "position"; duration: 300 }
            }

            MouseArea {
                id: maAccItem
                anchors { left: parent.left; right: switch1.left; top: parent.top; bottom: parent.bottom; }
                onDoubleClicked: {
                    main.accJid = accJid
                    main.accPass = accPasswd
                    main.accDefault = switch1.checked
                    main.accResource = accResource
                    main.accHost = accHost
                    main.accPort = accPort
                    main.accManualHostPort = accManualHostPort
                    pageStack.push( "qrc:/qml/AccountAddPage.qml" )
                }
                onClicked: {
                    wrapper.ListView.view.currentIndex = index
                    main.accJid = accJid
                    main.accPass = accPasswd
                    main.accDefault = accDefault
                    main.accResource = accResource
                    main.accHost = accHost
                    main.accPort = accPort
                    main.accManualHostPort = accManualHostPort
                }
            }

        }
    }

    Rectangle {
        id: thisReallySucks
        anchors.top: parent.top
        width: parent.width
        height: 96
        color: "red"

        Text {
            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 10; bottom: parent.bottom; bottomMargin: 10; }
            text: "Due to limitations of this app, only one account can be enabled at the same time. Sorry."
            wrapMode: Text.Wrap
            color: "white"
        }
    }

    ListView {
        id: listViewAccounts
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; top: thisReallySucks.bottom }
        clip: true
        delegate: componentAccountItem
        model: settings.accounts
    }

    Component.onCompleted: {
        settings.initListOfAccounts()
        main.accJid = ""
        statusBarText.text = qsTr("Accounts")
    }


    /********************************( Toolbar )************************************/

    ToolBarLayout {
        id: toolBarAccounts

        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                main.initAccount()
                pageStack.pop()
                statusBarText.text = "Contacts"
            }
        }

        ToolButton {
            iconSource: "toolbar-delete"
            onClicked: {
                if( main.accJid != "" ) {
                    dialogQueryRemove.open()
                }
            }
        }

        ToolButton {
            iconSource: "images/edit.svg"
            onClicked: {
                if( main.accJid != "" ) {
                    pageStack.push( "qrc:/qml/AccountAddPage.qml" )
                }
            }
        }

        ToolButton {
            iconSource: "toolbar-add"
            onClicked: {
                addMenu.open()
            }
        }
    }


    /*********************************************************************/
    CommonDialog {
        id: dialogQueryRemove
        titleText: qsTr("Remove account")

        buttonTexts: [qsTr("Yes"), qsTr("No")]

        onButtonClicked: {
            if (index === 0) {
                settings.removeAccount( main.accJid )
                settings.initListOfAccounts()
            }
        }

        content: Label { id: dialogInfoLabel; anchors.centerIn: parent; text: qsTr("Remove ") + main.accJid + "?";}
    }


    /*********************************************************************/

    Menu {
        id: addMenu
        // define the items in the menu and corresponding actions
        content: MenuLayout {
            MenuItem {
                text: qsTr("Facebook")
                onClicked: {
                    main.accJid = "@chat.facebook.com"
                    main.accPass = ""
                    main.accDefault = false
                    main.accManualHostPort = true
                    main.accResource = ""
                    main.accHost = "chat.facebook.com"
                    main.accPort = "5222"
                    pageStack.push( "qrc:/qml/AccountAddPage.qml" )
                }
            }
            MenuItem {
                text: qsTr("Google Talk")
                onClicked: {
                    main.accJid = "@gmail.com"
                    main.accPass = ""
                    main.accDefault = false
                    main.accManualHostPort = true
                    main.accResource = ""
                    main.accHost = "talk.google.com"
                    main.accPort = "5222"
                    pageStack.push( "qrc:/qml/AccountAddPage.qml" )
                }
            }
            MenuItem {
                text: qsTr("Manual")
                onClicked: {
                    main.accJid = ""
                    main.accPass = ""
                    main.accDefault = false
                    main.accResource = ""
                    main.accHost = ""
                    main.accPort = "5222"
                    pageStack.push( "qrc:/qml/AccountAddPage.qml" )
                }
            }
        }
    }

}
