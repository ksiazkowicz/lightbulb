#include "msglistmodel.h"

MsgListModel::MsgListModel(QObject *parent) : ListModel( new MsgItemModel, parent )
{
}

void MsgListModel::append( MsgItemModel *item ) {
    this->appendRow( item );
}

void MsgListModel::remove( int index ) {
    this->removeRow( index );
}

int MsgListModel::count() {
    return this->rowCount();
}

void MsgListModel::clearList()
{
    this->clear();
}
