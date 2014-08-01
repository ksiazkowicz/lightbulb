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
#include <QDebug>

EmoticonParser::EmoticonParser(QObject *parent) :
  QObject(parent)
{
  begin = " <img src='qrc:/smileys/";
  end = "' /> ";
}

QString EmoticonParser::parseEmoticons(QString string) {
  qDebug() << string;

  QString output = " " + string + " ";

  output.replace(" :) ", begin + "happy" + end);
  output.replace(" :-) ", begin + "happy" + end);

  output.replace(" :D ", begin + "laugh" + end);
  output.replace(" :-D ", begin + "laugh2" + end);

  output.replace(" ;) ", begin + "wink" + end);
  output.replace(" ;-) ", begin + "wink" + end);

  output.replace(" ;D ", begin + "wink2" + end);
  output.replace(" ;-D ", begin + "wink2" + end);

  output.replace(" :( ", begin + "sad" + end);
  output.replace(" :-( ", begin + "sad" + end);

  output.replace(" :P ", begin + "tounge" + end);
  output.replace(" :-P ", begin + "tounge" + end);
  output.replace(" :p ", begin + "tounge" + end);
  output.replace(" :-p ", begin + "tounge" + end);

  output.replace(" ;( ", begin + "cry" + end);
  output.replace(" ;-( ", begin + "cry" + end);

  output.replace(" :| ", begin + "indifference" + end);
  output.replace(" &lt;3 ", begin + "heart" + end);

  output.replace(" :\\ ", begin + "skeptical" + end);
  output.replace(" :-\\ ", begin + "skeptical" + end);

  output.replace(" :o ", begin + "suprised" + end);
  output.replace(" :O ", begin + "suprised" + end);
  output.replace(" o.o ", begin + "suprised" + end);

  output.replace(" :* ", begin + "kiss" + end);
  output.replace(" ;* ", begin + "kiss" + end);

  output.replace(" :X ", begin + "quiet" + end);
  output.replace(" :x ", begin + "quiet" + end);

  output.replace(" :&gt; ", begin + "smile" + end);

  output.replace(" B) ", begin + "cool" + end);
  output.replace(" B-| ", begin + "cool" + end);
   output.replace(" B| ", begin + "cool" + end);

  output.replace(" %) ", begin + "confused" + end);
  output.replace(" o.O ", begin + "confused" + end);
  output.replace(" :@ ", begin + "angry" + end);
  output.replace(" ;&gt; ", begin + "wink3" + end);
  output.replace(" &gt;) ", begin + "evil" + end);
  output.replace(" 8) ", begin + "nerdsmile" + end);
  output.replace(" (=_=) ", begin + "tired" + end);
  output.replace(" -_- ", begin + "tired" + end);

  //Facebook Related Emoticons
  output.replace(" :/ ", begin + "fb/unsure" + end);
  output.replace(" :'( ", begin + "fb/cry" + end);
  output.replace(" 3:) ", begin + "fb/devil" + end);
  output.replace(" O:) ", begin + "fb/angel" + end);
  output.replace(" :v ", begin + "fb/pacman" + end);
  output.replace(" :3 ", begin + "fb/curlylips" + end);
  output.replace(" :|] ", begin + "fb/robot" + end);
  output.replace(" :putnam: ", begin + "fb/putnam" + end);
  output.replace(" (^^^) ", begin + "fb/shark" + end);
  output.replace(" &lt;(\") ", begin + "fb/peng" + end);
  output.replace(" :poop: ", begin + "fb/poop" + end);
  output.replace(" &gt;:( ", begin + "fb/grumpy" + end);
  output.replace(" ^_^ ", begin + "fb/kiki" + end);
  output.replace(" ^^ ", begin + "fb/kiki" + end);

  output.replace(" (y) ", begin + "fb/thumb" + end);
  output.replace(" :like: ", begin + "fb/thumb" + end);

  output.replace(" &gt;:O ", begin + "fb/upset" + end);
  output.replace(" &gt;.&lt; ", begin + "fb/upset" + end);



  output = output.left(output.count()-1);
  output = output.right(output.count()-1); // cut those two spaces I added

  return output;
}
