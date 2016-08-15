import QtQuick 2.3
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: page
    property alias stack: page.parent

    Component {
            id: componentAccountItem

            Rectangle {
                width: parent.width
                height: 60
                color: "transparent"
                AccountItem {
                    text: xmppConnectivity.getAccountName(accGRID)
                    icon: "qrc:/accounts/" + xmppConnectivity.getAccountIcon(accGRID)

                    onEditButtonClick: stack.replace( "qrc:/Pages/AccountAdd", {"accGRID":accGRID})
                    onRemoveButtonClick: {
                        settings.removeAccount(accGRID)
                    }
                }

                //onClicked: dialog.createWithProperties("qrc:/dialogs/AccountDetails", {"accountGRID": accGRID})
            }
        }


    Label {
        id: accountsLabel
        text: "KONTA"
        font.bold: true
        anchors { top: parent.top; left: parent.left; margins: 20; }
    }

    ListView {
        id: listViewAccounts
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; top: accountsLabel.bottom }
        delegate: componentAccountItem
        model: settings.accounts
    }

    footer: ToolBar {
            RowLayout {
                anchors.fill: parent
                ToolButton {
                    text: "\uE72B"
                    font.family: "Segoe MDL2 Assets"
                    enabled: stack.depth > 1
                    onClicked: stack.pop()
                }
                Item { Layout.fillWidth: true }
                ToolButton {
                    id: menuButton
                    text: "\uE710"
                    font.family: "Segoe MDL2 Assets"
                    onClicked: stack.replace("qrc:/Pages/AccountAdd")

                }
            }
        }
}