/********************************************************************

src/ListModel.h
-- reimplements QAbstractListModel to make use of it in QML.
http://cdumez.blogspot.com/2010/11/how-to-use-c-list-model-in-qml.html

Copyright (c) 2010 Christophe Dumez, Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

#ifndef LISTMODEL_H
#define LISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QVariant>

class ListItem: public QObject {
  Q_OBJECT

public:
  ListItem(QObject* parent = 0) : QObject(parent) {}
  virtual ~ListItem() {}
  virtual QString id() const = 0;
  virtual QVariant data(int role) const = 0;
  virtual QHash<int, QByteArray> roleNames() const = 0;

signals:
  void dataChanged();
};


/***************************************************************************************************/

class ListModel : public QAbstractListModel
{
  Q_OBJECT

public:
  explicit ListModel(ListItem* prototype, QObject *parent) : QAbstractListModel(parent), m_prototype(prototype)
    {
      setRoleNames(m_prototype->roleNames());
    }
  ~ListModel() {
        delete m_prototype;
        clear();
      }
  int rowCount(const QModelIndex &parent = QModelIndex()) const {
      Q_UNUSED(parent);
      return m_list.size();
    }
  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const {
      if(index.row() < 0 || index.row() >= m_list.size())
        return QVariant();
      return m_list.at(index.row())->data(role);
    }
  void appendRow(ListItem* item) {
      appendRows(QList<ListItem*>() << item);
    }

  void appendRows(const QList<ListItem*> &items) {
      beginInsertRows(QModelIndex(), rowCount(), rowCount()+items.size()-1);
      foreach(ListItem *item, items) {
        connect(item, SIGNAL(dataChanged()), SLOT(handleItemChange()));
        m_list.append(item);
      }
      endInsertRows();
    }
  void insertRow(int row, ListItem* item) {
      beginInsertRows(QModelIndex(), row, row);
      connect(item, SIGNAL(dataChanged()), SLOT(handleItemChange()));
      m_list.insert(row, item);
      endInsertRows();
    }
  bool removeRow(int row, const QModelIndex &parent = QModelIndex()) {
      Q_UNUSED(parent);
        //qDebug() << "removeRow: m_list.size()="<<m_list.size();
      if(row < 0 || row >= m_list.size()) return false;
      beginRemoveRows(QModelIndex(), row, row);
      delete m_list.takeAt(row);
      endRemoveRows();
      return true;
    }
  bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) {
      Q_UNUSED(parent);
        //qDebug() << "removeRows: m_list.size()="<<m_list.size();
      if(row < 0 || (row+count) > m_list.size()) return false; /* !!! */
      beginRemoveRows(QModelIndex(), row, row+count-1);
      for(int i=0; i<count; ++i) {
        delete m_list.takeAt(row);
      }
      endRemoveRows();
      return true;
    }
  ListItem* takeRow(int row) {
      beginRemoveRows(QModelIndex(), row, row);
      ListItem* item = m_list.takeAt(row);
      endRemoveRows();
      return item;
    }
  bool takeRows( int row, int count, const QModelIndex &parent = QModelIndex() ) {
      Q_UNUSED(parent);
      if(row < 0 || (row+count) > m_list.size()) return false; /* !!! */
      beginRemoveRows(QModelIndex(), row, row+count-1);
      for(int i=0; i<count; ++i) {
        m_list.takeAt(row);
      }
      endRemoveRows();
      return true;
    }
  ListItem* value( int row ) {
      ListItem* item = m_list.value(row);
      return item;
  }
  ListItem* find(const QString &id) const {
      foreach(ListItem* item, m_list) {
        if(item->id() == id) return item;
      }
      return 0;
    }

  ListItem* find(const QString &id, int &row) const {
      row = 0;
      foreach(ListItem* item, m_list) {
          if(item->id() == id) { /*qDebug()<<item->id()<<" - "<<row;*/ return item;}
          row++;
      }
      row = -1;
      return 0;
  }
  QModelIndex indexFromItem( const ListItem* item) const {
      Q_ASSERT(item);
      for(int row=0; row<m_list.size(); ++row) {
        if(m_list.at(row) == item) return index(row);
      }
      return QModelIndex();
    }
  void clear() {
      qDeleteAll(m_list);
      m_list.clear();
    }

  ListItem* getElementByID( int id ) {
      int x = 0;
      foreach(ListItem* item, m_list) {
          if (x==id) return item;
          x++;
      }
  }

private slots:
  void handleItemChange() {
      ListItem* item = static_cast<ListItem*>(sender());
      QModelIndex index = indexFromItem(item);
      if(index.isValid())
        emit dataChanged(index, index);
    }

private:
  ListItem* m_prototype;
  QList<ListItem*> m_list;
};


#endif // LISTMODEL_H

