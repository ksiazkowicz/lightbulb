#ifndef CHATSITEMMODEL_H
#define CHATSITEMMODEL_H
#include "listmodel.h"

class ChatsItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleAccount = Qt::UserRole+1,
        roleName,
        roleJid
      };

public:
      ChatsItemModel(QObject *parent = 0): ListItem(parent) {
          contactName = "";
          contactJid = "";
          contactAccountID = 0;
      }
      explicit ChatsItemModel( const QString &_contactName,
                                       const QString &_contactJid,
                                       const int _accountID,
                                       QObject *parent = 0 ) : ListItem(parent),
          contactAccountID(_accountID),
          contactName(_contactName),
          contactJid(_contactJid)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleAccount:
            return accountID();
        case roleName:
          return name();
        case roleJid:
          return jid();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleAccount] = "account";
          names[roleName] = "name";
          names[roleJid] = "jid";
          return names;
      }

      virtual QString id() const { return contactJid; }

      void setAccountID(const int &_accountID) {
        if (contactAccountID != _accountID) {
            contactAccountID = _accountID;
            emit dataChanged();
          }
      }

      void setContactName( const QString &_contactName ) {
          if(contactName != _contactName) {
            contactName = _contactName;
            emit dataChanged();
          }
      }

      void setJid( const QString &_contactJid ) {
          if(contactJid != _contactJid) {
            contactJid = _contactJid;
            emit dataChanged();
          }
      }

      inline int accountID() const { return contactAccountID; }
      inline QString name() const { return contactName; }
      inline QString jid() const { return contactJid; }

      void copy( const ChatsItemModel* item ) {
          contactName = item->name();
          contactJid = item->jid();
          contactAccountID = item->accountID();
      }

    private:
      int contactAccountID;
      QString contactName;
      QString contactJid;
};

#endif // CHATSITEMMODEL_H
