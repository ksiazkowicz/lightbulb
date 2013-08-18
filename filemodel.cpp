/**
 * Copyright (C) 2012 by Kunal Parmar <pkunal.parmar@gmail.com>
 *
 **/

#include "filemodel.h"
#include <QDebug>
#include <QDir>


static QStringList getDrives() {
    QFileInfoList fileList  = QDir::drives();
    QStringList drives;
    foreach( QFileInfo file, fileList ){
        if( /*file.isWritable() &&*/
            /*file.filePath() != "Z:/" &&*/  file.filePath() != "D:/"  ){
            drives << file.filePath();
        }
    }
    return drives;
}

FileModel::FileModel ( QObject *parent)
    : QAbstractItemModel (parent)
    , mCurrentDirectory ("")
    , mFilesRetrieved (false)
{
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "caption";
    roles[IconRole] = "icon";
    setRoleNames(roles);

    openCurrentDirectory();
}

FileModel::~FileModel ()
{}

QVariant FileModel::data (const QModelIndex &index, int role) const
{
//    FileModel* model = const_cast<FileModel*>(this);
//    model->updateFiles ();

    if ( index.column () > 1  || !index.isValid () || index.row () >= mFiles.length () )
        return QVariant ();

    switch(role) {
    case Qt::DisplayRole:
        return mFiles[index.row ()];
    case IconRole:
        return isDir(index.row());
    }

    return QVariant ();
}

Qt::ItemFlags FileModel::flags (const QModelIndex &index) const
{
    if (index.isValid ())
        return Qt::ItemIsSelectable | Qt::ItemIsUserCheckable | Qt::ItemIsEnabled;
    return 0;
}

QVariant FileModel::headerData (int, Qt::Orientation, int) const
{
    return QVariant ();
}

QModelIndex FileModel::index (int row, int col, const QModelIndex& parent) const
{
    if (col > 1 || parent.isValid ())
        return QModelIndex();

//    FileModel* model = const_cast<FileModel*>(this);
//    model->updateFiles ();

    if (row >= mFiles.length ())
        return QModelIndex();

    return createIndex (row, col, 0);
}

QModelIndex FileModel::parent (const QModelIndex&) const
{
    return QModelIndex();
}

bool FileModel::hasChildren (const QModelIndex& parent) const
{
    return rowCount (parent);
}

int FileModel::rowCount (const QModelIndex &parent) const
{
    if (parent.column() > 0 || parent.isValid ())
        return 0;

//    FileModel* model = const_cast<FileModel*>(this);
//    model->updateFiles ();
    return mFiles.length ();
}

int FileModel::columnCount (const QModelIndex&) const
{
    return 2;
}

void FileModel::updateFiles ()
{
    if (!mFilesRetrieved) {
        qDebug() << "CurDir:" << currentDirectory();
        if( currentDirectory().isEmpty() ) {
            mFiles = getDrives();
        } else {
            mFiles = QDir ( currentDirectory ()).entryList ( QDir::AllEntries | QDir::Writable | QDir::Readable | QDir::NoDot | QDir::NoDotDot,QDir::DirsFirst| QDir::Name);
        }
        qDebug() << "retrieving " << mFiles.length () << " files" << endl;
        mFilesRetrieved = true;
        if (mFiles.length ()) {
            beginInsertRows (QModelIndex(), 0, mFiles.length ()-1);
            endInsertRows();
        }

        emit showEmptyDir(mFiles.length()<=0);
    }
}

QString FileModel::directory() const {
    QString name = QDir( mCurrentDirectory).dirName();
    if( name.isEmpty()) {
        return mCurrentDirectory;
    }
    return name;
}


bool FileModel::isDir( int index ) const
{
    QString path;
    if( currentDirectory().isEmpty()) {
        path = mFiles[index];
    } else {
        path = currentDirectory()+"/"+mFiles[index];
    }
    QFileInfo fileInfo( path);
    return !fileInfo.isFile();
}

void FileModel::setCurrentDirectory (const QString& dir) {
    mCurrentDirectory = dir;
    openCurrentDirectory();
}

void FileModel::openDirectory( int index)
{
    if (index >= 0 && index < mFiles.length() ) {
        if( currentDirectory().isEmpty()) {
            mCurrentDirectory = mFiles[index];
        } else {
            mCurrentDirectory = currentDirectory()+"/"+mFiles[index];
        }
        openCurrentDirectory();
    }
}

void FileModel::openCurrentDirectory()
{
    mFilesRetrieved = false;
    if (mFiles.length ()) {
        beginRemoveRows (QModelIndex (), 0, mFiles.length ()-1);
        mFiles.clear ();
        endRemoveRows();
    }
    updateFiles();

    emit directoryChanged();
}

void FileModel::goUp ()
{
    if (mCurrentDirectory.isEmpty())
        return;

    QDir dir (mCurrentDirectory);
    if ( dir.cdUp () ) {
        mCurrentDirectory = dir.absolutePath ();
    } else {
        mCurrentDirectory = "";
    }
    openCurrentDirectory();
}

bool FileModel::canGoUp ()
{
    return !mCurrentDirectory.isEmpty();
}

