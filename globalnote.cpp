#include "globalnote.h"
#include <aknglobalnote.h>
#include <e32std.h>
#include <e32base.h>
#include <eiknotapi.h>
#include <aknglobalconfirmationquery.h>
#include <aknglobalmsgquery.h>
#include <akngloballistquery.h>
#include <badesca.h>

globalnote::globalnote(QObject *parent) :
    QObject(parent)
{
}

void globalnote::displayGlobalNote(QString message)
{
   TPtrC16 aMessage(reinterpret_cast<const TUint16*>(message.utf16()));
   ShowNoteL(aMessage);
}

void globalnote::displayInfo(QString message)
{
   TPtrC16 aMessage(reinterpret_cast<const TUint16*>(message.utf16()));
   ShowInfoL(aMessage);
}

void globalnote::ShowNoteL(const TDesC16& aMessage)
{
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(EAknGlobalInformationNote,aMessage);
}

void globalnote::ShowInfoL(const TDesC16& aMessage)
{
    iNote = CAknGlobalNote::NewL();
    iNote->SetSoftkeys(R_AVKON_SOFTKEYS_CLOSE);
    iNoteId = iNote->ShowNoteL(EAknGlobalInformationNote,aMessage);
}


void globalnote::StopGlobalNoteL(void)
{
    if(iNote && iNoteId >= 0)
    {
        iNote->CancelNoteL(iNoteId);
    }

    iNoteId = -1;
}
