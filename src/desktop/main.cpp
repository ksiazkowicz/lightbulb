/********************************************************************

src/main.cpp

Copyright (c) 2013 Maciej Janiszewski

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

#include <QGuiApplication>
#include <QtGui/QPixmap>
#include <QUrl>

#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickStyle>

#include "../xmpp/MyXmppClient.h"

#include "../models/ListModel.h"
#include "../models/AccountsListModel.h"
#include "../models/AccountsItemModel.h"
#include "../models/RosterItemFilter.h"
#include "../models/MsgListModel.h"
#include "../models/NetworkCfgListModel.h"
#include "../models/ParticipantListModel.h"
#include "../models/EventListModel.h"
#include "../models/ServiceListModel.h"

#include "../cache/QMLVCard.h"
#include "../database/Settings.h"

#include "../database/DatabaseManager.h"
#include "../xmpp/XmppConnectivity.h"
#include "../EmoticonParser.h"
#include "../avkon/NetworkManager.h"
#include "../xmpp/EventsManager.h"

#include "../winrt/brokensocket.h"


int main(int argc, char *argv[]) {
    // initialize QApplication
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication* app = new QGuiApplication(argc, argv);

    // initialize settings
    Settings settings;

    // expose C++ classes to QML
    qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
    qmlRegisterType<QMLVCard>("lightbulb", 1, 0, "XmppVCard" );
    //qmlRegisterType<NetworkManager>("lightbulb", 1, 0, "NetworkManager" );

    qmlRegisterUncreatableType<SqlQueryModel>("lightbulb", 1, 0, "SqlQuery", "");
    qmlRegisterUncreatableType<AccountsListModel>("lightbulb", 1, 0, "AccountsList", "Use settings.accounts instead");
    qmlRegisterUncreatableType<RosterItemFilter>("lightbulb",1,0,"RosterModel","");
    //qmlRegisterUncreatableType<NetworkCfgListModel>("lightbulb",1,0,"NetworkCfgListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ParticipantListModel>("lightbulb",1,0,"ParticipantListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ChatsListModel>("lightbulb",1,0,"ChatsModel","because I say so, who cares?");
    qmlRegisterUncreatableType<MsgListModel>("lightbulb", 1, 0, "MsgModel", "because sliced bread is awesome");

    qmlRegisterUncreatableType<ListModel>("lightbulb", 1, 0, "GenListModel", "because sliced bread is awesome");
    qmlRegisterUncreatableType<ListItem>("lightbulb", 1, 0, "GenListItem", "because sliced bread is awesome");

    qmlRegisterUncreatableType<EventListModel>("lightbulb",1,0,"EventModel","anyone actually reads that stuff?");
    qmlRegisterUncreatableType<ServiceListModel>("lightbulb",1,0,"ServiceModel","while (true) this->getHype();");
    qmlRegisterUncreatableType<MyXmppClient>("lightbulb", 1, 0, "XmppClient", "Use XmppConnectivity.useClient(accountId) instead" );
    qmlRegisterUncreatableType<EventsManager>("lightbulb", 1, 0, "EventsManager", "Use XmppConnectivity.events" );

    QQmlApplicationEngine* viewer = new QQmlApplicationEngine();

    // initialize emoticon parser
    EmoticonParser parser;
    viewer->rootContext()->setContextProperty("emoticon",&parser);

    // register settings
    viewer->rootContext()->setContextProperty("settings",&settings);

    // initialize xmppconnectivity
    XmppConnectivity xmpp;
    viewer->rootContext()->setContextProperty("xmppConnectivity",&xmpp);

    // Qt5 cool stuff
    viewer->rootContext()->setContextProperty("appVersion","0.4.0");
    viewer->rootContext()->setContextProperty("buildDate","00-00-0000");

    // set universal style
    QQuickStyle::setStyle("Universal");

    viewer->load(QUrl(QLatin1String("qrc:/main.qml")));

    BrokenSocket socket;

    return app->exec();
}
