#include "messagewrapper.h"
#include "MyXmppClient.h"
//#include "qmlxmppclient.h"
#include <QDebug>

MessageWrapper::MessageWrapper(QObject *parent) : QObject(parent)
{
    //qmlObj = reinterpret_cast<QDeclarativeView*>(parent);
    mlm = NULL;
    mlm = new MsgListModel( this ); //??

    //QDeclarativeEngine *engine = qmlObj->engine();
    //engine->rootContext()->setContextProperty( "cppListOfMessages", mlm );
    openChatJid = "";
    m_myBareJid = "";
}


void MessageWrapper::messageReceived(const QXmppMessage &xmppMsg)
{
    qDebug() << "MessageWrapper::messageReceived(): xmppMsg.type():" << xmppMsg.type();

    if( xmppMsg.state() == QXmppMessage::Active ) {
        this->textMessage(xmppMsg);
    } else if( xmppMsg.state() == QXmppMessage::Inactive ) {
        qDebug() << "QXmppMessage::Inactive";
    } else if( xmppMsg.state() == QXmppMessage::Gone ) {
        qDebug() << "QXmppMessage::Gone";
    } else if( xmppMsg.state() == QXmppMessage::Composing ) {
        //this->startWriteMessage(xmppMsg);
    } else if( xmppMsg.state() == QXmppMessage::Paused ) {
        //this->pauseWriteMessage(xmppMsg);
    } else {
        this->textMessage(xmppMsg); //????
        qDebug() << "MessageWrapper::messageReceived(): xmppMsg.state():" << xmppMsg.state();
    }
}


void MessageWrapper::textMessage(const QXmppMessage &xmppMsg)
{
    QString id = xmppMsg.id();
    QString msg = xmppMsg.body();
    msg = msg.replace(">", "&gt;");  //fix for > stuff
    msg = msg.replace("<", "&lt;");  //and < stuff too ^^
    msg = this->parseMsgOnLink( msg );

    MeegimMessage mm;
    mm.dlr = false;
    if( (xmppMsg.stamp().isNull()) || (!xmppMsg.stamp().isValid()) ) {
        mm.date = QDateTime::currentDateTime();
    } else {
        mm.date = xmppMsg.stamp();
    }
    mm.msg = msg;
    mm.id = id;

    QString chatWithJid;
    //qDebug() << MyXmppClient::getBareJidByJid( xmppMsg.from() ) << " *** " << m_myBareJid ;
    if (  MyXmppClient::getBareJidByJid( xmppMsg.from() ) == m_myBareJid ) {
        mm.myMsg = true;
        chatWithJid = xmppMsg.to();
    } else {
        mm.myMsg = false;
        chatWithJid = xmppMsg.from();
    }

    QString resource("");
    if( chatWithJid.indexOf('/') >= 0 ) {
        resource = chatWithJid.split('/')[1];
        chatWithJid = chatWithJid.split('/')[0];
    }
    mm.resource = resource;

    if( ! listOfChats.contains(chatWithJid) )  {
        /* это первое сообщение от этого jid
         * Инициализируем список сообщени для этого jid
         */
        QList<MeegimMessage> *lm = new QList<MeegimMessage>();
        lm->append( mm );
        listOfChats[ chatWithJid ] = lm;
        qDebug() << "new msg: lenList:" << lm->length() << " jid:" << chatWithJid;
        emit openChat( chatWithJid );
    } else {
        QList<MeegimMessage> *lm = listOfChats[ chatWithJid ];
        lm->append( mm );
        listOfChats[ chatWithJid ] = lm;
        qDebug() << "exist msg: lenList:" << lm->length() << " jid:" << chatWithJid;
    }

    qDebug() << "textMessage: listOfChats.contains(" << chatWithJid << "):" << listOfChats.contains(chatWithJid) << " len:" << listOfChats.size() << " openChatJid:" << openChatJid;

    QString dataTimeMsg = mm.date.toString("hh:mm:ss");
    MsgItemModel *mim = new MsgItemModel( mm.id, mm.resource, dataTimeMsg, mm.msg, mm.dlr, mm.myMsg, MSGTYPE_TEXT, this );
    if( (mlm != NULL) && (openChatJid == chatWithJid) ) {
        mlm->append( mim );
    }

    //qDebug() << chatWithJid << " (" << mm.id << ") >" << msg << " " << listOfChats.contains(chatWithJid);
}


