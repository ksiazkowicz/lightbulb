import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: aboutPage
    orientationLock: 1
    tools: toolBarLayout

    Component.onCompleted: {
        statusBarText.text = qsTr("About...")
    }

    Image {
        id: logo
        source: "qrc:/Lightbulb.svg"
        y: 32
        sourceSize { width: 128; height: 128 }
        width: 128
        height: 128
        smooth: true
        scale: 1
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: programName
        color: vars.textColor
        text: "Lightbulb " + xmppClient.version + " β"
        anchors { top: logo.bottom; topMargin: 5; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
    }

    Text {
        id: names
        anchors { top: programName.bottom; horizontalCenterOffset: 2; horizontalCenter: parent.horizontalCenter; leftMargin: 10; rightMargin: 10; left: parent.left; right: parent.right }
        color: vars.textColor
        wrapMode: Text.Wrap
        text: "Maciej Janiszewski (pisarzk@gmail.com) with help from Fabian Hüllmantel and Paul Wallace\nbased on MeegIM by Anatoliy Kozlov"
        font.pixelSize: platformStyle.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: licenseStuff
        width: parent.width
        text: qsTr("This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details.")
        anchors { top: niceInfo.bottom; topMargin: 80; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        font.bold: true
        wrapMode: Text.WordWrap
        font.pixelSize: platformStyle.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        color: "red"
    }

    Text {
        id: niceInfo
        color: vars.textColor
        text: qsTr("During development of this software, no mobile device was harmed.")
        width: parent.width
        anchors { top: names.bottom; topMargin: 24; horizontalCenter: parent.horizontalCenter }
        wrapMode: Text.WordWrap
        font.pixelSize: platformStyle.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
    }


    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: { statusBarText.text = "Contacts"
                pageStack.pop() }
        }
    }

    Button {
        anchors { horizontalCenter: parent.horizontalCenter; top: niceInfo.top; topMargin: 64 }
        text: "Donate"
        onClicked: {
            vars.url = "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SA8DZYA7PUCCU";
            linkContextMenu.open()
        }
    }
}

