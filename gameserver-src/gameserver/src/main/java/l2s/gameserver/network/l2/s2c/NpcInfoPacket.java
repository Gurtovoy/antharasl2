/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.AbstractMaskPacket;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.network.l2.s2c.updatetype.NpcInfoType;
import l2s.gameserver.skills.AbnormalEffect;

public class NpcInfoPacket
extends AbstractMaskPacket<NpcInfoType> {
    private static final int IS_IN_COMBAT = 1;
    private static final int IS_ALIKE_DEAD = 2;
    private static final int IS_TARGETABLE = 4;
    private static final int IS_SHOW_NAME = 8;
    private final byte[] _masks = new byte[]{0, 12, 12, 0, 0};
    private final Creature _creature;
    private final int _npcId;
    private final boolean _isAttackable;
    private final int _rHand;
    private final int _lHand;
    private final String _name;
    private final String _title;
    private final int _state;
    private final NpcString _nameNpcString;
    private final NpcString _titleNpcString;
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

    public NpcInfoPacket(NpcInstance npc, Creature attacker) {
        this._creature = npc;
        this._name = npc.getVisibleName(attacker.getPlayer());
        this._title = npc.getVisibleTitle(attacker.getPlayer());
        this._npcId = npc.getDisplayId() != 0 ? npc.getDisplayId() : npc.getNpcId();
        this._isAttackable = !npc.isAlikeDead() && npc.isAutoAttackable(attacker);
        this._rHand = npc.getRightHandItem();
        this._lHand = npc.getLeftHandItem();
        this._showSpawnAnimation = npc.getSpawnAnimation();
        this._state = npc.getNpcState();
        NpcString nameNpcString = npc.getNameNpcString();
        this._nameNpcString = nameNpcString != null ? nameNpcString : NpcString.NONE;
        NpcString titleNpcString = npc.getTitleNpcString();
        NpcString npcString = this._titleNpcString = titleNpcString != null ? titleNpcString : NpcString.NONE;
        if (npc.isTargetable(attacker)) {
            this._statusMask |= 4;
        }
        if (npc.isShowName()) {
            this._statusMask |= 8;
        }
        this.common(attacker.getPlayer());
    }

    public NpcInfoPacket(Servitor servitor, Creature attacker) {
        this._creature = servitor;
        this._name = servitor.getVisibleName(attacker.getPlayer());
        this._title = servitor.getVisibleTitle(attacker.getPlayer());
        this._npcId = servitor.getDisplayId() != 0 ? servitor.getDisplayId() : servitor.getNpcId();
        this._isAttackable = servitor.isAutoAttackable(attacker);
        this._rHand = servitor.getTemplate().rhand;
        this._lHand = servitor.getTemplate().lhand;
        this._showSpawnAnimation = servitor.getSpawnAnimation();
        this._state = servitor.getNpcState();
        this._nameNpcString = NpcString.NONE;
        this._titleNpcString = NpcString.NONE;
        if (servitor.isTargetable(attacker)) {
            this._statusMask |= 4;
        }
        if (servitor.isShowName()) {
            this._statusMask |= 8;
        }
        this.common(attacker.getPlayer());
    }

    private void common(Player attacker) {
        this._npcObjId = this._creature.getObjectId();
        this._loc = this._creature.getLoc();
        this._pAtkSpd = this._creature.getPAtkSpd();
        this._mAtkSpd = this._creature.getMAtkSpd();
        this._atkSpdMul = this._creature.getAttackSpeedMultiplier();
        this._runSpdMul = this._creature.getMovementSpeedMultiplier();
        this._pvpFlag = this._creature.getPvpFlag();
        this._karma = this._creature.getKarma();
        this._alive = !this._creature.isAlikeDead();
        this._running = this._creature.isRunning();
        this._flying = this._creature.isFlying();
        this._inWater = this._creature.isInWater();
        this._team = this._creature.getTeam();
        this._currentHP = attacker != null && attacker.canReceiveStatusUpdate(this._creature, StatusUpdatePacket.UpdateType.DEFAULT, 9) ? (int)this._creature.getCurrentHp() : (int)this._creature.getCurrentHpPercents();
        this._currentMP = attacker != null && attacker.canReceiveStatusUpdate(this._creature, StatusUpdatePacket.UpdateType.DEFAULT, 11) ? (int)this._creature.getCurrentMp() : (int)this._creature.getCurrentMpPercents();
        this._maxHP = attacker != null && attacker.canReceiveStatusUpdate(this._creature, StatusUpdatePacket.UpdateType.DEFAULT, 10) ? this._creature.getMaxHp() : 100;
        this._maxMP = attacker != null && attacker.canReceiveStatusUpdate(this._creature, StatusUpdatePacket.UpdateType.DEFAULT, 12) ? this._creature.getMaxMp() : 100;
        this._enchantEffect = this._creature.getEnchantEffect();
        this._transformId = this._creature.getVisualTransformId();
        this._abnormalEffects = this._creature.getAbnormalEffectsArray();
        Clan clan = this._creature.getClan();
        Alliance alliance = clan == null ? null : clan.getAlliance();
        this._clanId = clan == null ? 0 : clan.getClanId();
        this._clanCrestId = clan == null ? 0 : clan.getCrestId();
        this._largeClanCrestId = clan == null ? 0 : clan.getCrestLargeId();
        this._allyId = alliance == null ? 0 : alliance.getAllyId();
        this._allyCrestId = alliance == null ? 0 : alliance.getAllyCrestId();
    }

    public NpcInfoPacket init() {
        this.addComponentType(new NpcInfoType[]{NpcInfoType.ATTACKABLE, NpcInfoType.UNKNOWN1, NpcInfoType.ID, NpcInfoType.POSITION, NpcInfoType.ALIVE, NpcInfoType.RUNNING});
        if (this._name != "") {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.NAME});
        }
        if (this._title != "") {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.TITLE});
        }
        if (this._loc.h > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.HEADING});
        }
        if (this._pAtkSpd > 0 || this._mAtkSpd > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.ATK_CAST_SPEED});
        }
        if (this._running && this._creature.getRunSpeed() > 0 || !this._running && this._creature.getWalkSpeed() > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.SPEED_MULTIPLIER});
        }
        if (this._rHand > 0 || this._lHand > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.EQUIPPED});
        }
        if (this._team != TeamType.NONE) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.TEAM});
        }
        if (this._state > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.DISPLAY_EFFECT});
        }
        if (this._inWater || this._flying) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.SWIM_OR_FLY});
        }
        if (this._flying) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.FLYING});
        }
        if (this._maxHP > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.MAX_HP});
        }
        if (this._maxMP > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.MAX_MP});
        }
        if (this._currentHP <= this._maxHP) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.CURRENT_HP});
        }
        if (this._currentMP <= this._maxMP) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.CURRENT_MP});
        }
        if (this._abnormalEffects.length > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.ABNORMALS});
        }
        if (this._enchantEffect > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.ENCHANT});
        }
        if (this._transformId > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.TRANSFORMATION});
        }
        if (this._clanId > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.CLAN});
        }
        this.addComponentType(new NpcInfoType[]{NpcInfoType.UNKNOWN8});
        if (this._creature.getPvpFlag() > 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.PVP_FLAG});
        }
        if (this._creature.getKarma() != 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.REPUTATION});
        }
        if (this._creature.isInCombat()) {
            this._statusMask |= 1;
        }
        if (this._creature.isAlikeDead()) {
            this._statusMask |= 2;
        }
        if (this._statusMask != 0) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.VISUAL_STATE});
        }
        if (this._nameNpcString != NpcString.NONE) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.NAME_NPCSTRINGID});
        }
        if (this._titleNpcString != NpcString.NONE) {
            this.addComponentType(new NpcInfoType[]{NpcInfoType.TITLE_NPCSTRINGID});
        }
        return this;
    }

    public NpcInfoPacket update(IUpdateTypeComponent ... components) {
        this._showSpawnAnimation = 1;
        this.addComponentType(new NpcInfoType[]{NpcInfoType.ATTACKABLE, NpcInfoType.UNKNOWN1, NpcInfoType.ID, NpcInfoType.POSITION, NpcInfoType.ALIVE, NpcInfoType.RUNNING});
        for (IUpdateTypeComponent component : components) {
            if (!(component instanceof NpcInfoType)) continue;
            this.addComponentType(new NpcInfoType[]{(NpcInfoType)component});
        }
        return this;
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
    protected void writeImpl() {
        this.writeD(this._npcObjId);
        this.writeC(this._showSpawnAnimation);
        this.writeH(37);
        this.writeB(this._masks);
        this.writeC(this._initSize);
        if (this.containsMask(NpcInfoType.ATTACKABLE)) {
            this.writeC(this._isAttackable);
        }
        if (this.containsMask(NpcInfoType.UNKNOWN1)) {
            this.writeD(0);
        }
        if (this.containsMask(NpcInfoType.TITLE)) {
            this.writeS(this._title);
        }
        this.writeH(this._blockSize);
        if (this.containsMask(NpcInfoType.ID)) {
            this.writeD(this._npcId + 1000000);
        }
        if (this.containsMask(NpcInfoType.POSITION)) {
            this.writeD(this._loc.x);
            this.writeD(this._loc.y);
            this.writeD(this._loc.z);
        }
        if (this.containsMask(NpcInfoType.HEADING)) {
            this.writeD(this._loc.h);
        }
        if (this.containsMask(NpcInfoType.UNKNOWN2)) {
            this.writeD(0);
        }
        if (this.containsMask(NpcInfoType.ATK_CAST_SPEED)) {
            this.writeD(this._pAtkSpd);
            this.writeD(this._mAtkSpd);
        }
        if (this.containsMask(NpcInfoType.SPEED_MULTIPLIER)) {
            this.writeCutF(this._runSpdMul);
            this.writeCutF(this._atkSpdMul);
        }
        if (this.containsMask(NpcInfoType.EQUIPPED)) {
            this.writeD(this._rHand);
            this.writeD(0);
            this.writeD(this._lHand);
        }
        if (this.containsMask(NpcInfoType.ALIVE)) {
            this.writeC(this._alive);
        }
        if (this.containsMask(NpcInfoType.RUNNING)) {
            this.writeC(this._running);
        }
        if (this.containsMask(NpcInfoType.SWIM_OR_FLY)) {
            this.writeC(this._inWater ? 1 : (this._flying ? 2 : 0));
        }
        if (this.containsMask(NpcInfoType.TEAM)) {
            this.writeC(this._team.ordinal());
        }
        if (this.containsMask(NpcInfoType.ENCHANT)) {
            this.writeD(this._enchantEffect);
        }
        if (this.containsMask(NpcInfoType.FLYING)) {
            this.writeD(this._flying);
        }
        if (this.containsMask(NpcInfoType.CLONE)) {
            this.writeD(0);
        }
        if (this.containsMask(NpcInfoType.UNKNOWN8)) {
            this.writeD(0);
        }
        if (this.containsMask(NpcInfoType.DISPLAY_EFFECT)) {
            this.writeD(this._state);
        }
        if (this.containsMask(NpcInfoType.TRANSFORMATION)) {
            this.writeD(this._transformId);
        }
        if (this.containsMask(NpcInfoType.CURRENT_HP)) {
            this.writeD(this._currentHP);
        }
        if (this.containsMask(NpcInfoType.CURRENT_MP)) {
            this.writeD(this._currentMP);
        }
        if (this.containsMask(NpcInfoType.MAX_HP)) {
            this.writeD(this._maxHP);
        }
        if (this.containsMask(NpcInfoType.MAX_MP)) {
            this.writeD(this._maxMP);
        }
        if (this.containsMask(NpcInfoType.SUMMONED)) {
            this.writeC(0);
        }
        if (this.containsMask(NpcInfoType.UNKNOWN12)) {
            this.writeD(0);
            this.writeD(0);
        }
        if (this.containsMask(NpcInfoType.NAME)) {
            this.writeS(this._name);
        }
        if (this.containsMask(NpcInfoType.NAME_NPCSTRINGID)) {
            this.writeD(this._nameNpcString.getId());
        }
        if (this.containsMask(NpcInfoType.TITLE_NPCSTRINGID)) {
            this.writeD(this._titleNpcString.getId());
        }
        if (this.containsMask(NpcInfoType.PVP_FLAG)) {
            this.writeC(this._pvpFlag);
        }
        if (this.containsMask(NpcInfoType.REPUTATION)) {
            this.writeD(this._karma);
        }
        if (this.containsMask(NpcInfoType.CLAN)) {
            this.writeD(this._clanId);
            this.writeD(this._clanCrestId);
            this.writeD(this._largeClanCrestId);
            this.writeD(this._allyId);
            this.writeD(this._allyCrestId);
        }
        if (this.containsMask(NpcInfoType.VISUAL_STATE)) {
            this.writeC(this._statusMask);
        }
        if (this.containsMask(NpcInfoType.ABNORMALS)) {
            this.writeH(this._abnormalEffects.length);
            for (AbnormalEffect abnormal : this._abnormalEffects) {
                this.writeH(abnormal.getId());
            }
        }
    }

    public static class PetInfoPacket
    extends NpcInfoPacket {
        public PetInfoPacket(PetInstance summon, Creature attacker) {
            super(summon, attacker);
        }
    }

    public static class SummonInfoPacket
    extends NpcInfoPacket {
        public SummonInfoPacket(SummonInstance summon, Creature attacker) {
            super(summon, attacker);
        }
    }
}

