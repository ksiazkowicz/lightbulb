/********************************************************************

src/avkon/LightbulbHSWidget.cpp
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

#include "lightbulbhswidget.h"
#include <QApplication>
#include <apgtask.h>
#include <eikenv.h>

#include <QPixmap>
#include <QPainter>
#include <QDebug>
#include <QMap>
#include <QSvgRenderer>
#include <QSettings>
#include <QDir>

LightbulbHSWidget::LightbulbHSWidget(QObject *parent) :
    QObject(parent)
{
    widget = QHSWidget::create("wideimage", "Fluorescent", "0xE00AC666", this);
    connect(widget, SIGNAL(handleEvent(QHSWidget*, QHSEvent)), this, SLOT(handleEvent(QHSWidget*, QHSEvent) ));
    connect(widget, SIGNAL(handleItemEvent(QHSWidget*, QString, QHSItemEvent)), this, SLOT(handleItemEvent(QHSWidget*, QString, QHSItemEvent)));
    widgetData = new WidgetDataModel(this);
}

void LightbulbHSWidget::publishWidget() {
    try {
        widget->PublishWidget();
    } catch (...) {}
}


void LightbulbHSWidget::handleItemEvent( QHSWidget* /*aSender*/, QString aTemplateItemName,
    QHSItemEvent aEvent)
{
    switch (aEvent) {
        case ESelect:
             this->bringToFront();
             break;
        default: publishWidget(); break;
    }
}

bool LightbulbHSWidget::changeRow(int rowNumber, QString name, int presence, QString accountIcon, int unreadCount, bool renderIfUpdated) {
  bool isRenderingNeeded;

  if (rowNumber > maxRowsCount-1) return false;

  if (widgetData->rowCount() < rowNumber+1) {
      WidgetItemModel* item = new WidgetItemModel();
      item->setContactName(name);
      item->setPresence(presence);
      item->setAccountIcon(accountIcon);
      item->setUnreadMsg(unreadCount);
      widgetData->append(item);
  } else {
      WidgetItemModel* item = (WidgetItemModel*)widgetData->getElementByID(rowNumber);
      if (item == 0) return false;

      if (item->name() != name) {
          item->setContactName(name);
          isRenderingNeeded = true;
      }
      if (item->presence() != presence) {
          item->setPresence(presence);
          isRenderingNeeded = true;
      }
      if (item->accountIcon() != accountIcon) {
          item->setAccountIcon(accountIcon);
          isRenderingNeeded = true;
      }
      if (item->unreadMsg() != unreadCount) {
          item->setUnreadMsg(unreadCount);
          isRenderingNeeded = true;
      }
  }

  // actually update it

  if (isRenderingNeeded && renderIfUpdated) {
      renderWidget();
      return false;
  }

  return isRenderingNeeded;
}

void LightbulbHSWidget::postWidget( int unreadCount, int presence, bool showGlobalUnreadCnt, bool showChatUnreadCnt, bool showStatus, QString accountIcon )
{
    bool needToRender;

    if (mPresence != presence) {
        mPresence = presence;
        needToRender = true;
    }

    if (unreadMsgCount != unreadCount) {
        unreadMsgCount = unreadCount;
        needToRender = true;
    }

    if (showGlobalUnreadCount != showGlobalUnreadCnt) {
        showGlobalUnreadCount = showGlobalUnreadCnt;
        if (unreadCount > 0) needToRender = true;
    }

    if (showContactUnreadCount != showChatUnreadCnt) {
        showContactUnreadCount = showChatUnreadCnt;
        needToRender = true;
    }

    if (showMyPresence != showStatus) {
        showMyPresence = showStatus;
        needToRender = true;
    }

    if (accountsIcon != accountIcon) {
        accountsIcon = accountIcon;
        needToRender = true;
    }

    if (needToRender) {
        qDebug() << "LightbulbHSWidget::postWidget(): widget data changed. Rendering.";
        renderWidget();
    }

}

