import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.Portrait

    property bool first_start: true

    onStatusChanged: {
        console.log("status", status);
        if (status == PageStatus.Active && !first_start) {
            console.log("refräs");
            lastpublished.refresh();
        }
    }

    Component.onCompleted: {
        appWin.reactivated.connect(lastpublished.refresh)
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        Component.onCompleted: {
            console.log("src", globalMedia.source)
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                visible: globalMedia.source != ""
                text: qsTr("Nu spelas")
                onClicked: pageStack.push(Qt.resolvedUrl("PlayPage.qml"), {now_playing: true})
            }
            MenuItem {
                text: qsTr("Sök")
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            anchors.fill: parent

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("S'Play")
            }



            Label {
                text: qsTr("Livekanaler")
                x: Theme.paddingMedium
            }
            Row {
//                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: parent.width*0.25

                Image {
                    width: parent.width*0.25
                    height: parent.width*0.25
                    source: "https://static-cdn.sr.se/sida/images/132/2186745_512_512.jpg?preset=api-default-square"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                                           {id: 0,
                                            name: "P1",
                                            imageurl: parent.source,
                                            url: "https://sverigesradio.se/topsy/direkt/srapi/132.mp3",
                                            download_url: ""});

                        }
                    }
                }


                Image {
                    source: "https://static-cdn.sr.se/sida/images/163/2186754_512_512.jpg?preset=api-default-square"
                    width: parent.width*0.25
                    height: parent.width*0.25
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                                           {id: 0,
                                            name: "P2",
                                            imageurl: parent.source,
                                            url: "https://sverigesradio.se/topsy/direkt/srapi/163.mp3",
                                            download_url: ""});

                        }
                    }
                }
                Image {
                    source: "https://static-cdn.sr.se/sida/images/164/2186756_512_512.jpg?preset=api-default-square"
                    width: parent.width*0.25
                    height: parent.width*0.25
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                                           {id: 0,
                                            name: "P3",
                                            imageurl: parent.source,
                                            url: "https://sverigesradio.se/topsy/direkt/srapi/164.mp3",
                                            download_url: ""});

                        }
                    }
                }
                BackgroundItem {
                    width: parent.width*0.25
                    height: parent.width*0.25
                    Label {
                        text: qsTr("Fler...")
                        anchors.bottom: parent.bottom
                        x: Theme.paddingMedium
                    }
                    highlighted: true
                    onClicked: {  pageStack.push(Qt.resolvedUrl("ChannelsPage.qml")) }
                }
            }

            Button {
                x: Theme.horizontalPageMargin
                text: qsTr("Senaste nyheterna")
                color: Theme.secondaryHighlightColor
                onClicked: {pageStack.push(Qt.resolvedUrl("ProgramPage.qml"),
                                           {url:  "https://api.sr.se/api/v2/news/episodes?format=json",
                                            program_name: text})}


            }
            Button {
                x: Theme.horizontalPageMargin
                text: qsTr("Kategorier")
                color: Theme.secondaryHighlightColor
                onClicked: {  pageStack.push(Qt.resolvedUrl("CategoriesPage.qml")) }
            }

            Label {
                text: qsTr("Senast publicerade program")
                x: Theme.paddingMedium
            }
            JSONListModel {
                id: lastpublished
                source: "https://api.sr.se/api/v2/lastpublished?format=json&pagination=false"
                query: "$.shows"
            }
            SilicaListView {
                id: lastPublishedList
                height: parent.width*0.25
                width: parent.width
                orientation: ListView.Horizontal


                model: lastpublished.model


                delegate: BackgroundItem {
                    id: delegate
                    width: visible ? parent.height : 0
                    height: parent.height
                    visible: model.listenpodfile ? true : model.broadcast ? true : false

                    Image {
                        id:img
                        width: parent.height
                        height: parent.height
                        source: model.imageurl

                    }

                    onClicked:  {
                        console.log(imageurl)
                        pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                                       {id: model.program.id,
                                        name: program.name,
                                        title: title,
                                        imageurl: imageurl,
                                        url: model.listenpodfile ? model.listenpodfile.url : model.broadcast.broadcastfiles[0].url,
                                        downloadurl: model.downloadpodfile ? model.downloadpodfile.url : ""});
                    }
                }
                HorizontalScrollDecorator { flickable: lastPublishedList }
            }
            Button {
                x: Theme.horizontalPageMargin
                text: qsTr("Favoriter")
                color: Theme.secondaryHighlightColor
                onClicked: {  pageStack.push(Qt.resolvedUrl("FavouritesPage.qml")) }
            }
        }
    }
}
