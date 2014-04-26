/**********************************************************************

src/EmoticonParser.cpp
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

#include "EmoticonParser.h"

EmoticonParser::EmoticonParser(QObject *parent) :
  QObject(parent)
{
  begin = " <img src='qrc:/smileys/";
  end = "' /> ";
}

QString EmoticonParser::parseEmoticons(QString string) {
  QString output = " " + string + " ";

  output.replace(" :) ", begin + ":)" + end);
  output.replace(" :-) ", begin + ":)" + end);

  output.replace(" :D ", begin + ":D" + end);
  output.replace(" :-D ", begin + ":-D" + end);

  output.replace(" ;) ", begin + ";)" + end);
  output.replace(" ;-) ", begin + ";)" + end);

  output.replace(" ;D ", begin + ";D" + end);
  output.replace(" ;-D ", begin + ";D" + end);

  output.replace(" :( ", begin + ":(" + end);
  output.replace(" :-( ", begin + ":(" + end);

  output.replace(" :P ", begin + ":P" + end);
  output.replace(" :-P ", begin + ":P" + end);
  output.replace(" :p ", begin + ":P" + end);
  output.replace(" :-p ", begin + ":P" + end);

  output.replace(" ;( ", begin + ";(" + end);
  output.replace(" ;-( ", begin + ";(" + end);

  output.replace(" :| ", begin + ":|" + end);
  output.replace(" &lt;3 ", begin + "<3" + end);

  output.replace(" :\\ ", begin + ":\\" + end);
  output.replace(" :-\\ ", begin + ":\\" + end);

  output.replace(" :o ", begin + ":O" + end);
  output.replace(" :O ", begin + ":O" + end);
  output.replace(" o.o ", begin + ":O" + end);

  output.replace(" :* ", begin + ":*" + end);
  output.replace(" ;* ", begin + ":*" + end);

  output.replace(" :X ", begin + ":X" + end);
  output.replace(" :x ", begin + ":x" + end);

  output.replace(" :&gt; ", begin + ":>" + end);

  output.replace(" B) ", begin + "B)" + end);
  output.replace(" B-| ", begin + "B)" + end);

  output.replace(" %) ", begin + "%)" + end);
  output.replace(" o.O ", begin + "%)" + end); //not
  output.replace(" :@ ", begin + ":@" + end);
  output.replace(" ;&gt; ", begin + ";>" + end);
  output.replace(" >) ", begin + ">)" + end);
  output.replace(" 8) ", begin + "8)" + end);
  output.replace(" (=_=) ", begin + "=_=" + end);
  output.replace(" -_- ", begin + "=_=" + end);

  //Facebook Related Emoticons
  output.replace(" :/ ", begin + ":/" + end); //not
  output.replace(" :'( ", begin + ":'(" + end);//not
  output.replace(" 3:) ", begin + "3:)" + end);
  output.replace(" O:) ", begin + "O:)" + end);
  output.replace(" :v ", begin + ":v" + end);
  output.replace(" :3 ", begin + ":3" + end);
  output.replace(" :|] ", begin + ":|]" + end);
  output.replace(" :putnam: ", begin + ":putnam:" + end);
  output.replace(" (^^^) ", begin + "(^^^)" + end);
  output.replace(" &lt;('') ", begin + "peng" + end);//not
  output.replace(" :poop: ", begin + ":poop:" + end);
  output.replace(" &gt;:( ", begin + ">:(" + end);
  output.replace(" ^_^ ", begin + "^_^" + end);

  output.replace(" (y) ", begin + "(y)" + end);
  output.replace(" :like: ", begin + "(y)" + end);

  output.replace(" &gt;:O ", begin + ">:O" + end);
  output.replace(" >.< ", begin + ">:O" + end);



  output = output.left(output.count()-1);
  output = output.right(output.count()-1); // cut those two spaces I added

  return output;
}
