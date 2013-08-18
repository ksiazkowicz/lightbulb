#ifndef ROSTERLISTMODEL_H
#define ROSTERLISTMODEL_H

#include "listmodel.h"
#include "rosteritemmodel.h"

class RosterListModel : public ListModel
{
    Q_OBJECT
    
public:
    explicit RosterListModel( QObject *parent = 0 );

    Q_INVOKABLE void append( RosterItemModel *item );
    Q_INVOKABLE void remove( int index );
    Q_INVOKABLE int count();

    Q_INVOKABLE void clearList();

signals:
    void rosterChanged();
};

#endif // ROSTERLISTMODEL_H
