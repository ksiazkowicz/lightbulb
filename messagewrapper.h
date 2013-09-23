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

class MeegimMessage
{
public:
    MeegimMessage() { dlr = false; msg = ""; id = ""; myMsg = false; resource = ""; }
    bool dlr;
    bool myMsg;
    QString id;
    QString resource;
    QString msg;
    QDateTime date;
    void toString() {
        qDebug()<<"MSG: ["<<date.toString("hh:mm:ss")<<"] id:["<<id<<"] isMy:["<<myMsg<<"] dlr:["<<dlr<<"] txt:["<<msg<<"]";
    }
};




class MessageWrapper : public QObject
{
    Q_OBJECT

    QXmppMessage *xmppMessage;

    /* "jid" => list of MeegimMessage */
    QString openChatJid;

    QString m_myBareJid;

    QMap< QString, QString > bufAttentions;
public:
    explicit MessageWrapper(QObject *parent = 0);

    void setMyJid( const QString &myBareJid ) { m_myBareJid = myBareJid; }
    void setChatBareJid( const QString &chatBareJid )  { openChatJid = chatBareJid; }

    void textMessage(const QXmppMessage &xmppMsg);

    void attention( const QString &bareJid, const bool isMsgMine );

    QString parseMsgOnLink( const QString &inString ) const;
};

#endif // MESSAGEWRAPPER_H
