/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.GameTimeController;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CharacterSelectedPacket
extends L2GameServerPacket {
    private int _sessionId;
    private int char_id;
    private int clan_id;
    private int sex;
    private int race;
    private int class_id;
    private String _name;
    private String _title;
    private Location _loc;
    private double curHp;
    private double curMp;
    private int level;
    private int karma;
    private int _pk;
    private long _exp;
    private long _sp;

    public CharacterSelectedPacket(Player cha, int sessionId) {
        this._sessionId = sessionId;
        this._name = cha.getName();
        this.char_id = cha.getObjectId();
        this._title = cha.getTitle();
        this.clan_id = cha.getClanId();
        this.sex = cha.getSex().ordinal();
        this.race = cha.getRace().ordinal();
        this.class_id = cha.getClassId().getId();
        this._loc = cha.getLoc();
        this.curHp = cha.getCurrentHp();
        this.curMp = cha.getCurrentMp();
        this._sp = cha.getSp();
        this._exp = cha.getExp();
        this.level = cha.getLevel();
        this.karma = cha.getKarma();
        this._pk = cha.getPkKills();
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._name);
        this.writeD(this.char_id);
        this.writeS(this._title);
        this.writeD(this._sessionId);
        this.writeD(this.clan_id);
        this.writeD(0);
        this.writeD(this.sex);
        this.writeD(this.race);
        this.writeD(this.class_id);
        this.writeD(1);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeF(this.curHp);
        this.writeF(this.curMp);
        this.writeQ(this._sp);
        this.writeQ(this._exp);
        this.writeD(this.level);
        this.writeD(this.karma);
        this.writeD(this._pk);
        this.writeD(GameTimeController.getInstance().getGameTime());
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeB(new byte[64]);
        this.writeD(0);
    }
}

