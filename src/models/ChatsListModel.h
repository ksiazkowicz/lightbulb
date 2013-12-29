#ifndef CHATSLISTMODEL_H
#define CHATSLISTMODEL_H

#include "ListModel.h"
#include "ChatsItemModel.h"

class ChatsListModel : public ListModel
{
    Q_OBJECT

public:
    explicit ChatsListModel( QObject *parent = 0) :ListModel( new ChatsItemModel, parent ) {}

    Q_INVOKABLE void append( ChatsItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

    Q_INVOKABLE void clearList() { this->clear(); }

signals:
    void chatsChanged();
};

#endif // CHATSLISTMODEL_H
