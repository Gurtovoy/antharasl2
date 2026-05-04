/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowAllPacket;

public class PartySmallWindowAddPacket
extends L2GameServerPacket {
    private final int _leaderObjectId;
    private final int _loot;
    private final PartySmallWindowAllPacket.PartyMember _member;

    public PartySmallWindowAddPacket(Player player, Player member) {
        this._leaderObjectId = member.getParty().getPartyLeader().getObjectId();
        this._loot = member.getParty().getLootDistribution();
        this._member = new PartySmallWindowAllPacket.PartySmallWindowMemberInfo((Player)member).member;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._leaderObjectId);
        this.writeD(this._loot);
        this.writeD(this._member.objId);
        this.writeS(this._member.name);
        this.writeD(this._member.curCp);
        this.writeD(this._member.maxCp);
        this.writeD(this._member.curHp);
        this.writeD(this._member.maxHp);
        this.writeD(this._member.curMp);
        this.writeD(this._member.maxMp);
        this.writeD(0);
        this.writeC(this._member.level);
        this.writeH(this._member.classId);
        this.writeC(this._member.sex);
        this.writeH(this._member.raceId);
    }
}

