// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
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
        sourceSize.width: 128
        sourceSize.height: 128
        width: 128
        height: 128
        smooth: true
        scale: 1
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: programName
        color: main.textColor
        text: "Lightbulb 0.0.9"
        anchors { top: logo.bottom; topMargin: 5; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5

    }

    Text {
        id: myName
        anchors { top: programName.bottom; horizontalCenterOffset: 2; horizontalCenter: parent.horizontalCenter }
        color: main.textColor
        text: "Maciej Janiszewski (2013)"
        font.pixelSize: platformStyle.fontSizeMedium
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: authorName
        color: main.textColor
        text: "(pisarzk@gmail.com)"
        anchors { top: myName.bottom; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
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
        color: main.textColor
    }

    Text {
        id: niceInfo
        color: main.textColor
        text: qsTr("During development of this software, no mobile device was harmed.")
        width: parent.width
        anchors { top: authorName.bottom; topMargin: 80; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        wrapMode: Text.WordWrap
        font.pixelSize: platformStyle.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
    }


    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: { statusBarText.text = "Contacts"
                pageStack.pop() }
        }
    }
}

