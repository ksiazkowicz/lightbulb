// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import QtMobility.location 1.1

CommonDialog {
    id: attachment

    titleText: qsTr("Choose an attachment")
    privateCloseIcon: true

    property string accountId;
    property string contactJid;
    property string contactResource;
    property bool isFacebook;

    // Code for dynamic load
    Component.onCompleted: {
        open();
        isCreated = true }
    property bool isCreated: false

    height: Math.min(grid.height + (platformStyle.paddingLarge * 4), platformContentMaximumHeight)

    PositionSource {
        id: positionSource
        updateInterval: 5000

        active: true
        Component.onCompleted: update()

        function getMapTile(size,zoom) {
            return 'http://m.nok.it/?c='+position.coordinate.latitude +','+position.coordinate.longitude+'&z=' + zoom +'&w=' + size + '&h=' + size;
        }
    }

    content: Grid {
        id: grid
        property int cellSize: platformStyle.graphicSizeLarge + platformStyle.graphicSizeTiny
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }

        ToolButton {
            iconSource: "qrc:/Attachments/document"
            width: parent.cellSize
            height: parent.cellSize
            enabled: !isFacebook
            onClicked: {
                var filename = avkon.openFileSelectionDlg(false,false);
                if (filename != " ") {
                    xmppConnectivity.useClient(accountId).sendAFile(contactJid,contactResource,filename)
                    avkon.displayGlobalNote("Attempting to send a file. ^^",false)
                } else {
                    avkon.displayGlobalNote("No files selected.",true)
                }
                attachment.close()
            }
        }
        ToolButton {
            iconSource: "qrc:/Attachments/photo"
            width: parent.cellSize
            height: parent.cellSize
            enabled: !isFacebook
            onClicked: {
                var files = avkon.openMediaSelectionDialog(0);
                for (var i=0; i<files.length; i++)
                    xmppConnectivity.useClient(accountId).sendAFile(contactJid,contactResource,files[i])

                if (files.length > 0)
                    avkon.displayGlobalNote("Attempting to send " + (files.length > 1 ? files.length + " files" : "a file") +". ^^",false)
                else avkon.displayGlobalNote("No files selected.",true)
                attachment.close()
            }
        }
        ToolButton {
            iconSource: "qrc:/Attachments/video"
            width: parent.cellSize
            height: parent.cellSize
            enabled: !isFacebook
            onClicked: {
                var files = avkon.openMediaSelectionDialog(1);
                for (var i=0; i<files.length; i++)
                    xmppConnectivity.useClient(accountId).sendAFile(contactJid,contactResource,files[i])

                if (files.length > 0)
                    avkon.displayGlobalNote("Attempting to send " + (files.length > 1 ? files.length + " files" : "a file") +". ^^",false)
                else avkon.displayGlobalNote("No files selected.",true)
                attachment.close()
            }
        }
        ToolButton {
            iconSource: "qrc:/Attachments/song"
            width: parent.cellSize
            height: parent.cellSize
            enabled: !isFacebook
            onClicked: {
                var files = avkon.openMediaSelectionDialog(3);
                for (var i=0; i<files.length; i++)
                    xmppConnectivity.useClient(accountId).sendAFile(contactJid,contactResource,files[i])

                if (files.length > 0)
                    avkon.displayGlobalNote("Attempting to send " + (files.length > 1 ? files.length + " files" : "a file") +". ^^",false)
                else avkon.displayGlobalNote("No files selected.",true)
                attachment.close()
            }
        }
        ToolButton {
            iconSource: "qrc:/Attachments/location"
            width: parent.cellSize
            height: parent.cellSize
            enabled: positionSource.position.latitudeValid && positionSource.position.longitudeValid
            onClicked: { sendLocation(); attachment.close() }
        }
    }

    onStatusChanged: { if (isCreated && attachment.status === DialogStatus.Closed) { attachment.destroy() } }

    function sendLocation() {
        var messageWasSent = xmppConnectivity.useClient(accountId).sendMessage(contactJid,contactResource,positionSource.getMapTile(640,16),1,xmppConnectivity.getChatType(accountId,contactJid));
        if (messageWasSent) {
            notify.notifySndVibr("LocationSent")
        } else avkon.displayGlobalNote("Something went wrong while sending location.",true);

        xmppConnectivity.resetUnreadMessages(accountId,contactJid)
    }
}
