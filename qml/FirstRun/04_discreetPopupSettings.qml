import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Preflets"

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    Component.onCompleted: statusBarText.text = qsTr("First run")

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
            onClicked: pageStack.pop()
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: {
                popups.savePreferences()
                pageStack.push("qrc:/FirstRun/05")
            }
        }

    }

    Flickable {
        id: prefletView
        anchors.fill: parent
        contentHeight: popups.height
        contentWidth: firstRunPage.width
        flickableDirection: Flickable.VerticalFlick
        Popups {
            id: popups
            width: firstRunPage.width
        }
    }
}

