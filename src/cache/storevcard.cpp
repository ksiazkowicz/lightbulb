/********************************************************************

src/cache/StoreVCard.cpp
-- stores VCards

Copyright (c) 2013 Anatoliy Kozlov, Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

#include "storevcard.h"

#include <QFile>
#include <QDir>
#include <QDebug>

StoreVCard::StoreVCard(QObject *parent) : QObject(parent) {
}

QString StoreVCard::getElementStore( const QDomDocument *doc, const QString &nodeName ) {
    QString ret("");

    QDomNode nodeElement = doc->elementsByTagName( nodeName ).item(0);
    QDomNode te = nodeElement.firstChild();

    if (!te.isNull())
        ret = te.nodeValue();

    return ret;
}



bool StoreVCard::setVCard( const QString &bareJid, vCardData &vCard ) {
    QDomDocument vCardXMLDoc("vCard");

    if( pathCache.isEmpty() )
        return false;

    QDomElement rootVCard = vCardXMLDoc.createElement("vCard");
    vCardXMLDoc.appendChild( rootVCard );

    QDomElement nodeNickname = vCardXMLDoc.createElement( "nickName" );
    rootVCard.appendChild(nodeNickname);
    QDomText txtNickname = vCardXMLDoc.createTextNode( vCard.nickName.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "firstName", vCard.firstName );
    nodeNickname = vCardXMLDoc.createElement( "firstName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.firstName.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "middleName", vCard.middleName );
    nodeNickname = vCardXMLDoc.createElement( "middleName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.middleName.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "lastName", vCard.lastName );
    nodeNickname = vCardXMLDoc.createElement( "lastName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.lastName.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "url", vCard.url );
    nodeNickname = vCardXMLDoc.createElement( "url" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.url.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "eMail", vCard.eMail );
    nodeNickname = vCardXMLDoc.createElement( "eMail" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.eMail.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    //setElementStore( "fullName", vCard.fullName );
    nodeNickname = vCardXMLDoc.createElement( "fullName" );
    rootVCard.appendChild(nodeNickname);
    txtNickname = vCardXMLDoc.createTextNode( vCard.fullName.toUtf8() );
    nodeNickname.appendChild( txtNickname );

    #ifdef QT_DEBUG
    //qDebug() << "doc=" << vCardXMLDoc.toString();
    #endif

    QString fileVCard = pathCache + QDir::separator() + bareJid + QDir::separator() +"vCard.xml";
    QFile xmlVCardFile(fileVCard);
    if( !xmlVCardFile.open( QIODevice::WriteOnly | QIODevice::Text ) ) {
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
