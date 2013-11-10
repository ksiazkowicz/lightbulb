// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    Component.onCompleted: statusBarText.text = qsTr("First run")

    Text {
        id: chapter
        color: main.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Account setup"
    }

    Text {
        id: text
        color: main.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: qsTr("In this step you're going to configure your account. Enter your accounts details and tap Next to continue.");
    }

    // account setup

    SelectionListItem {
        id: serverSelection
        platformInverted: main.platformInverted
        subTitle: selectionDialog.selectedIndex >= 0
                  ? selectionDialog.model.get(selectionDialog.selectedIndex).name
                  : "FB Chat, GTalk or manual"
        anchors { top: text.bottom; topMargin: 24 }
        title: "Server"

        onClicked: selectionDialog.open()

        SelectionDialog {
            id: selectionDialog
            titleText: "Available options"
            selectedIndex: -1
            model: ListModel {
                ListElement { name: "Facebook Chat" }
                ListElement { name: "Google Talk" }
                ListElement { name: "Generic XMPP server" }
            }
            onSelectedIndexChanged: {
                tiPass.text = ""
                tiPort.text = "5222"
                if (selectionDialog.selectedIndex == 0) {
                    tiJid.text = "@chat.facebook.com";
                    tiHost.text = "chat.facebook.com";
                }
                if (selectionDialog.selectedIndex == 1) {
                        tiJid.text = "@gmail.com";
                        tiHost.text = "talk.google.com";
                        break;
                }
                if (selectionDialog.selectedIndex == 2) {
                        tiJid.text = "";
                        tiHost.text = "";
                        break;
                }
            }
        }
    }

    Column {
        id: contentPage
        width: firstRunPage.width - 20
        anchors { top: serverSelection.bottom; bottom: toolBarLayout.top; topMargin: 10; horizontalCenter: parent.horizontalCenter }
        visible: serverSelection.visible
        spacing: 5
        Text {
            text: "Login"
            color: main.textColor
        }
        TextField {
            id: tiJid
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            width: firstRunPage.width - 10
            placeholderText: qsTr("login@server.com")
            onActiveFocusChanged: {
                main.splitscreenY = inputContext.height - (main.height - tiJid.y) + 1.5*tiPass.height
                console.log(main.splitscreenY)
            }
        }

        Item {
            id: spacer2
            height: 5
            width: firstRunPage.width
        }

        Text {
            text: "Password"
            color: main.textColor
        }

        TextField {
            id: tiPass
            anchors.horizontalCenter: parent.horizontalCenter
            width: firstRunPage.width-10
            height: 50
            echoMode: TextInput.Password
            placeholderText: qsTr("Password")
            onActiveFocusChanged: {

            }
        }

        Item {
            id: spacer3
            height: 5
            width: firstRunPage.width
        }

        Text {
            text: "Server"
            color: main.textColor
            visible: selectionDialog.selectedIndex == 2
        }

        Rectangle {
            id: somethingInteresting
            height: 50
            width: firstRunPage.width-10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            visible: selectionDialog.selectedIndex == 2
            TextField {
                id: tiHost
                width: parent.width-10-tiPort.width
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                readOnly: !selectionDialog.selectedIndex == 2
                placeholderText: "talk.google.com"

                onActiveFocusChanged: {
                    main.splitscreenY = inputContext.height - (main.height - somethingInteresting.y) + 1.5*somethingInteresting.height
                }
            }
            TextField {
               id: tiPort
               anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
               width: 60
               readOnly: !selectionDialog.selectedIndex == 2
               placeholderText: "5222"

               onActiveFocusChanged: {
                   main.splitscreenY = inputContext.height - (main.height - somethingInteresting.y) + 1.5*somethingInteresting.height
               }
            }
        }

    }



    // toolbar

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
            onClicked: {
                globalUnreadCount++;
                pageStack.pop()
            }
        }

        ToolButton {
            text: "Skip"
            platformInverted: main.platformInverted
            onClicked: pageStack.push("qrc:/FirstRun/04")
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: {
                if (tiJid.text == "" || tiJid.text == "@gmail.com" || tiJid.text == "@chat.facebook.com" || tiPass.text == "" || tiHost.text == "" || tiPort.text == "") {
                    notify.postInfo("Incomplete account details. Unable to continue.");
                    return
                }

                settings.setAccount( tiJid.text, tiPass.text, true, "Lightbulb", tiHost.text, tiPort.text, true )

                settings.initListOfAccounts()

                pageStack.push("qrc:/FirstRun/04")
            }
        }
    }


}

