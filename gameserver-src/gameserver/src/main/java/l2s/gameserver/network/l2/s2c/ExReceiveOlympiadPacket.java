/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadGame;
import l2s.gameserver.model.entity.olympiad.OlympiadManager;
import l2s.gameserver.model.entity.olympiad.OlympiadMember;
import l2s.gameserver.network.l2.ServerPacketOpcodes;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public abstract class ExReceiveOlympiadPacket
extends L2GameServerPacket {
    private int _type;

    public ExReceiveOlympiadPacket(int type) {
        this._type = type;
    }

    @Override
    protected ServerPacketOpcodes getOpcodes() {
        return ServerPacketOpcodes.ExReceiveOlympiadPacket;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._type);
    }

    public static class MatchResult
    extends ExReceiveOlympiadPacket {
        private boolean _tie;
        private String _name;
        private List<PlayerInfo> _teamOne = new ArrayList<PlayerInfo>(3);
        private List<PlayerInfo> _teamTwo = new ArrayList<PlayerInfo>(3);

        public MatchResult(boolean tie, String winnerName) {
            super(1);
            this._tie = tie;
            this._name = winnerName;
        }

        public void addPlayer(TeamType team, OlympiadMember member, int gameResultPoints, int dealOutDamage) {
            int points = Config.OLYMPIAD_OLDSTYLE_STAT ? 0 : member.getStat().getPoints();
            this.addPlayer(team, member.getName(), member.getClanName(), member.getClassId(), points, gameResultPoints, dealOutDamage);
        }

        public void addPlayer(TeamType team, String name, String clanName, int classId, int points, int resultPoints, int damage) {
            switch (team) {
                case RED: {
                    this._teamOne.add(new PlayerInfo(name, clanName, classId, points, resultPoints, damage));
                    break;
                }
                case BLUE: {
                    this._teamTwo.add(new PlayerInfo(name, clanName, classId, points, resultPoints, damage));
                }
            }
        }

        @Override
        protected void writeImpl() {
            super.writeImpl();
            this.writeD(this._tie);
            this.writeS(this._name);
            this.writeD(1);
            this.writeD(this._teamOne.size());
            for (PlayerInfo playerInfo : this._teamOne) {
                this.writeS(playerInfo._name);
                this.writeS(playerInfo._clanName);
                this.writeD(0);
                this.writeD(playerInfo._classId);
                this.writeD(playerInfo._damage);
                this.writeD(playerInfo._currentPoints);
                this.writeD(playerInfo._gamePoints);
                this.writeD(0);
            }
            this.writeD(2);
            this.writeD(this._teamTwo.size());
            for (PlayerInfo playerInfo : this._teamTwo) {
                this.writeS(playerInfo._name);
                this.writeS(playerInfo._clanName);
                this.writeD(0);
                this.writeD(playerInfo._classId);
                this.writeD(playerInfo._damage);
                this.writeD(playerInfo._currentPoints);
                this.writeD(playerInfo._gamePoints);
                this.writeD(0);
            }
        }

        private static class PlayerInfo {
            private String _name;
            private String _clanName;
            private int _classId;
            private int _currentPoints;
            private int _gamePoints;
            private int _damage;

            public PlayerInfo(String name, String clanName, int classId, int currentPoints, int gamePoints, int damage) {
                this._name = name;
                this._clanName = clanName;
                this._classId = classId;
                this._currentPoints = currentPoints;
                this._gamePoints = gamePoints;
                this._damage = damage;
            }
        }
    }

    public static class MatchList
    extends ExReceiveOlympiadPacket {
        private List<ArenaInfo> _arenaList = Collections.emptyList();

        public MatchList() {
            super(0);
            OlympiadManager manager = Olympiad._manager;
            if (manager != null) {
                this._arenaList = new ArrayList<ArenaInfo>();
                for (int i = 0; i < Olympiad.STADIUMS.length; ++i) {
                    OlympiadGame game = manager.getOlympiadInstance(i);
                    if (game == null || game.getState() <= 0) continue;
                    this._arenaList.add(new ArenaInfo(i, game.getState(), game.getType().ordinal(), game.getMemberName1(), game.getMemberName2()));
                }
            }
        }

        public MatchList(List<ArenaInfo> arenaList) {
            super(0);
            this._arenaList = arenaList;
        }

        @Override
        protected void writeImpl() {
            super.writeImpl();
            this.writeD(this._arenaList.size());
            this.writeD(0);
            for (ArenaInfo arena : this._arenaList) {
                this.writeD(arena._id);
                this.writeD(arena._matchType);
                this.writeD(arena._status);
                this.writeS(arena._name1);
                this.writeS(arena._name2);
            }
        }

        public static class ArenaInfo {
            public int _status;
            private int _id;
            private int _matchType;
            public String _name1;
            public String _name2;

            public ArenaInfo(int id, int status, int match_type, String name1, String name2) {
                this._id = id;
                this._status = status;
                this._matchType = match_type;
                this._name1 = name1;
                this._name2 = name2;
            }
        }
    }
}

