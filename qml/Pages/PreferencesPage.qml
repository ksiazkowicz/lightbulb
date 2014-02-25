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

    SelectionDialog {
        id: selectionDialog
        titleText: "Pages"
        selectedIndex: -1
        platformInverted: main.platformInverted
        model: ListModel {
            ListElement { name: "Events" }
            ListElement { name: "Popups" }
            ListElement { name: "Widget" }
            ListElement { name: "Connection" }
            ListElement { name: "Notification LED" }
            ListElement { name: "Colors" }
            ListElement { name: "Contact list" }
            ListElement { name: "Advanced" }
        }
        onSelectedIndexChanged: {
            switch (selectedIndex) {
                case 0: {
                    titleText.text = "Events";
                    preflet.source = "qrc:/Preflets/Events";
                    break;
                }
                case 1: {
                    titleText.text = "Discreet popups";
                    preflet.source = "qrc:/Preflets/Popups";
                    break;
                }
                case 2: {
                    titleText.text = "Homescreen widget";
                    preflet.source = "qrc:/Preflets/Widget";
                    break;
                }
                case 3: {
                    titleText.text = "Connection";
                    preflet.source = "qrc:/Preflets/Connection";
                    break;
                }
                case 4: {
                    titleText.text = "Notification LED";
                    break;
                }
                case 5: {
                    titleText.text = "Colors";
                    preflet.source = "qrc:/Preflets/Colors";
                    break;
                }
                case 6: {
                    titleText.text = "Contact list";
                    preflet.source = "qrc:/Preflets/Roster";
                    break;
                }
                case 7: {
                    titleText.text = "Advanced";
                    preflet.source = "qrc:/Preflets/Advanced";
                    break;
                }
                default: break;
            }
            preflet.width = preferencesPage.width;
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
            onClicked: {
                selectionDialog.open()
            }
        }
    }
    Flickable {
        id: prefletView
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: prefletSwitcher.bottom }
        contentHeight: preflet.item.height
        contentWidth: preferencesPage.width
        flickableDirection: Flickable.VerticalFlick
        Loader {
            id: preflet
            source: "qrc:/Preflets/Popups"
            width: preferencesPage.width
        }
    }

}
