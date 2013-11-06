#include "QAvkonHelper.h"
#include <akndiscreetpopup.h>
#include <aknkeylock.h>
#include <aknglobalnote.h>
#include <CAknFileSelectionDialog.h>
#include <AknCommonDialogs.h>
#include <hwrmlight.h>
#include <e32svr.h>
#include <eikmenup.h>
#include <eikenv.h> // CEikonEnv
#include <apgcli.h> // RApaLsSession
#include <apgtask.h> // TApaTaskList, TApaTask
#include <QUrl>

_LIT(KBrowserPrefix, "4 " );
static const TUid KUidBrowser = { 0x10008D39 };

QAvkonHelper::QAvkonHelper(QObject *parent) :
    QObject(parent)
{
    light = CHWRMLight::NewL();
    notifyLight = CHWRMLight::NewL();
}

void QAvkonHelper::showPopup(QString title, QString message) {
    TPtrC16 sTitle(reinterpret_cast<const TUint16*>(title.utf16()));
    TPtrC16 sMessage(reinterpret_cast<const TUint16*>(message.utf16()));

    TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage,KAknsIIDNone, KNullDesC, 0, 0, 180, 0, NULL, {0xE22AC278}));
}

void QAvkonHelper::lockDevice() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    aKeyLock.EnableKeyLock();
    aKeyLock.Close();
}

void QAvkonHelper::unlockDevice() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    aKeyLock.DisableKeyLock();
    aKeyLock.Close();
}

void QAvkonHelper::screenBlink() {
    light->LightBlinkL(CHWRMLight::EPrimaryDisplay | CHWRMLight::EPrimaryKeyboard, 1000, 1000, 1000, KHWRMDefaultIntensity);
}

void QAvkonHelper::notificationBlink() {
    notifyLight->LightBlinkL(CHWRMLight::ECustomTarget2, 30, 1, 1, KHWRMDefaultIntensity);
}

void QAvkonHelper::displayGlobalNote(QString message)
{
   TPtrC16 aMessage(reinterpret_cast<const TUint16*>(message.utf16()));
   ShowNoteL(aMessage);
}

void QAvkonHelper::ShowNoteL(const TDesC16& aMessage)
{
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(EAknGlobalInformationNote,aMessage);
}

QString QAvkonHelper::openFileSelectionDlg()
{
    TBuf16<255> filename;
    if (!AknCommonDialogs::RunSelectDlgLD(filename, 0))
            return NULL;
    QString qString = QString::fromUtf16(filename.Ptr(), filename.Length());

    if (qString.right(4) != ".mp3" && qString.right(4) != ".wav" && qString != "") {
        this->displayGlobalNote("Format not supported.");
        return NULL;
    }

    if (qString != "") {
        this->displayGlobalNote("File set to " + qString + ".");
    }

    return qString;

}

void QAvkonHelper::openDefaultBrowser(const QUrl &url) const
{
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

    TApaTaskList taskList(CEikonEnv::Static()->WsSession());
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