void LightbulbHSWidget::renderWidget() {
    QPixmap pixmap(312,82);

    QDir test;

    if (test.exists(skinPath+"\\background.png"))
      pixmap.load(skinPath+"\\background.png");
    else pixmap.fill(Qt::black);

    painter = new QPainter( &pixmap );

    painter->setRenderHint(QPainter::Antialiasing);

    if (showMyPresence) {
      switch (mPresence) {
        case 1: presence_online->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 2: presence_chatty->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 3: presence_away->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 4: presence_xa->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 5: presence_busy->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        default: presence_offline->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
      }

      if (showSmallAccountIcon) {
        if (accountsIcon == "Facebook")
          account_facebook->render(painter,QRect(accountIconPosition,QSize(accountIconSize,accountIconSize)));
        else if (accountsIcon == "Hangouts")
          account_hangouts->render(painter,QRect(accountIconPosition,QSize(accountIconSize,accountIconSize)));
        else if (accountsIcon == "XMPP")
          account_generic->render(painter,QRect(accountIconPosition,QSize(accountIconSize,accountIconSize)));
      }
    } else {
        if (accountsIcon == "Facebook")
          account_facebook->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize)));
        else if (accountsIcon == "Hangouts")
          account_hangouts->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize)));
        else if (accountsIcon == "XMPP")
          account_generic->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize)));
    }

    QFont font = QApplication::font();

    QPen pen = painter->pen();
    pen.setCosmetic(true);
    pen.setColor(QColor(unreadColor));
    painter->setPen(pen);

    if (unreadMsgCount > 0 && showGlobalUnreadCount) {
        unreadMark->render(painter,QRect(unreadMarkPosition,QSize(unreadMarkSize,unreadMarkSize)));
        if (showUnreadMarkText) {
            font.setPixelSize( unreadFontSize );
            painter->setFont( font );
            painter->drawText( QRect(unreadMarkTextPosition.x(), unreadMarkTextPosition.y(), unreadMarkTextWidth, unreadMarkTextHeight), Qt::AlignCenter, QString::number(unreadMsgCount));
        }
    }

    pen.setColor(QColor(contactColor));
    painter->setPen(pen);

    font.setPixelSize( contactFontSize );
    painter->setFont( font );

    WidgetItemModel* isEmpty = (WidgetItemModel*)widgetData->getElementByID(0);
    int emptyPresence;
    if (isEmpty == 0)
      emptyPresence = -2;
    else emptyPresence = isEmpty->presence();

    if (widgetData->rowCount() > 0 && emptyPresence != -2) {
        QRect textRow = QRect(contactsPosition.x(), contactsPosition.y(), rowWidth, rowHeight);
        for (int i=0; i<maxRowsCount; i++) {
            WidgetItemModel* item = (WidgetItemModel*)widgetData->getElementByID(i);
            if (item != 0) {
              QString name;
              if (showContactUnreadCount && item->unreadMsg() > 0)
                name = "[" + QString::number(item->unreadMsg()) + "] ";

              name += item->name();

              painter->drawText( textRow, Qt::AlignLeft, name);

              switch (item->presence()) {
                  case 0: indicator_online->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
                  case 1: indicator_chatty->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
                  case 2: indicator_away->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
                  case 3: indicator_busy->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
                  case 4: indicator_xa->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
                  case 5: indicator_offline->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
              }
              textRow.translate( 0, rowHeight+spacing );
            } else break;
        }
    } else painter->drawText( QRect(noDataAvailablePosition.x(),noDataAvailablePosition.y(),noDataAvailableWidth,noDataAvailableHeight), Qt::AlignVCenter, "Nothing to report, sir!");

    if (test.exists(skinPath+"\\fader.png")) {
      QImage fader(skinPath+"\\fader.png");
      painter->drawImage(faderPosition.x(),faderPosition.y(),fader,faderPosition.x()+faderWidth,faderPosition.y()+faderHeight);
    }
    widget->SetItem("image1",pixmap.toSymbianCFbsBitmap()->Handle());
    publishWidget();
    painter->end();
}

void LightbulbHSWidget::bringToFront()
{
    TApaTask task( CEikonEnv::Static()->WsSession() );
    task.SetWgId(CEikonEnv::Static()->RootWin().Identifier());
    task.BringToForeground();
}

