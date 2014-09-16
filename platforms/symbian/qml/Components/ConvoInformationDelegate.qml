/********************************************************************

qml/Components/ConvoInformationDelegate.qml
-- delegate for information messages

Copyright (c) 2014 Maciej Janiszewski

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

import QtQuick 1.1
import com.nokia.symbian 1.1

Item {
    id: wrapper
    height: platformStyle.paddingLarge + message.paintedHeight

    property string date: _dateTime.substr(0,8) == Qt.formatDateTime(new Date(), "dd-MM-yy") ? _dateTime.substr(9,5) : _dateTime

    anchors { left: parent.left; right: parent.right; margins: platformStyle.paddingSmall }

    function parseCE(text) {
        // replaces CE with actual values
        // CE stands for Conversation Expressions
        var temp = text;

        temp = temp.replace("[[name]]",contactName);
        temp = temp.replace("[[mucName]]",msgResource);
        temp = temp.replace("[[bareJid]]",contactJid);
        temp = temp.replace("[[bold]]","<b>");
        temp = temp.replace("[[/bold]]","</b>")
        temp = temp.replace("[[date]]",wrapper.date)

        temp = temp.replace("[[INFO]]","<img src='qrc:/convo/defaultSkin/infoIcon' />");
        temp = temp.replace("[[ERR]]","<img src='qrc:/convo/defaultSkin/errorIcon' />");
        temp = temp.replace("[[ALERT]]","<img src='qrc:/convo/defaultSkin/alertIcon' />");

        return temp;
    }

    Text {
        id: message
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
        horizontalAlignment: Text.AlignHCenter
        text: parseCE(_msgText)
        width: parent.width
        color: "#888888"
        font.pixelSize: platformStyle.fontSizeSmall
        font.italic: true
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
    }
}
