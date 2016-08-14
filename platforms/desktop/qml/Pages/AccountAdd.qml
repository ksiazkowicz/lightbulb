import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import "../Components"

Page {
    id: accAddPage
    property alias stack: accAddPage.parent

    property string accGRID: ""
    property string pageName: accGRID !== "" ? qsTr("Editing ") + xmppConnectivity.getAccountName(accGRID) : "New account"

    Component.onCompleted: {
        if (accGRID != "") {
            if (settings.gStr(accGRID,'host') == "chat.facebook.com")
                serverSelection.currentIndex = 0;
            else if (settings.gStr(accGRID,'host') == "talk.google.com")
                serverSelection.currentIndex = 1;
            else
                serverSelection.currentIndex = 2;

            name.value = settings.gStr(accGRID,'name')
            login.value = settings.gStr(accGRID,'jid')
            password.value = settings.gStr(accGRID,'passwd')
            serverDetails.value = settings.gStr(accGRID,'host') + ":" + settings.gStr(accGRID,'port')
            resource.value = settings.gStr(accGRID,'resource')
            if (name.value == "false")
                name.value = "";
        }
    }

    Flickable {
        id: flickArea
        anchors { left: parent.left; leftMargin: 5; right: parent.right; rightMargin: 5; top: parent.top; topMargin: 5; bottom: parent.bottom; }

        contentHeight: contentPage.height
        contentWidth: contentPage.width

        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            id: contentPage
            width: accAddPage.width - flickArea.anchors.rightMargin - flickArea.anchors.leftMargin
            spacing: 5
            Label {
                text: "Server"
            }

            ComboBox {
                id: serverSelection
                anchors { left: parent.left; right: parent.right }
                model: ["Facebook Chat", "Google Talk", "Generic XMPP server"]
                onCurrentIndexChanged: {
                    password.value = ""
                    switch (serverSelection.currentIndex) {
                        case 0: {
                            login.value = "@chat.facebook.com";
                            serverDetails.value = "chat.facebook.com:5222";
                            break;
                        }
                        case 1: {
                            login.value = "@gmail.com";
                            serverDetails.value = "talk.google.com:5222";
                            break;
                        }
                        case 2: {
                            login.value = "";
                            serverDetails.value = "";
                            break;
                        }
                    }
                }
            }

            SettingField {
                id: name
                settingLabel: "Name (optional)"
                width: parent.width
            }

            SettingField {
                id: login
                settingLabel: "Login"
                placeholder: "login@server.com"
                enabled: serverSelection.currentIndex != -1
                width: parent.width
            }

            SettingField {
                id: password
                settingLabel: "Password"
                enabled: serverSelection.currentIndex != -1
                width: parent.width
                echoMode: TextInput.Password
            }

            SettingField {
                id: resource
                settingLabel: "Resource (optional)"
                placeholder: "(default: Lightbulb)"
                enabled: serverSelection.currentIndex != -1
                width: parent.width
            }

            SettingField {
                id: serverDetails
                settingLabel: "Server details"
                placeholder: "talk.google.com:5222"
                enabled: serverSelection.currentIndex == 2
                visible: enabled
                width: parent.width
                height: visible ? 66 : 0

                // need support for input validation
            }

            CheckBox {
               id: goOnline
               text: qsTr("Go online on startup")
               enabled: serverSelection.currentIndex != -1
               checked: settings.gBool(accGRID,'connectOnStart')
            }
        }
    }

    /******************************************/

    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: "\uE72B"
                font.family: "Segoe MDL2 Assets"
                enabled: stack.depth > 1
                onClicked: stack.replace("qrc:/Pages/AccountPage")
            }
            Item { Layout.fillWidth: true }
            ToolButton {
                text: "\uE73E"
                font.family: "Segoe MDL2 Assets"
                enabled: login.value !== "" && password.value !== "" && serverSelection.currentIndex != -1
                onClicked: {
                    var grid,vName,icon;
                    grid = accGRID != "" ? accGRID : settings.generateGRID();
                    vName = name.value == "" ? xmppConnectivity.generateAccountName(serverDetails.value.split(":")[0],login.value) : name.value
                    switch (serverSelection.currentIndex) {
                        case 0: icon = "facebook"; break;
                        case 1: icon = "hangouts"; break;
                        case 2: icon = "xmpp"; break;
                    }

                    settings.setAccount(grid,vName,icon,login.value, password.value,goOnline.checked,resource.value,serverDetails.value.split(":")[0],serverDetails.value.split(":")[1],true)
                    stack.pop()
                }
            }
        }
    }
}
