#include "nativechaticon.h"
#include <eikenv.h>
#include <centralrepository.h>
#include <e32base.h>
#include <e32property.h>

nativechaticon::nativechaticon(QObject *parent) :
    QObject(parent)
{
}

TInt nativechaticon::getChatIconStatus()
{
    TInt i=0;
    RProperty iProp;
    const TUint32 KCoreAppUIsNewChatStatus = 0x00000104;
    const TUid KPSUidCoreApplicationUIs = { 0x101F8767 };
    if ( iProp.Attach( KPSUidCoreApplicationUIs, KCoreAppUIsNewChatStatus )>=0 )
    if ( iProp.Get(i)==0 ) i = i>=2?1:0;
    return i;
}

void nativechaticon::setChatIconStatus(int i)
{
    RProperty iProp;
    const TUint32 KCoreAppUIsNewChatStatus = 0x00000104;
    const TUid KPSUidCoreApplicationUIs = { 0x101F8767 };
    if ( iProp.Attach( KPSUidCoreApplicationUIs, KCoreAppUIsNewChatStatus )>=0 )
    iProp.Set(i);
}

