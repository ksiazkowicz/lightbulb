/********************************************************************

src/database/Settings.cpp
-- holds settings of the app and accounts details

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

#include "Settings.h"

#include <QDir>
#include <QDebug>

QString Settings::appName = "Fluorescent";
QString Settings::confFile = QDir::currentPath() + QDir::separator() + Settings::appName + ".conf";

Settings::Settings(QObject *parent) : QSettings(Settings::confFile, QSettings::NativeFormat , parent) {
}

/*************************** (generic settings) **************************/
QVariant Settings::get(QString group, QString key) {
    beginGroup( group );
    QVariant ret = value( key, false );
    endGroup();
    return ret;
}
void     Settings::set(QVariant data, QString group, QString key) {
    beginGroup(group);
    setValue(key,data);
    endGroup();
}
