#include "rosterlistmodel.h"

RosterListModel::RosterListModel( QObject *parent ) :ListModel( new RosterItemModel, parent )
{
}


void RosterListModel::append( RosterItemModel *item ) {
    this->appendRow( item );
}

void RosterListModel::remove( int index ) {
    this->removeRow( index );
}

int RosterListModel::count() {
    return this->rowCount();
}

void RosterListModel::clearList()
{
    this->clear();
}
