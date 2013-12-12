#ifndef ACCOUNTSLISTMODEL_H
#define ACCOUNTSLISTMODEL_H

#include "listmodel.h"
#include "accountsitemmodel.h"

class AccountsListModel : public ListModel
{
    Q_OBJECT
public:
    explicit AccountsListModel( QObject *parent = 0 );

    Q_INVOKABLE void append( AccountsItemModel *item );
    Q_INVOKABLE void remove( int index );
    Q_INVOKABLE int count();
    Q_INVOKABLE void clearList();
};

#endif // ACCOUNTSLISTMODEL_H
