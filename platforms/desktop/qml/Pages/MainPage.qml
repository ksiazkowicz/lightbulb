import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls.Universal 2.0

Page {
    id: mainPage
    property alias stack: mainPage.parent
    property string grid: ""

    Label {
        id: rak
        text: "dzialalo przez " + xmppConnectivity.dupa + "s"
    }
    Label {
        id: rak2
        anchors { top: rak.bottom; }
        text: "uzywane konto: " + mainPage.grid

    }

    Connections {
        target: xmppConnectivity
        onDupaChanged: rak.text = "dzialalo przez " + xmppConnectivity.dupa + "s"
        onInitready: {
            mainPage.grid = xmppConnectivity.getFirstGrid()
            rak2.text = "uzywane konto: " + mainPage.grid
        }
    }

    footer: ToolBar {
            RowLayout {
                anchors.fill: parent
                /*ToolButton {
                    text: "\uE72B"
                    font.family: "Segoe MDL2 Assets"
                    enabled: stack.depth > 1
                    onClicked: stack.pop()
                }*/
                Item { Layout.fillWidth: true }
                ToolButton {
                    text: qsTr("Hehe")
                    onClicked: xmppConnectivity.useClient("jiddupa2").connectToXmppServer()
                }
                ToolButton {
                    id: menuButton
                    text: "\uE712"
                    font.family: "Segoe MDL2 Assets"
                    onClicked: mainMenu.open()

                    Menu {
                        y: -mainMenu.height
                        id: mainMenu
                        MenuItem {
                            text: qsTr("Join a MUC")
                            onClicked: dialog.createWithContext("qrc:/dialogs/MUC/Join")
                        }
                        MenuItem {
                            text: qsTr("Browse services")
                            onClicked: dialog.createWithContext("qrc:/dialogs/Services/Ask")
                        }
                        MenuItem {
                            text: qsTr("Preferences")
                            onClicked: stack.push( "qrc:/pages/Preferences" )
                        }
                        MenuItem {
                            text: qsTr("XML Console")
                            onClicked: stack.push( "qrc:/pages/XMLConsole" )
                        }
                        MenuItem {
                            text: qsTr("About...")
                            onClicked: stack.push( "qrc:/Pages/AboutPage" )
                        }
                        MenuItem {
                            text: qsTr("Exit")
                            onClicked: {
                                Qt.quit()
                            }
                        }
                        MenuItem {
                            text: qsTr("Accounts")
                            onClicked: stack.push("qrc:/Pages/AccountPage")
                        }
                    }
                }
            }
        }

}
