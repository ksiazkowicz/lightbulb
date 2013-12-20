#include "storevcard.h"

#include <QFile>
#include <QDir>
#include <QDebug>

StoreVCard::StoreVCard(QObject *parent) : QObject(parent)
{
}

QString StoreVCard::getElementStore( const QDomDocument *doc, const QString &nodeName )
{
    QString ret("");

    QDomNode nodeElement = doc->elementsByTagName( nodeName ).item(0);
    QDomNode te = nodeElement.firstChild();

    if( !te.isNull() ) {
        ret = te.nodeValue();
    }

    return ret;
}



bool StoreVCard::setVCard( const QString &bareJid, vCardData &vCard )
{
    QDomDocument vCardXMLDoc("vCard");

    if( pathCache.isEmpty() ) {
        return false;
    }

    QDomElement rootVCard = vCardXMLDoc.createElement("vCard");
    vCardXMLDoc.appendChild( rootVCard );

    QDomElement nodeNickname = vCardXMLDoc.createElement( "nickName" );
    rootVCard.appendChild(nodeNickname);
    QDomText txtNickname = vCardXMLDoc.createTextNode( vCard.nickName );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "firstName", vCard.firstName );
    nodeNickname = vCardXMLDoc.createElement( "firstName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.firstName );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "middleName", vCard.middleName );
    nodeNickname = vCardXMLDoc.createElement( "middleName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.middleName );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "lastName", vCard.lastName );
    nodeNickname = vCardXMLDoc.createElement( "lastName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.lastName );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "url", vCard.url );
    nodeNickname = vCardXMLDoc.createElement( "url" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.url );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "eMail", vCard.eMail );
    nodeNickname = vCardXMLDoc.createElement( "eMail" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.eMail );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "fullName", vCard.fullName );
    nodeNickname = vCardXMLDoc.createElement( "fullName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.fullName );
    nodeNickname.appendChild( txtNickname );

    #ifdef QT_DEBUG
    //qDebug() << "doc=" << vCardXMLDoc.toString();
    #endif

    QString fileVCard = pathCache + QDir::separator() + bareJid + QDir::separator() +"vCard.xml";
    QFile xmlVCardFile(fileVCard);
    if( !xmlVCardFile.open( QIODevice::WriteOnly | QIODevice::Text ) )
    {
        qCritical()  << "commitVCard: Failed to open file for writing: " <<  fileVCard;
        return false;
    }
    QTextStream stream( &xmlVCardFile );
    stream << vCardXMLDoc.toString();
    xmlVCardFile.close();

    return true;
}


vCardData StoreVCard::getVCard( const QString &bareJid )
{
    QDomDocument vCardXMLDoc;
    vCardData data;

    QString fileVCard = pathCache + QDir::separator() + bareJid + QDir::separator() +"vCard.xml";
    QFile xmlVCardFile(fileVCard);
    if( xmlVCardFile.exists() )
    {
        if( xmlVCardFile.open( QIODevice::ReadOnly | QIODevice::Text ) ) {
            if( vCardXMLDoc.setContent( &xmlVCardFile ) ) {
                xmlVCardFile.close();
            }
        } else {
            qWarning() << "initVCard: Failed to open file: " << fileVCard;
        }
    }
    else
    {
        return data;
    }

    data.nickName = getElementStore( &vCardXMLDoc, "nickName" );
    data.firstName = getElementStore( &vCardXMLDoc, "firstName" );
    data.middleName = getElementStore( &vCardXMLDoc, "middleName" );
    data.lastName = getElementStore( &vCardXMLDoc, "lastName" );
    data.url = getElementStore( &vCardXMLDoc, "url" );
    data.eMail = getElementStore( &vCardXMLDoc, "eMail" );
    data.fullName = getElementStore( &vCardXMLDoc, "fullName" );

    #ifdef QT_DEBUG
    //qDebug() << "isVCardEmpty ? " << data.isEmpty();
    #endif


    return data;
}
