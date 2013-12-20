import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    property int tmpValue: 2

    Component.onCompleted: {
        settings.sBool(true,"notifications","wibblyWobblyTimeyWimeyStuff")
        settings.sInt(tmpValue, "notifications", "blinkScreenDevice");
        blinker.running = true;
        globalUnreadCount++;
        statusBarText.text = qsTr("First run")
    }

    Text {
        id: chapter
        color: main.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Notification LED"
    }

    Text {
        id: text
        color: main.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: qsTr("Because every phone is different, we need you do do a couple of tests before proceeding to ensure that all the features will work properly. Lightbulb will now try different ways to access your phones notification LED. \n\nObserve your menu button. Tap on \"Next\" if it's blinking, or \"Try again\" if it isn't.")
    }

    Button {
        id: ledNo
        y: 420
        text: "Try again"
        width: parent.width/2 - 10
        platformInverted: main.platformInverted
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            switch (tmpValue) {
                case 2: tmpValue = 1; break;
                case 1: tmpValue = 4; break;
                case 4: tmpValue = 2; break;
            }
            settings.sInt(tmpValue, "notifications", "blinkScreenDevice")
        }
    }


    // toolbar

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
            onClicked: {
                globalUnreadCount--;
                pageStack.pop()
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked:{
                globalUnreadCount--;
                pageStack.push("qrc:/FirstRun/03")
            }
        }

    }


}

