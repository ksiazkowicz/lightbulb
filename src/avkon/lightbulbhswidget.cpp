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

QString row1; int row1presence;
QString row2; int row2presence;
QString row3; int row3presence;
QString row4; int row4presence;
int mPresence;
int unreadMsgCount;

LightbulbHSWidget::LightbulbHSWidget(QObject *parent) :
    QObject(parent)
{

    widget = QHSWidget::create("wideimage", "Lightbulb", "0xE22AC278", this);
    connect(widget, SIGNAL(handleEvent(QHSWidget*, QHSEvent)), this, SLOT(handleEvent(QHSWidget*, QHSEvent) ));
    connect(widget, SIGNAL(handleItemEvent(QHSWidget*, QString, QHSItemEvent)), this, SLOT(handleItemEvent(QHSWidget*, QString, QHSItemEvent)));
}

void LightbulbHSWidget::registerWidget()
{
    widget->RegisterWidget();

}

void LightbulbHSWidget::publishWidget()
{
    try {
        widget->PublishWidget();
    }
    catch (...) {
    }
}

void LightbulbHSWidget::removeWidget()
{
    widget->RemoveWidget();
}

void LightbulbHSWidget::handleEvent( QHSWidget* /*aSender*/, QHSEvent aEvent )
{
    switch(aEvent)
                    {
                    case EActivate:
                    case EResume:
                            {
                            publishWidget();
                            }
                            break;
                    default:
                            publishWidget();
                            break;
                    }

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

void LightbulbHSWidget::postWidget( QString nRow1, int r1Presence, QString nRow2, int r2Presence, QString nRow3, int r3Presence, QString nRow4, int r4Presence, int unreadCount, int presence )
{
    bool needToRender;
    if (row1 != nRow1) {
        row1 = nRow1;
        needToRender = true;
    }

    if (row1presence != r1Presence) {
        row1presence = r1Presence;
        needToRender = true;
    }

    if (row2 != nRow2) {
        row2 = nRow2;
        needToRender = true;
    }

    if (row2presence != r2Presence) {
        row2presence = r2Presence;
        needToRender = true;
    }

    if (row3 != nRow3) {
        row3 = nRow3;
        needToRender = true;
    }
    if (row3presence != r3Presence) {
        row3presence = r3Presence;
        needToRender = true;
    }

    if (row4 != nRow4) {
        row4 = nRow4;
        needToRender = true;
    }

    if (row4presence != r4Presence) {
        row4presence = r4Presence;
        needToRender = true;
    }

    if (mPresence != presence) {
        mPresence = presence;
        needToRender = true;
    }

    if (unreadMsgCount != unreadCount) {
        unreadMsgCount = unreadCount;
        needToRender = true;
    }

    if (needToRender) {
        qDebug() << "LightbulbHSWidget::postWidget(): widget data changed. Rendering.";
        renderWidget();
    }

}

void LightbulbHSWidget::renderWidget() {
    QStringList rows;
    rows<<row1<<row2<<row3<<row4;
    QMap<QString, int> statuses;
    statuses[row1] = row1presence;
    statuses[row2] = row2presence;
    statuses[row3] = row3presence;
    statuses[row4] = row4presence;

    QPixmap pixmap( skinPath+"\\background.png" );
    painter = new QPainter( &pixmap );

    painter->setRenderHint(QPainter::Antialiasing);

    switch (mPresence) {
        case 1: presence_online->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 2: presence_chatty->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 3: presence_away->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 4: presence_xa->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        case 5: presence_busy->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
        default: presence_offline->render(painter,QRect(presencePosition,QSize(presenceSize,presenceSize))); break;
    }

    QFont font = QApplication::font();

    QPen pen = painter->pen();
    pen.setCosmetic(true);
    pen.setColor(QColor(unreadColor));
    painter->setPen(pen);

    if (unreadMsgCount > 0) {
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

    int rowCount = rows.count();
    if (rows.count() > maxRowsCount) rowCount = maxRowsCount;

    if (row1presence > -2) {
        QRect textRow = QRect(contactsPosition.x(), contactsPosition.y(), rowWidth, rowHeight);
        for (int i=0; i<maxRowsCount; i++) {
            painter->drawText( textRow, Qt::AlignLeft, rows.at(i));
            textRow.translate( 0, rowHeight+spacing );
        }
    } else painter->drawText( QRect(noDataAvailablePosition.x(),noDataAvailablePosition.y(),noDataAvailableWidth,noDataAvailableHeight), Qt::AlignVCenter, "Nothing to report, sir!");

    for (int i=0; i<maxRowsCount; i++) {
        switch (statuses[rows.at(i)]) {
            case 0: indicator_online->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
            case 1: indicator_chatty->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
            case 2: indicator_away->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
            case 3: indicator_busy->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
            case 4: indicator_xa->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
            case 5: indicator_offline->render(painter,QRect(contactsPosition.x()+rowWidth,contactsPosition.y()+((rowHeight-indicatorSize)/2)+(i*(rowHeight+spacing)),indicatorSize,indicatorSize)); break;
        }
    }

    QImage fader(skinPath+"\\fader.png");
    painter->drawImage(faderPosition.x(),faderPosition.y(),fader,faderPosition.x()+faderWidth,faderPosition.y()+faderHeight);

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
    contactColor = skinsettings.value( "contactColor", false ).toString();
    unreadColor = skinsettings.value( "unreadColor", false ).toString();
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

    useNonBuiltInUnreadMark = skinsettings.value( "useNonBuiltInUnreadMark", false ).toBool();
    if (useNonBuiltInUnreadMark) unreadMark = new QSvgRenderer(QString(skinPath+"\\unread.svg"));
        else unreadMark = new QSvgRenderer(QString(":/unread-count"));

    showUnreadMarkText = skinsettings.value( "showUnreadMarkText", false ).toBool();
    contactFontSize = skinsettings.value( "contactFontSize", false ).toInt();
    unreadFontSize = skinsettings.value( "unreadFontSize", false ).toInt();
    maxRowsCount = skinsettings.value( "maxRowsCount", false ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "noDataAvailable" );
    noDataAvailableWidth = skinsettings.value( "width", false ).toInt();
    noDataAvailableHeight = skinsettings.value( "height", false ).toInt();
    noDataAvailablePosition = QPoint(skinsettings.value( "x", false ).toInt(),skinsettings.value( "y", false ).toInt());
    skinsettings.endGroup();

    skinsettings.beginGroup( "presence" );
    presencePosition = QPoint(skinsettings.value( "x", false ).toInt(),skinsettings.value( "y", false ).toInt());
    presenceSize = skinsettings.value( "size", false ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "contacts" );
    contactsPosition = QPoint(skinsettings.value( "x", false ).toInt(),skinsettings.value( "y", false ).toInt());
    rowWidth = skinsettings.value( "width", false ).toInt();
    rowHeight = skinsettings.value( "height", false).toInt();
    spacing = skinsettings.value( "spacing", false).toInt();
    indicatorSize = skinsettings.value( "indicatorSize", false).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "fader" );
    faderPosition = QPoint(skinsettings.value( "x", false ).toInt(),skinsettings.value( "y", false ).toInt());
    faderWidth = skinsettings.value( "width", false ).toInt();
    faderHeight = skinsettings.value( "height", false).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "unreadMark" );
    unreadMarkPosition = QPoint(skinsettings.value( "x", false ).toInt(),skinsettings.value( "y", false ).toInt());
    unreadMarkSize = skinsettings.value( "size", false ).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "unreadMarkText" );
    unreadMarkTextPosition = QPoint(skinsettings.value( "x", false ).toInt(),skinsettings.value( "y", false ).toInt());
    unreadMarkTextWidth = skinsettings.value( "width", false ).toInt();
    unreadMarkTextHeight = skinsettings.value( "height", false).toInt();
    skinsettings.endGroup();

    skinsettings.beginGroup( "Details" );
    qDebug() << "LightbulbHSWidget::loadSkin(" + skinPath + "): loaded " + skinsettings.value("name",false).toString() + " (" + skinsettings.value("version",false).toString() + ") by " + skinsettings.value("author",false).toString();
    skinsettings.endGroup();
}
