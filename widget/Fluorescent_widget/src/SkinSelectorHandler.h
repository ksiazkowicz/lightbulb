/********************************************************************

src/database/SkinSelectorHandler.h
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

#ifndef SKINSELECTORHANDLER_H
#define SKINSELECTORHANDLER_H

#include <QObject>
#include <QStringList>
#include <QSettings>

class SkinSelectorHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY( QStringList skins READ getAvailableSkins NOTIFY availableSkinsChanged )
public:
    explicit SkinSelectorHandler(QObject *parent = 0);
    
signals:
    void availableSkinsChanged();

public slots:
    QStringList getAvailableSkins() { return availableSkins; }
    void loadAvailableSkins();
    Q_INVOKABLE QString getSkinName(QString path);

private:
    QStringList availableSkins;
    QSettings* skinVerifier;
    
};

#endif // SKINSELECTORHANDLER_H
