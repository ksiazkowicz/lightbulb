// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import lightbulb 1.0

Rectangle {
    width: 100
    height: 62

    Label {
        text: "it works"
    }

    Settings { id: settings }

    Component.onCompleted: hsWidget.registerWidget()

        function cleanWidget() {
            hsWidget.changeRow(0,"",-2,"",0,false)
            hsWidget.changeRow(1,"",-2,"",0,false)
            hsWidget.changeRow(2,"",-2,"",0,false)
            hsWidget.changeRow(3,"",-2,"",0,false)
            hsWidget.unreadCount = 0
            hsWidget.status = 0
            hsWidget.pushWidget()
        }

        function updateWidget() {
                hsWidget.unreadCount = vars.globalUnreadCount
                switch (settings.gInt("widget","data")) {
                    case 0: hsWidget.getLatest4Chats(); break;
                    case 1: hsWidget.getFirst4Contacts(); break;
                    case 2: hsWidget.getLatestStatusChanges(); break;
                }
                hsWidget.pushWidget();
        }

        HSWidget {
            id: hsWidget
            property int unreadCount: 0
            property int status: 0

            Component.onCompleted: {
                var skinName = settings.get("widget","skin")
                if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
                loadSkin(skinName);
                if (settings.get("widget","enableHsWidget")) cleanWidget()
            }

            function pushWidget() { postWidget(unreadCount,status,settings.get("widget","showGlobalUnreadCnt"),settings.get("widget","showUnreadCntChat"),settings.get("widget","showStatus"),"Hangouts"); }

            function getLatest4Chats() {
                /*var name,presence,unreadCount,accountId;
                for (var i=0; i<4;i++) {
                    name = xmppConnectivity.getChatProperty(i+1,"name")
                    presence = getPresenceId(xmppConnectivity.getChatProperty(i+1,"presence"))
                    unreadCount = xmppConnectivity.getChatProperty(i+1,"unreadMsg")
                    accountId = xmppConnectivity.getChatProperty(i+1,"accountId")
                    hsWidget.changeRow(i,name,presence,accountId,unreadCount,false)
                }*/
                hsWidget.renderWidget()
            }
            function getLatestStatusChanges() {
                /*var name,presence,unreadCount,accountId;
                for (var i=0; i<4;i++) {
                    name = xmppConnectivity.getChangeProperty(i+1,"name")
                    presence = getPresenceId(xmppConnectivity.getChangeProperty(i+1,"presence"))
                    unreadCount = xmppConnectivity.getChangeProperty(i+1,"unreadMsg")
                    accountId = xmppConnectivity.getChangeProperty(i+1,"accountId")
                    hsWidget.changeRow(i,name,presence,accountId,unreadCount,false)
                }*/
                hsWidget.renderWidget()
            }
            function getFirst4Contacts() {
                /*var name,presence,unreadCount,accountId;
                for (var i=0; i<4;i++) {
                    name = xmppConnectivity.client.getPropertyByOrderID(i,"name");
                    presence = getPresenceId(xmppConnectivity.client.getPropertyByOrderID(i,"presence"))
                    unreadCount = xmppConnectivity.client.getPropertyByOrderID(i,"unreadMsg");
                    accountId = xmppConnectivity.currentAccount
                    hsWidget.changeRow(i,name,presence,accountId,unreadCount,false)
                }*/
                hsWidget.renderWidget()
            }
            function getPresenceId(presence) {
                if (presence == "qrc:/presence/online") return 0;
                else if (presence == "qrc:/presence/chatty") return 1;
                else if (presence == "qrc:/presence/away") return 2;
                else if (presence == "qrc:/presence/busy") return 3;
                else if (presence == "qrc:/presence/xa") return 4;
                else if (presence == "qrc:/presence/offline") return 5;
                else return -2;
            }
        }

        function updateSkin() {
            var skinName = settings.get("widget","skin")
            if (skinName === "false") skinName = "C:\\data\\.config\\Fluorescent\\widgets\\Belle Albus";
            hsWidget.loadSkin(skinName);
            hsWidget.renderWidget();
        }

        function registerWidget() {
            hsWidget.registerWidget()
            hsWidget.publishWidget()
        }
}
