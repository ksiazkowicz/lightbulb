/********************************************************************

src/cache/QMLVCard.cpp
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

#include "qmlvcard.h"
#include <QDebug>

QMLVCard::QMLVCard(QObject *parent) : QObject(parent)
{
    m_photo = "";
    m_nickname = "";
    m_name = "";
    m_middlename = "";
    m_lastname = "";
    m_fullname = "";
    m_birthday = "";
    m_email = "";
    m_url = "";
}

void QMLVCard::setVCard( QMLVCard *value )
{
    m_vcard =value;

    m_photo = value->getPhoto();
    m_nickname = value->getNickName();
    m_name = value->getName();
    m_middlename = value->getMiddleName();
    m_lastname = value->getLastName();
    m_fullname = value->getFullName();
    m_birthday = value->getBirthday();
    m_email = value->getEMail();
    m_url = value->getUrl();
    m_jid = value->getJid();
    #ifdef QT_DEBUG
        //qDebug()<<"***>"<<m_photo <<m_nickname<<m_name<<m_middlename<<m_lastname<<m_fullname<<m_birthday<<m_email<<m_url<<m_jid;
    #endif


    emit vCardChanged();
}

void QMLVCard::clearData() //Q_INVOKABLE
{
    m_vcard = 0;
    m_photo = "";
    m_nickname = "";
    m_name = "";
    m_middlename = "";
    m_lastname = "";
    m_fullname = "";
    m_birthday = "";
    m_email = "";
    m_url = "";
    m_jid = "";
}
