#ifndef ROSTERITEMMODEL_H
#define ROSTERITEMMODEL_H

#include "listmodel.h"

#define ROSTER_ITEM_CONTACT 0
#define ROSTER_ITEM_MUC 1

class RosterItemModel : public ListItem
{
    Q_OBJECT

public:
    enum Roles {
        roleName = Qt::UserRole+1,
        roleJid,
        roleResource,
        rolePresence,
        roleStatusText,
        roleUnreadMsg
      };

public:
      RosterItemModel(QObject *parent = 0): ListItem(parent) {
          contactName = "";
          contactJid = "";
          contactResource = "";
          contactPresence = "";
          contactStatusText = "";
          contactUnreadMsg = 0;
      }
      explicit RosterItemModel( const QString &_contactName,
                                       const QString &_contactJid,
                                       const QString &_contactResource,
                                       const QString &_contactPresence,
                                       const QString &_contactStatusText,
                                       const int _contactUnreadMsg,
                                       QObject *parent = 0 ) : ListItem(parent),
          contactName(_contactName),
          contactJid(_contactJid),
          contactResource(_contactResource),
          contactStatusText(_contactStatusText),
          contactPresence(_contactPresence),
          contactUnreadMsg(_contactUnreadMsg)
      {
      }

      virtual QVariant data(int role) const {
        switch(role) {
        case roleName:
          return name();
        case roleJid:
          return jid();
        case roleResource:
          return resource();
        case roleStatusText:
          return statusText();
        case rolePresence:
          return presence();
        case roleUnreadMsg:
          return unreadMsg();
        default:
          return QVariant();
        }
      }
      virtual QHash<int, QByteArray> roleNames() const {
          QHash<int, QByteArray> names;
          names[roleName] = "name";
          names[roleJid] = "jid";
          names[roleResource] = "resource";
          names[rolePresence] = "presence";
          names[roleStatusText] = "statusText";
          names[roleUnreadMsg] = "unreadMsg";
          return names;
        }


      virtual QString id() const { return contactJid; }

      void setPresence( const QString &_contactPresence ) {
          if(contactPresence != _contactPresence) {
            contactPresence = _contactPresence;
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

      void setResource( const QString &_contactResource ) {
          if(contactResource != _contactResource) {
            contactResource = _contactResource;
            emit dataChanged();
          }
      }

      void setStatusText( const QString &_contactStatusText )  {
          if(contactStatusText != _contactStatusText) {
            contactStatusText = _contactStatusText;
            emit dataChanged();
          }
      }

      void setUnreadMsg( const int _contactUnreadMsg )  {
          if(contactUnreadMsg != _contactUnreadMsg) {
            contactUnreadMsg = _contactUnreadMsg;
            emit dataChanged();
          }
      }

      inline QString presence() const { return contactPresence; }
      inline QString name() const { return contactName; }
      inline QString jid() const { return contactJid; }
      inline QString resource() const { return contactResource; }
      inline QString statusText() const { return contactStatusText; }
      inline int unreadMsg() const { return contactUnreadMsg; }

      void copy( const RosterItemModel* item ) {
          contactName = item->name();
          contactPresence = item->presence();
          contactName = item->name();
          contactJid = item->jid();
          contactResource = item->resource();
          contactStatusText = item->statusText();
          contactUnreadMsg = item->unreadMsg();
      }

    private:
      QString contactName;
      QString contactJid;
      QString contactResource;
      QString contactPresence;
      QString contactStatusText;
      int contactUnreadMsg;
};

#endif // ROSTERITEMMODEL_H

