/********************************************************************

 assets/main.qml
 -- Main QML file, contains PageStack and loads globally available
 -- objects
 
 Copyright (c) 2015 Maciej Janiszewski
 
 This file is part of Lightbulb.
 
 Lightbulb is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 *********************************************************************/

import bb.cascades 1.4
import lightbulb 1.0
import "./"
import "Pages"

NavigationPane {
    id: navigationPane

    // The initial page
    Page {
        titleBar: TitleBar { title: "Fluorescent Alpha" }

        content: Container {
            Label {
                text: "Amount of placeholders on this page is too damn high"
                textStyle {
                    color: Color.White
                }
                verticalAlignment: VerticalAlignment.Center
                layoutProperties: StackLayoutProperties { spaceQuota: 1 }
            }
        }

        actions: [
            ActionItem {
                title: "Contacts"
                ActionBar.placement: ActionBarPlacement.OnBar

                onTriggered: navigationPane.push(rosterPage);
            },
            ActionItem {
                title: "Services"
                ActionBar.placement: ActionBarPlacement.OnBar

                //onTriggered:
            },
            ActionItem {
                title: "Preferences"
                ActionBar.placement: ActionBarPlacement.OnBar

                //onTriggered: navigationPane.push(secondPage);
            },
            ActionItem {
                title: "Accounts"
                ActionBar.placement: ActionBarPlacement.OnBar

                onTriggered: navigationPane.push(accounts);
            } ,
            ActionItem {
                title: "About"
                ActionBar.placement: ActionBarPlacement.OnBar

                //onTriggered:
            },
            ActionItem {
                title: "Test Notifications"
                ActionBar.placement: ActionBarPlacement.OnBar

                onTriggered: xmppConnectivity.notificationSystemTest();
            }
        ]
    } // end of Page

    attachedObjects: [
        RosterPage { id: rosterPage },
        AccountAddPage { id: addAccountPage },
        AccountsPage { id: accounts },
        NotificationPlugin { id: notifications }
    ] // end of attachedObjects list

    onCreationCompleted: {
        xmppConnectivity.pushedSystemNotification.connect(notifications.pushSystemNotification)
    }
} // end of NavigationPane

