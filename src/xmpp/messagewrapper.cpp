#include "messagewrapper.h"
#include "MyXmppClient.h"
//#include "qmlxmppclient.h"
#include <QDebug>

MessageWrapper::MessageWrapper(QObject *parent) : QObject(parent)
{
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

QString MessageWrapper::parseEmoticons( QString string ) {
    QString nStr = " " + string + " ";
    QString begin = " <img src='qrc:/smileys/";
    QString end = "' /> ";

    nStr.replace(" :) ", begin + ":)" + end);
    nStr.replace(" :-) ", begin + ":)" + end);

    nStr.replace(" :D ", begin + ":D" + end);
    nStr.replace(" :-D ", begin + ":-D" + end);

    nStr.replace(" ;) ", begin + ";)" + end);
    nStr.replace(" ;-) ", begin + ";)" + end);

    nStr.replace(" ;D ", begin + ";D" + end);
    nStr.replace(" ;-D ", begin + ";D" + end);

    nStr.replace(" :( ", begin + ":(" + end);
    nStr.replace(" :-( ", begin + ":(" + end);

    nStr.replace(" :P ", begin + ":P" + end);
    nStr.replace(" :-P ", begin + ":P" + end);

    nStr.replace(" ;( ", begin + ";(" + end);
    nStr.replace(" ;-( ", begin + ";(" + end);

    nStr.replace(" :| ", begin + ":|" + end);
    nStr.replace(" &lt;3 ", begin + "<3" + end);

    nStr.replace(" :\\ ", begin + ":\\" + end);
    nStr.replace(" :-\\ ", begin + ":\\" + end);

    nStr.replace(" :o ", begin + ":O" + end);
    nStr.replace(" :O ", begin + ":O" + end);
    nStr.replace(" o.o ", begin + ":O" + end);

    nStr.replace(" :* ", begin + ":*" + end);
    nStr.replace(" ;* ", begin + ":*" + end);

    nStr.replace(" :X ", begin + ":X" + end);
    nStr.replace(" :x ", begin + ":x" + end);

    nStr.replace(" :&gt; ", begin + ":>" + end);
    nStr.replace(" B) ", begin + "B)" + end);
    nStr.replace(" %) ", begin + "%)" + end);
    nStr.replace(" :@ ", begin + ":@" + end);
    nStr.replace(" ;&gt; ", begin + ";>" + end);
    nStr.replace(" >) ", begin + ">)" + end);
    nStr.replace(" 8) ", begin + "8)" + end);
    nStr.replace(" (=_=) ", begin + "=_=" + end);

    return nStr;
}

void MessageWrapper::attention(const QString &bareJid, const bool isMsgMine)
{
    QString dataTimeMsg = QDateTime::currentDateTime().toString("hh:mm:ss");
    bufAttentions[ bareJid ] = dataTimeMsg;
    //qDebug() << "*** " << Q_FUNC_INFO <<": "<< bufAttentions.contains(bareJid) << ": "<< bufAttentions[ bareJid ] << ": " << openChatJid;
}
