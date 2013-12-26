#include "lightbulbhswidget.h"
#include <QApplication>
#include <apgtask.h>
#include <eikenv.h>

#include <QPixmap>
#include <QPainter>
#include <QDebug>
#include <QMap>
#include <QSvgRenderer>

LightbulbHSWidget::LightbulbHSWidget(QObject *parent) :
    QObject(parent)
{

    widget = QHSWidget::create("wideimage", "Lightbulb", "0xE22AC278", this);
    connect(widget, SIGNAL(handleEvent(QHSWidget*, QHSEvent)), this, SLOT(handleEvent(QHSWidget*, QHSEvent) ));
    connect(widget, SIGNAL(handleItemEvent(QHSWidget*, QString, QHSItemEvent)), this, SLOT(handleItemEvent(QHSWidget*, QString, QHSItemEvent)));

    indicator_online = new QSvgRenderer(QString(":/presence/online"));
    indicator_chatty = new QSvgRenderer(QString(":/presence/chatty"));
    indicator_away = new QSvgRenderer(QString(":/presence/away"));
    indicator_xa = new QSvgRenderer(QString(":/presence/xa"));
    indicator_busy = new QSvgRenderer(QString(":/presence/busy"));
    indicator_offline = new QSvgRenderer(QString(":/presence/offline"));

    presence_online = new QSvgRenderer(QString(":/presence/online"));
    presence_chatty = new QSvgRenderer(QString(":/presence/chatty"));
    presence_away = new QSvgRenderer(QString(":/presence/away"));
    presence_xa = new QSvgRenderer(QString(":/presence/xa"));
    presence_busy = new QSvgRenderer(QString(":/presence/busy"));
    presence_offline = new QSvgRenderer(QString(":/presence/offline"));
    unreadMark = new QSvgRenderer(QString(":/unread-count"));
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
    QStringList rows;
    rows<<nRow1<<nRow2<<nRow3<<nRow4;
    QMap<QString, int> statuses;
    statuses[nRow1] = r1Presence;
    statuses[nRow2] = r2Presence;
    statuses[nRow3] = r3Presence;
    statuses[nRow4] = r4Presence;

    QPixmap pixmap( "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus\\background.png" );
    painter = new QPainter( &pixmap );

    painter->setRenderHint(QPainter::Antialiasing);

    switch (presence) {
        case 1: presence_online->render(painter,QRect(6,7,64,64)); break;
        case 2: presence_chatty->render(painter,QRect(6,7,64,64)); break;
        case 3: presence_away->render(painter,QRect(6,7,64,64)); break;
        case 4: presence_xa->render(painter,QRect(6,7,64,64)); break;
        case 5: presence_busy->render(painter,QRect(6,7,64,64)); break;
        default: presence_offline->render(painter,QRect(6,7,64,64)); break;
    }

    QFont font = QApplication::font();

    QPen pen = painter->pen();
    pen.setCosmetic(true);
    pen.setColor(Qt::white);
    painter->setPen(pen);

    if (unreadCount > 0) {
        unreadMark->render(painter,QRect(6,7,64,64));
        font.setPixelSize( 14 );
        painter->setFont( font );
        painter->drawText( QRect(48, 54, 22, 14), Qt::AlignCenter, QString::number(unreadCount));
    }

    pen.setColor(Qt::black);
    painter->setPen(pen);

    font.setPixelSize( 16 );
    painter->setFont( font );

    if (r1Presence > -2) {
        QRect textRow = QRect(88, 4, 303, 18);
        for (int i=0; i<rows.count(); i++) {
            painter->drawText( textRow, Qt::AlignLeft, rows.at(i));
            textRow.translate( 0, 18 );
        }
    } else painter->drawText( QRect(88,0,303,82), Qt::AlignVCenter, "Nothing to report, sir!");

    for (int i=0; i<rows.count(); i++) {
        switch (statuses[rows.at(i)]) {
            case 0: indicator_online->render(painter,QRect(291,6+(i*18),11,11)); break;
            case 1: indicator_chatty->render(painter,QRect(291,6+(i*18),11,11)); break;
            case 2: indicator_away->render(painter,QRect(291,6+(i*18),11,11)); break;
            case 3: indicator_busy->render(painter,QRect(291,6+(i*18),11,11)); break;
            case 4: indicator_xa->render(painter,QRect(291,6+(i*18),11,11)); break;
            case 5: indicator_offline->render(painter,QRect(291,6+(i*18),11,11)); break;
        }
    }

    QImage fader("C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus\\fader.png");
    painter->drawImage(268,7,fader,268+36,7+67);

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
