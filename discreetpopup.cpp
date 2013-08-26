#include "discreetpopup.h"
#include <akndiscreetpopup.h>

discreetpopup::discreetpopup(QObject *parent) :
    QObject(parent)
{
}

void discreetpopup::showPopup(QString title, QString message) {
    TPtrC16 sTitle(reinterpret_cast<const TUint16*>(title.utf16()));
    TPtrC16 sMessage(reinterpret_cast<const TUint16*>(message.utf16()));

    TRAP_IGNORE(CAknDiscreetPopup::ShowGlobalPopupL(sTitle, sMessage,KAknsIIDNone, KNullDesC, 0, 0, 180, 0, NULL, {0xE22AC278}));
}