void MessageWrapper::initChat( QString jid ) //Q_INVOKABLE
{
    //openChatJid = jid; //обозначаем, к каким jid открыто окно чата //не факт,вызов этого происходит и при новом сообщ.
    qDebug() << "initChat(): listOfChats.contains "<< jid <<": " << listOfChats.contains(jid) << " mlm.len:" << mlm->count();

    if( listOfChats.contains(jid) && (openChatJid == jid) )
    {
        mlm->removeRows( 0, mlm->count() ); //TODO: может takeRows() ???

        QList<MeegimMessage> *currChat = listOfChats[ jid ];

        QList< MeegimMessage >::const_iterator itr = currChat->begin();
        while ( itr != currChat->end() )
        {
            MeegimMessage m = *itr;
            itr++;

            QString dataTimeMsg = m.date.toString("hh:mm:ss");
            MsgItemModel *mim = new MsgItemModel( m.id, m.resource, dataTimeMsg, m.msg, m.dlr, m.myMsg, MSGTYPE_TEXT, this );
            mlm->append(mim);
        }
    }
    else if( ! listOfChats.contains(jid) && (openChatJid == jid) )
    {
        mlm->removeRows( 0, mlm->count() ); //TODO: может takeRows() ???

        QList<MeegimMessage> *lm = new QList<MeegimMessage>();
        listOfChats[ jid ] = lm;
    }

    //attentions
    if( bufAttentions.contains(jid) )
    {
        QString ca = bufAttentions[jid];
        if( ca != "" )
        {
            MsgItemModel *mim = new MsgItemModel( 0, "", ca, "", false, false, MSGTYPE_ATTENTION, this );
            mlm->append(mim);
            bufAttentions[ jid ] = "";
        }
    }

}


void MessageWrapper::clearChat(QString bareJid)
{
    if( listOfChats.contains(bareJid) )
    {
        QList<MeegimMessage> *lm = listOfChats[ bareJid ];
        int L = lm->length();
        for( int k=0; k<L; k++ )
        {
            lm->takeLast();
        }
        mlm->removeRows( 0, mlm->count() );
    }
}



void MessageWrapper::messageDelivered( const QString &jid, const QString &id )
{
    QString pureJid = jid.split('/')[0];
    qDebug() << "MessageWrapper::messageDelivered(): " << pureJid << " " << id << " listOfChats.len:" << listOfChats.size() << " jid:" << listOfChats.contains( pureJid );
    if( listOfChats.contains( pureJid ) ) {
        QList<MeegimMessage> *list_mm = listOfChats[ pureJid ];
        QList<MeegimMessage>::iterator itr = list_mm->end(); /* с конца искть нужное сообщ. будет быстрее :) */
        while( itr != list_mm->begin() )
        {
            itr--;
            qDebug() << "DLR*:" << (*itr).id;
            if( (*itr).id == id ) {
                (*itr).dlr = true;
                listOfChats[ pureJid ] = list_mm;
                break;
            }
        }

        MsgItemModel *item = reinterpret_cast<MsgItemModel*>( mlm->find( id ) );
        if( item != 0 ) {
            item->setMsgDlr( true );
        }
    }
}


void MessageWrapper::removeListOfChat( QString &bareJid )
{
    if( listOfChats.contains(bareJid) )  {
        QList<MeegimMessage> *list_mm = listOfChats.take( bareJid );
        if( list_mm != NULL ) {
            delete list_mm;
        }
        qDebug() << "listOfChats.contains("<<bareJid<<"):"<<listOfChats.contains(bareJid);
    }
}



QString MessageWrapper::parseMsgOnLink( const QString &inString ) const
{
    QString outString = "";
    outString = outString.replace("<","&lt;");
    outString = outString.replace(">","&gt;");
    int pos = 0;
    int pos_space = 0;

    bool strangeTagOpen = false;
    bool strangeTagClose = false;

    qDebug() << inString;
    while( (pos = inString.indexOf("http", pos)) >= 0 )
    {
        outString += inString.mid(pos_space, pos - pos_space);

        QString prevSmb = inString.mid( pos-1, 1 );
        if( prevSmb == "<" ) { strangeTagOpen = true; }

        pos_space = inString.indexOf( " ", pos );
        if( pos_space < 0 ) {
            pos_space = inString.indexOf( "\"", pos );
            if( pos_space < 0 ) {
                pos_space = inString.indexOf( ">", pos );
                strangeTagClose = true;
            }
        }
        QString link = inString.mid( pos, pos_space-pos );
        QString nLink = "<a href=\"" + link + "\">" + link + "</a>";
        if( strangeTagOpen && strangeTagClose ) {
            nLink = "a href=\"" + link + "\">" + link + "</a";
        }

        //qDebug() << "pos="<<pos<<" pos_space="<<pos_space<<" ["<<link<<"]";
        outString += nLink;

        pos = pos_space;

        strangeTagOpen = false;
        strangeTagClose = false;
    }
    if( pos_space >= 0 ) {
        outString += inString.mid(pos_space);
    }

    //qDebug() << outString;
    return outString;
}


void MessageWrapper::attention(const QString &bareJid, const bool isMsgMine)
{
    QString dataTimeMsg = QDateTime::currentDateTime().toString("hh:mm:ss");
    if( bareJid == openChatJid )
    {
        MsgItemModel *mim = new MsgItemModel( 0, "", dataTimeMsg, "", false, isMsgMine, MSGTYPE_ATTENTION, this );
        mlm->append(mim);
    }
    else
    {
        bufAttentions[ bareJid ] = dataTimeMsg;
    }
    //qDebug() << "*** " << Q_FUNC_INFO <<": "<< bufAttentions.contains(bareJid) << ": "<< bufAttentions[ bareJid ] << ": " << openChatJid;
}
