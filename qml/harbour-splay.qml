import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: appWin
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    signal reactivated

    onVisibleChanged: {
        console.log("viz",visible)
        if (visible)
            reactivated()
    }


    Item {
        id: db
        property var db_conn
        property ListModel favourites_model : ListModel { id: favouritesModel }

        Component.onCompleted: {
            db_conn = LocalStorage.openDatabaseSync("SPlayDB", "1.0", "S'Play storage", 100000)
            db_conn.transaction(function (tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Favourites (id INT UNIQUE, name STRING)');
            });
            updateFavourites();
        }

        function isFavourite(id) {
            var is_fav = false
            db_conn.transaction(function (tx) {
                var res = tx.executeSql('SELECT id FROM Favourites WHERE id=?', [id] );
                console.log("isfav", res.rows.length !== 0);
                is_fav = res.rows.length !== 0;
            });
            return is_fav;
        }
        function setFavourite(id, name) {
            console.log("setvfav", id);
            db_conn.transaction(function (tx) {
                tx.executeSql('INSERT INTO Favourites VALUES(?, ?)', [id, name] );
            });
            updateFavourites();
        }
        function unsetFavourite(id) {
            console.log("unsetvfav", id);
            db_conn.transaction(function (tx) {
                tx.executeSql('DELETE FROM Favourites WHERE id=?', [id] );
            });
            updateFavourites();
        }
        function updateFavourites() {
            favourites_model.clear();
            db_conn.transaction(function (tx) {
                var rs = tx.executeSql('SELECT * FROM Favourites');
                for (var i = 0; i < rs.rows.length; i++) {
                    console.log("fav!", rs.rows.item(i).id, rs.rows.item(i).name);
                    favourites_model.append(rs.rows.item(i));
                }
            })
        }
    }


    Timer {
        id: playRetry

        property int retry_cnt: 0

        interval: 1000; running: false; repeat: true
        onTriggered: { console.log("retry playback");
                       retry_cnt++;
                       if(retry_cnt > 10) { stop() };
                       globalMedia.play();
        }
    }

    Timer {
        id: liveReset

        interval: 5000; running: false; repeat: false
        onTriggered: {if(globalMedia.playbackState === MediaPlayer.PausedState) {
                          console.log("reset live position");
                          globalMedia.stop();
                          var tmp = globalMedia.source;
                          globalMedia.source = "";
                          globalMedia.source = tmp;
                      }
        }
    }



    MediaPlayer {
        property string name
        property string title
        property string imageurl
        property string downloadurl
        property string description
        property int id

        id: globalMedia
        onAvailabilityChanged: {console.log("avail", availability)}
        onError: {console.log("err", error);
                  if (error === MediaPlayer.NetworkError) {
                    playRetry.retry_cnt = 0;
                    playRetry.start();
                  }
        }
        onPlaying: {
            playRetry.stop();
            liveReset.stop();
        }
        onPlaybackStateChanged: {
            console.log("playbackstate", playbackState);
            if (playbackState === MediaPlayer.PausedState && duration === 0) {
                liveReset.start();
            }
        }
    }

}
