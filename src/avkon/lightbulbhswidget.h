/********************************************************************

src/avkon/LightbulbHSWidget.h
-- manages the homescreen widget - registering/unregistering, rendering
-- etc.

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

#ifndef LIGHTBULBHSWIDGET_H
#define LIGHTBULBHSWIDGET_H

#include <QObject>
#include <QImage>
#include <QPixmap>
#include <QPainter>
#include "qhswidget.h"
#include <QSvgRenderer>
#include "WidgetDataModel.h"
#include "WidgetItemModel.h"

class LightbulbHSWidget : public QObject
{
    Q_OBJECT
public:
    explicit LightbulbHSWidget(QObject *parent = 0);
    Q_INVOKABLE void registerWidget() { widget->RegisterWidget(); }
    Q_INVOKABLE void publishWidget();
    Q_INVOKABLE void removeWidget() { widget->RemoveWidget(); }
    Q_INVOKABLE bool changeRow(int rowNumber, QString name, int presence,QString accountIcon, int unreadCount, bool renderIfUpdated=true);
    Q_INVOKABLE void postWidget(int unreadCount, int presence, bool showGlobalUnreadCnt, bool showStatus, QString accountIcon );
    Q_INVOKABLE void loadSkin(QString path);
    Q_INVOKABLE void renderWidget();
    void bringToFront();
signals:
    void HomescreenUpdated();
public slots:
    void handleEvent(QHSWidget*, QHSEvent aEvent ) { publishWidget(); }
    void handleItemEvent(QHSWidget*, QString aTemplateItemName,
                             QHSItemEvent aEvent);
private:
    QHSWidget*  widget;
    // load the svgs
    QSvgRenderer* indicator_online;
    QSvgRenderer* indicator_chatty;
    QSvgRenderer* indicator_away;
    QSvgRenderer* indicator_xa;
    QSvgRenderer* indicator_busy;
    QSvgRenderer* indicator_offline;
    QSvgRenderer* presence_online;
    QSvgRenderer* presence_chatty;
    QSvgRenderer* presence_away;
    QSvgRenderer* presence_xa;
    QSvgRenderer* presence_busy;
    QSvgRenderer* presence_offline;
    QSvgRenderer* account_facebook;
    QSvgRenderer* account_hangouts;
    QSvgRenderer* account_generic;
    QSvgRenderer* unreadMark;

    QPainter*     painter;

    // skin variables
    QString     skinPath;
    QString     contactColor;
    QString     unreadColor;
    bool        useNonBuiltInPresence;
    bool        useNonBuiltInIndicators;
    bool        useNonBuiltInUnreadMark;
    bool        useNonBuiltInAccountIcons;
    bool        showUnreadMarkText;
    bool        showSmallAccountIcon;
    bool        showContactAccountIcon;
    QPoint      presencePosition;
    QPoint      contactsPosition;
    QPoint      unreadMarkPosition;
    QPoint      accountIconPosition;
    QPoint      noDataAvailablePosition;
    QPoint      faderPosition;
    QPoint      unreadMarkTextPosition;
    int         noDataAvailableWidth;
    int         noDataAvailableHeight;
    int         maxRowsCount;
    int         rowHeight;
    int         rowWidth;
    int         spacing;
    int         indicatorSize;
    int         presenceSize;
    int         unreadMarkSize;
    int         accountIconSize;
    int         faderWidth;
    int         faderHeight;

    int         unreadMarkTextWidth;
    int         unreadMarkTextHeight;

    int         contactFontSize;
    int         unreadFontSize;

    // widget data
    WidgetDataModel* widgetData;
    int mPresence;
    int unreadMsgCount;
    QString accountsIcon;

    // widget settings
    bool showMyPresence;
    bool showGlobalUnreadCount;
    bool showContactUnreadCount;
};

#endif // QSAMPLEWIDGET_H
