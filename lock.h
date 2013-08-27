#ifndef LOCK_H
#define LOCK_H

#include <QObject>
#include <e32base.h>
#include <hwrmlight.h>

class lock : public QObject
{
    Q_OBJECT
public:
    explicit lock(QObject *parent = 0);
    Q_INVOKABLE void lockDevice();
    Q_INVOKABLE void unlockDevice();
    Q_INVOKABLE bool isLocked();
    Q_INVOKABLE void blink();
    Q_INVOKABLE void notificationBlink();
    Q_INVOKABLE void notificationStop();

private:
    CHWRMLight* light; // Light control
    CHWRMLight* notifyLight;
    
signals:
    
public slots:
    
};

#endif // LOCK_H
