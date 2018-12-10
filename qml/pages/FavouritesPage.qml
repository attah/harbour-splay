import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property int category_id
    property string category_name

    SilicaListView {
        id: listView

        PullDownMenu {
            visible: globalMedia.source != ""
            MenuItem {
                text: qsTr("Nu spelas")
                onClicked: pageStack.push(Qt.resolvedUrl("PlayPage.qml"), {now_playing: true})
            }
        }


        model: db.favourites_model
        anchors.fill: parent

        header: PageHeader {
            title: category_name
        }
        delegate: ListItem {
            id: delegate

            Label {
                id: label
                x: Theme.horizontalPageMargin
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked:  {
                console.log("pushing program", id)
                pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),
                               {url:  "http://api.sr.se/api/v2/episodes/index?format=json&size=20&programid="+id,
                                program_name: name});

            }
            menu: ContextMenu {
                MenuItem {
                    text: "Ta bort favoritmarkering"
                    onClicked: db.unsetFavourite(id)
                }
            }

        }
        VerticalScrollDecorator {}
    }

}
