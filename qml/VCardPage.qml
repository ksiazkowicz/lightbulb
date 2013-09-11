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
        if( main.requestMyVCard == true ) {
            console.log("QML::VCargPage: Request vCard for: " + xmppClient.myBareJid )
            xmppClient.requestVCard( xmppClient.myBareJid )
        } else {
            console.log("QML::VCargPage: Request vCard for: " + xmppClient.chatJid )
            xmppClient.requestVCard( xmppClient.chatJid )
        }
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
        vCardPhoto = "images/avatar.png"
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
                    height: 128
                    width: height
                    source: "images/avatar.png"
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
                        text: requestMyVCard ? "Me" : xmppClient.getNameByJid(bareJid)
                        wrapMode: Text.Wrap
                        color: main.textColor
                    }
                    Row {
                        anchors { top: txtJid.bottom }
                        Image {
                            id: statusImg
                            source: xmppClient.getPicPresenceByJid(bareJid)
                            sourceSize.height: 24
                            sourceSize.width: 24
                            anchors { top: parent.top; left: parent.left }
                        }
                        Text {
                            anchors { left: parent.left; leftMargin: 24; }
                            width: columnContent.width - 162
                            font.pixelSize: 18
                            text: xmppClient.getStatusTextByJid(bareJid)
                            color: "gray"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }


            Text {
                id: txtNickname
                text: "<b>" + qsTr("Nickname") + "</b><br />" + vCardNickName
                font.pixelSize: 18
                color: main.textColor
                height: vCardNickName != "" ? 41 : 0
                visible: vCardNickName != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtNickname.visible
            }

            Text {
                id: txtName
                text: "<b>" + qsTr("Name") + "</b><br />" + vCardName
                font.pixelSize: 18
                color: main.textColor
                height: vCardName != "" ? 41 : 0
                visible: vCardName != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtName.visible
            }

            Text {
                id: txtMiddleName
                text: "<b>" + qsTr("Middle name") + "</b><br />" + vCardMiddleName
                font.pixelSize: 18
                color: main.textColor
                height: vCardMiddleName != "" ? 41 : 0
                visible: vCardMiddleName != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtMiddleName.visible
            }

            Text {
                id: txtLastName
                text: "<b>" + qsTr("Lastname") + "</b><br />" + vCardLastName
                font.pixelSize: 18
                color: main.textColor
                height: vCardLastName != "" ? 41 : 0
                visible: vCardLastName != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtLastName.visible
            }

            Text {
                id: txtFullName
                text: "<b>" + qsTr("Full name") + "</b><br />" + vCardFullName
                font.pixelSize: 18
                color: main.textColor
                height: vCardFullName != "" ? 41 : 0
                visible: vCardFullName != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtFullName.visible
            }

            Text {
                id: txtEmail
                text: "<b>" + qsTr("E-mail") + "</b><br />" + vCardEmail
                font.pixelSize: 18
                color: main.textColor
                height: vCardEmail != "" ? 41 : 0
                visible: vCardEmail != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtEmail.visible
            }

            Text {
                id: txtBirthday
                text: "<b>" + qsTr("Birthday") + "</b><br />" + vCardBirthday
                font.pixelSize: 18
                color: main.textColor
                height: vCardBirthday != "" ? 41 : 0
                visible: vCardBirthday != ""
            }
            Rectangle {
                color: "gray"
                height: 1
                width: parent.width
                visible: txtBirthday.visible
            }

            Text {
                id: txtUrl
                text: "<b>" + qsTr("Website") + "</b><br /><a href=\"" + vCardUrl + "\">" + vCardUrl + "</a>"
                font.pixelSize: 18
                color: main.textColor
                wrapMode: Text.WrapAnywhere
                width: parent.width
                height: vCardUrl != "" ? ((txtUrl.lineCount+1)*18)+5 : 0
                visible: vCardUrl != ""
                onLinkActivated: { main.url=link; linkContextMenu.open()}
            }


        }

    }

    ToolBarLayout {
        id: toolBar
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
                statusBarText.text = "Contacts"
                xmppClient.chatJid = ""
            }
        }/*
        ToolButton {
            iconSource: "images/bar_ok.png"
            anchors.left: parent.left
            anchors.leftMargin: (3.5*(parent.width/4) - 0.5*toolBarButtonOptions.width)
            onClicked: {
                //TODO: Отправка vCard на сервер
                //xmppClient.setMyVCard()
                var objVCard = Qt.createQmlObject("import QtQuick 1.1; import meegim 1.0; XmppVCard {}", parent, "VCardPage.qml: XmppVCard" )
                objVCard.name = "xyxyxy"
                console.log(objVCard.name)
            }
            visible: false
        }*/
    }

}
