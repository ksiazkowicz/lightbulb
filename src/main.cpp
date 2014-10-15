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

// import different QML stuff for Qt 5 and Qt 4
#if QT_VERSION < 0x050000
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/qdeclarative.h>
#include <qmlapplicationviewer.h>
#else
#include <QQmlApplicationEngine>
#include <QtQml>
#endif

#include "xmpp/MyXmppClient.h"

#include "models/AccountsListModel.h"
#include "models/RosterItemFilter.h"
#include "models/MsgListModel.h"
#include "models/NetworkCfgListModel.h"
#include "models/ParticipantListModel.h"
#include "models/EventListModel.h"

#include "cache/QMLVCard.h"
#include "database/Settings.h"

#ifdef Q_OS_SYMBIAN
#include "QAvkonHelper.h"
#include <QSplashScreen>
#endif

#include "database/DatabaseManager.h"
#include "xmpp/XmppConnectivity.h"
#include "EmoticonParser.h"
#include "UpdateManager.h"
#include "avkon/NetworkManager.h"
#include "database/MigrationManager.h"
#include "xmpp/EventsManager.h"

#ifdef Q_OS_SAILFISH
#include <sailfishapp.h>
#include <QGuiApplication>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    #ifdef Q_OS_SAILFISH
    QGuiApplication *app = SailfishApp::application(argc,argv);
    #else
    QApplication* app = new QApplication(argc, argv);
    #endif
    #ifdef Q_OS_SYMBIAN
    QSplashScreen *splash = new QSplashScreen(QPixmap(":/splash"));
    splash->show();
    #endif

    // expose C++ classes to QML
    qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
    qmlRegisterType<QMLVCard>("lightbulb", 1, 0, "XmppVCard" );
    qmlRegisterType<NetworkManager>("lightbulb", 1, 0, "NetworkManager" );

    Settings settings;
    XmppConnectivity xmpp;
    MigrationManager migration;
    UpdateManager updater;

    qmlRegisterUncreatableType<SqlQueryModel>("lightbulb", 1, 0, "SqlQuery", "");
    qmlRegisterUncreatableType<AccountsListModel>("lightbulb", 1, 0, "AccountsList", "Use settings.accounts instead");
    qmlRegisterUncreatableType<RosterItemFilter>("lightbulb",1,0,"RosterModel","");
    qmlRegisterUncreatableType<NetworkCfgListModel>("lightbulb",1,0,"NetworkCfgListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ParticipantListModel>("lightbulb",1,0,"ParticipantListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ChatsListModel>("lightbulb",1,0,"ChatsModel","because I say so, who cares?");
    qmlRegisterUncreatableType<MsgListModel>("lightbulb", 1, 0, "MsgModel", "because sliced bread is awesome");
    qmlRegisterUncreatableType<EventListModel>("lightbulb",1,0,"EventModel","anyone actually reads that stuff?");
    qmlRegisterUncreatableType<MyXmppClient>("lightbulb", 1, 0, "XmppClient", "Use XmppConnectivity.useClient(accountId) instead" );
    qmlRegisterUncreatableType<EventsManager>("lightbulb", 1, 0, "EventsManager", "Use XmppConnectivity.events" );

    #if QT_VERSION < 0x050000
    QmlApplicationViewer viewer;
    #ifdef Q_OS_SYMBIAN
    CAknAppUi* appUi = dynamic_cast<CAknAppUi*> (CEikonEnv::Static()->AppUi());
    QAvkonHelper avkon(&viewer,appUi);
    viewer.rootContext()->setContextProperty("avkon", &avkon);

    qmlRegisterType<ClipboardAdapter>("lightbulb", 1, 0, "Clipboard" );
    #endif
    #endif

    EmoticonParser parser;

    #if QT_VERSION < 0x050000
    viewer.rootContext()->setContextProperty("emoticon",&parser);
    viewer.rootContext()->setContextProperty("appVersion",QString(VERSION).mid(1,5));
    viewer.rootContext()->setContextProperty("buildDate",QString(BUILDDATE).mid(1,10));
    viewer.rootContext()->setContextProperty("migration",&migration);
    viewer.rootContext()->setContextProperty("updater",&updater);
    viewer.rootContext()->setContextProperty("settings",&settings);
    viewer.rootContext()->setContextProperty("xmppConnectivity",&xmpp);
    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer.setProperty("orientationMethod", 1);
    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showFullScreen();
    splash->finish(&viewer);
    splash->deleteLater();
    #else
    // Qt5 cool stuff
    #ifdef Q_OS_SAILFISH
    QQuickView *viewer = SailfishApp::createView();
    QObject::connect(viewer->engine(), SIGNAL(quit()), app, SLOT(quit()));
    viewer->setSource(QUrl("qrc:///qml/main.qml"));
    viewer->rootContext()->setContextProperty("emoticon",&parser);
    viewer->rootContext()->setContextProperty("appVersion",VERSION);
    viewer->rootContext()->setContextProperty("buildDate",BUILDDATE);
    viewer->rootContext()->setContextProperty("migration",&migration);
    viewer->rootContext()->setContextProperty("updater",&updater);
    viewer->rootContext()->setContextProperty("settings",&settings);
    viewer->rootContext()->setContextProperty("xmppConnectivity",&xmpp);
    #else
    QQmlApplicationEngine viewer;
    viewer.rootContext()->setContextProperty("emoticon",&parser);
    viewer.rootContext()->setContextProperty("appVersion",VERSION);
    viewer.rootContext()->setContextProperty("buildDate",BUILDDATE);
    viewer.rootContext()->setContextProperty("migration",&migration);
    viewer.rootContext()->setContextProperty("updater",&updater);
    viewer.rootContext()->setContextProperty("settings",&settings);
    viewer.rootContext()->setContextProperty("xmppConnectivity",&xmpp);
    viewer.load(QUrl(QStringLiteral("qrc:///qml/main.qml")));
    #endif
    #endif

    return app->exec();
}
