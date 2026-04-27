/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 */
package l2s.gameserver.listener.zone.impl;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.listener.zone.OnZoneEnterLeaveListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.network.l2.components.SceneMovie;

public class PresentSceneMovieZoneListener
implements OnZoneEnterLeaveListener {
    private final SceneMovie _sceneMovie;

    public PresentSceneMovieZoneListener(SceneMovie sceneMovie) {
        this._sceneMovie = sceneMovie;
    }

    @Override
    public void onZoneEnter(Zone zone, Creature actor) {
        if (!actor.isPlayer()) {
            return;
        }
        Player player = actor.getPlayer();
        if (player == null) {
            return;
        }
        String var = "@" + this._sceneMovie.toString().toLowerCase();
        if (!player.getVarBoolean(var)) {
            PresentSceneMovieZoneListener.scheduleShowMovie(this._sceneMovie, player);
            player.setVar(var, "true", -1L);
        }
    }

    @Override
    public void onZoneLeave(Zone zone, Creature cha) {
    }

    public static void scheduleShowMovie(SceneMovie sceneMovie, Player player) {
        ThreadPoolManager.getInstance().schedule(new ShowMovie(sceneMovie, player), 1000L);
    }

    private static class ShowMovie
    implements Runnable {
        private final SceneMovie _sceneMovie;
        private final HardReference<Player> _playerRef;

        public ShowMovie(SceneMovie sceneMovie, Player player) {
            this._sceneMovie = sceneMovie;
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            player.startScenePlayer(this._sceneMovie);
        }
    }
}

