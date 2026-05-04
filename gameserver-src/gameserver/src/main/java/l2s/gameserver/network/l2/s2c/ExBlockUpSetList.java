package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.ServerPacketOpcodes;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public abstract class ExBlockUpSetList
extends L2GameServerPacket {
    @Override
    protected ServerPacketOpcodes getOpcodes() {
        return ServerPacketOpcodes.ExBlockUpSetList;
    }

    public static class CloseUI
    extends ExBlockUpSetList {
        public static final CloseUI STATIC = new CloseUI();

        @Override
        protected void writeImpl() {
            this.writeD(-1);
        }
    }

    public static class ChangeTeam
    extends ExBlockUpSetList {
        private int _objectId;
        private boolean _fromRedTeam;

        public ChangeTeam(Player player, boolean fromRedTeam) {
            this._objectId = player.getObjectId();
            this._fromRedTeam = fromRedTeam;
        }

        @Override
        protected void writeImpl() {
            this.writeD(5);
            this.writeD(this._objectId);
            this.writeD(this._fromRedTeam ? 1 : 0);
            this.writeD(this._fromRedTeam ? 0 : 1);
        }
    }

    public static class RequestReady
    extends ExBlockUpSetList {
        public static final RequestReady STATIC = new RequestReady();

        @Override
        protected void writeImpl() {
            this.writeD(4);
        }
    }

    public static class ChangeTimeToStart
    extends ExBlockUpSetList {
        private final int _seconds;

        public ChangeTimeToStart(int seconds) {
            this._seconds = seconds;
        }

        @Override
        protected void writeImpl() {
            this.writeD(3);
            this.writeD(this._seconds);
        }
    }

    public static class RemovePlayer
    extends ExBlockUpSetList {
        private final int _objectId;
        private final boolean _isRedTeam;

        public RemovePlayer(Player player, boolean isRedTeam) {
            this._objectId = player.getObjectId();
            this._isRedTeam = isRedTeam;
        }

        @Override
        protected void writeImpl() {
            this.writeD(2);
            this.writeD(-1);
            this.writeD(this._isRedTeam ? 1 : 0);
            this.writeD(this._objectId);
        }
    }

    public static class AddPlayer
    extends ExBlockUpSetList {
        private final int _objectId;
        private final String _name;
        private final boolean _isRedTeam;

        public AddPlayer(Player player, boolean isRedTeam) {
            this._objectId = player.getObjectId();
            this._name = player.getName();
            this._isRedTeam = isRedTeam;
        }

        @Override
        protected void writeImpl() {
            this.writeD(1);
            this.writeD(-1);
            this.writeD(this._isRedTeam ? 1 : 0);
            this.writeD(this._objectId);
            this.writeS(this._name);
        }
    }

    public static class TeamList
    extends ExBlockUpSetList {
        private final List<Player> _bluePlayers;
        private final List<Player> _redPlayers;
        private final int _roomNumber;

        public TeamList(List<Player> redPlayers, List<Player> bluePlayers, int roomNumber) {
            this._redPlayers = redPlayers;
            this._bluePlayers = bluePlayers;
            this._roomNumber = roomNumber - 1;
        }

        @Override
        protected void writeImpl() {
            this.writeD(0);
            this.writeD(this._roomNumber);
            this.writeD(-1);
            this.writeD(this._bluePlayers.size());
            for (Player player : this._bluePlayers) {
                this.writeD(player.getObjectId());
                this.writeS(player.getName());
            }
            this.writeD(this._redPlayers.size());
            for (Player player : this._redPlayers) {
                this.writeD(player.getObjectId());
                this.writeS(player.getName());
            }
        }
    }
}

