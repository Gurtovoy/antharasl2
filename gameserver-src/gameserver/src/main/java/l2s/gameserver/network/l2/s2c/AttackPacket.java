/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AttackPacket
extends L2GameServerPacket {
    public static final int HITFLAG_MISS = 1;
    public static final int HITFLAG_SHLD = 2;
    public static final int HITFLAG_CRIT = 4;
    public static final int HITFLAG_USESS = 8;
    public final int _attackerId;
    public final boolean _soulshot;
    private final int _grade;
    private final int _x;
    private final int _y;
    private final int _z;
    private final int _tx;
    private final int _ty;
    private final int _tz;
    private Hit[] hits;
    private final int _addShotEffect;

    public AttackPacket(Creature attacker, Creature target, boolean ss, int grade) {
        this._attackerId = attacker.getObjectId();
        this._soulshot = ss;
        this._grade = grade;
        this._addShotEffect = attacker.getAdditionalVisualSSEffect();
        this._x = attacker.getX();
        this._y = attacker.getY();
        this._z = attacker.getZ();
        this._tx = target.getX();
        this._ty = target.getY();
        this._tz = target.getZ();
        this.hits = new Hit[0];
    }

    public void addHit(GameObject target, int damage, boolean miss, boolean crit, boolean shld) {
        int pos = this.hits.length;
        Hit[] tmp = new Hit[pos + 1];
        System.arraycopy(this.hits, 0, tmp, 0, this.hits.length);
        tmp[pos] = new Hit(target, damage, miss, crit, shld);
        this.hits = tmp;
    }

    public boolean hasHits() {
        return this.hits.length > 0;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._attackerId);
        this.writeD(this.hits[0]._targetId);
        this.writeD(this._soulshot ? this._addShotEffect : 0);
        this.writeD(this.hits[0]._damage);
        this.writeD(this.hits[0]._flags);
        this.writeD(this._soulshot ? this._grade : 0);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
        this.writeH(this.hits.length - 1);
        for (int i = 1; i < this.hits.length; ++i) {
            this.writeD(this.hits[i]._targetId);
            this.writeD(this.hits[i]._damage);
            this.writeD(this.hits[i]._flags);
            this.writeD(this._soulshot ? this._grade : 0);
        }
        this.writeD(this._tx);
        this.writeD(this._ty);
        this.writeD(this._tz);
    }

    private class Hit {
        int _targetId;
        int _damage;
        int _flags;

        Hit(GameObject target, int damage, boolean miss, boolean crit, boolean shld) {
            this._targetId = target.getObjectId();
            this._damage = damage;
            if (miss) {
                this._flags = 1;
                return;
            }
            if (AttackPacket.this._soulshot) {
                this._flags = 8;
            }
            if (crit) {
                this._flags |= 4;
            }
            if (shld) {
                this._flags |= 2;
            }
        }
    }
}

