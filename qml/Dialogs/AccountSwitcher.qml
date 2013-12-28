// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: accountSwitcher
    privateCloseIcon: true
    titleText: qsTr("Available accounts")

    platformInverted: main.platformInverted

    content: ListView {
        id: listViewAccounts
        clip: true
        anchors { fill: parent }
        delegate: Component {
            Rectangle {
                id: wrapper
                clip: true
                width: parent.width
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
                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: 5; leftMargin: 5 }
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
                MouseArea {
                    id: maAccItem
                    anchors.fill: parent
                    onClicked: {
                        wrapper.ListView.view.currentIndex = index
                        main.changeAccount(index)
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
