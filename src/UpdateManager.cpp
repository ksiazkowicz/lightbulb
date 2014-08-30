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
  httpStuff = new QNetworkAccessManager(this);
  connect(httpStuff,SIGNAL(finished(QNetworkReply*)),this,SLOT(dataReceived(QNetworkReply*)));

  httpStuff->moveToThread(new QThread());
  updateAvailable = false;
}

void UpdateManager::checkForUpdate() {
  httpStuff->get(QNetworkRequest(QUrl("https://ksiazkowicz.github.io/lightbulb/fluorescent_version.txt")));
}

QString UpdateManager::getLatestVersion() {
  return replyData.split(";")[0];
}

QDateTime UpdateManager::getUpdateDate() {
  return QDateTime::fromString(replyData.split(";")[1],"dd-MM-yyyy");
}

QString UpdateManager::getUpdateUrl() {
  return replyData.split(";")[2];
}

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
  QString clientVersion = VERSION;
  QString latestVersion = getLatestVersion();
  QString releaseDate = getUpdateDate().toString("dd-MM-yy");

  // compare major version
  if (clientVersion.split('.')[0].toInt() < latestVersion.split('.')[0].toInt())
      updateAvailable = true;

  // if version on the server is older, return
  if (clientVersion.split('.')[0].toInt() > latestVersion.split('.')[0].toInt())
    return;

  // compare minor version
  if (clientVersion.split('.')[1].toInt() < latestVersion.split('.')[1].toInt())
      updateAvailable = true;

  // if version on the server is older, return
  if (clientVersion.split('.')[1].toInt() > latestVersion.split('.')[1].toInt())
    return;

  // compare maintenance version
  if (clientVersion.split('.')[2].toInt() < latestVersion.split('.')[2].toInt())
      updateAvailable = true;

  // if version on the server is older, return
  if (clientVersion.split('.')[2].toInt() > latestVersion.split('.')[2].toInt())
    return;

  // compare release date (remember to update this every build)
  if (getUpdateDate() > QDateTime::fromString("29-08-2014","dd-MM-yyyy"))
      updateAvailable = true;

  // emit signal
  if (updateAvailable == true)
    emit updateFound(latestVersion,releaseDate);
  else
    emit versionUpToDate();
}
