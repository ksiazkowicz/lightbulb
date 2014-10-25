/********************************************************************

src/avkon/QAvkonHelper.cpp
-- interface to native Symbian APIs

Copyright (c) 2013 Maciej Janiszewski,
                   Fabian H�llmantel,
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
#include <AknCommonDialogsDynMem.h>
#include <aknglobalmsgquery.h>
#include <hwrmlight.h>
#include <e32svr.h>
#include <eikmenup.h>
#include <coemain.h>
#include <MGFetch.h>
#include <apgcli.h> // RApaLsSession
#include <apgtask.h> // TApaTaskList, TApaTask
#include <QUrl>
#include <QProcess>
#include <QTimer>
#include <QFileDialog>

#include <coreapplicationuisdomainpskeys.h> //keys for RProperty
#include <e32property.h> //http://katastrophos.net/symbian-dev/GUID-C6E5F800-0637-419E-8FE5-1EBB40E725AA/GUID-C4776034-D190-3FC4-AF45-C7F195093AC3.html

#include <MAknFileFilter.h>

#include <f32file.h>

#include <QDebug>
#include <QtDeclarative/QDeclarativeView>

// filters out non-sound files
class CExtensionFilter : public MAknFileFilter {
public:
    TBool Accept(const TDesC &aDriveAndPath, const TEntry &aEntry) const
    {
        if (aEntry.IsDir() || aEntry.iName.Right(4) == _L(".wav") || aEntry.iName.Right(4) == _L(".mp3") ||  aEntry.iName.Right(4) == _L(".aac"))
            return ETrue;
        else return EFalse;
    }
};

static const TUid KUidBrowser = { 0x10008D39 };

QAvkonHelper::QAvkonHelper(QDeclarativeView *view, CAknAppUi *app, QObject *parent) :
  QObject(parent), m_view(view), m_app(app)
{
    notifyLight = CHWRMLight::NewL();
    chatIconStatus = true;
    hideChatIcon();
    iAudioPlayer = AvkonMedia::NewL();
}

void QAvkonHelper::showChatIcon() {
    if (!chatIconStatus) {
        RProperty iProperty;
        iProperty.Set(KPSUidCoreApplicationUIs, KCoreAppUIsUipInd, ECoreAppUIsShow);
        chatIconStatus = true;
    }
}

void QAvkonHelper::hideChatIcon() {
    if (chatIconStatus) {
        RProperty iProperty;
        //to disable it:
        iProperty.Set( KPSUidCoreApplicationUIs, KCoreAppUIsUipInd, ECoreAppUIsDoNotShow);
        chatIconStatus = false;
    }
}

void QAvkonHelper::playNotification(QString path) {
  TPtrC16 kPath(reinterpret_cast<const TUint16*>(path.utf16()));
  if (!iAudioPlayer->isInSilentMode())
    iAudioPlayer->PlayL(kPath);
}

void QAvkonHelper::showPopup(QString title, QString message) {
    if (lastPopup != title + ";" + message) lastPopup = title + ";" + message; else return;

    if (_switchToApp) {
        TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(convertToSymbianString(title), convertToSymbianString(message),KAknsIIDNone, KNullDesC, 0, 0, KAknDiscreetPopupDurationLong, 0, NULL, {0xE00AC666}));
    } else TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(convertToSymbianString(title), convertToSymbianString(message),KAknsIIDNone, KNullDesC, 0, 0, KAknDiscreetPopupDurationLong, 0, NULL));
    QTimer::singleShot(2000,this,SLOT(cleanLastMsg()));
}

void QAvkonHelper::notificationBlink(int device) {
    switch (device) {
        case 1: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget1, 30, 1, 1, KHWRMDefaultIntensity)); break;
        case 2: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget2, 30, 1, 1, KHWRMDefaultIntensity)); break;
        default: TRAP_IGNORE(notifyLight->LightBlinkL(CHWRMLight::ECustomTarget2, 30, 1, 1, KHWRMDefaultIntensity)); break;
    }
}

void QAvkonHelper::displayGlobalNote(QString message, bool isError) {
   if (isError) ShowErrorL(convertToSymbianString(message)); else ShowNoteL(convertToSymbianString(message));
}

void QAvkonHelper::ShowNoteL(const TDesC16& aMessage) {
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(EAknGlobalConfirmationNote,aMessage);
}

void QAvkonHelper::ShowErrorL(const TDesC16& aMessage) {
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(EAknGlobalErrorNote,aMessage);
}

QString QAvkonHelper::openFileSelectionDlg(bool onlySounds, bool showNotification, QString startPath) {
    TBuf16<256> filename;
    TInt types = AknCommonDialogsDynMem::EMemoryTypeMMCExternal|
                 AknCommonDialogsDynMem::EMemoryTypeInternalMassStorage|
                 AknCommonDialogsDynMem::EMemoryTypePhone;

    TBool run;

    if (onlySounds) {
        CExtensionFilter* extensionFilter = new (ELeave) CExtensionFilter;
        CleanupStack::PushL(extensionFilter);
        run = AknCommonDialogsDynMem::RunSelectDlgLD(types, filename, convertToSymbianString(startPath), 0, 0, _L("Select a sound file"), extensionFilter);
        CleanupStack::PopAndDestroy(extensionFilter);
    } else {
        run = AknCommonDialogsDynMem::RunSelectDlgLD(types, filename, convertToSymbianString(startPath), 0, 0, _L("Select a file"));
      }

    if (!run) {
        return " ";
    } else {
        // convert Symbian string to QString
        QString qString = QString::fromUtf16(filename.Ptr(), filename.Length());

        if (showNotification)
         this->displayGlobalNote("File set to " + qString + ".",false); // SUCCESS! ^^

        return qString;
    }
}

QString QAvkonHelper::openMediaSelectionDialog(int type) {
    // initialize variables
    CDesCArrayFlat* fileArray = new CDesCArrayFlat(3);
    TBool selectionOk = EFalse;
    TMediaFileType aType;

    // check if type is valid and set a TMediaFileType according to this data
    switch (type) {
      case 0: aType = EImageFile; break;
      case 1: aType = EVideoFile; break;
      case 2: aType = EAudioFile; break;
      case 3: aType = EMusicFile; break;
      default: return "";
      }

    // open selection dialog
    TRAP_IGNORE(selectionOk = MGFetch::RunL(*fileArray,aType,ETrue,KNullDesC,KNullDesC););

    if (selectionOk) {
        // initialize variable
        QString selected;

        // go through the file array
        for (int i = 0; i < fileArray->Count(); i++) {
            selected += QString::fromUtf16(fileArray->MdcaPoint(i).Ptr(),
                                           fileArray->MdcaPoint(i).Length()) + "\n";
        }
    } else
        // selection dialog was cancelled
        return "";

}

QString QAvkonHelper::openFolderSelectionDlg(QString lastDir) {
  // Show system dialog for folder selection
  QString dirname = QFileDialog::getExistingDirectory(0,"Change folder", lastDir,
      QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
  return dirname;
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
    if (displayAvkonQueryDialog("Close","Are you sure you want to restart the app?")) {
        QProcess::startDetached(QApplication::applicationFilePath());
        exit(12);
        hideChatIcon();
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
        hideChatIcon();
    }
}

bool QAvkonHelper::displayAvkonQueryDialog(QString title, QString message) {
    // based on https://github.com/huellif/RebootMe/blob/master/main.cpp, Fabian Hullmantel

    CAknGlobalMsgQuery* pDlg = CAknGlobalMsgQuery::NewL(); //creating the pointer
    CleanupStack::PushL(pDlg);                             //exception handling
    TRequestStatus iStatus;                                //the app should wait until the user selected an option

    pDlg->ShowMsgQueryL(iStatus, convertToSymbianString(message), R_AVKON_SOFTKEYS_YES_NO, convertToSymbianString(title), KNullDesC,0,-1,CAknQueryDialog::ENoTone);

    User::WaitForRequest(iStatus);                  //the app should wait until the user selected an option

    CleanupStack::PopAndDestroy(pDlg);              //freeing CleanupStack
    return iStatus.Int() == EAknSoftkeyYes;
}

TPtrC16 QAvkonHelper::convertToSymbianString(QString string) {
  return reinterpret_cast<const TUint16*>(string.utf16());
}
