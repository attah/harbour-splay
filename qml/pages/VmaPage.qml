import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    property alias model: listView.model

    SilicaListView {
        id: listView
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("VMA")
        }


        delegate: BackgroundItem {
            id: delegate
            height: detailsColumn.implicitHeight+Theme.paddingSmall
            Column {
                id: detailsColumn
                width: parent.width
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width-2*Theme.horizontalPageMargin
                    text: title
                    color: delegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    wrapMode: "WordWrap"
                }
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width-2*Theme.horizontalPageMargin
                    text: description
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: "WordWrap"
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width*2/5
                    Component.onCompleted:  {
                        text = new Date(parseInt(date.substr(6))).toLocaleString(Locale);
                    }

                    text: ""
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeTiny
                }

            }

            onClicked:  {
                Qt.openUrlExternally(url)
            }
        }
        VerticalScrollDecorator {}
        Label {
            text: qsTr("Tomt")
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.rgba(Theme.primaryColor, 0.4)
            visible: model.count === 0
            anchors.centerIn: parent
        }
    }

}
