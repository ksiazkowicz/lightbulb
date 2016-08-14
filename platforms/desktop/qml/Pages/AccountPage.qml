import QtQuick 2.3
import QtQuick.Controls 2.0
import lightbulb 1.0
import "../Components"

Page {
    Component {
            id: componentAccountItem

            Rectangle {
                width: parent.width
                height: 60
                color: "transparent"
                AccountItem {
                    text: xmppConnectivity.getAccountName(accGRID)
                    icon: "qrc:/accounts/" + xmppConnectivity.getAccountIcon(accGRID)

                    onEditButtonClick: main.stack.replace( "qrc:/Pages/AccountAdd", {"accGRID":accGRID})
                    onRemoveButtonClick: {
                        if (avkon.displayAvkonQueryDialog("Remove","Are you sure you want to remove account " + accJid + "?"))
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
    Button {
        anchors { top: parent.top; right: parent.right; }
        text: "doda"
        onClicked: parent.parent.parent.replace("qrc:/Pages/AccountAdd")
    }

    ListView {
        id: listViewAccounts
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; top: accountsLabel.bottom }
        delegate: componentAccountItem
        model: settings.accounts
    }
}
