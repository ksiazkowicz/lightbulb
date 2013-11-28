import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

Page {
    id: vCardPage
    tools: toolBar

    property string bareJid: ""
    property bool readOnly: true

    property alias vCardPhoto: avatar.source
    property string vCardNickName: ""
    property string vCardName: ""
    property string vCardMiddleName: ""
    property string vCardLastName: ""
    property string vCardFullName: ""
    property string vCardEmail: ""
    property string vCardBirthday: ""
    property string vCardUrl: ""

    Component.onCompleted: {
        console.log("QML::VCargPage: Request vCard for: " + xmppClient.chatJid )
        xmppClient.requestVCard( xmppClient.chatJid )
        clearForm()
    }

    Connections {
        target: xmppVCard
        onVCardChanged: {
            //console.log( "QML: VCardPage: onVCardChanged: " + xmppVCard.nickname )
            if( xmppVCard.photo != "" ) {
                vCardPhoto = xmppVCard.photo
            }
            vCardNickName = xmppVCard.nickname
            vCardName = xmppVCard.name
            vCardMiddleName = xmppVCard.middlename
            vCardLastName = xmppVCard.lastname
            vCardFullName = xmppVCard.fullname
            vCardEmail = xmppVCard.email
            vCardBirthday = xmppVCard.birthday
            vCardUrl = xmppVCard.url
            bareJid = xmppVCard.jid

        }
    }
    function clearForm()
    {
        vCardPhoto = "qrc:/avatar"
        vCardNickName = ""
        vCardName = ""
        vCardMiddleName = ""
        vCardLastName = ""
        vCardFullName = ""
        vCardEmail = ""
        vCardBirthday = ""
        vCardUrl = ""
        bareJid = ""
    }

    Flickable {
        id: flickArea
        anchors.top: parent.top; anchors.topMargin: 12
        anchors.bottom: parent.bottom; anchors.bottomMargin: 12
        anchors.left: parent.left; anchors.leftMargin: 20
        anchors.right: parent.right; anchors.rightMargin: 20

        contentHeight: columnContent.height
        contentWidth: columnContent.width

        flickableDirection: Flickable.VerticalFlick

        Column {
            id: columnContent
            width: vCardPage.width - flickArea.anchors.rightMargin - flickArea.anchors.leftMargin
            spacing: 5

            Row {
                id: rowAvatarAndJid
                height: avatar.height
                width: columnContent.width
                spacing: 15
                Image {
                    id: avatar
                    smooth: true
                    width: 128
                    height: 128
                    source: "qrc:/avatar"
                    sourceSize.height: height
                    sourceSize.width: width
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item {
                    id: container
                    width: parent.width - 143
                    anchors { right: parent.right; rightMargin: 10; }
                    Text {
                        id: txtJid
                        width: container.width
                        text: xmppClient.contactName
                        wrapMode: Text.Wrap
                        color: main.textColor
                    }
                    Row {
                        spacing: 5
                        anchors { top: txtJid.bottom }
                        Image {
                            id: statusImg
                            width: 24
                            source: selectedContactPresence
                            sourceSize.height: 24
                            sourceSize.width: 24
                        }
                        Text {
                            width: columnContent.width - 162
                            font.pixelSize: 18
                            text: selectedContactStatusText
                            color: "gray"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }


            Text {
                id: txtNickname
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardNickName != "" ? "<b>" + qsTr("Nickname") + "</b><br />" + vCardNickName : ""
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtNickname.visible
            }

            Text {
                id: txtName
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardName != "" ? "<b>" + qsTr("Name") + "</b><br />" + vCardName : ""
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtName.visible
            }

            Text {
                id: txtMiddleName
                text: vCardMiddleName != "" ? "<b>" + qsTr("Middle name") + "</b><br />" + vCardMiddleName : ""
                anchors { left: parent.left; leftMargin: 10 }
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtMiddleName.visible
            }

            Text {
                id: txtLastName
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardLastName != "" ? "<b>" + qsTr("Lastname") + "</b><br />" + vCardLastName : ""
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtLastName.visible
            }

            Text {
                id: txtFullName
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardFullName != "" ? "<b>" + qsTr("Full name") + "</b><br />" + vCardFullName : ""
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtFullName.visible
            }

            Text {
                id: txtBareJid
                anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                text: "<b>" + qsTr("Jabber ID") + "</b><br />" + bareJid
                font.pixelSize: 18
                color: main.textColor
                width: parent.width
                wrapMode: Text.WrapAnywhere
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
            }

            Text {
                id: txtEmail
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardEmail != "" ? "<b>" + qsTr("E-mail") + "</b><br />" + vCardEmail : ""
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtEmail.visible
            }

            Text {
                id: txtBirthday
                anchors { left: parent.left; leftMargin: 10 }
                text: vCardBirthday != "" ? "<b>" + qsTr("Birthday") + "</b><br />" + vCardBirthday : ""
                font.pixelSize: 18
                color: main.textColor
                visible: text != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                opacity: 0.5
                width: parent.width
                visible: txtBirthday.visible
            }

            Text {
                id: txtUrl
                anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                text: vCardUrl != "" ? "<b>" + qsTr("Website") + "</b><br /><a href=\"" + vCardUrl + "\">" + vCardUrl + "</a>" : ""
                font.pixelSize: 18
                color: main.textColor
                wrapMode: Text.WrapAnywhere
                width: parent.width
                visible: text != ""
                onLinkActivated: { main.url=link; linkContextMenu.open()}
            }


        }

    }

    ToolBarLayout {
        id: toolBar
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: {
                pageStack.pop()
                statusBarText.text = "Contacts"
                xmppClient.chatJid = ""
            }
        }
    }

}
