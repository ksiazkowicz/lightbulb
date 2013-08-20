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

#define LIGHTBULB_NAMESPACE "lightbulb"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app( createApplication(argc, argv) );

    qmlRegisterType<MyXmppClient>(LIGHTBULB_NAMESPACE, 1, 0, "XmppClient" );
    qmlRegisterType<MeegIMSettings>(LIGHTBULB_NAMESPACE, 1, 0, "MeegIMSettings" );
    qmlRegisterType<QMLVCard>(LIGHTBULB_NAMESPACE, 1, 0, "XmppVCard" );
    qmlRegisterType<QmlClipboardAdapter>(LIGHTBULB_NAMESPACE, 1, 0, "Clipboard" );
    qmlRegisterType<LightbulbHSWidget>(LIGHTBULB_NAMESPACE, 1, 0, "Hswidget" );
    qmlRegisterType<globalnote>(LIGHTBULB_NAMESPACE, 1, 0, "GlobalNote");
    qmlRegisterType<FileModel>(LIGHTBULB_NAMESPACE, 1, 0, "FileModel");
    qmlRegisterType<FileIO>(LIGHTBULB_NAMESPACE, 1, 0, "FileIO");
    //qmlRegisterType<nativechaticon>(LIGHTBULB_NAMESPACE,1, 0, "ChatIcon");

    qmlRegisterUncreatableType<RosterListModel>(LIGHTBULB_NAMESPACE, 1, 0, "Roster", "Use xmppClient.roster instead");
    qmlRegisterUncreatableType<MsgListModel>(LIGHTBULB_NAMESPACE, 1, 0, "MessagesList", "");
    qmlRegisterUncreatableType<ChatsListModel>(LIGHTBULB_NAMESPACE, 1, 0, "ChatsList", "");
    qmlRegisterUncreatableType<AccountsListModel>(LIGHTBULB_NAMESPACE, 1, 0, "AccountsList", "Use settings.accounts instead");

    QmlApplicationViewer viewer;
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showExpanded();

    return app->exec();
}

