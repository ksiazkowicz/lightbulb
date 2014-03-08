/********************************************************************

src/cache/StoreVCard.h
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

#ifndef STOREVCARD_H
#define STOREVCARD_H

#include <QObject>
#include <QDomDocument>
#include <QDomElement>


class vCardData
{
public:
    QString nickName;
    QString firstName;
    QString middleName;
    QString lastName;
    QString url;
    QString eMail;
    QString fullName;
    vCardData() {
        nickName = "";
        firstName = "";
        middleName = "";
        lastName = "";
        url = "";
        eMail = "";
        fullName = "";
    }
    bool isEmpty() {
        return (nickName.isEmpty() &&
                firstName.isEmpty() &&
                middleName.isEmpty() &&
                lastName.isEmpty() &&
                url.isEmpty() &&
                eMail.isEmpty() &&
                fullName.isEmpty()
                );
    }
};

class StoreVCard : public QObject
{
    Q_OBJECT

    //QDomDocument *vCardXMLDoc;
    //QDomElement rootVCard;

    QString pathCache;

    //void setElementStore( const QString &nodeName, const QString &text );
    QString getElementStore( const QDomDocument *doc, const QString &nodeName );
public:
    explicit StoreVCard(QObject *parent = 0);

    void setCachePath( const QString &path ) {
        pathCache = path;
    }

    bool setVCard( const QString &bareJid, vCardData &vCard );
    vCardData getVCard( const QString &bareJid );
    
signals:
    
public slots:

private:
    QString m_birthday;
    QString m_url;
    
};

#endif // STOREVCARD_H