void LightbulbHSWidget::loadSkin(QString path) {
    skinPath = path;

    QSettings skinsettings(path + "\\settings.txt",QSettings::NativeFormat);

    skinsettings.beginGroup( "colors" );
    contactColor = skinsettings.value( "contacts", "#FFFFFF" ).toString();
    unreadColor = skinsettings.value( "unreadmark", "#FFFFFF" ).toString();
    skinsettings.endGroup();

    skinsettings.beginGroup( "settings" );
    useNonBuiltInPresence = skinsettings.value( "useNonBuiltInPresence", false ).toBool();
    if (useNonBuiltInPresence) {
        presence_online = new QSvgRenderer(QString(skinPath+"\\presence\\online.svg"));
        presence_chatty = new QSvgRenderer(QString(skinPath+"\\presence\\chatty.svg"));
        presence_away = new QSvgRenderer(QString(skinPath+"\\presence\\away.svg"));
        presence_xa = new QSvgRenderer(QString(skinPath+"\\presence\\xa.svg"));
        presence_busy = new QSvgRenderer(QString(skinPath+"\\presence\\busy.svg"));
        presence_offline = new QSvgRenderer(QString(skinPath+"\\presence\\offline.svg"));
    } else {
        presence_online = new QSvgRenderer(QString(":/presence/online"));
        presence_chatty = new QSvgRenderer(QString(":/presence/chatty"));
        presence_away = new QSvgRenderer(QString(":/presence/away"));
        presence_xa = new QSvgRenderer(QString(":/presence/xa"));
        presence_busy = new QSvgRenderer(QString(":/presence/busy"));
        presence_offline = new QSvgRenderer(QString(":/presence/offline"));
    }

    useNonBuiltInIndicators = skinsettings.value( "useNonBuiltInIndicators", false ).toBool();
    if (useNonBuiltInIndicators) {
        indicator_online = new QSvgRenderer(QString(skinPath+"\\indicator\\online.svg"));
        indicator_chatty = new QSvgRenderer(QString(skinPath+"\\indicator\\chatty.svg"));
        indicator_away = new QSvgRenderer(QString(skinPath+"\\indicator\\away.svg"));
        indicator_xa = new QSvgRenderer(QString(skinPath+"\\indicator\\xa.svg"));
        indicator_busy = new QSvgRenderer(QString(skinPath+"\\indicator\\busy.svg"));
        indicator_offline = new QSvgRenderer(QString(skinPath+"\\indicator\\offline.svg"));
    } else {
        indicator_online = new QSvgRenderer(QString(":/presence/online"));
        indicator_chatty = new QSvgRenderer(QString(":/presence/chatty"));
        indicator_away = new QSvgRenderer(QString(":/presence/away"));
        indicator_xa = new QSvgRenderer(QString(":/presence/xa"));
        indicator_busy = new QSvgRenderer(QString(":/presence/busy"));
        indicator_offline = new QSvgRenderer(QString(":/presence/offline"));
    }

    useNonBuiltInAccountIcons = skinsettings.value( "useNonBuiltInAccountIcons", false ).toBool();
    if (useNonBuiltInAccountIcons) {
        account_facebook = new QSvgRenderer(QString(skinPath+"\\accounts\\facebook.svg"));
        account_hangouts = new QSvgRenderer(QString(skinPath+"\\accounts\\hangouts.svg"));
        account_generic = new QSvgRenderer(QString(skinPath+"\\accounts\\xmpp.svg"));
    } else {
        account_facebook = new QSvgRenderer(QString(":/accounts/Facebook"));
        account_hangouts = new QSvgRenderer(QString(":/accounts/Hangouts"));
        account_generic = new QSvgRenderer(QString(":/accounts/XMPP"));
    }

    useNonBuiltInUnreadMark = skinsettings.value( "useNonBuiltInUnreadMark", false ).toBool();
    if (useNonBuiltInUnreadMark) unreadMark = new QSvgRenderer(QString(skinPath+"\\unread.svg"));
        else unreadMark = new QSvgRenderer(QString(":/unread-count"));

    showUnreadMarkText = skinsettings.value( "showUnreadMarkText", true ).toBool();
    showSmallAccountIcon = skinsettings.value( "showSmallAccountIcon", true ).toBool();
    showContactAccountIcon = skinsettings.value( "showContactAccountIcon", true ).toBool();
    contactFontSize = skinsettings.value( "contactFontSize", 16 ).toInt();
    unreadFontSize = skinsettings.value( "unreadFontSize", 14 ).toInt();
    maxRowsCount = skinsettings.value( "maxRowsCount", 4 ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "noDataAvailable" );
    noDataAvailableWidth = skinsettings.value( "width", 303 ).toInt();
    noDataAvailableHeight = skinsettings.value( "height", 82 ).toInt();
    noDataAvailablePosition = QPoint(skinsettings.value( "x", 88 ).toInt(),skinsettings.value( "y", 0 ).toInt());
    skinsettings.endGroup();

    skinsettings.beginGroup( "presence" );
    presencePosition = QPoint(skinsettings.value( "x", 6 ).toInt(),skinsettings.value( "y", 7 ).toInt());
    presenceSize = skinsettings.value( "size", 64 ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "contacts" );
    contactsPosition = QPoint(skinsettings.value( "x", 88 ).toInt(),skinsettings.value( "y", 4 ).toInt());
    rowWidth = skinsettings.value("width", 203).toInt();
    rowHeight = skinsettings.value("height", 18).toInt();
    spacing = skinsettings.value("spacing", 0).toInt();
    indicatorSize = skinsettings.value("indicatorSize", 12).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "fader" );
    faderPosition = QPoint(skinsettings.value( "x", 268).toInt(),skinsettings.value( "y", 7 ).toInt());
    faderWidth = skinsettings.value( "width", false ).toInt();
    faderHeight = skinsettings.value( "height", false).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "unreadMark" );
    unreadMarkPosition = QPoint(skinsettings.value( "x", 6 ).toInt(),skinsettings.value( "y", 7 ).toInt());
    unreadMarkSize = skinsettings.value( "size", 64 ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "unreadMarkText" );
    unreadMarkTextPosition = QPoint(skinsettings.value("x", 48).toInt(),skinsettings.value("y", 54).toInt());
    unreadMarkTextWidth = skinsettings.value("width", 22 ).toInt();
    unreadMarkTextHeight = skinsettings.value("height", 14).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "accountIcon" );
    accountIconPosition = QPoint(skinsettings.value( "x", 6 ).toInt(),skinsettings.value( "y", 7 ).toInt());
    accountIconSize = skinsettings.value( "size", 24 ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "Details" );
    qDebug().nospace() << "LightbulbHSWidget::loadSkin(" << qPrintable(skinPath) << "): loaded " << qPrintable(skinsettings.value("name","Fallback theme").toString())
             << " (" << qPrintable(skinsettings.value("version","0.0.0").toString())
             << ") by " << qPrintable(skinsettings.value("author","/dev/null").toString());
    skinsettings.endGroup();
}
