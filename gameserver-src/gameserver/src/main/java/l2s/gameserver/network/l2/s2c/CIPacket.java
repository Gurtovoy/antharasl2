/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Iterator;
import java.util.Set;
import l2s.gameserver.Config;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.instances.DecoyInstance;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.skills.AbnormalEffect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CIPacket
extends L2GameServerPacket {
    private static final Logger _log = LoggerFactory.getLogger(CIPacket.class);
    private boolean _canWrite = false;
    private int[][] _inv;
    private int _mAtkSpd;
    private int _pAtkSpd;
    private int _runSpd;
    private int _walkSpd;
    private int _swimRunSpd;
    private int _swimWalkSpd;
    private int _flRunSpd;
    private int _flWalkSpd;
    private int _flyRunSpd;
    private int _flyWalkSpd;
    private Location _loc;
    private Location _fishLoc;
    private String _name;
    private String _title;
    private int _objId;
    private int _race;
    private int _sex;
    private int base_class;
    private int pvp_flag;
    private int karma;
    private int rec_have;
    private double speed_move;
    private double speed_atack;
    private double col_radius;
    private double col_height;
    private int hair_style;
    private int hair_color;
    private int face;
    private int clan_id;
    private int clan_crest_id;
    private int large_clan_crest_id;
    private int ally_id;
    private int ally_crest_id;
    private int class_id;
    private int _sit;
    private int _run;
    private int _combat;
    private int _dead;
    private int private_store;
    private int _enchant;
    private int _hero;
    private int _fishing;
    private int mount_type;
    private int plg_class;
    private int pledge_type;
    private int clan_rep_score;
    private int cw_level;
    private int mount_id;
    private int _nameColor;
    private int _title_color;
    private int _transform;
    private int _agathion;
    private Cubic[] cubics;
    private boolean _isPartyRoomLeader;
    private boolean _isFlying;
    private int _curHp;
    private int _maxHp;
    private int _curMp;
    private int _maxMp;
    private int _curCp;
    private TeamType _team;
    private Set<AbnormalEffect> _abnormalEffects;
    private boolean _showHeadAccessories;
    private int _armorSetEnchant;
    public static final int[] PAPERDOLL_ORDER = new int[]{0, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};

    public CIPacket(Player cha, Player receiver) {
        this((Creature)cha, receiver);
    }

    public CIPacket(DecoyInstance cha, Player receiver) {
        this((Creature)cha, receiver);
    }

    public CIPacket(Creature cha, Player receiver) {
        if (cha == null) {
            System.out.println("CIPacket: cha is null!");
            Thread.dumpStack();
            return;
        }
        if (receiver == null) {
            return;
        }
        if (cha.isInvisible(receiver)) {
            return;
        }
        if (cha.isDeleted()) {
            return;
        }
        this._objId = cha.getObjectId();
        if (this._objId == 0) {
            return;
        }
        if (receiver.getObjectId() == this._objId) {
            _log.error("You cant send CIPacket about his character to active user!!!");
            return;
        }
        Player player = cha.getPlayer();
        if (player == null) {
            return;
        }
        if (player.isInBoat()) {
            this._loc = player.getInBoatPosition();
        }
        if (this._loc == null) {
            this._loc = cha.getLoc();
        }
        if (this._loc == null) {
            return;
        }
        this._name = player.getVisibleName(receiver);
        this._nameColor = player.getVisibleNameColor(receiver);
        if (player.isConnected() || player.isInOfflineMode() || player.isFakePlayer() || player.getPrivateStoreType() > 0 || (player.getAccountName() != null && player.getAccountName().startsWith("#"))) {
            this._title = player.getVisibleTitle(receiver);
            this._title_color = player.getVisibleTitleColor(receiver);
        } else {
            this._title = "NO CARRIER";
            this._title_color = 255;
        }
        if (player.isPledgeVisible(receiver)) {
            Clan clan = player.getClan();
            Alliance alliance = clan == null ? null : clan.getAlliance();
            this.clan_id = clan == null ? 0 : clan.getClanId();
            this.clan_crest_id = clan == null ? 0 : clan.getCrestId();
            this.large_clan_crest_id = clan == null ? 0 : clan.getCrestLargeId();
            this.ally_id = alliance == null ? 0 : alliance.getAllyId();
            int n = this.ally_crest_id = alliance == null ? 0 : alliance.getAllyCrestId();
        }
        if (player.isMounted()) {
            this._enchant = 0;
            this.mount_id = player.getMountNpcId() + 1000000;
            this.mount_type = player.getMountType().ordinal();
        } else {
            this._enchant = player.getEnchantEffect();
            this.mount_id = 0;
            this.mount_type = 0;
        }
        this._inv = new int[38][4];
        for (int PAPERDOLL_ID : PAPERDOLL_ORDER) {
            this._inv[PAPERDOLL_ID][0] = player.getInventory().getPaperdollItemId(PAPERDOLL_ID);
            this._inv[PAPERDOLL_ID][1] = player.getInventory().getPaperdollVariation1Id(PAPERDOLL_ID);
            this._inv[PAPERDOLL_ID][2] = player.getInventory().getPaperdollVariation2Id(PAPERDOLL_ID);
            this._inv[PAPERDOLL_ID][3] = player.getInventory().getPaperdollVisualId(PAPERDOLL_ID);
        }
        this._mAtkSpd = player.getMAtkSpd();
        this._pAtkSpd = player.getPAtkSpd();
        this.speed_move = player.getMovementSpeedMultiplier();
        this._runSpd = (int)((double)player.getRunSpeed() / this.speed_move);
        this._walkSpd = (int)((double)player.getWalkSpeed() / this.speed_move);
        this._flRunSpd = 0;
        this._flWalkSpd = 0;
        if (player.isFlying()) {
            this._flyRunSpd = this._runSpd;
            this._flyWalkSpd = this._walkSpd;
        } else {
            this._flyRunSpd = 0;
            this._flyWalkSpd = 0;
        }
        this._swimRunSpd = player.getSwimRunSpeed();
        this._swimWalkSpd = player.getSwimWalkSpeed();
        this._race = player.getRace().ordinal();
        this._sex = player.getSex().ordinal();
        this.base_class = player.getBaseClassId();
        this.pvp_flag = player.getPvpFlag();
        this.karma = player.getKarma();
        this.speed_atack = player.getAttackSpeedMultiplier();
        this.col_radius = player.getCurrentCollisionRadius();
        this.col_height = player.getCurrentCollisionHeight();
        this.hair_style = player.getInventory().getPaperdollItemId(15) > 0 ? this._sex : (player.getBeautyHairStyle() > 0 ? player.getBeautyHairStyle() : player.getHairStyle());
        this.hair_color = player.getBeautyHairColor() > 0 ? player.getBeautyHairColor() : player.getHairColor();
        this.face = player.getBeautyFace() > 0 ? player.getBeautyFace() : player.getFace();
        this.clan_rep_score = this.clan_id > 0 && player.getClan() != null ? player.getClan().getReputationScore() : 0;
        this._sit = player.isSitting() ? 0 : 1;
        this._run = player.isRunning() ? 1 : 0;
        this._combat = player.isInCombat() ? 1 : 0;
        int n = this._dead = player.isAlikeDead() ? 1 : 0;
        this.private_store = player.isInObserverMode() ? 7 : (player.isInBuffStore() ? 0 : player.getPrivateStoreType());
        this.cubics = player.getCubics().toArray(new Cubic[player.getCubics().size()]);
        this._abnormalEffects = player.getAbnormalEffects();
        this.rec_have = player.isGM() ? 0 : player.getRecomHave();
        this.class_id = player.getClassId().getId();
        this._team = player.getTeam();
        this._hero = player.isHero() || player.isGM() && Config.GM_HERO_AURA ? 1 : 0;
        this._fishing = player.getFishing().isInProcess() ? 1 : 0;
        this._fishLoc = player.getFishing().getHookLocation();
        this.plg_class = player.getPledgeRank().ordinal();
        this.pledge_type = player.getPledgeType();
        this._transform = player.getVisualTransformId();
        this._agathion = player.getAgathionNpcId();
        this._isPartyRoomLeader = player.getMatchingRoom() != null && player.getMatchingRoom().getType() == MatchingRoom.PARTY_MATCHING && player.getMatchingRoom().getLeader() == player;
        this._isFlying = player.isInFlyingTransform();
        this._curHp = receiver.canReceiveStatusUpdate(player, StatusUpdatePacket.UpdateType.DEFAULT, 9) ? (int)player.getCurrentHp() : (int)player.getCurrentHpPercents();
        this._maxHp = receiver.canReceiveStatusUpdate(player, StatusUpdatePacket.UpdateType.DEFAULT, 10) ? player.getMaxHp() : 100;
        this._curMp = receiver.canReceiveStatusUpdate(player, StatusUpdatePacket.UpdateType.DEFAULT, 11) ? (int)player.getCurrentMp() : (int)player.getCurrentMpPercents();
        this._maxMp = receiver.canReceiveStatusUpdate(player, StatusUpdatePacket.UpdateType.DEFAULT, 12) ? player.getMaxMp() : 100;
        this._curCp = receiver.canReceiveStatusUpdate(player, StatusUpdatePacket.UpdateType.DEFAULT, 33) ? (int)player.getCurrentCp() : (int)player.getCurrentCpPercents();
        this._showHeadAccessories = !player.hideHeadAccessories();
        this._armorSetEnchant = player.getArmorSetEnchant();
        this._canWrite = true;
    }

    @Override
    protected boolean canWrite() {
        return this._canWrite;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(0);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
        this.writeD(0);
        this.writeD(this._objId);
        this.writeS(this._name);
        this.writeH(this._race);
        this.writeC(this._sex);
        this.writeD(this.base_class);
        for (int PAPERDOLL_ID : PAPERDOLL_ORDER) {
            this.writeD(this._inv[PAPERDOLL_ID][0]);
        }
        this.writeD(this._inv[7][1]);
        this.writeD(this._inv[7][2]);
        this.writeD(this._inv[8][1]);
        this.writeD(this._inv[8][2]);
        this.writeD(this._inv[14][1]);
        this.writeD(this._inv[14][2]);
        this.writeC(this._armorSetEnchant);
        this.writeD(this._inv[7][3]);
        this.writeD(this._inv[8][3]);
        this.writeD(this._inv[14][3]);
        this.writeD(this._inv[9][3]);
        this.writeD(this._inv[10][3]);
        this.writeD(this._inv[11][3]);
        this.writeD(this._inv[12][3]);
        this.writeD(this._inv[15][3]);
        this.writeD(this._inv[16][3]);
        this.writeC(this.pvp_flag);
        this.writeD(this.karma);
        this.writeD(this._mAtkSpd);
        this.writeD(this._pAtkSpd);
        this.writeH(this._runSpd);
        this.writeH(this._walkSpd);
        this.writeH(this._swimRunSpd);
        this.writeH(this._swimWalkSpd);
        this.writeH(this._flRunSpd);
        this.writeH(this._flWalkSpd);
        this.writeH(this._flyRunSpd);
        this.writeH(this._flyWalkSpd);
        this.writeF(this.speed_move);
        this.writeF(this.speed_atack);
        this.writeF(this.col_radius);
        this.writeF(this.col_height);
        this.writeD(this.hair_style);
        this.writeD(this.hair_color);
        this.writeD(this.face);
        this.writeS(this._title);
        this.writeD(this.clan_id);
        this.writeD(this.clan_crest_id);
        this.writeD(this.ally_id);
        this.writeD(this.ally_crest_id);
        this.writeC(this._sit);
        this.writeC(this._run);
        this.writeC(this._combat);
        this.writeC(this._dead);
        this.writeC(0);
        this.writeC(this.mount_type);
        this.writeC(this.private_store);
        this.writeH(this.cubics.length);
        for (Cubic cubic : this.cubics) {
            this.writeH(cubic == null ? 0 : cubic.getId());
        }
        this.writeC(this._isPartyRoomLeader ? 1 : 0);
        this.writeC(this._isFlying ? 2 : 0);
        this.writeH(this.rec_have);
        this.writeD(this.mount_id);
        this.writeD(this.class_id);
        this.writeD(0);
        this.writeC(this._enchant);
        this.writeC(this._team.ordinal());
        this.writeD(this.large_clan_crest_id);
        this.writeC(0);
        this.writeC(this._hero);
        this.writeC(this._fishing);
        this.writeD(this._fishLoc.x);
        this.writeD(this._fishLoc.y);
        this.writeD(this._fishLoc.z);
        this.writeD(this._nameColor);
        this.writeD(this._loc.h);
        this.writeC(this.plg_class);
        this.writeH(this.pledge_type);
        this.writeD(this._title_color);
        this.writeC(0);
        this.writeD(this.clan_rep_score);
        this.writeD(this._transform);
        this.writeD(this._agathion);
        this.writeC(1);
        this.writeD(this._curCp);
        this.writeD(this._curHp);
        this.writeD(this._maxHp);
        this.writeD(this._curMp);
        this.writeD(this._maxMp);
        this.writeC(0);
        this.writeD(this._abnormalEffects.size());
        Iterator<AbnormalEffect> object = this._abnormalEffects.iterator();
        while (object.hasNext()) {
            AbnormalEffect abnormal = object.next();
            this.writeH(abnormal.getId());
        }
        this.writeC(0);
        this.writeC(this._showHeadAccessories);
        this.writeC(0);
    }
}

