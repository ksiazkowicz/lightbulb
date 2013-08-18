import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
  id: filedialog
  property bool dirMode :false;

  height: 400

  signal fileSelected(variant filePath);
  signal directorySelected(variant dirPath);

  titleText: dirMode ? " Choose Directory" : " Choose File"

  content: [
    Column {
      width: parent.width
      height: 400
      spacing: 5

      Item{
          width:parent.width; height:5;
      }


      Row {
          id: buttonsRow
          height:upButton.height
          width: parent.width
          Button {
            id: upButton
            text: 'Up'
            width: 70
            height: parent.height
            enabled: fileModel.canGoUp
            onClicked: fileModel.goUp()
          }
          Button {
            id: dirButton
            text: fileModel.directory;
            width: parent.width - upButton.width
            height: parent.height
            onClicked: {
                if( dirMode ) {
                    console.log("Directory selected: " + fileModel.currentDirectory() );
                    filedialog.directorySelected(fileModel.currentDirectory());
                    filedialog.accept();
                }
            }
          }
      }

      Flickable {
          width: parent.width-20
          height: 288

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
                     subItemIndicator: icon ? true : false

                     Row {
                         spacing:8
                         Image {
                             id:fileIcon
                             source: icon ? "qrc:/qml/images/folder.svg" :"qrc:/qml/images/file.svg"
                             sourceSize.width: 48
                             sourceSize.height: 48
                             //anchors.verticalCenter: parent.verticalCenter
                         }

                         ListItemText {
                             mode: container.mode
                             role: "Title"
                             clip: true
                             wrapMode: Text.NoWrap
                             anchors.verticalCenter: parent.verticalCenter
                             id: mainText
                             text: caption
                             width: container.width - fileIcon.width - 25
                         }
                     }

                     onClicked: {
                         var isDir = fileModel.isDir(index);

                         if( isDir) {
                             fileModel.openDirectory(index);
                         } else {
                             if ( dirMode == false ) {
                                 console.log("File Selected:" + fileModel.currentDirectory() + '/' + caption);
                                 filedialog.fileSelected(fileModel.currentDirectory() + '/' + caption);
                                 filedialog.accept();
                             }
                         }
                     }
                }
            }
          }

          Item {
              id:emptyList
              width:parent.width;height:parent.height
              visible: false
              Connections {
                target: fileModel;
                onShowEmptyDir:{
                    console.debug("Empty list visible:"+ show);
                    emptyList.visible = show;
                }
              }

              Label{
                  anchors.centerIn: parent
                  color:"white"
                  text:"<h2>Welcome to the void!</h2>"
              }
          }
      }
    }
  ]
  onAccepted: { filedialog.destroy() }
  onRejected: { filedialog.destroy() }
}
