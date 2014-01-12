import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: accountsPage
    tools: toolBarAccounts

    property int currentIndex: -1;

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
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: accJid
                font.pixelSize: 18
                clip: true
                color: vars.textColor
            }
            states: State {
                name: "Current"
                when: (wrapper.ListView.isCurrentItem && (vars.accJid != "") )
                PropertyChanges { target: wrapper; gradient: gr_press }
            }

            transitions: Transition {
                //NumberAnimation { properties: "position"; duration: 300 }
            }

            MouseArea {
                id: maAccItem
                anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; }
                onDoubleClicked: {
                    vars.accJid = accJid
                    vars.accPass = accPasswd
                    vars.accDefault = switch1.checked
                    vars.accResource = accResource
                    vars.accHost = accHost
                    vars.accPort = accPort
                    vars.accManualHostPort = accManualHostPort
                    pageStack.push( "qrc:/pages/AccountsAdd" )
                }
                onClicked: {
                    wrapper.ListView.view.currentIndex = index
                    accountsPage.currentIndex = index
                    vars.accJid = accJid
                    vars.accPass = accPasswd
                    vars.accDefault = accDefault
                    vars.accResource = accResource
                    vars.accHost = accHost
                    vars.accPort = accPort
                    vars.accManualHostPort = accManualHostPort
                }
            }

        }
    }

    ListView {
        id: listViewAccounts
        anchors { fill: parent }
        clip: true
        delegate: componentAccountItem
        model: settings.accounts
    }

    Component.onCompleted: {
        settings.initListOfAccounts()
        vars.accJid = ""
        statusBarText.text = qsTr("Accounts")
    }


    /********************************( Toolbar )************************************/

    ToolBarLayout {
        id: toolBarAccounts

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                settings.initListOfAccounts()
                pageStack.pop()
                statusBarText.text = "Contacts"
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-delete_inverse" : "toolbar-delete"
            onClicked: if( vars.accJid != "" ) {
                           if (avkon.displayAvkonQueryDialog("Remove","Are you sure you want to remove account " + vars.accJid + "?")) {
                               xmppConnectivity.accountRemoved(accountsPage.currentIndex)
                               settings.removeAccount( vars.accJid )
                               settings.initListOfAccounts()
                           }
                       }
        }

        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/edit_inverse" : "qrc:/toolbar/edit"
            onClicked: if( vars.accJid != "" ) pageStack.push( "qrc:/pages/AccountsAdd" )
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            onClicked: {
                vars.accJid = "";
                pageStack.push( "qrc:/pages/AccountsAdd" )
            }
        }
    }
}
