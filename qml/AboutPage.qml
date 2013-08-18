// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: aboutPage
    tools: toolBarLayout

    Component.onCompleted: {
        statusBarText.text = qsTr("About...")
    }

    Image {
        id: image1
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
        id: text1
        y: 176
        color: main.platformInverted ? "black" : "white"
        text: "Lightbulb 0.0.8"
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 25
    }

    Text {
        id: text2
        y: 213
        color: main.platformInverted ? "black" : "white"
        text: "Maciej Janiszewski (2013)"
        anchors.horizontalCenterOffset: 2
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 19
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: text3
        y: 236
        color: main.platformInverted ? "black" : "white"
        text: "(pisarzk@gmail.com)"
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: text4
        x: 29
        y: 425
        color: main.platformInverted ? "black" : "white"
        text: qsTr("Initially based on MeegIM. Using qxmpp 0.7.6")
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: text5
        x: 89
        y: 443
        color: main.platformInverted ? "black" : "white"
        text: qsTr("Made possible with Qt 4.7.4")
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: text6
        y: 467
        width: 304
        height: 77
        color: "red"
        //text: qsTr("Software is provided as-is. Things gonna break, world is going to burn etc. I'm aware of that. I WARNED YOU!")
        text: qsTr("UNOFFICIAL PRE-RELEASE BUILD! I hope you won't leak it, would you?")
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        wrapMode: Text.WordWrap
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: text7
        y: 357
        width: 304
        height: 18
        color: main.platformInverted ? "black" : "white"
        text: qsTr("During development of this software, no mobile device was harmed.")
        anchors.horizontalCenterOffset: 1
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 15
        horizontalAlignment: Text.AlignHCenter
    }


    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.replace( "qrc:/qml/./RosterPage.qml")
            }
        }
    }
}
