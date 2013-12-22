import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    Component.onCompleted: statusBarText.text = qsTr("First run")

    Text {
        id: chapter
        color: vars.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Colors"
    }

    Text {
        id: text
        color: vars.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: "Choice between darkness and light."
        horizontalAlignment: Text.AlignHCenter
    }

    // toolbar

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-previous_inverse" : "toolbar-previous"
            onClicked: pageStack.pop()
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: pageStack.push("qrc:/FirstRun/07")
        }

    }

    Image {
        id: darkImg
        x: 0
        y: 162
        width: 180
        height: 320
        source: "qrc:/FirstRun/img/black"
    }

    Image {
        id: whiteImg
        x: 180
        y: 162
        width: 180
        height: 320
        source: "qrc:/FirstRun/img/white"
    }

    RadioButton {
        id: dark
        x: 65
        y: 500
        text: ""
        checked: !settings.gBool("ui", "invertPlatform")
        onCheckedChanged: if (checked) light.checked = false;
    }

    RadioButton {
        id: light
        x: 245
        y: 500
        text: ""
        checked: settings.gBool("ui", "invertPlatform")
        onCheckedChanged: {
            if (checked) dark.checked = false;
            settings.sBool(checked,"ui", "invertPlatform")
            main.platformInverted = checked
            vars.textColor = checked ? platformStyle.colorNormalDark : platformStyle.colorNormalLight
        }
    }


}
