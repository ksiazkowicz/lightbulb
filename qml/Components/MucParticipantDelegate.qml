// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Item {
    id: mucPartDelegate
    height: 48
    property string contactJid
    property string accountId
    property bool kick
    property bool permission
    Image {
        id: imgPresence
        source: presence
        sourceSize { height: 24; width: 24 }
        anchors { verticalCenter: mucPartDelegate.verticalCenter; left: parent.left; leftMargin: 10; }
        height: 24
        width: 24
    }
    Image {
        source: visible ? "qrc:/muc_modOverlay" : ""
        sourceSize { height: 32; width: 32 }
        anchors { verticalCenter: mucPartDelegate.verticalCenter; left: parent.left; leftMargin: 4; }
        smooth: visible
        visible: xmppConnectivity.getMUCParticipantAffiliationName(affiliation) == "admin"
    }
    Flickable {
        id: flick
        flickableDirection: Flickable.HorizontalFlick
        interactive: (kick || permission)
        boundsBehavior: Flickable.DragOverBounds
        height: 48
        width: mucPartDelegate.width
        contentWidth: wrapper.width + buttonRow.width+10

        NumberAnimation {
            id: animation
            target: flick
            property: "contentX"
            to: 1.0
            duration: 250
            easing.type: Easing.Linear
            running: false
        }

        onMovingChanged: {
            if (!flicking && !moving) {
                if ((contentX/buttonRow.width)) >= 0.5) {
                    animation.to = wrapper.width;
                    animation.from = contentX;
                    animation.running = true;
                } else {
                    animation.to = 0;
                    animation.from = contentX;
                    animation.running = true;
                }
            }
        }

        onContentXChanged: partName.opacity = 1-(contentX/buttonRow.width)

        Item {
            id: wrapper
            width: mucPartDelegate.width
            anchors.left: parent.left
            height: 48
            Text {
                id: partName
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: 5; leftMargin: 44 }
                text: name
                font.pixelSize: 18
                clip: true
                color: main.textColor
                elide: Text.ElideRight
            }
        }
        ButtonRow {
            id: buttonRow
            anchors.left: wrapper.right;
            visible: kick || permission
            ToolButton {
                text: "Kick"
                enabled: kick
                onClicked: dialog.createWithProperties("qrc:/dialogs/MUC/Query",{"contactJid":contactJid,"accountId":accountId,"userJid":bareJid,"titleText":qsTr("Kick reason (optional)"),"actionType":1})
            }
            ToolButton {
                text: "Ban"
                enabled: permission
                onClicked: dialog.createWithProperties("qrc:/dialogs/MUC/Query",{"contactJid":contactJid,"accountId":accountId,"userJid":bareJid,"titleText":qsTr("Ban reason (optional)"),"actionType":2})
            }
        }
    }
}
