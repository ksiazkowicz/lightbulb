#ifndef QMLROSTERMODEL_H
#define QMLROSTERMODEL_H

#include "rosterlistmodel.h"

class QMLRosterModel : public RosterListModel
{
    Q_OBJECT

    //Q_PROPERTY( RosterListModel* roster READ getRoster WRITE setRoster NOTIFY rosterChanged )

public:
    explicit QMLRosterModel(QObject *parent = 0);
    
signals:
    
public slots:
    
};

#endif // QMLROSTERMODEL_H
