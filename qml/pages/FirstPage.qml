import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    property int divider: (Screen.height > 2*Screen.width)===(page.orientation===Orientation.Portrait) ? 4 : 5

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: page.orientation == Orientation.Portrait
                       ? column1.height + column2.height +header.height + Theme.paddingMedium
                       : column1.height + Theme.paddingMedium

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
        PageHeader {
            id: header
            title: qsTr("S'Play")
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column1
            anchors.top: header.bottom
            anchors.left: parent.left

            width: page.orientation === Orientation.Portrait ? parent.width : parent.width/2

            LongPhonePadding {
                padding: Screen.height*0.1
            }

            Label {
                text: qsTr("Livekanaler")
                x: Theme.paddingMedium
                bottomPadding: Theme.paddingMedium
            }


            ChannelItem {
                height: (Screen.width/6*2+parent.width/divider)/3
                width: parent.width

                imageUrl: "https://static-cdn.sr.se/sida/images/132/2186745_512_512.jpg?preset=api-default-square"
                channelId: 132

            }
            ChannelItem {
                height: (Screen.width/6*2+parent.width/divider)/3
                width: parent.width

                imageUrl: "https://static-cdn.sr.se/sida/images/163/2186754_512_512.jpg?preset=api-default-square"
                channelId: 163

            }

            ChannelItem {
                height: (Screen.width/6*2+parent.width/divider)/3
                width: parent.width

                imageUrl: "https://static-cdn.sr.se/sida/images/164/2186756_512_512.jpg?preset=api-default-square"
                channelId: 164

            }

            BarButton {
                text: qsTr("Alla kanaler")
                height: Screen.width/6
                onClicked: {  pageStack.push(Qt.resolvedUrl("ChannelsPage.qml")) }
            }

        }
        Column {
            id: column2

            anchors.top: page.orientation === Orientation.Portrait ? column1.bottom : header.bottom
            anchors.topMargin: page.orientation === Orientation.Portrait ? Theme.paddingLarge : 0
            anchors.right: parent.right

            width: page.orientation === Orientation.Portrait ? parent.width : parent.width/2

            Label {
                text: qsTr("Senast publicerade program")
                x: Theme.paddingMedium
                bottomPadding: Theme.paddingMedium
            }
            JSONListModel {
                id: lastpublished
                source: "https://api.sr.se/api/v2/lastpublished?format=json&pagination=false"
                query: "$.shows"

                property bool initialized: false
                onVisibleChanged: {
                    if (visible)
                    {
                        if(initialized)
                            refresh()
                        initialized = true
                    }
                }
            }
            SilicaListView {
                id: lastPublishedList
                height: parent.width/divider
                width: parent.width
                orientation: ListView.Horizontal
                clip: true


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

                    function hasBroadcast() {
                        console.log(model.broadcast != undefined  && model.broadcast.broadcastfiles.length)
                        return model.broadcast != undefined && model.broadcast.broadcastfiles.length
                    }

                    onClicked:  {
                        console.log(imageurl)
                        pageStack.push(Qt.resolvedUrl("PlayPage.qml"),
                                       {program_id: model.program.id,
                                        episode_id: model.id,
                                        name: program.name,
                                        title: title,
                                        imageurl: imageurl,
                                        url: hasBroadcast() ? model.broadcast.broadcastfiles[0].url : model.listenpodfile.url,
                                        downloadurl: model.downloadpodfile ? model.downloadpodfile.url : ""});
                    }
                }
                HorizontalScrollDecorator { flickable: lastPublishedList }
            }

            BarButton {
                text: qsTr("Kategorier")
                height: Screen.width/6
                onClicked: {  pageStack.push(Qt.resolvedUrl("CategoriesPage.qml")) }
            }

            BarButton {
                text: qsTr("Favoriter")
                height: Screen.width/6
                onClicked: {  pageStack.push(Qt.resolvedUrl("FavouritesPage.qml")) }
            }

            BarButton {
                text: qsTr("VMA (%1)").arg(vma_messages.count)
                height: Screen.width/6
                attention: vma_messages.count != 0
                JSONListModel {
                    id: vma_messages
//                    source: "https://raw.githubusercontent.com/attah/sr-samples/master/vma.json"
                    source: "https://api.sr.se/api/v2/vma?format=json&pagination=none"
                    query: "$.messages"

                    property bool initialized: false
                    onVisibleChanged: {
                        if (visible)
                        {
                            if(initialized)
                                refresh()
                            initialized = true
                        }
                    }
                }
                onClicked: {  pageStack.push(Qt.resolvedUrl("VmaPage.qml"), {vma_model: vma_messages}) }
            }
        }
    }
}
