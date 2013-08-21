// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

Page {
    id: archivePage
    orientationLock: 1
    tools: toolBarLayout

    Component.onCompleted: {
        statusBarText.text = qsTr("Archive")
        fileModel.setCurrentDirectory("C:\\Data\\.config\\Lightbulb\\archive\\" + xmppClient.chatJid)
    }

    property string filePath: ""

    property bool dirMode :false

    Column {
        anchors { fill: parent.fill }
        spacing: 5

        Flickable {
            width: parent.width-20

            contentHeight: columnContent.height
            contentWidth: columnContent.width

            flickableDirection: Flickable.VerticalFlick

            Column {
                id: columnContent
                spacing: 0

            Repeater {
              id: entries
              model: fileModel

              delegate: ListItem {
                       id:container
                       height: 48

                       ListItemText {
                           mode: container.mode
                           role: "Title"
                           clip: true
                           wrapMode: Text.NoWrap
                           anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
                           id: mainText
                           text: caption.substr(0,caption.length-4)
                           width: container.width
                           platformInverted: main.platformInverted
                       }
                       onClicked: {
                           console.log("File Selected:" + fileModel.currentDirectory() + '\\' + caption);
                           filePath = fileModel.currentDirectory() + '\\' + caption;
                           copyDialog.open();
                           myFile.source = filePath;
                           logText.text = myFile.read();
                       }
                  }
              }
            }

        }
     }

    Item {
        id:emptyList
        anchors.fill: parent
        visible: false
        Connections {
          target: fileModel;
          onShowEmptyDir:{
              emptyList.visible = show;
          }
        }

        Label{
            anchors.centerIn: parent
            color:textColor
            text:"<h2>No logs here yet</h2>"
        }
    }

    CommonDialog{
        id: copyDialog
        width: parent.width
        height: parent.height
        titleText: "Log"
        privateCloseIcon: true

        FileIO {
                id: myFile
                source: filePath
                onError: console.log(msg)
            }

        content: TextArea {
                id: logText
                anchors.fill: parent
                wrapMode: Text.Wrap
                font.pixelSize: 14
                readOnly: true
            }
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: "toolbar-back"
            onClicked: { pageStack.replace( "qrc:/qml/RosterPage.qml") }
        }
    }
}
