#ifndef MSGITEMMODEL_H
#define MSGITEMMODEL_H

#include "listmodel.h"

#define MSGTYPE_TEXT 0
#define MSGTYPE_ATTENTION 1

class MsgItemModel : public ListItem
{
    Q_OBJECT

    enum Roles {
        r_msgId =  Qt::UserRole+1,
        r_msgResource,
        r_msgText,
        r_msgDateTime,
        r_msgDlr,
        r_msgMy,
        r_msgType
      };


    QString m_id; //bare jid
    QString m_resource;
    QString m_datetime;
    QString m_text;
    bool m_dlr;
    bool m_myMsg;
    int m_type;

public:
    MsgItemModel(QObject *parent = 0): ListItem(parent) {}
    explicit MsgItemModel( const QString _msgId,
                           const QString &_msgResource,
                           const QString &_msgDateTime,
                           const QString &_msgText,
                           const bool &_msgDlr,
                           const bool &_msgMy,
                           const int &_msgType,
                           QObject *parent = 0 );

    virtual QVariant data(int role) const;
    virtual QHash<int, QByteArray> roleNames() const;
    virtual QString id() const { return m_id; }

    void setMsgId( QString &_id );
    void setResource( QString &_resource );
    void setMsgText( QString &_msgText );
    void setMsgDateTime( QString &_msgDateTime );
    void setMsgDlr( bool _msgDlr );
    void setMsgMy( bool _msgMy );
    void setMsgType( int _msgType );

    inline QString msgId() const { return m_id; }
    inline QString msgResource() const { return m_resource; }
    inline QString msgText() const { return m_text; }
    inline QString msgDateTime() const { return m_datetime; }
    inline bool msgMy() const { return m_myMsg; }
    inline bool msgDlr() const { return m_dlr; }
    inline int msgType() const { return m_type; }
    
signals:
    
public slots:
    
};

#endif // MSGITEMMODEL_H
