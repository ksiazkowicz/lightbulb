#ifndef NATIVECHATICON_H
#define NATIVECHATICON_H

#include <QObject>
#include <eikenv.h>
#include <centralrepository.h>
#include <e32base.h>
#include <e32property.h>

class nativechaticon : public QObject
{
    Q_OBJECT
public:
    explicit nativechaticon(QObject *parent = 0);
    Q_INVOKABLE TInt getChatIconStatus();
    Q_INVOKABLE void setChatIconStatus(int);
    
signals:
    
public slots:
    
};

#endif // NATIVECHATICON_H
