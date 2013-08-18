import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: accAddPage

    tools: toolBarLayout

    Component.onCompleted: {
            tiJid.text = main.accJid
            tiPass.text = main.accPass
            tiHost.text = main.accHost
            tiPort.text = main.accPort
            tiResource.text = main.accResource
        if (tiJid.text != "") {
            statusBarText.text = qsTr("Editing ") + tiJid.text
        } else { statusBarText.text = qsTr("New account") }
    }

    Flickable {
        id: flickArea
        anchors { left: parent.left; leftMargin: 5; right: parent.right; rightMargin: 5; top: parent.top; topMargin: 5; bottom: parent.bottom; }

        contentHeight: contentPage.height
        contentWidth: contentPage.width

        flickableDirection: Flickable.VerticalFlick


        Column {
            id: contentPage
            width: accAddPage.width - flickArea.anchors.rightMargin - flickArea.anchors.leftMargin
            spacing: 5
            Text {
                text: "Jabber ID"
                color: main.platformInverted ? "black" : "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            TextField {
                id: tiJid
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                width: accAddPage.width - 10
                placeholderText: qsTr("login@server.com")
            }

            Item {
                id: spacer2
                height: 10
                width: accAddPage.width
            }

            Text {
                text: "Password"
                color: main.platformInverted ? "black" : "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: tiPass
                anchors.horizontalCenter: parent.horizontalCenter
                width: accAddPage.width-10
                height: 50
                echoMode: TextInput.Password
                placeholderText: qsTr("Password")
            }

            Item {
                id: spacer3
                height: 10
                width: accAddPage.width
            }

            CheckBox {
                id: checkBoxDefault
                text: qsTr("Enabled")
                checked: main.accDefault
                platformInverted: main.platformInverted
            }

            Item {
                id: spacer4
                height: 10
                width: accAddPage.width
            }

            Text {
                text: "Resource (optional)"
                color: main.platformInverted ? "black" : "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: tiResource
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                width: accAddPage.width-10
                placeholderText: qsTr("(default: Lightbulb)")

                onActiveFocusChanged: {
                    main.splitscreenY = inputContext.height - (main.height - y - height - 18)
                }
            }

            Item {
                id: spacer5
                height: 10
                width: accAddPage.width
            }

            CheckBox {
                id: checkBoxHostPort
                text: qsTr("Manually specify server host/port")
                checked: main.accManualHostPort
                platformInverted: main.platformInverted
            }

            Item {
                id: spacer6
                height: 10
                width: accAddPage.width
            }

            Rectangle {
                id: somethingInteresting
                height: 50
                width: accAddPage.width-20
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                TextField {
                    id: tiHost
                    width: parent.width-10-tiPort.width
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    readOnly: !checkBoxHostPort.checked
                    placeholderText: "talk.google.com"

                    onActiveFocusChanged: {
                        main.splitscreenY = inputContext.height - (main.height - somethingInteresting.y - somethingInteresting.height - 18)
                    }
                }
                TextField {
                   id: tiPort
                   anchors.right: parent.right
                   anchors.top: parent.top
                   anchors.bottom: parent.bottom
                   width: 60
                   readOnly: !checkBoxHostPort.checked
                   placeholderText: "5222"

                   onActiveFocusChanged: {
                       main.splitscreenY = inputContext.height - (main.height - somethingInteresting.y - somethingInteresting.height - 18)
                   }
                }
            }

        }

    }


    /******************************************/

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.replace( "qrc:/qml/AccountsPage.qml" )
            }
        }

        ToolButton {
            iconSource: "images/ok.svg"
            onClicked: {
                var jid = tiJid.text
                var pass = tiPass.text
                var isDflt = checkBoxDefault.checked == true ? true : false
                if( (jid=="") || (pass=="") ) {
                    return
                }

                var host = tiHost.text
                var port = tiPort.text
                var resource = tiResource.text
                var isHostPortManually = checkBoxHostPort.checked == true ? true : false

                settings.setAccount( jid, pass, isDflt, resource, host, port,  isHostPortManually )

                settings.initListOfAccounts()

                pageStack.replace( "qrc:/qml/AccountsPage.qml" )
            }
        }
    }
}
