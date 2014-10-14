/********************************************************************

src/xmpp/MessageWrapper.cpp
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

#include "messagewrapper.h"
#include <QDebug>

MessageWrapper::MessageWrapper(QObject *parent) : QObject(parent) {
}

QString MessageWrapper::parseMsgOnLink( const QString &inString ) const
{
    QString outString = "";
    int pos = 0;
    int pos_space = 0;

    bool strangeTagOpen = false;
    bool strangeTagClose = false;

    qDebug() << inString;

    while( (pos = inString.indexOf("http", pos)) >= 0 )
    {
        outString += inString.mid(pos_space, pos - pos_space);

        QString prevSmb = inString.mid( pos-1, 1 );
        if( prevSmb == "<" ) { strangeTagOpen = true; }

        pos_space = inString.indexOf( " ", pos );
        if( pos_space < 0 ) {
            pos_space = inString.indexOf( "\"", pos );
            if( pos_space < 0 ) {
                pos_space = inString.indexOf( ">", pos );
                strangeTagClose = true;
            }
        }
        QString link = inString.mid( pos, pos_space-pos );
        QString nLink = "<a href=\"" + link + "\">" + link + "</a>";
        if( strangeTagOpen && strangeTagClose ) {
            nLink = "a href=\"" + link + "\">" + link + "</a";
        }

        outString += nLink;

        pos = pos_space;

        strangeTagOpen = false;
        strangeTagClose = false;
    }
    if( pos_space >= 0 ) {
        outString += inString.mid(pos_space);
    }

    return outString;
}
