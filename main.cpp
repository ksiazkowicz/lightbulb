#include <QtGui/QApplication>
#include <QUrl>
#include "qmlapplicationviewer.h"

#include "MyXmppClient.h"

#include "rosterlistmodel.h"
#include "chatslistmodel.h"
#include "accountslistmodel.h"
#include "qmlvcard.h"
#include "SettingsDBWrapper.h"
#include "qmlclipboardadapter.h"
#include "lightbulbhswidget.h"
#include "QAvkonHelper.h"
#include "DatabaseManager.h"
#include "SymbiosisAPIClient.h"

#define LIGHTBULB_NAMESPACE "lightbulb"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app( createApplication(argc, argv) );

    qmlRegisterType<MyXmppClient>(LIGHTBULB_NAMESPACE, 1, 0, "XmppClient" );
    qmlRegisterType<SettingsDBWrapper>(LIGHTBULB_NAMESPACE, 1, 0, "MeegIMSettings" );
    qmlRegisterType<QMLVCard>(LIGHTBULB_NAMESPACE, 1, 0, "XmppVCard" );
    qmlRegisterType<QmlClipboardAdapter>(LIGHTBULB_NAMESPACE, 1, 0, "Clipboard" );
    qmlRegisterType<LightbulbHSWidget>(LIGHTBULB_NAMESPACE, 1, 0, "HSWidget" );
    qmlRegisterType<QAvkonHelper>(LIGHTBULB_NAMESPACE, 1, 0, "Avkon");

    qmlRegisterType<SymbiosisAPIClient>(LIGHTBULB_NAMESPACE, 1, 0, "SymbiosisAPI" );

    qmlRegisterUncreatableType<RosterListModel>(LIGHTBULB_NAMESPACE, 1, 0, "Roster", "Use xmppClient.roster instead");
    qmlRegisterUncreatableType<SqlQueryModel>(LIGHTBULB_NAMESPACE, 1, 0, "SqlQuery", "");
    qmlRegisterUncreatableType<ChatsListModel>(LIGHTBULB_NAMESPACE, 1, 0, "ChatsList", "");
    qmlRegisterUncreatableType<AccountsListModel>(LIGHTBULB_NAMESPACE, 1, 0, "AccountsList", "Use settings.accounts instead");

    QmlApplicationViewer viewer;
    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);

    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showFullScreen();

    return app->exec();
}

