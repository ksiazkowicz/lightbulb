/********************************************************************

src/avkon/QAvkonHelper.cpp
-- interface to native Symbian APIs

Copyright (c) 2013 Maciej Janiszewski,
                   Fabian Hüllmantel,
                   Dickson Leong

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

#include "QAvkonHelper.h"
#include <aknnotewrappers.h>
#include <aknglobalnote.h>
#include <AknCommonDialogsDynMem.h>
#include <aknglobalmsgquery.h>
#include <e32svr.h>
#include <eikmenup.h>
#include <coemain.h>
#include <apgcli.h> // RApaLsSession
#include <apgtask.h> // TApaTaskList, TApaTask
#include <QUrl>
#include <QProcess>

#include <MAknFileFilter.h>

#include <f32file.h>

#include <QDebug>
#include <QtDeclarative/QDeclarativeView>

// filters out non-sound files
class CExtensionFilter : public MAknFileFilter {
public:
    TBool Accept(const TDesC &aDriveAndPath, const TEntry &aEntry) const
    {
        if (aEntry.IsDir() || aEntry.iName.Right(4) == _L(".wav") || aEntry.iName.Right(4) == _L(".mp3") )
            return ETrue;
        else return EFalse;
    }
};

static const TUid KUidBrowser = { 0x10008D39 };

QAvkonHelper::QAvkonHelper(QDeclarativeView *view, CAknAppUi *app, QObject *parent) :
  QObject(parent), m_view(view), m_app(app)
{
}

void QAvkonHelper::displayGlobalNote(QString message, bool isError) {
   TPtrC16 aMessage(reinterpret_cast<const TUint16*>(message.utf16()));
   if (isError) ShowErrorL(aMessage); else ShowNoteL(aMessage);
}

void QAvkonHelper::ShowNoteL(const TDesC16& aMessage) {
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(EAknGlobalConfirmationNote,aMessage);
}

void QAvkonHelper::ShowErrorL(const TDesC16& aMessage) {
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(EAknGlobalErrorNote,aMessage);
}

void QAvkonHelper::openDefaultBrowser(const QUrl &url) const {
    _LIT(KBrowserPrefix, "4 " );
    // code ported from Tweetian by Dickson
    // https://github.com/dicksonleong/Tweetian/blob/master/src/symbianutils.cpp

    // convert url to encoded version of QString
    QString encUrl(QString::fromUtf8(url.toEncoded()));
    // using qt_QString2TPtrC() based on
    // <http://qt.gitorious.org/qt/qt/blobs/4.7/src/corelib/kernel/qcore_symbian_p.h#line102>
    TPtrC tUrl(TPtrC16(static_cast<const TUint16*>(encUrl.utf16()), encUrl.length()));

    // Following code based on
    // <http://www.developer.nokia.com/Community/Wiki/Launch_default_web_browser_using_Symbian_C%2B%2B>

    // create a session with apparc server
    RApaLsSession appArcSession;
    User::LeaveIfError(appArcSession.Connect());
    CleanupClosePushL<RApaLsSession>(appArcSession);

    // get the default application uid for application/x-web-browse
    TDataType mimeDatatype(_L8("application/x-web-browse"));
    TUid handlerUID;
    appArcSession.AppForDataType(mimeDatatype, handlerUID);

    // if UiD not found, use the native browser
    if (handlerUID.iUid == 0 || handlerUID.iUid == -1)
        handlerUID = KUidBrowser;

    // Following code based on
    // <http://qt.gitorious.org/qt/qt/blobs/4.7/src/gui/util/qdesktopservices_s60.cpp#line213>

    HBufC* buf16 = HBufC::NewLC(tUrl.Length() + KBrowserPrefix.iTypeLength);
    buf16->Des().Copy(KBrowserPrefix); // Prefix used to launch correct browser view
    buf16->Des().Append(tUrl);

    TApaTaskList taskList(CCoeEnv::Static()->WsSession());
    TApaTask task = taskList.FindApp(handlerUID);
    if (task.Exists()) {
        // Switch to existing browser instance
        task.BringToForeground();
        HBufC8* param8 = HBufC8::NewLC(buf16->Length());
        param8->Des().Append(buf16->Des());
        task.SendMessage(TUid::Uid( 0 ), *param8); // Uid is not used
        CleanupStack::PopAndDestroy(param8);
    } else {
        // Start a new browser instance
        TThreadId id;
        appArcSession.StartDocument(*buf16, handlerUID, id);
    }

    CleanupStack::PopAndDestroy(buf16);
    CleanupStack::PopAndDestroy(&appArcSession);
}

void QAvkonHelper::minimize() const {
    m_view->lower();
}

void QAvkonHelper::setAppHiddenState(bool state) {
  m_app->HideApplicationFromFSW(state);
}

void QAvkonHelper::restartApp() {
    if (displayAvkonQueryDialog("Close","Are you sure you want to restart the app?"))
    {
        QProcess::startDetached(QApplication::applicationFilePath());
        exit(12);
    }
}

void QAvkonHelper::restartAppMigra() {
  CAknGlobalMsgQuery* pDlg = CAknGlobalMsgQuery::NewL();
  CleanupStack::PushL(pDlg);
  TRequestStatus iStatus;
  pDlg->ShowMsgQueryL(iStatus, _L("Lightbulb will now be restarted. Have fun. ^^"), R_AVKON_SOFTKEYS_OK_EMPTY, _L("Migration completed"), KNullDesC,0,-1,CAknQueryDialog::ENoTone);

  User::WaitForRequest(iStatus);

  CleanupStack::PopAndDestroy(pDlg);
  if (iStatus.Int() == EAknSoftkeyOk) {
        QProcess::startDetached(QApplication::applicationFilePath());
        m_view->close();
        //exit(12);
    }
}

bool QAvkonHelper::displayAvkonQueryDialog(QString title, QString message) {
    // based on https://github.com/huellif/RebootMe/blob/master/main.cpp, Fabian Hüllmantel

    TPtrC16 aTitle(reinterpret_cast<const TUint16*>(title.utf16()));     // convert title to Symbian string
    TPtrC16 aMessage(reinterpret_cast<const TUint16*>(message.utf16())); // convert message to Symbian string

    CAknGlobalMsgQuery* pDlg = CAknGlobalMsgQuery::NewL();//creating the pointer
    CleanupStack::PushL(pDlg);                      //exception handling
    TRequestStatus iStatus;                         //the app should wait until the user selected an option
    pDlg->ShowMsgQueryL(iStatus, aMessage, R_AVKON_SOFTKEYS_YES_NO, aTitle, KNullDesC,0,-1,CAknQueryDialog::ENoTone);
    // in the above line iStatus makes it wait for user selection
    // R_AVKON_SOFTKEYS_YES_NO displays yes and no buttons
    // KNullDesC means no image in the window
    // 0 and -1 means no icon
    // the last one disables sound

    User::WaitForRequest(iStatus);                  //the app should wait until the user selected an option

    CleanupStack::PopAndDestroy(pDlg);              //freeing CleanupStack
    if (iStatus.Int() == EAknSoftkeyYes) return true; else return false;
}
