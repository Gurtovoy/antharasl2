package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.skills.AbnormalEffect;

public class MyPetSummonInfoPacket
extends L2GameServerPacket {
    private static final int IS_ATTACKABLE = 1;
    private static final int IS_UNK_FLAG_2 = 2;
    private static final int IS_RUNNING = 4;
    private static final int IS_IN_COMBAT = 8;
    private static final int IS_ALIKE_DEAD = 16;
    private static final int IS_RIDEABLE = 32;
    private int _runSpd;
    private int _walkSpd;
    private int MAtkSpd;
    private int PAtkSpd;
    private int pvp_flag;
    private int karma;
    private int _type;
    private int obj_id;
    private int npc_id;
    private int incombat;
    private int dead;
    private int _sp;
    private int level;
    private int curFed;
    private int maxFed;
    private int curHp;
    private int maxHp;
    private int curMp;
    private int maxMp;
    private int curLoad;
    private int maxLoad;
    private int PAtk;
    private int PDef;
    private int MAtk;
    private int MDef;
    private int sps;
    private int ss;
    private int type;
    private int _showSpawnAnimation;
    private int _pAccuracy;
    private int _pEvasion;
    private int _pCrit;
    private int _mAccuracy;
    private int _mEvasion;
    private int _mCrit;
    private Location _loc;
    private double col_redius;
    private double col_height;
    private long exp;
    private long exp_this_lvl;
    private long exp_next_lvl;
    private String _name;
    private String title;
    private TeamType _team;
    private double _atkSpdMul;
    private double _runSpdMul;
    private int _transformId;
    private AbnormalEffect[] _abnormalEffects;
    private int _rhand;
    private int _lhand;
    private int _flags;

    public MyPetSummonInfoPacket(Servitor summon) {
        this._type = summon.getServitorType();
        this.obj_id = summon.getObjectId();
        this.npc_id = summon.getNpcId();
        this._loc = summon.getLoc();
        this.MAtkSpd = summon.getMAtkSpd();
        this.PAtkSpd = summon.getPAtkSpd();
        this._runSpd = summon.getRunSpeed();
        this._walkSpd = summon.getWalkSpeed();
        this.col_redius = summon.getCurrentCollisionRadius();
        this.col_height = summon.getCurrentCollisionHeight();
        this.incombat = summon.isInCombat() ? 1 : 0;
        this.dead = summon.isAlikeDead() ? 1 : 0;
        this._name = summon.getVisibleName(summon.getPlayer());
        this.title = summon.getVisibleTitle(summon.getPlayer());
        this.pvp_flag = summon.getPvpFlag();
        this.karma = summon.getKarma();
        this.curFed = summon.getCurrentFed();
        this.maxFed = summon.getMaxFed();
        this.curHp = (int)summon.getCurrentHp();
        this.maxHp = summon.getMaxHp();
        this.curMp = (int)summon.getCurrentMp();
        this.maxMp = summon.getMaxMp();
        this._sp = summon.getSp();
        this.level = summon.getLevel();
        this.exp = summon.getExp();
        this.exp_this_lvl = summon.getExpForThisLevel();
        this.exp_next_lvl = summon.getExpForNextLevel();
        this.curLoad = summon.getCurrentLoad();
        this.maxLoad = summon.getMaxLoad();
        this.PAtk = summon.getPAtk(null);
        this.PDef = summon.getPDef(null);
        this.MAtk = summon.getMAtk(null, null);
        this.MDef = summon.getMDef(null, null);
        this._pAccuracy = summon.getPAccuracy();
        this._pEvasion = summon.getPEvasionRate(null);
        this._pCrit = summon.getPCriticalHit(null);
        this._mAccuracy = summon.getMAccuracy();
        this._mEvasion = summon.getMEvasionRate(null);
        this._mCrit = summon.getMCriticalHit(null, null);
        this._abnormalEffects = summon.getAbnormalEffectsArray();
        this._team = summon.getTeam();
        this.ss = summon.getSoulshotConsumeCount();
        this.sps = summon.getSpiritshotConsumeCount();
        this._showSpawnAnimation = summon.getSpawnAnimation();
        this.type = summon.getFormId();
        this._atkSpdMul = summon.getAttackSpeedMultiplier();
        this._runSpdMul = summon.getMovementSpeedMultiplier();
        this._transformId = summon.getVisualTransformId();
        boolean rideable = summon.isMountable();
        Player owner = summon.getPlayer();
        if (owner != null && owner.isTransformed()) {
            rideable = false;
        }
        this._rhand = summon.getTemplate().rhand;
        this._lhand = summon.getTemplate().lhand;
        if (summon.isAutoAttackable(summon.getPlayer())) {
            this._flags |= 1;
        }
        this._flags |= 2;
        if (summon.isRunning()) {
            this._flags |= 4;
        }
        if (summon.isInCombat()) {
            this._flags |= 8;
        }
        if (summon.isAlikeDead()) {
            this._flags |= 0x10;
        }
        if (rideable) {
            this._flags |= 0x20;
        }
    }

    public MyPetSummonInfoPacket update() {
        this._showSpawnAnimation = 1;
        return this;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        this.writeD(this.obj_id);
        this.writeD(this.npc_id + 1000000);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._loc.h);
        this.writeD(this.MAtkSpd);
        this.writeD(this.PAtkSpd);
        this.writeH(this._runSpd);
        this.writeH(this._walkSpd);
        this.writeH(this._runSpd);
        this.writeH(this._walkSpd);
        this.writeH(this._runSpd);
        this.writeH(this._walkSpd);
        this.writeH(this._runSpd);
        this.writeH(this._walkSpd);
        this.writeF(this._runSpdMul);
        this.writeF(this._atkSpdMul);
        this.writeF(this.col_redius);
        this.writeF(this.col_height);
        this.writeD(this._rhand);
        this.writeD(0);
        this.writeD(this._lhand);
        this.writeC(this._showSpawnAnimation);
        this.writeD(-1);
        this.writeS(this._name);
        this.writeD(-1);
        this.writeS(this.title);
        this.writeC(this.pvp_flag);
        this.writeD(this.karma);
        this.writeD(this.curFed);
        this.writeD(this.maxFed);
        this.writeD(this.curHp);
        this.writeD(this.maxHp);
        this.writeD(this.curMp);
        this.writeD(this.maxMp);
        this.writeQ(this._sp);
        this.writeC(this.level);
        this.writeQ(this.exp);
        this.writeQ(this.exp_this_lvl);
        this.writeQ(this.exp_next_lvl);
        this.writeD(this.curLoad);
        this.writeD(this.maxLoad);
        this.writeD(this.PAtk);
        this.writeD(this.PDef);
        this.writeD(this._pAccuracy);
        this.writeD(this._pEvasion);
        this.writeD(this._pCrit);
        this.writeD(this.MAtk);
        this.writeD(this.MDef);
        this.writeD(this._mAccuracy);
        this.writeD(this._mEvasion);
        this.writeD(this._mCrit);
        this.writeD(this._runSpd);
        this.writeD(this.PAtkSpd);
        this.writeD(this.MAtkSpd);
        this.writeC(0);
        this.writeC(this._team.ordinal());
        this.writeC(this.ss);
        this.writeC(this.sps);
        this.writeD(this.type);
        this.writeD(this._transformId);
        this.writeC(0);
        this.writeC(0);
        this.writeH(this._abnormalEffects.length);
        for (AbnormalEffect abnormal : this._abnormalEffects) {
            this.writeH(abnormal.getId());
        }
        this.writeC(this._flags);
    }
}

