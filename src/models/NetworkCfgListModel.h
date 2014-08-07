#ifndef NETWORKCFGLISTMODEL_H
#define NETWORKCFGLISTMODEL_H

#include "ListModel.h"
#include "NetworkCfgItemModel.h"

class NetworkCfgListModel : public ListModel
{
    Q_OBJECT

public:
    explicit NetworkCfgListModel( QObject *parent = 0) :ListModel( new NetworkCfgItemModel, parent ) {}

    Q_INVOKABLE void append( NetworkCfgItemModel *item ) { this->appendRow( item ); }
    Q_INVOKABLE void remove( int index ) { this->removeRow( index ); }
    Q_INVOKABLE int count() { return this->rowCount(); }

signals:
    void cfgChanged();
};

#endif // NETWORKCFGLISTMODEL_H
