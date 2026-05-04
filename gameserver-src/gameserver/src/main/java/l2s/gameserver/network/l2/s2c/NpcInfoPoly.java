package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.network.l2.ServerPacketOpcodes;
import l2s.gameserver.network.l2.s2c.AbstractMaskPacket;
import l2s.gameserver.network.l2.s2c.updatetype.NpcInfoType;
import l2s.gameserver.skills.AbnormalEffect;
import l2s.gameserver.templates.npc.NpcTemplate;

public class NpcInfoPoly
extends AbstractMaskPacket<NpcInfoType> {
    private static final int IS_IN_COMBAT = 1;
    private static final int IS_ALIKE_DEAD = 2;
    private static final int IS_TARGETABLE = 4;
    private static final int IS_SHOW_NAME = 8;
    private final byte[] _masks = new byte[]{0, 12, 12, 0, 0};
    private final int _npcId;
    private final boolean _isAttackable;
    private final int _rHand;
    private final int _lHand;
    private final String _name;
    private final String _title;
    private int _initSize = 0;
    private int _blockSize = 0;
    private int _statusMask = 0;
    private int _showSpawnAnimation;
    private int _npcObjId;
    private Location _loc;
    private int _pAtkSpd;
    private int _mAtkSpd;
    private double _atkSpdMul;
    private double _runSpdMul;
    private int _pvpFlag;
    private int _karma;
    private boolean _alive;
    private boolean _running;
    private boolean _flying;
    private boolean _inWater;
    private TeamType _team;
    private int _currentHP;
    private int _currentMP;
    private int _maxHP;
    private int _maxMP;
    private int _enchantEffect;
    private int _transformId;
    private AbnormalEffect[] _abnormalEffects;
    private int _clanId;
    private int _clanCrestId;
    private int _largeClanCrestId;
    private int _allyId;
    private int _allyCrestId;

    public NpcInfoPoly(Player player, Creature attacker) {
        NpcTemplate template = NpcHolder.getInstance().getTemplate(player.getPolyId());
        this._npcObjId = player.getObjectId();
        this._name = player.getVisibleName(attacker.getPlayer());
        this._title = player.getVisibleTitle(attacker.getPlayer());
        this._npcId = template.displayId != 0 ? template.displayId : template.getId();
        this._isAttackable = player.isAutoAttackable(attacker);
        this._loc = player.getLoc();
        this._rHand = template.rhand;
        this._lHand = template.lhand;
        this._mAtkSpd = player.getMAtkSpd();
        this._pAtkSpd = player.getPAtkSpd();
        this._atkSpdMul = player.getAttackSpeedMultiplier();
        this._runSpdMul = player.getMovementSpeedMultiplier();
        this._pvpFlag = player.getPvpFlag();
        this._karma = player.getKarma();
        this._alive = !player.isAlikeDead();
        this._running = player.isRunning();
        this._flying = player.isFlying();
        this._inWater = player.isInWater();
        this._team = player.getTeam();
        this._currentHP = (int)player.getCurrentHp();
        this._currentMP = (int)player.getCurrentMp();
        this._maxHP = player.getMaxHp();
        this._maxMP = player.getMaxMp();
        this._enchantEffect = player.getEnchantEffect();
        this._transformId = 0;
        this._abnormalEffects = player.getAbnormalEffectsArray();
        for (NpcInfoType component : NpcInfoType.VALUES) {
            this.addComponentType(new NpcInfoType[]{component});
        }
        if (player.isInCombat()) {
            this._statusMask |= 1;
        }
        if (player.isAlikeDead()) {
            this._statusMask |= 2;
        }
        if (player.isTargetable(attacker)) {
            this._statusMask |= 4;
        }
        this._statusMask |= 8;
    }

    @Override
    protected byte[] getMasks() {
        return this._masks;
    }

    @Override
    protected void onNewMaskAdded(NpcInfoType component) {
        switch (component) {
            case ATTACKABLE: 
            case UNKNOWN1: {
                this._initSize += component.getBlockLength();
                break;
            }
            case TITLE: {
                this._initSize += component.getBlockLength() + this._title.length() * 2;
                break;
            }
            case NAME: {
                this._blockSize += component.getBlockLength() + this._name.length() * 2;
                break;
            }
            default: {
                this._blockSize += component.getBlockLength();
            }
        }
    }

    @Override
    protected ServerPacketOpcodes getOpcodes() {
        return ServerPacketOpcodes.NpcInfoPacket;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._npcObjId);
        this.writeC(0);
        this.writeH(37);
        this.writeB(this._masks);
        this.writeC(this._initSize);
        this.writeC(this._isAttackable);
        this.writeD(0);
        this.writeS(this._title);
        this.writeH(this._blockSize);
        this.writeD(this._npcId + 1000000);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(this._loc.h);
        this.writeD(0);
        this.writeD(this._mAtkSpd);
        this.writeD(this._pAtkSpd);
        this.writeCutF(this._runSpdMul);
        this.writeCutF(this._atkSpdMul);
        this.writeD(this._rHand);
        this.writeD(0);
        this.writeD(this._lHand);
        this.writeC(this._alive);
        this.writeC(this._running);
        this.writeC(this._inWater ? 1 : (this._flying ? 2 : 0));
        this.writeC(this._team.ordinal());
        this.writeD(this._enchantEffect);
        this.writeD(this._flying);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(this._transformId);
        this.writeD(this._currentHP);
        this.writeD(this._currentMP);
        this.writeD(this._maxHP);
        this.writeD(this._maxMP);
        this.writeC(0);
        this.writeD(0);
        this.writeD(0);
        this.writeS(this._name);
        this.writeD(-1);
        this.writeD(-1);
        this.writeC(this._pvpFlag);
        this.writeD(this._karma);
        this.writeD(this._clanId);
        this.writeD(this._clanCrestId);
        this.writeD(this._largeClanCrestId);
        this.writeD(this._allyId);
        this.writeD(this._allyCrestId);
        this.writeC(this._statusMask);
        this.writeH(this._abnormalEffects.length);
        for (AbnormalEffect abnormal : this._abnormalEffects) {
            this.writeH(abnormal.getId());
        }
    }
}

