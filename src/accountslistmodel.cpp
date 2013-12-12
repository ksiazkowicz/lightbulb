#include "accountslistmodel.h"

AccountsListModel::AccountsListModel( QObject *parent ) :ListModel( new AccountsItemModel, parent )
{
}


void AccountsListModel::append( AccountsItemModel *item ) {
    this->appendRow( item );
}

void AccountsListModel::remove( int index ) {
    this->removeRow( index );
}

int AccountsListModel::count() {
    return this->rowCount();
}

void AccountsListModel::clearList()
{
    this->clear();
}
