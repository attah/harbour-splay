import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
import Sailfish.Silica 1.0
import Amber.Mpris 1.0
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
        id: timekeeper
        property var endtimes: new Object
        property var rightnow: new Object
    }


    Item {
        id: db
        property var db_conn
        property ListModel favourites_model : ListModel { id: favouritesModel }

        Component.onCompleted: {
            db_conn = LocalStorage.openDatabaseSync("SPlayDB", "1.0", "S'Play storage", 100000)
            db_conn.transaction(function (tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Favourites (id INT UNIQUE, name STRING)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS Progress (id INT UNIQUE, position INT)');
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
                var rs = tx.executeSql('SELECT * FROM Favourites ORDER BY name');
                for (var i = 0; i < rs.rows.length; i++) {
                    console.log("fav!", rs.rows.item(i).id, rs.rows.item(i).name);
                    favourites_model.append(rs.rows.item(i));
                }
            })
        }
        function setProgress(id, position) {
            console.log("setprog", id, position);
            db_conn.transaction(function (tx) {
                tx.executeSql('REPLACE INTO Progress VALUES(?, ?)', [id, position] );
            });
        }
        function getProgress(id) {
            var position = 0
            db_conn.transaction(function (tx) {
                var res = tx.executeSql('SELECT position FROM Progress WHERE id=?', [id] );
                console.log("prog", res.rows.length !== 0, JSON.stringify(res));
                if(res.rows.length !== 0)
                    position = res.rows[0].position;
            });
            return position;
        }
        function removeProgress(id) {
            console.log("remprog", id);
            db_conn.transaction(function (tx) {
                tx.executeSql('DELETE FROM Progress WHERE id=?', [id] );
            });
        }
    }

    SoundEffect {
        id: retrySound
        source: "boop.wav"
    }

    Timer {
        id: playRetry

        property int retry_cnt: 0

        interval: 1000; running: false; repeat: true
        onTriggered: { console.log("retry playback");
                       if(retry_cnt % 2 == 0) {
                           retrySound.play();
                       }
                       retry_cnt++;
                       if(retry_cnt > 20) { stop() };
                       globalMedia.play();
        }
    }

    Timer {
        id: liveReset

        interval: 5000; running: false; repeat: false
        onTriggered: {if(globalMedia.playbackState !== MediaPlayer.PlayingState) {
                          console.log("reset live position");
                          globalMedia.stop();
                          globalMedia.autoLoad = false; //don't preload
                          var tmp = globalMedia.source;
                          globalMedia.source = "";
                          globalMedia.source = tmp;
                          globalMedia.autoLoad = true;
                      }
        }
    }

    MediaPlayer {
        id: globalMedia
        property string name
        property string title
        property string imageurl
        property string downloadurl
        property string description
        property int program_id
        property int episode_id
        property bool inited: false

        autoLoad: true

        onAvailabilityChanged: {console.log("avail", availability)}
        onError: {console.log("err", error);
                  if (error === MediaPlayer.NetworkError) {
                    playRetry.retry_cnt = 0;
                    playRetry.start();
                  }
        }

        function goForward() {
            seek(position + 10000 < duration ? position + 10000 : duration)
        }

        function goBackward() {
            seek(position - 10000 > 0 ? position - 10000 : 0)
        }

        function togglePlaying() {
            if (playbackState == MediaPlayer.PlayingState) {
                pause()
            }
            else {
                play()
            }
        }

        onPlaying: {
            playRetry.stop();
            liveReset.stop();
        }
        onPlaybackStateChanged: {
            console.log("playbackstate", playbackState);
            console.log("sp", position, duration);

            if (playbackState !== MediaPlayer.PlayingState && duration === 0) {
                liveReset.start();
            }
            if (playbackState !== MediaPlayer.PlayingState) {
                //           Invalid           Live             For good measure
                if(duration !== -1 && duration !== 0 && position !== 0) {
                    if (position > 5000) {
                        db.setProgress(episode_id, position)
                    }
                    if (position > (duration-5000) || position <= 5000) {
                        console.log("rp",position);
                        db.removeProgress(episode_id)
                    }
                }
            }
        }
    }

    MprisPlayer {

        id: mprisConnection
        serviceName: "splay"
        playbackStatus: globalMedia.playbackState == MediaPlayer.PlayingState ? Mpris.Playing : Mpris.Paused

        identity: "S'Play"

        canControl: true

        canPause: true
        canPlay: true
        canGoNext: globalMedia.duration !== 0
        canGoPrevious: globalMedia.duration !== 0

        canSeek: false

        onPauseRequested: globalMedia.pause()
        onPlayRequested: globalMedia.play()
        onPlayPauseRequested: globalMedia.togglePlaying()
        onNextRequested: globalMedia.goForward()
        onPreviousRequested: globalMedia.goBackward()

        metaData {
            title: globalMedia.name
            artUrl: globalMedia.imageurl
        }


    }

}
