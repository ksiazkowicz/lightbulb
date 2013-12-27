/********************************************************************

src/avkon/QAvkonHelper.h
-- interface to native Symbian APIs

Copyright (c) 2013 Maciej Janiszewski,
                   Fabian Hüllmantel,
                   Dickson Leong

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

#ifndef QAVKONHELPER_H
#define QAVKONHELPER_H

#include <QApplication>
#include <QClipboard>
#include <aknglobalnote.h>
#include <hwrmlight.h>
#include <QUrl>

class QDeclarativeView;

class QAvkonHelper : public QObject
{
    Q_OBJECT
public:
    explicit QAvkonHelper(QDeclarativeView *view, QObject *parent = 0);
    Q_INVOKABLE void showPopup(QString title,QString message, bool goToApp);
    Q_INVOKABLE void notificationBlink(int device);
    Q_INVOKABLE void displayGlobalNote(QString message, bool isError);
    Q_INVOKABLE QString openFileSelectionDlg();
    Q_INVOKABLE void openDefaultBrowser(const QUrl &url) const;

    Q_INVOKABLE void showChatIcon();
    Q_INVOKABLE void hideChatIcon();
    Q_INVOKABLE void minimize() const;
    Q_INVOKABLE void restartApp();
    Q_INVOKABLE bool displayAvkonQueryDialog(QString title, QString message);

private:
    TInt iNoteId;
    CAknGlobalNote* iNote;
    CHWRMLight* notifyLight;
    void ShowNoteL(const TDesC& aMessage);
    void ShowErrorL(const TDesC& aMessage);
    QDeclarativeView *m_view;

    bool chatIconStatus;
    
signals:
    
public slots:
    
};

class ClipboardAdapter : public QObject
{
    Q_OBJECT
public:
    explicit ClipboardAdapter(QObject *parent = 0) : QObject(parent) {
        clipboard = QApplication::clipboard();
    }

    Q_INVOKABLE void setText(QString text) {
        clipboard->setText(text, QClipboard::Clipboard);
        clipboard->setText(text, QClipboard::Selection);
    }

private:
    QClipboard *clipboard;
};

#endif // QAVKONHELPER_H
