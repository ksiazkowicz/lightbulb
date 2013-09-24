#ifndef MESSAGEWRAPPER_H
#define MESSAGEWRAPPER_H

#include "QXmppMessage.h"
//#include "QXmppPacket.h"
#include <QMap>
#include <QDateTime>
#include <QVariant>
#include <QtDeclarative>
#include "DatabaseManager.h"

class MyXmppClient;

class MessageWrapper : public QObject
{
    Q_OBJECT

    QXmppMessage *xmppMessage;

    QMap< QString, QString > bufAttentions;
public:
    explicit MessageWrapper(QObject *parent = 0);

    void attention( const QString &bareJid, const bool isMsgMine );

    QString parseMsgOnLink( const QString &inString ) const;
};

#endif // MESSAGEWRAPPER_H
