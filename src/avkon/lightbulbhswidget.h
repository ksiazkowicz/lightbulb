#ifndef LIGHTBULBHSWIDGET_H
#define LIGHTBULBHSWIDGET_H

#include <QObject>
#include <QImage>
#include <QPixmap>
#include <QPainter>
#include "qhswidget.h"
#include <QSvgRenderer>

class LightbulbHSWidget : public QObject
{
    Q_OBJECT
public:
    explicit LightbulbHSWidget(QObject *parent = 0);
    Q_INVOKABLE void registerWidget();
    Q_INVOKABLE void publishWidget();
    Q_INVOKABLE void removeWidget();
    Q_INVOKABLE void postWidget( QString nRow1, int r1Presence, QString nRow2, int r2Presence, QString nRow3, int r3Presence, QString nRow4, int r4Presence, int unreadCount, int presence );
    Q_INVOKABLE void loadSkin(QString path);
    Q_INVOKABLE void renderWidget();
    void bringToFront();
signals:
    void HomescreenUpdated();
public slots:
    void handleEvent(QHSWidget*, QHSEvent aEvent );
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
    QSvgRenderer* unreadMark;

    QPainter*     painter;

    // skin variables
    QString     skinPath;
    QString     contactColor;
    QString     unreadColor;
    bool        useNonBuiltInPresence;
    bool        useNonBuiltInIndicators;
    bool        useNonBuiltInUnreadMark;
    bool        showUnreadMarkText;
    QPoint      presencePosition;
    QPoint      contactsPosition;
    QPoint      unreadMarkPosition;
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
    int         faderWidth;
    int         faderHeight;

    int         unreadMarkTextWidth;
    int         unreadMarkTextHeight;

    int         contactFontSize;
    int         unreadFontSize;
};

#endif // QSAMPLEWIDGET_H
