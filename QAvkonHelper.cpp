#include "QAvkonHelper.h"
#include <akndiscreetpopup.h>
#include <aknkeylock.h>
#include <aknglobalnote.h>
#include <hwrmlight.h>
#include <e32svr.h>

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
