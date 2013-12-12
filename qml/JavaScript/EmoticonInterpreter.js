/**********************************************************************

qml/JavaScript/EmoticonParser.js
-- quick and dirty code for emoticon support

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

**********************************************************************/

function parseEmoticons(string) {
	var begin = " <img src='qrc:/smileys/";
    var end = "' /> ";

    string.replace(" :) ", begin + ":)" + end);
    string.replace(" :-) ", begin + ":)" + end);

    string.replace(" :D ", begin + ":D" + end);
    string.replace(" :-D ", begin + ":-D" + end);

    string.replace(" ;) ", begin + ";)" + end);
    string.replace(" ;-) ", begin + ";)" + end);

    string.replace(" ;D ", begin + ";D" + end);
    string.replace(" ;-D ", begin + ";D" + end);

    string.replace(" :( ", begin + ":(" + end);
    string.replace(" :-( ", begin + ":(" + end);

    string.replace(" :P ", begin + ":P" + end);
    string.replace(" :-P ", begin + ":P" + end);

    string.replace(" ;( ", begin + ";(" + end);
    string.replace(" ;-( ", begin + ";(" + end);

    string.replace(" :| ", begin + ":|" + end);
    string.replace(" &lt;3 ", begin + "<3" + end);

    string.replace(" :\\ ", begin + ":\\" + end);
    string.replace(" :-\\ ", begin + ":\\" + end);

    string.replace(" :o ", begin + ":O" + end);
    string.replace(" :O ", begin + ":O" + end);
    string.replace(" o.o ", begin + ":O" + end);

    string.replace(" :* ", begin + ":*" + end);
    string.replace(" ;* ", begin + ":*" + end);

    string.replace(" :X ", begin + ":X" + end);
    string.replace(" :x ", begin + ":x" + end);

    string.replace(" :&gt; ", begin + ":>" + end);
    string.replace(" B) ", begin + "B)" + end);
    string.replace(" %) ", begin + "%)" + end);
    string.replace(" :@ ", begin + ":@" + end);
    string.replace(" ;&gt; ", begin + ";>" + end);
    string.replace(" >) ", begin + ">)" + end);
    string.replace(" 8) ", begin + "8)" + end);
    string.replace(" (=_=) ", begin + "=_=" + end);

    return string;
}