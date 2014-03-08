// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: accountSwitcher
    privateCloseIcon: true
    titleText: qsTr("Available accounts")
    buttonTexts: [qsTr("Settings")]
    height: 320

    platformInverted: main.platformInverted

    onButtonClicked: {
        main.pageStack.push( "qrc:/pages/Accounts" )
    }

    content: ListView {
        id: listViewAccounts
        clip: true
        anchors { fill: parent }

        delegate: Component {
            Rectangle {
                id: wrapper
                clip: true
                width: parent.width
                height: 48
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
                    id: imgPresence
                    source: "qrc:/presence/" + notify.getStatusNameByIndex(xmppConnectivity.getStatusByIndex(accGRID))
                    sourceSize.height: 24
                    sourceSize.width: 24
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                    height: 24
                    width: 24
                }
                Text {
                    anchors { verticalCenter: parent.verticalCenter; left: imgPresence.right; right: parent.right; rightMargin: 10; leftMargin: 10 }
                    text: xmppConnectivity.getAccountName(accGRID)
                    font.pixelSize: 18
                    clip: true
                    color: vars.textColor
                }
                Image {
                    id: imgAccount
                    source: "qrc:/accounts/" + accIcon
                    sourceSize.height: 24
                    sourceSize.width: 24
                    anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 10 }
                    height: 24
                    width: 24
                }
                states: State {
                    name: "Current"
                    when: xmppConnectivity.currentAccount == accGRID
                    PropertyChanges { target: wrapper; gradient: gr_press }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wrapper.ListView.view.currentIndex = index
                        main.changeAccount(accGRID)
                        close()
                    }
                }
            }
         }
        model: settings.accounts
    }

    Component.onCompleted: {
        settings.initListOfAccounts()
        open()
    }
}
