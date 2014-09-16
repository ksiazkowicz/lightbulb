import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Components"

CommonDialog {
    id: accountDetails
    titleText: qsTr("Account Details")

    platformInverted: main.platformInverted
    buttonTexts: [qsTr("OK")]

    property string accountGRID: null

    function encryptPassword(password) {
        var encrypt = ""

        for (var i = 0; i < password.length; i++)
            encrypt += "•";
        return encrypt
    }

    content: Item {
        height: Math.min(flickable.contentHeight + (platformStyle.paddingLarge * 2), platformContentMaximumHeight)
        width: parent.width

        Flickable {
            id: flickable
            contentHeight: columnContent.height
            height: parent.height - (platformStyle.paddingLarge * 2)
            width: parent.width - (platformStyle.paddingLarge * 2)
            anchors { left: parent.left; top: parent.top; margins: platformStyle.paddingLarge}
            flickableDirection: Flickable.VerticalFlick
            clip: true
            interactive: contentHeight > height

            Column {
                id: columnContent
                width: parent.width
                spacing: platformStyle.paddingMedium

                DetailsItem {
                    title: qsTr("Name:")
                    value: xmppConnectivity.getAccountName(accountGRID)
                    valueFont.bold: true
                }

                LineItem {}

                DetailsItem {
                    title: qsTr("Login:")
                    value: settings.gStr(accountGRID, "jid")
                    valueFont.bold: true
                }

                LineItem {}

                Column {
                    width: parent.width
                    spacing: platformStyle.paddingSmall

                    Label {
                        platformInverted: main.platformInverted
                        text: qsTr("Password:")
                    }

                    Item {
                        anchors { left: parent.left; right: parent.right }
                        height: Math.max(passwordText.height, showPasswordButton.height)

                        property string accountPassword: settings.gStr(accountGRID, "passwd")
                        property bool isShow: false

                        Label {
                            id: passwordText

                            anchors {
                                left: parent.left
                                right: showPasswordButton.left
                                verticalCenter: parent.verticalCenter
                            }

                            platformInverted: main.platformInverted
                            font.bold: true
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                            text: parent.isShow ? parent.accountPassword : encryptPassword(parent.accountPassword)
                        }

                        ToolButton {
                            id: showPasswordButton
                            platformInverted: main.platformInverted
                            checkable: true

                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            iconSource: platformInverted ? "qrc:/toolbar/eye_inverse" : "qrc:/toolbar/eye"
                            onClicked: parent.isShow = checked
                        }
                    }
                }

                LineItem {}

                DetailsItem {
                    title: qsTr("Host:")
                    value: settings.gStr(accountGRID, "host")
                    valueFont.bold: true
                }

                LineItem {}

                DetailsItem {
                    property string port: settings.gStr(accountGRID, "port")
                    title: qsTr("Port:")
                    value: (port == "false") ? "5222" : port
                    valueFont.bold: true
                }

                LineItem { visible: resourceItem.visible }

                DetailsItem {
                    id: resourceItem
                    property string resource: settings.gStr(accountGRID, "resource")
                    title: qsTr("Resource:")
                    visible: (resource != "")
                    value: resource
                    valueFont.bold: true
                }
            }
        }

        ScrollBar {
            id: scrollBar

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: platformStyle.paddingSmall - 2
            }

            flickableItem: flickable
            interactive: false
            orientation: Qt.Vertical
            platformInverted: main.platformInverted
        }
    }

    // Code for dynamic load
    Component.onCompleted: {
        open()
        isCreated = true
    }

    property bool isCreated: false
    onStatusChanged: if (isCreated && accountDetails.status === DialogStatus.Closed) accountDetails.destroy()
}
