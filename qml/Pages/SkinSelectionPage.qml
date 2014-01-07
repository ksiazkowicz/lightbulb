import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

Page {
    orientationLock: 1
    tools: ToolBarLayout {
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: { statusBarText.text = "Contacts"
                pageStack.pop()
            }
        }
    }

    CommonDialog {
        titleText: "Beta"
        buttonTexts: [qsTr("I understand")]
        platformInverted: main.platformInverted
        height: 200

        Component.onCompleted: open()

        content: Text {
            color: vars.textColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignJustify
            anchors { fill: parent; margins: platformStyle.paddingSmall }
            text: qsTr("This is a quick and dirty solution for testing widget skins. Don't report any issues regarding it.")
        }
    }

    Component.onCompleted: {
        statusBarText.text = qsTr("Widget Skin")
    }

    SelectorHandler { id: selector }

    ListView {
        anchors { fill: parent }
        model: selector.skins
        delegate: MouseArea {
                    height: 48
                    width: parent.width
                    Text {
                        anchors { fill: parent; margins: 10 }
                        text: selector.getSkinName(modelData)
                        color: vars.textColor
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        settings.sStr("C:\\data\\.config\\Lightbulb\\widgets\\" + modelData,"ui","widgetSkin")
                        notify.updateSkin()
                        notify.postInfo("Skin changed to " + modelData + ".");
                    }
        }
    }

}

