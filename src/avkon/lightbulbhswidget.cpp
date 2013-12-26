#include "lightbulbhswidget.h"
#include <QApplication>
#include <apgtask.h>
#include <eikenv.h>

#include <QPixmap>
#include <QPainter>
#include <QDebug>
#include <QMap>

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
                    /*case ESelect:
                        {
                            this->bringToFront();
                        }*/
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
    QPainter painter( &pixmap );

    painter.setRenderHint(QPainter::Antialiasing);

    QImage ownStatus;

    switch (presence) {
        case 0: ownStatus.load(":/presence-widget/m-online"); break;
        case 1: ownStatus.load(":/presence-widget/m-chatty"); break;
        case 2: ownStatus.load(":/presence-widget/m-away"); break;
        case 3: ownStatus.load(":/presence-widget/m-xa"); break;
        case 4: ownStatus.load(":/presence-widget/m-busy"); break;
        default: ownStatus.load(":/presence-widget/m-offline"); break;
    }

    painter.drawImage(6,8,ownStatus);

    QFont font = QApplication::font();

    QPen pen = painter.pen();
    pen.setCosmetic(true);
    pen.setColor(Qt::white);
    painter.setPen(pen);

    if (unreadCount > 0) {
        QImage unreadMark(":/presence-widget/unreadMark");
        painter.drawImage(6,8,unreadMark);
        font.setPixelSize( 10 );
        painter.setFont( font );
        QRect unreadRow = QRect(57, 57, 73, 70);
        painter.drawText( unreadRow, Qt::AlignCenter, QString::number(unreadCount));
    }

    pen.setColor(Qt::black);
    painter.setPen(pen);

    font.setPixelSize( 16 );
    painter.setFont( font );

    QRect textRow = QRect(88, 4, 303, 20);
    for (int i=0; i<4; i++) {
        painter.drawText( textRow, Qt::AlignLeft, rows.at(i));
        textRow.translate( 0, 18 );
    };

    QImage status;

    for (int i=0; i<4; i++) {
        switch (statuses[rows.at(i)]) {
            case 0: status.load(":/presence-widget/online"); break;
            case 1: status.load(":/presence-widget/chatty"); break;
            case 2: status.load(":/presence-widget/away"); break;
            case 3: status.load(":/presence-widget/dnd"); break;
            case 4: status.load(":/presence-widget/xa"); break;
        }
        if (statuses[rows.at(i)] > -2) painter.drawImage(291,6+(i*18),status);
    }

    widget->SetItem("image1",pixmap.toSymbianCFbsBitmap()->Handle());
    publishWidget();
}

void LightbulbHSWidget::bringToFront()
{
    TApaTask task( CEikonEnv::Static()->WsSession() );
    task.SetWgId(CEikonEnv::Static()->RootWin().Identifier());
    task.BringToForeground();
}

void LightbulbHSWidget::postNotification(QString message) {
    Q_UNUSED(message)
    /*QMessageBox msgBox;
    msgBox.setText(message);
    msgBox.exec();*/
}
