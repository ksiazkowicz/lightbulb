/********************************************************************

src/avkon/QHSWidget.h
-- interface to HSWidgetPlugin dll

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

#ifndef QHSWIDGET_H
#define QHSWIDGET_H

#include <QObject>
#include <QString>
#include <QLibrary>

const QString DLLName("HSWidgetPlugin0xE22AC278.dll");

/**
 * Defines the events that may take place for a homescreen widget.
 */
enum QHSEvent
{
    EUnknown    = 0, ///< Unknown event: Means that event has not been defined.
    EActivate   = 1, ///< Activation event: Means that widget has been added to HS as content.
    EDeactivate = 2, ///< Deactivation event: Means that widget has been removed frm.
    ESuspend    = 3, ///< Suspension event: Means that HS reading widget data is suspended.
    EResume     = 4  ///< Resume event. Means that HS reading widget data is resumed.
};

/**
 * Defines the events that may take place for a homescreen widget item.
 */
enum QHSItemEvent
{
    EUnknownItemEvent = 0, ///< Unknown event: Means that event has note been defined.
    ESelect           = 1  ///< Selection event: Means that the widget item has been selected.
};




class QHSWidget : public QObject
{
    Q_OBJECT
protected:
    explicit QHSWidget(QString templateType, QString widgetName, QString widgetId, QObject *parent = 0): QObject(parent)
    {
    }
public:
    virtual ~QHSWidget(){}


    virtual void RegisterWidget() = 0;
    virtual void PublishWidget() = 0;
    virtual void SetItem(QString item, QString value) = 0;
    virtual void SetItem(QString item, int value) = 0;
    virtual void RemoveWidget() = 0;
    virtual QString WidgetName() = 0;

signals:
    void handleEvent(QHSWidget* sender, QHSEvent event);
    void handleItemEvent(QHSWidget* sender, QString WidgetItemName, QHSItemEvent event);


public:
    typedef QHSWidget* (*createHSWidget)(QString, QString, QString, QObject*);
    static QHSWidget* create(QString templateType, QString widgetName, QString widgetId, QObject *parent = 0)
    {
        QLibrary lib(DLLName);

        if (lib.load())
        {

            createHSWidget func = (createHSWidget) lib.resolve("5");

            if (func)
            {
                QHSWidget* widget = func(templateType,widgetName,widgetId,parent);
                if (widget)
                {
                    lib.setParent(widget); // implementation unloads its QLibrary children in destructor
                    return widget;
                }

            }
            lib.unload();
        }

        return 0;
    }
};





#endif // QHSWIDGET_H
