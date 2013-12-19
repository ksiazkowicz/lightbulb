#ifndef ROSTERLISTMODEL_H
#define ROSTERLISTMODEL_H

#include "listmodel.h"
#include "rosteritemmodel.h"

class RosterListModel : public ListModel
{
    Q_OBJECT
    
public:
    explicit RosterListModel( QObject *parent = 0) :ListModel( new RosterItemModel, parent ) {}

    Q_INVOKABLE void append( RosterItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

    Q_INVOKABLE void clearList() { this->clear(); }

signals:
    void rosterChanged();
};

#endif // ROSTERLISTMODEL_H

