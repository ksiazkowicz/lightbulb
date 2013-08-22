#include <QtGui/QApplication>
#include <QUrl>
#include "qmlapplicationviewer.h"

#include "MyXmppClient.h"

#include "rosterlistmodel.h"
#include "chatslistmodel.h"
#include "msglistmodel.h"
#include "accountslistmodel.h"
#include "qmlvcard.h"
#include "meegimsettings.h"
#include "qmlclipboardadapter.h"
#include "lightbulbhswidget.h"
#include "globalnote.h"
#include "filemodel.h"
//#include "nativechaticon.h"
#include "fileio.h"
#include "lock.h"

#include <QtGui/QSplashScreen>
#include <QtGui/QPixmap>

#define LIGHTBULB_NAMESPACE "lightbulb"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app( createApplication(argc, argv) );

    QSplashScreen *splash = new QSplashScreen(QPixmap("qrc:/qml/images/splash.png"));
    splash->show();

    qmlRegisterType<MyXmppClient>(LIGHTBULB_NAMESPACE, 1, 0, "XmppClient" );
    qmlRegisterType<MeegIMSettings>(LIGHTBULB_NAMESPACE, 1, 0, "MeegIMSettings" );
    qmlRegisterType<QMLVCard>(LIGHTBULB_NAMESPACE, 1, 0, "XmppVCard" );
    qmlRegisterType<QmlClipboardAdapter>(LIGHTBULB_NAMESPACE, 1, 0, "Clipboard" );
    qmlRegisterType<LightbulbHSWidget>(LIGHTBULB_NAMESPACE, 1, 0, "Hswidget" );
    qmlRegisterType<globalnote>(LIGHTBULB_NAMESPACE, 1, 0, "GlobalNote");
    qmlRegisterType<FileModel>(LIGHTBULB_NAMESPACE, 1, 0, "FileModel");
    qmlRegisterType<FileIO>(LIGHTBULB_NAMESPACE, 1, 0, "FileIO");
    //qmlRegisterType<nativechaticon>(LIGHTBULB_NAMESPACE,1, 0, "ChatIcon");
    qmlRegisterType<lock>(LIGHTBULB_NAMESPACE, 1, 0, "Lock");

    qmlRegisterUncreatableType<RosterListModel>(LIGHTBULB_NAMESPACE, 1, 0, "Roster", "Use xmppClient.roster instead");
    qmlRegisterUncreatableType<MsgListModel>(LIGHTBULB_NAMESPACE, 1, 0, "MessagesList", "");
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

    splash->finish(&viewer); //instead of &viewer write & and the name of your  QmlApplicationViewer or QDeclarativeView
    splash->deleteLater();

    return app->exec();
}

