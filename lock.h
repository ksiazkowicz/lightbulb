#ifndef LOCK_H
#define LOCK_H

#include <QObject>

class lock : public QObject
{
    Q_OBJECT
public:
    explicit lock(QObject *parent = 0);
    Q_INVOKABLE void lockDevice();
    Q_INVOKABLE void unlockDevice();
    Q_INVOKABLE bool isLocked();
    
signals:
    
public slots:
    
};

#endif // LOCK_H
