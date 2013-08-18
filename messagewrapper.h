#ifndef MESSAGEWRAPPER_H
#define MESSAGEWRAPPER_H

#include "QXmppMessage.h"
//#include "QXmppPacket.h"
#include <QMap>
#include <QDateTime>
#include <QVariant>
#include <QtDeclarative>

#include "msgitemmodel.h"
#include "msglistmodel.h"

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
    //QDeclarativeView *qmlObj;
    MsgListModel *mlm;

    QXmppMessage *xmppMessage;

    //QVariantMap qmlBufOpenChats;

    /* "jid" => list of MeegimMessage */
    QMap<QString, QList<MeegimMessage>* > listOfChats;
    QString openChatJid;

    QString m_myBareJid;

    QString parseMsgOnLink( const QString &inString ) const;

    QMap< QString, QString > bufAttentions;
public:
    explicit MessageWrapper(QObject *parent = 0);

    void initChat( QString jid );
    void clearChat( QString bareJid );
    void hideChat() { openChatJid = ""; }

    void setMyJid( const QString &myBareJid ) { m_myBareJid = myBareJid; }
    void setChatBareJid( const QString &chatBareJid )  { openChatJid = chatBareJid; }

    void removeListOfChat( QString &bareJid );

    MsgListModel* getMessages() const { return mlm; }

    void textMessage(const QXmppMessage &xmppMsg);

    void attention( const QString &bareJid, const bool isMsgMine );
    
signals:
    void openChat(QString jid);
    //void sendMyMsg( const QXmppMessage &xmppMsg );
    
public slots:
    void messageReceived( const QXmppMessage &xmppMsg ); //don't use - depricated
    void messageDelivered( const QString &jid, const QString &id );
    
};

#endif // MESSAGEWRAPPER_H
