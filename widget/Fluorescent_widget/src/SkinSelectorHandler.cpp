/********************************************************************

src/database/SkinSelectorHandler.cpp
-- loads skins and exposes them to QML

Copyright (c) 2013 Maciej Janiszewski

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

#include "SkinSelectorHandler.h"
#include <QSettings>
#include <QDir>
#include <QDebug>
#include <QStringList>

SkinSelectorHandler::SkinSelectorHandler(QObject *parent) :
    QObject(parent)
{
    loadAvailableSkins();
}

void SkinSelectorHandler::loadAvailableSkins() {
    QStringList skins;
    QDir dir("C:\\data\\.config\\Fluorescent\\widgets");

    if (dir.exists("C:\\data\\.config\\Fluorescent\\widgets")) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden  | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir() && dir.exists(info.absoluteFilePath() + "/settings.txt")) {
                QString skinName = getSkinName(info.baseName());
                if (skinName != "-!-404-!-") {
                    qDebug() << "SkinSelectorHandler::loadAvailableSkins(): found skin " << skinName;
                    skins.append(info.baseName());
                }
            }
        }
    }
    qDebug() << "SkinSelectorHandler::loadAvailableSkins(): available - "<< skins;
    availableSkins = skins;
}

QString SkinSelectorHandler::getSkinName(QString path) {
    skinVerifier = new QSettings("C:\\data\\.config\\Fluorescent\\widgets\\" + path + "\\settings.txt",QSettings::NativeFormat);
    skinVerifier->beginGroup("Details");
    QString skinName = skinVerifier->value("name","-!-404-!-").toString();
    skinVerifier->endGroup();
    return skinName;
}
