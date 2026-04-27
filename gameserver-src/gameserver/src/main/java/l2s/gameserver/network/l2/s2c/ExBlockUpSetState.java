/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.ServerPacketOpcodes;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public abstract class ExBlockUpSetState
extends L2GameServerPacket {
    @Override
    protected ServerPacketOpcodes getOpcodes() {
        return ServerPacketOpcodes.ExBlockUpSetState;
    }

    public static class PointsInfo
    extends ExBlockUpSetState {
        private final int _timeLeft;
        private final int _bluePoints;
        private final int _redPoints;

        public PointsInfo(int timeLeft, int bluePoints, int redPoints) {
            this._timeLeft = timeLeft;
            this._bluePoints = bluePoints;
            this._redPoints = redPoints;
        }

        @Override
        protected void writeImpl() {
            this.writeD(2);
            this.writeD(this._timeLeft);
            this.writeD(this._bluePoints);
            this.writeD(this._redPoints);
        }
    }

    public static class GameEnd
    extends ExBlockUpSetState {
        public static final GameEnd REMOVE_COUNTER = new GameEnd();
        private final int _winner;

        public GameEnd(boolean isRedTeamWin) {
            this._winner = isRedTeamWin ? 1 : 0;
        }

        private GameEnd() {
            this._winner = -1;
        }

        @Override
        protected void writeImpl() {
            this.writeD(1);
            this.writeD(this._winner);
            this.writeD(0);
        }
    }

    public static class ChangePoints
    extends ExBlockUpSetState {
        private final int _timeLeft;
        private final int _bluePoints;
        private final int _redPoints;
        private final boolean _isRedTeam;
        private final int _objectId;
        private final int _playerPoints;

        public ChangePoints(int timeLeft, int bluePoints, int redPoints, boolean isRedTeam, Player player, int playerPoints) {
            this._timeLeft = timeLeft;
            this._bluePoints = bluePoints;
            this._redPoints = redPoints;
            this._isRedTeam = isRedTeam;
            this._objectId = player.getObjectId();
            this._playerPoints = playerPoints;
        }

        @Override
        protected void writeImpl() {
            this.writeD(0);
            this.writeD(this._timeLeft);
            this.writeD(this._bluePoints);
            this.writeD(this._redPoints);
            this.writeD(this._isRedTeam ? 1 : 0);
            this.writeD(this._objectId);
            this.writeD(this._playerPoints);
        }
    }
}

