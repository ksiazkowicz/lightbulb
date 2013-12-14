/********************************************************************

src/xmpp/MessageWrapper.h
-- looks for strings beginning with http, https and then makes them
hyperlinks with "<a href..." stuff. Will be rewritten with JS one day.

Copyright (c) 2013 Anatoliy Kozlov,
                   Maciej Janiszewski

This file is part of Lightbulb and was derived from MeegIM.

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

#ifndef MESSAGEWRAPPER_H
#define MESSAGEWRAPPER_H

#include <QObject>

class MessageWrapper : public QObject
{
    Q_OBJECT

public:
    explicit MessageWrapper(QObject *parent = 0);

    QString parseMsgOnLink( const QString &inString ) const;
};

#endif // MESSAGEWRAPPER_H
