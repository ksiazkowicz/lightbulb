/**********************************************************************

src/EmoticonParser.h
-- quick and dirty code for emoticon support

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

**********************************************************************/

#ifndef EMOTICONPARSER_H
#define EMOTICONPARSER_H

#include <QObject>

class EmoticonParser : public QObject
{
  Q_OBJECT
public:
  explicit EmoticonParser(QObject *parent = 0);
  
signals:
  
public slots:
  Q_INVOKABLE QString parseEmoticons(QString string);

private:
  QString begin;
  QString end;
  
};

#endif // EMOTICONPARSER_H
