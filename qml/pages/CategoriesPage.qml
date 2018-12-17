import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaListView {
        id: listView

        PullDownMenu {
            visible: globalMedia.source != ""
            MenuItem {
                text: qsTr("Nu spelas")
                onClicked: pageStack.push(Qt.resolvedUrl("PlayPage.qml"), {now_playing: true})
            }
        }

        JSONListModel {
            id: programs
            source: "https://api.sr.se/api/v2/programcategories?pagination=false&format=json"
            query: "$.programcategories"
        }

        model: programs.model
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Kategorier")
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.horizontalPageMargin
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked:  {
                pageStack.push(Qt.resolvedUrl("CategoryPage.qml"), {category_id: id, category_name: name});
            }
        }
        VerticalScrollDecorator {}
    }

}
