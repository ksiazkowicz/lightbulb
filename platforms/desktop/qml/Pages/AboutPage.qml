import QtQuick 2.0
import QtQuick.Controls 2.0

Page {
    id: aboutPage

    Flickable {
        id: about
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent

        contentHeight: logo.height + 32 + programName.height + 5 + names.height + niceInfo.height + 24 + buttons.height + 64 + licenseStuff.height
        Image {
            id: logo
            source: "qrc:/Lightbulb.svg"
            sourceSize { width: 128; height: 128 }
            width: 128
            height: 128
            smooth: true
            scale: 1
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 32 }
        }
        Label {
            id: programName
            text: "Fluorescent IM " + appVersion + " α"
            anchors { top: logo.bottom; topMargin: 5; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 20
        }

        Label {
            id: names
            anchors { top: programName.bottom; leftMargin: 10; rightMargin: 10; left: parent.left; right: parent.right }
            wrapMode: Text.Wrap
            text: "coded with ♥ and coffee\nbuilt on " + buildDate
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: licenseStuff
            width: parent.width
            text: qsTr("This program comes with ABSOLUTELY NO WARRANTY. This is free software, and you are welcome to redistribute it under certain conditions. See GPL v3 license for details.")
            anchors { top: githubBtn.bottom; topMargin: 14; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
            font.bold: true
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            color: "red"
        }

        Label {
            id: niceInfo
            text: qsTr("Made possible thanks to AWESOME Symbian community")
            width: parent.width
            anchors { top: names.bottom; topMargin: 24; horizontalCenter: parent.horizontalCenter }
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
        }
        Row {
            id: buttons
            anchors { horizontalCenter: parent.horizontalCenter; top: niceInfo.bottom; topMargin: 14 }
            spacing: 20
            Button {
                text: "Contributors"
                onClicked: dialog.create("qrc:/dialogs/Contributors")
            }
            Button {
                text: "Donate"
                onClicked: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=SA8DZYA7PUCCU&lc=US"})
            }
        }
        Button {
            id: githubBtn
            text: "Fork me on GitHub"
            anchors { horizontalCenter: parent.horizontalCenter; top: buttons.bottom; topMargin: 20 }
            onClicked: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": "https://github.com/ksiazkowicz/lightbulb"})
        }
    }

    ScrollBar {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            margins: 18
        }
        orientation: Qt.Vertical
    }
}
