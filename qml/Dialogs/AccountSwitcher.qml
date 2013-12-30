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
        currentIndex: xmppConnectivity.currentAccount
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
                Text {
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: 10; leftMargin: 10 }
                    text: accJid
                    font.pixelSize: 18
                    clip: true
                    color: vars.textColor
                }
                states: State {
                    name: "Current"
                    when: wrapper.ListView.isCurrentItem
                    PropertyChanges { target: wrapper; gradient: gr_press }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        wrapper.ListView.view.currentIndex = index
                        xmppConnectivity.currentAccount = index
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
