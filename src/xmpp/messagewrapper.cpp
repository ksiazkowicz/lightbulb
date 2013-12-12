#include "messagewrapper.h"
#include "MyXmppClient.h"
//#include "qmlxmppclient.h"
#include <QDebug>

MessageWrapper::MessageWrapper(QObject *parent) : QObject(parent) {
}

QString MessageWrapper::parseMsgOnLink( const QString &inString ) const
{
    QString outString = "";
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
    bufAttentions[ bareJid ] = dataTimeMsg;
    //qDebug() << "*** " << Q_FUNC_INFO <<": "<< bufAttentions.contains(bareJid) << ": "<< bufAttentions[ bareJid ] << ": " << openChatJid;
}
