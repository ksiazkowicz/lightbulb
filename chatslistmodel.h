#ifndef OCLISTMODEL_H
#define OCLISTMODEL_H

#include "listmodel.h"
#include "rosteritemmodel.h"

class ChatsListModel : public ListModel
{
    Q_OBJECT
public:
    explicit ChatsListModel(QObject *parent = 0);

    Q_INVOKABLE void append( RosterItemModel *item );
    Q_INVOKABLE void remove( int index );
    Q_INVOKABLE int count();

    Q_INVOKABLE void clearList();
    
};

#endif // OCLISTMODEL_H
