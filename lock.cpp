#include "lock.h"
#include "aknkeylock.h"

lock::lock(QObject *parent) :
    QObject(parent)
{
}

void lock::lockDevice() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    aKeyLock.EnableKeyLock();
    aKeyLock.Close();
}

void lock::unlockDevice() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    aKeyLock.DisableKeyLock();
    aKeyLock.Close();
}

bool lock::isLocked() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    bool smiercCierpienie;
    smiercCierpienie = aKeyLock.IsKeyLockEnabled();
    aKeyLock.Close();
    return smiercCierpienie;
}
