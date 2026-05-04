package l2s.gameserver.model.actor.instances.player;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.SubClassType;

public class SubClass {
    private final Player _owner;
    private int _classId = 0;
    private int _index = 1;
    private boolean _active = false;
    private SubClassType _type = SubClassType.BASE_CLASS;
    private int _level = 1;
    private long _exp = 0L;
    private long _sp = 0L;
    private int _maxLvl = Experience.getMaxLevel();
    private long _minExp = 0L;
    private long _maxExp = Experience.getExpForLevel(this._maxLvl + 1) - 1L;
    private double _hp = 1.0;
    private double _mp = 1.0;
    private double _cp = 1.0;

    public SubClass(Player owner) {
        this._owner = owner;
    }

    public int getClassId() {
        return this._classId;
    }

    public long getExp() {
        return this._exp;
    }

    public long getMaxExp() {
        return this._maxExp;
    }

    public void addExp(long val, boolean delevel) {
        this.setExp(this._exp + val, delevel);
    }

    public long getSp() {
        return this._sp;
    }

    public void addSp(long val) {
        this.setSp(this._sp + val);
    }

    public int getLevel() {
        return this._level;
    }

    public void setClassId(int id) {
        if (this._classId == id) {
            return;
        }
        this._classId = id;
    }

    public void setExp(long val, boolean delevel) {
        this._exp = val;
        if (!delevel) {
            this._exp = Math.min(Math.max(Experience.getExpForLevel(this._level), this._exp), this._maxExp);
        }
        this._exp = Math.min(this._exp, this._maxExp);
        this._exp = Math.max(this._minExp, this._exp);
        this._level = Experience.getLevel(this._exp);
    }

    public void setSp(long spValue) {
        this._sp = Math.min(Math.max(0L, spValue), Config.SP_LIMIT);
    }

    public void setHp(double hpValue) {
        this._hp = Math.max(0.0, hpValue);
    }

    public double getHp() {
        return this._hp;
    }

    public void setMp(double mpValue) {
        this._mp = Math.max(0.0, mpValue);
    }

    public double getMp() {
        return this._mp;
    }

    public void setCp(double cpValue) {
        this._cp = Math.max(0.0, cpValue);
    }

    public double getCp() {
        return this._cp;
    }

    public void setActive(boolean active) {
        this._active = active;
    }

    public boolean isActive() {
        return this._active;
    }

    public void setType(SubClassType type) {
        if (this._type == type) {
            return;
        }
        this._type = type;
        if (this._type == SubClassType.SUBCLASS) {
            this._maxLvl = Experience.getMaxSubLevel();
            this._minExp = Experience.getExpForLevel(Config.SUB_START_LEVEL);
            this._level = Math.min(Math.max(Config.SUB_START_LEVEL, this._level), this._maxLvl);
        } else {
            this._maxLvl = Experience.getMaxLevel();
            this._minExp = 0L;
            this._level = Math.min(Math.max(1, this._level), this._maxLvl);
        }
        this._minExp = Math.max(0L, this._minExp);
        this._maxExp = Experience.getExpForLevel(this._maxLvl + 1) - 1L;
        this._exp = Math.min(Math.max(Experience.getExpForLevel(this._level), this._exp), this._maxExp);
    }

    public SubClassType getType() {
        return this._type;
    }

    public boolean isBase() {
        return this._type == SubClassType.BASE_CLASS;
    }

    public String toString() {
        return ClassId.VALUES[this._classId].toString() + " " + this._level;
    }

    public int getMaxLevel() {
        return this._maxLvl;
    }

    public void setIndex(int i) {
        this._index = i;
    }

    public int getIndex() {
        return this._index;
    }
}

