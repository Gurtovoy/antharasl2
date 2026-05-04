package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.SkillCastingType;

public class MagicSkillUse
extends L2GameServerPacket {
    public static final int NONE = -1;
    private final int _targetId;
    private final int _skillId;
    private final int _skillLevel;
    private final int _hitTime;
    private final int _reuseDelay;
    private final int _chaId;
    private final int _x;
    private final int _y;
    private final int _z;
    private final int _tx;
    private final int _ty;
    private final int _tz;
    private final SkillCastingType _castingType;
    private int _reuseGroup;
    private boolean _isServitorSkill;
    private int _actionId;
    private Location _groundLoc = null;
    private boolean _criticalBlow = false;

    public MagicSkillUse(Creature cha, Creature target, int skillId, int skillLevel, int hitTime, long reuseDelay, SkillCastingType castingType, int reuseGroup, boolean isServitorSkill, int actionId) {
        this._chaId = cha.getObjectId();
        this._targetId = target.getObjectId();
        this._skillId = skillId;
        this._skillLevel = skillLevel;
        this._hitTime = hitTime;
        this._reuseDelay = (int)reuseDelay;
        this._x = cha.getX();
        this._y = cha.getY();
        this._z = cha.getZ();
        this._tx = target.getX();
        this._ty = target.getY();
        this._tz = target.getZ();
        this._reuseGroup = reuseGroup;
        this._isServitorSkill = isServitorSkill;
        this._actionId = actionId;
        this._castingType = castingType;
    }

    public MagicSkillUse(Creature cha, Creature target, int skillId, int skillLevel, int hitTime, long reuseDelay, SkillCastingType castingType) {
        this(cha, target, skillId, skillLevel, hitTime, reuseDelay, castingType, -1, false, 0);
    }

    public MagicSkillUse(Creature cha, Creature target, int skillId, int skillLevel, int hitTime, long reuseDelay) {
        this(cha, target, skillId, skillLevel, hitTime, reuseDelay, SkillCastingType.NORMAL, -1, false, 0);
    }

    public MagicSkillUse(Creature cha, int skillId, int skillLevel, int hitTime, long reuseDelay) {
        this(cha, cha, skillId, skillLevel, hitTime, reuseDelay, SkillCastingType.NORMAL, -1, false, 0);
    }

    public MagicSkillUse setReuseSkillId(int id) {
        this._reuseGroup = id;
        return this;
    }

    public MagicSkillUse setServitorSkillInfo(int actionId) {
        this._isServitorSkill = true;
        this._actionId = actionId;
        return this;
    }

    public MagicSkillUse setGroundLoc(Location loc) {
        this._groundLoc = loc;
        return this;
    }

    public MagicSkillUse setCriticalBlow(boolean value) {
        this._criticalBlow = value;
        return this;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._castingType.getClientBarId());
        this.writeD(this._chaId);
        this.writeD(this._targetId);
        this.writeD(this._skillId);
        this.writeD(this._skillLevel);
        this.writeD(this._hitTime);
        this.writeD(this._reuseGroup);
        this.writeD(this._reuseDelay);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
        if (this._criticalBlow) {
            this.writeH(2);
            for (int i = 0; i < 2; ++i) {
                this.writeH(0);
            }
        } else {
            this.writeH(0);
        }
        if (this._groundLoc != null) {
            this.writeH(1);
            this.writeD(this._groundLoc.x);
            this.writeD(this._groundLoc.y);
            this.writeD(this._groundLoc.z);
        } else {
            this.writeH(0);
        }
        this.writeD(this._tx);
        this.writeD(this._ty);
        this.writeD(this._tz);
        this.writeD(this._isServitorSkill ? 1 : 0);
        this.writeD(this._actionId);
    }

    @Override
    public L2GameServerPacket packet(Player player) {
        if (player != null && player.isNotShowBuffAnim()) {
            return this._chaId == player.getObjectId() ? super.packet(player) : null;
        }
        return super.packet(player);
    }
}

