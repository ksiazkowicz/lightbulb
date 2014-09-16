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
#include "StoreVCard.h"
#include <QDir>

QMLVCard::QMLVCard(QObject *parent) : QObject(parent)
{
}

void QMLVCard::clearData() { //Q_INVOKABLE
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

void QMLVCard::loadVCard(QString bareJid) { //Q_INVOKABLE
  StoreVCard storage;
  storage.setCachePath(QDir::currentPath() + QDir::separator() + QString("cache"));
  vCardData data = storage.getVCard(bareJid);

  m_nickname = data.nickName;
  m_name = data.firstName;
  m_middlename = data.middleName;
  m_lastname = data.lastName;
  m_fullname = data.fullName;
  m_email = data.eMail;
  m_url = data.url;
  m_jid = bareJid;
  emit vCardChanged();
}
