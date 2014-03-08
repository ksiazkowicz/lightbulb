/********************************************************************

src/cache/QMLVCard.h
-- exposes VCards to QML

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

#ifndef QMLVCARD_H
#define QMLVCARD_H

#include <QObject>

class QMLVCard : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY( QMLVCard )

    Q_PROPERTY( QString photo READ getPhoto NOTIFY vCardChanged )
    Q_PROPERTY( QString nickname READ getNickName NOTIFY vCardChanged )
    Q_PROPERTY( QString name READ getName NOTIFY vCardChanged )
    Q_PROPERTY( QString middlename READ getMiddleName NOTIFY vCardChanged )
    Q_PROPERTY( QString lastname READ getLastName NOTIFY vCardChanged )
    Q_PROPERTY( QString fullname READ getFullName NOTIFY vCardChanged )
    Q_PROPERTY( QString email READ getEMail NOTIFY vCardChanged )
    Q_PROPERTY( QString birthday READ getBirthday NOTIFY vCardChanged )
    Q_PROPERTY( QString url READ getUrl NOTIFY vCardChanged )
    Q_PROPERTY( QString jid READ getJid NOTIFY vCardChanged )

    Q_PROPERTY( QMLVCard* vcard READ getVCard WRITE setVCard NOTIFY vCardChanged )

public:
    explicit QMLVCard(QObject *parent = 0);

    QString getPhoto() const { return m_photo; }
    void setPhoto( const QString &photo ) { if(photo != m_photo) { m_photo =photo; } }

    QString getNickName() const { return m_nickname; }
    void setNickName( const QString &value ) { if(value != m_nickname) { m_nickname =value; } }

    QString getName() const { return m_name; }
    void setName( const QString &value ) { if(value != m_name) { m_name =value; } }

    QString getMiddleName() const { return m_middlename; }
    void setMiddleName( const QString &value ) { if(value != m_middlename) { m_middlename =value; } }

    QString getLastName() const { return m_lastname; }
    void setLastName( const QString &value ) { if(value != m_lastname) { m_lastname =value; } }

    QString getFullName() const { return m_fullname; }
    void setFullName( const QString &value ) { if(value != m_fullname) { m_fullname =value; } }

    QString getEMail() const { return m_email; }
    void setEMail( const QString &value ) { if(value != m_email) { m_email =value; } }

    QString getBirthday() const { return m_birthday; }
    void setBirthday( const QString &value ) { if(value != m_birthday) { m_birthday =value; } }

    QString getUrl() const { return m_url; }
    void setUrl( const QString &value ) { if(value != m_url) { m_url =value; } }
    
    QMLVCard* getVCard() const { return m_vcard; }
    void setVCard( QMLVCard *value );

    QString getJid() const { return m_jid; }
    void setJid( const QString &value ) { if(value != m_jid) { m_jid =value; } }

    Q_INVOKABLE void clearData();

signals:
    void vCardChanged();
    
public slots:

private:
    QString m_photo;
    QString m_nickname;
    QString m_name;
    QString m_middlename;
    QString m_lastname;
    QString m_fullname;
    QString m_email;
    QString m_birthday;
    QString m_url;
    QString m_jid;
    QMLVCard *m_vcard;
    
};

#endif // QMLVCARD_H
