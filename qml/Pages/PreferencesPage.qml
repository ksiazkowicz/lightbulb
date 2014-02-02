import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page {
    id: preferencesPage
    tools: ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Rectangle {
        id: prefletSwitcher

        height: 46

        z: 1

        gradient: Gradient {
            GradientStop { position: 0; color: "#3c3c3c" }
            GradientStop { position: 0.04; color: "#6c6c6c" }
            GradientStop { position: 0.05; color: "#3c3c3c" }
            GradientStop { position: 0.06; color: "#4c4c4c" }
            GradientStop { position: 1; color: "#191919" }
        }

        anchors { top: parent.top; left: parent.left; right: parent.right }

        Text {
            id: titleText
            anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: platformStyle.paddingSmall  }
            text: "Discreet popups"
            color: "white"
            font.pixelSize: 20
        }
        ToolButton {
            iconSource: "toolbar-list"
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: platformStyle.paddingSmall }
        }
    }
    Flickable {
        id: prefletView
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: prefletSwitcher.bottom }
        contentHeight: preflet.height
        contentWidth: preferencesPage.width
        flickableDirection: Flickable.VerticalFlick
        Loader {
            id: preflet
            source: "qrc:/Preflets/Popups.qml"
            width: preferencesPage.width
        }
    }

}
