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
#include <akndiscreetpopup.h>
#include <aknnotewrappers.h>
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
    notifyLight = CHWRMLight::NewL();
}

void QAvkonHelper::showPopup(QString title, QString message, bool goToApp) {
    TPtrC16 sTitle(reinterpret_cast<const TUint16*>(title.utf16()));
    TPtrC16 sMessage(reinterpret_cast<const TUint16*>(message.utf16()));

    if (goToApp) {
        TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage,KAknsIIDNone, KNullDesC, 0, 0, KAknDiscreetPopupDurationLong, 0, NULL, {0xE22AC278}));
    } else TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage,KAknsIIDNone, KNullDesC, 0, 0, KAknDiscreetPopupDurationLong, 0, NULL));
}

void QAvkonHelper::notificationBlink(int device) {
    switch (device) {
        case 1: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget1, 30, 1, 1, KHWRMDefaultIntensity)); break;
        case 2: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget2, 30, 1, 1, KHWRMDefaultIntensity)); break;
        case 3: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget3, 30, 1, 1, KHWRMDefaultIntensity)); break;
        case 4: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget4, 30, 1, 1, KHWRMDefaultIntensity)); break;
        default: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget2, 30, 1, 1, KHWRMDefaultIntensity)); break;
    }
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

QString QAvkonHelper::openFileSelectionDlg() {
    TBuf16<255> filename;
    //open native FileSelection dialog
    if (!AknCommonDialogs::RunSelectDlgLD(filename, 0)) return NULL;
    // convert Symbian string to QString
    QString qString = QString::fromUtf16(filename.Ptr(), filename.Length());

    if (qString.right(4) != ".mp3" && qString.right(4) != ".wav" && qString != "") {
        // if file format different than .mp3 or .wav, display an error
        this->displayGlobalNote("Format not supported.",true);
        return NULL;
    } else this->displayGlobalNote("File set to " + qString + ".",false); // SUCCESS! ^^

    return qString;
}

void QAvkonHelper::openDefaultBrowser(const QUrl &url) const {
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
