#include "lock.h"
#include <aknkeylock.h>
#include <hwrmlight.h>
#include <e32svr.h>

lock::lock(QObject *parent) :
    QObject(parent)
{
    light = CHWRMLight::NewL();
    notifyLight = CHWRMLight::NewL();
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

void lock::blink() {
    light->LightBlinkL(CHWRMLight::EPrimaryDisplay | CHWRMLight::EPrimaryKeyboard, 1000, 1000, 1000, KHWRMDefaultIntensity);
}

void lock::notificationBlink() {
    notifyLight->LightBlinkL(CHWRMLight::ECustomTarget2, 20, 10, 10, KHWRMDefaultIntensity);
}
