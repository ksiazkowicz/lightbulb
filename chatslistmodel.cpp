#include "chatslistmodel.h"


ChatsListModel::ChatsListModel( QObject *parent ) :ListModel( new RosterItemModel, parent )
{
}


void ChatsListModel::append( RosterItemModel *item ) {
    this->appendRow( item );
}

void ChatsListModel::remove( int index ) {
    this->removeRow( index );
}

int ChatsListModel::count() {
    return this->rowCount();
}

void ChatsListModel::clearList()
{
    this->clear();
}
