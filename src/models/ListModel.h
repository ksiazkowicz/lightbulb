/********************************************************************

src/ListModel.h
-- reimplements QAbstractListModel to make use of it in QML.
http://cdumez.blogspot.com/2010/11/how-to-use-c-list-model-in-qml.html

Copyright (c) 2010 Christophe Dumez

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
  explicit ListModel(ListItem* prototype, QObject* parent = 0);
  ~ListModel();
  int rowCount(const QModelIndex &parent = QModelIndex()) const;
  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
  void appendRow(ListItem* item);
  void appendRows(const QList<ListItem*> &items);
  void insertRow(int row, ListItem* item);
  bool removeRow(int row, const QModelIndex &parent = QModelIndex());
  bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());
  ListItem* takeRow(int row);
  bool takeRows( int row, int count, const QModelIndex &parent = QModelIndex() );
  ListItem* value( int row );
  ListItem* find(const QString &id) const;
  ListItem* find(const QString &id, int &row) const;
  QModelIndex indexFromItem( const ListItem* item) const;
  void clear();

private slots:
  void handleItemChange();

private:
  ListItem* m_prototype;
  QList<ListItem*> m_list;
};


#endif // LISTMODEL_H
