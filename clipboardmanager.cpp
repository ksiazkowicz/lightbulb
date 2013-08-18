#ifndef QMLCLIPBOARDADAPTER_H
#define QMLCLIPBOARDADAPTER_H

#include <QApplication>
#include <QClipboard>
#include <QObject>

class QmlClipboardAdapter : public QObject
{
    Q_OBJECT
public:
    explicit QmlClipboardAdapter(QObject *parent = 0) : QObject(parent) {
        clipboard = QApplication::clipboard();
    }

    Q_INVOKABLE void setText(QString text){
        clipboard->setText(text, QClipboard::Clipboard);
        clipboard->setText(text, QClipboard::Selection);
    }

private:
    QClipboard *clipboard;
};

#endif // QMLCLIPBOARDADAPTER_H
