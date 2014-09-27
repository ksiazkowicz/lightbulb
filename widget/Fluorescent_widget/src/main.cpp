/********************************************************************

src/main.cpp

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

#include <QtGui/QApplication>
#include <QtGui/QSplashScreen>
#include <QtGui/QPixmap>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/qdeclarative.h>
#include <QUrl>
#include "qmlapplicationviewer.h"

#include "Settings.h"
#include "LightbulbHSWidget.h"
#include "SkinSelectorHandler.h"

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QSplashScreen *splash = new QSplashScreen(QPixmap(":/splash"));
    splash->show();

    // expose C++ classes to QML
    qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
    qmlRegisterType<LightbulbHSWidget>("lightbulb", 1, 0, "HSWidget" );
    qmlRegisterType<SkinSelectorHandler>("lightbulb",1,0,"SelectorHandler");

    // initialize viewer and set it parameters
    QmlApplicationViewer viewer;

    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer.setProperty("orientationMethod", 1);

    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showFullScreen();

    splash->finish(&viewer);
    splash->deleteLater();

    return app.exec();
}
