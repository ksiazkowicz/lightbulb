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

#include <QtGui/QApplication>
#include <QtGui/QSplashScreen>
#include <QtGui/QPixmap>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/qdeclarative.h>
#include <QUrl>
#include <QDebug>
#include "qmlapplicationviewer.h"

#include "MyXmppClient.h"

#include "AccountsListModel.h"
#include "RosterListModel.h"
#include "MsgListModel.h"
#include "NetworkCfgListModel.h"
#include "ParticipantListModel.h"
#include "EventListModel.h"

#include "QMLVCard.h"
#include "Settings.h"
#include "QAvkonHelper.h"
#include "DatabaseManager.h"
#include "XmppConnectivity.h"
#include "EmoticonParser.h"
#include "NetworkManager.h"
#include "MigrationManager.h"
#include "EventsManager.h"

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    qDebug() << "Fluorescent 0.4 build 0007";
    qDebug() << "Maciej Janiszewski";
    qDebug() << "------------------";

    qDebug() << "main(): Initializing splashscreen";
    QSplashScreen *splash = new QSplashScreen(QPixmap(":/splash"));
    splash->show();

    qDebug() << "main(): Registering classes...";

    // expose C++ classes to QML
    qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
    qmlRegisterType<QMLVCard>("lightbulb", 1, 0, "XmppVCard" );
    qmlRegisterType<ClipboardAdapter>("lightbulb", 1, 0, "Clipboard" );
    qmlRegisterType<XmppConnectivity>("lightbulb",1,0,"XmppConnectivity");

    qmlRegisterType<NetworkManager>("lightbulb",1,0,"NetworkManager");
    qmlRegisterType<MigrationManager>("lightbulb",1,0,"MigrationManager");

    qmlRegisterUncreatableType<SqlQueryModel>("lightbulb", 1, 0, "SqlQuery", "");
    qmlRegisterUncreatableType<AccountsListModel>("lightbulb", 1, 0, "AccountsList", "Use settings.accounts instead");
    qmlRegisterUncreatableType<RosterListModel>("lightbulb",1,0,"RosterModel","");
    qmlRegisterUncreatableType<NetworkCfgListModel>("lightbulb",1,0,"NetworkCfgListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ParticipantListModel>("lightbulb",1,0,"ParticipantListModel","just use NetworkManager.connections");
    qmlRegisterUncreatableType<ChatsListModel>("lightbulb",1,0,"ChatsModel","because I say so, who cares?");
    qmlRegisterUncreatableType<MsgListModel>("lightbulb", 1, 0, "MsgModel", "because sliced bread is awesome");
    qmlRegisterUncreatableType<EventListModel>("lightbulb",1,0,"EventModel","anyone actually reads that stuff?");
    qmlRegisterUncreatableType<MyXmppClient>("lightbulb", 1, 0, "XmppClient", "Use XmppConnectivity.useClient(accountId) instead" );
    qmlRegisterUncreatableType<EventsManager>("lightbulb", 1, 0, "EventsManager", "Use XmppConnectivity.events" );

    qDebug() << "main(): Classes registered";
    qDebug() << "main(): Initializing view...";

    // initialize viewer and set it parameters
    QmlApplicationViewer viewer;
    CAknAppUi* appUi = dynamic_cast<CAknAppUi*> (CEikonEnv::Static()->AppUi());
    QAvkonHelper avkon(&viewer,appUi);
    viewer.rootContext()->setContextProperty("avkon", &avkon);

    EmoticonParser parser;
    viewer.rootContext()->setContextProperty("emoticon",&parser);
    viewer.rootContext()->setContextProperty("appVersion",VERSION);

    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer.setProperty("orientationMethod", 1);

    qDebug() << "main(): Done. Loading QML file";

    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showFullScreen();

    splash->finish(&viewer);
    splash->deleteLater();

    qDebug() << "main(): App is ready";

    return app.exec();
}

