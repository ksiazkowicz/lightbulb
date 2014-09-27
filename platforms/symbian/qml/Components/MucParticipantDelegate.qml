// import QtQuick 1.1 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import lightbulb 1.0
import com.nokia.symbian 1.1

Item {
    id: mucPartDelegate
    height: platformStyle.graphicSizeMedium + platformStyle.paddingLarge
    property string contactJid
    property string accountId
    property bool kick
    property bool permission
    Image {
        id: imgPresence
        source: presence
        sourceSize { height: platformStyle.graphicSizeTiny; width: platformStyle.graphicSizeTiny }
        anchors { verticalCenter: mucPartDelegate.verticalCenter; left: parent.left; leftMargin: platformStyle.paddingMedium; }
    }
    Image {
        source: visible ? "qrc:/muc_modOverlay" : ""
        sourceSize { height: platformStyle.graphicSizeMedium; width: platformStyle.graphicSizeMedium }
        anchors { verticalCenter: mucPartDelegate.verticalCenter; left: parent.left; leftMargin: platformStyle.paddingSmall; }
        smooth: visible
        visible: xmppConnectivity.getMUCParticipantAffiliationName(affiliation) == "admin"
    }
    Flickable {
        id: flick
        flickableDirection: Flickable.HorizontalFlick
        interactive: (kick || permission)
        boundsBehavior: Flickable.DragOverBounds
        height: mucPartDelegate.height
        width: mucPartDelegate.width
        contentWidth: wrapper.width + buttonRow.width+platformStyle.paddingMedium

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
                if ((contentX/buttonRow.width) >= 0.5) {
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
            height: flick.height
            Text {
                id: partName
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; rightMargin: platformStyle.paddingSmall; leftMargin: platformStyle.graphicSizeMedium + platformStyle.paddingLarge }
                text: name
                font.pixelSize: platformStyle.fontSizeSmall
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
                platformInverted: main.platformInverted
                onClicked: dialog.createWithProperties("qrc:/dialogs/MUC/Query",{"contactJid":contactJid,"accountId":accountId,"userJid":bareJid,"titleText":qsTr("Kick reason (optional)"),"actionType":1})
            }
            ToolButton {
                text: "Ban"
                enabled: permission
                platformInverted: main.platformInverted
                onClicked: dialog.createWithProperties("qrc:/dialogs/MUC/Query",{"contactJid":contactJid,"accountId":accountId,"userJid":bareJid,"titleText":qsTr("Ban reason (optional)"),"actionType":2})
            }
        }
    }
}
