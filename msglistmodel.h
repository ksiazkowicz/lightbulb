#ifndef MSGLISTMODEL_H
#define MSGLISTMODEL_H

#include "listmodel.h"
#include "msgitemmodel.h"

class MsgListModel : public ListModel
{
    Q_OBJECT
public:
    explicit MsgListModel(QObject *parent = 0);

    Q_INVOKABLE void append( MsgItemModel *item );
    Q_INVOKABLE void remove( int index );
    Q_INVOKABLE int count();

    Q_INVOKABLE void clearList();
    
signals:
    
public slots:
    
};

#endif // MSGLISTMODEL_H
