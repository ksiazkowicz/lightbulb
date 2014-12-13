/********************************************************************

src/UpdateManager.cpp
-- autoupdater written using QNetworkAccessManager, hosted on GitHub
-- Pages.

Copyright (c) 2014 Maciej Janiszewski

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

#include "UpdateManager.h"

UpdateManager::UpdateManager(QObject *parent) :
  QObject(parent)
{
  httpStuff = new QNetworkAccessManager;
  connect(httpStuff,SIGNAL(finished(QNetworkReply*)),this,SLOT(dataReceived(QNetworkReply*)));

  updateAvailable = false;
}

void UpdateManager::checkForUpdate() {
  httpStuff->get(QNetworkRequest(QUrl("http://ksiazkowicz.github.io/lightbulb/fluorescent_version.txt")));
}

QString UpdateManager::getLatestVersion() { return replyData.split(";")[0]; }
QDateTime UpdateManager::getUpdateDate() { return QDateTime::fromString(replyData.split(";")[1],"dd-MM-yyyy"); }
QString UpdateManager::getUpdateUrl() { return replyData.split(";")[2]; }

void UpdateManager::dataReceived(QNetworkReply *reply) {
  if (reply->error() == QNetworkReply::NoError) {
      replyData = reply->readAll();
      this->compareVersions();
  } else {
      // throw an error
      emit errorOccured(reply->errorString());
  }
}

void UpdateManager::compareVersions() {
  // get versions to compare
  QStringList clientVersion = QString(VERSION).split('.');
  QStringList latestVersion = getLatestVersion().split('.');
  QString releaseDate = getUpdateDate().toString("dd-MM-yy");

  // iterate through version number
  for (int i=0; i < clientVersion.count(); i++) {
      // check if version is lower than current one
      if (clientVersion[i].toInt() < latestVersion[i].toInt())
        updateAvailable = true;

      // version on the server is older, return
      if (clientVersion[i].toInt() > latestVersion[i].toInt())
        return;
  }

  // compare release date
  if (getUpdateDate() > QDateTime::fromString(QString(BUILDDATE).mid(1,10),"yyyy-MM-dd"))
      updateAvailable = true;

  // emit signal
  if (updateAvailable == true)
    emit updateFound(getLatestVersion(),releaseDate);
  else
    emit versionUpToDate();
}
