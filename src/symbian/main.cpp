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

#include <QApplication>
#include <QtGui/QPixmap>
#include <QUrl>

#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/qdeclarative.h>
#include <qmlapplicationviewer.h>

#include "../xmpp/MyXmppClient.h"

#include "../models/AccountsListModel.h"
#include "../models/RosterItemFilter.h"
#include "../models/MsgListModel.h"
#include "../models/NetworkCfgListModel.h"
#include "../models/ParticipantListModel.h"
#include "../models/EventListModel.h"
#include "../models/ServiceListModel.h"

#include "../cache/QMLVCard.h"
#include "../database/Settings.h"

#include "../avkon/QAvkonHelper.h"
#include <QSplashScreen>
#include "../FluorescentLogger.h"

#include "../database/DatabaseManager.h"
#include "../xmpp/XmppConnectivity.h"
#include "../EmoticonParser.h"
#include "../UpdateManager.h"
#include "../avkon/NetworkManager.h"
#include "../database/MigrationManager.h"
#include "../xmpp/EventsManager.h"

FluorescentLogger debugger;

void debug(QtMsgType type, const char *msg) {
  debugger.debug(type,msg);
}

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    // initialize QApplication
    QApplication* app = new QApplication(argc, argv);

    // initialize settings
    Settings settings;

    // if enabled, save debug log to file
    if (settings.gBool("advanced","logToFile")) {
      debugger.start();
      debugger.initLog();
      qInstallMsgHandler(debug);
    }


    // display a splashscreen
    QSplashScreen *splash = new QSplashScreen(QPixmap(":/splash"));
    splash->show();

    // expose C++ classes to QML
    qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
    qmlRegisterType<QMLVCard>("lightbulb", 1, 0, "XmppVCard" );
    qmlRegisterType<NetworkManager>("lightbulb", 1, 0, "NetworkManager" );

    qmlRegisterUncreatableType<SqlQueryModel>("lightbulb", 1, 0, "SqlQuery", "");
    qmlRegisterUncreatableType<AccountsListModel>("lightbulb", 1, 0, "AccountsList", "Use settings.accounts instead");
    qmlRegisterUncreatableType<RosterItemFilter>("lightbulb",1,0,"RosterModel","");
    qmlRegisterUncreatableType<NetworkCfgListModel>("lightbulb",1,0,"NetworkCfgListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ParticipantListModel>("lightbulb",1,0,"ParticipantListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ChatsListModel>("lightbulb",1,0,"ChatsModel","because I say so, who cares?");
    qmlRegisterUncreatableType<MsgListModel>("lightbulb", 1, 0, "MsgModel", "because sliced bread is awesome");
    qmlRegisterUncreatableType<EventListModel>("lightbulb",1,0,"EventModel","anyone actually reads that stuff?");
    qmlRegisterUncreatableType<ServiceListModel>("lightbulb",1,0,"ServiceModel","while (true) this->getHype();");
    qmlRegisterUncreatableType<MyXmppClient>("lightbulb", 1, 0, "XmppClient", "Use XmppConnectivity.useClient(accountId) instead" );
    qmlRegisterUncreatableType<EventsManager>("lightbulb", 1, 0, "EventsManager", "Use XmppConnectivity.events" );

    QmlApplicationViewer* viewer = new QmlApplicationViewer();

    CAknAppUi* appUi = dynamic_cast<CAknAppUi*> (CEikonEnv::Static()->AppUi());
    QAvkonHelper avkon(viewer,appUi);
    viewer->rootContext()->setContextProperty("avkon", &avkon);

    qmlRegisterType<ClipboardAdapter>("lightbulb", 1, 0, "Clipboard" );

    // initialize emoticon parser
    EmoticonParser parser;
    viewer->rootContext()->setContextProperty("emoticon",&parser);

    // initialize migration manager
    MigrationManager migration;
    viewer->rootContext()->setContextProperty("migration",&migration);

    // initialize update manager
    UpdateManager updater;
    viewer->rootContext()->setContextProperty("updater",&updater);

    // register settings
    viewer->rootContext()->setContextProperty("settings",&settings);

    // initialize xmppconnectivity
    XmppConnectivity xmpp;
    viewer->rootContext()->setContextProperty("xmppConnectivity",&xmpp);

    // Symbian workarounds
    viewer->rootContext()->setContextProperty("appVersion",QString(VERSION).mid(1,5));
    viewer->rootContext()->setContextProperty("buildDate",QString(BUILDDATE).mid(1,10));

    viewer->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->setAttribute(Qt::WA_NoSystemBackground);
    viewer->viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer->viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer->setProperty("orientationMethod", 1);

    // initialize main page and fullscreen mode
    viewer->setSource(QUrl(QLatin1String("qrc:/qml/main.qml")));
    viewer->showFullScreen();

    // ok, done, hide the splashscreen
    splash->finish(viewer);
    splash->deleteLater();

    return app->exec();
}
