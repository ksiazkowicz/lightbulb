#include "globalnote.h"
#include <aknglobalnote.h>

globalnote::globalnote(QObject *parent) :
    QObject(parent)
{
}

void globalnote::displayGlobalNote(QString message)
{
   TPtrC16 aMessage(reinterpret_cast<const TUint16*>(message.utf16()));
   ShowNoteL(aMessage);
}

void globalnote::ShowNoteL(const TDesC16& aMessage)
{
    ShowGlobalNoteL(EAknGlobalInformationNote, aMessage);
}


void globalnote::ShowGlobalNoteL(TAknGlobalNoteType aNoteType, const TDesC16& aMessage)
{
    iNote = CAknGlobalNote::NewL();
    iNoteId = iNote->ShowNoteL(aNoteType,aMessage);
}


void globalnote::StopGlobalNoteL(void)
{
    if(iNote && iNoteId >= 0)
    {
        iNote->CancelNoteL(iNoteId);
    }

    iNoteId = -1;
}
