/**
 * Copyright (C) 2012 by Kunal Parmar <pkunal.parmar@gmail.com>
 *
 **/

#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QObject>
#include <QAbstractItemModel>
#include <QStringList>

class FileModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(bool canGoUp READ canGoUp NOTIFY directoryChanged )
    Q_PROPERTY(QString directory READ directory NOTIFY directoryChanged )

public:
    enum { IconRole = Qt::UserRole + 1 };

    FileModel ( QObject* parent=0);
    ~FileModel ();

    QVariant data (const QModelIndex &index, int role) const;
    Qt::ItemFlags flags (const QModelIndex &index) const;
    QVariant headerData (int section, Qt::Orientation orientation,
            int role = Qt::DisplayRole) const;
    QModelIndex index (int row, int column,
            const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent (const QModelIndex &index) const;
    bool hasChildren (const QModelIndex& parent = QModelIndex ()) const;
    int rowCount (const QModelIndex &parent = QModelIndex()) const;
    int columnCount (const QModelIndex &parent = QModelIndex()) const;

    Q_INVOKABLE void openDirectory( int index);
    Q_INVOKABLE void updateFiles ();

    Q_INVOKABLE QString currentDirectory () const { return mCurrentDirectory; }
    Q_INVOKABLE void setCurrentDirectory (const QString& dir);

    Q_INVOKABLE QString directory() const;

    Q_INVOKABLE bool isDir( int path) const;

    Q_INVOKABLE void goUp ();
    bool canGoUp ();

Q_SIGNALS:

    void showEmptyDir(bool show);

    void directoryChanged ();

private Q_SLOTS:

    void openCurrentDirectory();
private:
    bool mFilesRetrieved;
    QStringList mFiles;
    QString mCurrentDirectory;

};

#endif
