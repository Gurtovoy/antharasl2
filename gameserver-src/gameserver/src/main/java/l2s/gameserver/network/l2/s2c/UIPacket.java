/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.AbstractMaskPacket;
import l2s.gameserver.network.l2.s2c.updatetype.UserInfoType;

public class UIPacket
extends AbstractMaskPacket<UserInfoType> {
    public static final int USER_RELATION_PARTY_MEMBER = 8;
    public static final int USER_RELATION_PARTY_LEADER = 16;
    public static final int USER_RELATION_CLAN_MEMBER = 32;
    public static final int USER_RELATION_CLAN_LEADER = 64;
    public static final int USER_RELATION_IN_SIEGE = 128;
    public static final int USER_RELATION_ATTACKER = 256;
    public static final int USER_RELATION_IN_DOMINION_WAR = 4096;
    private boolean _canWrite = false;
    private boolean partyRoom;
    private int _runSpd;
    private int _walkSpd;
    private int _swimRunSpd;
    private int _swimWalkSpd;
    private int _flRunSpd;
    private int _flWalkSpd;
    private int _flyRunSpd;
    private int _flyWalkSpd;
    private int _relation;
    private double move_speed;
    private double attack_speed;
    private double col_radius;
    private double col_height;
    private Location _loc;
    private int obj_id;
    private int vehicle_obj_id;
    private int _race;
    private int sex;
    private int base_class;
    private int level;
    private int curCp;
    private int maxCp;
    private int _weaponEnchant;
    private int _armorSetEnchant;
    private int _weaponFlag;
    private long _exp;
    private long _sp;
    private int curHp;
    private int maxHp;
    private int curMp;
    private int maxMp;
    private int curLoad;
    private int maxLoad;
    private int rec_left;
    private int rec_have;
    private int _str;
    private int _con;
    private int _dex;
    private int _int;
    private int _wit;
    private int _men;
    private int ClanPrivs;
    private int InventoryLimit;
    private int _patk;
    private int _patkspd;
    private int _pdef;
    private int _matk;
    private int _matkspd;
    private int _pEvasion;
    private int _pAccuracy;
    private int _pCrit;
    private int _mEvasion;
    private int _mAccuracy;
    private int _mCrit;
    private int _mdef;
    private int pvp_flag;
    private int karma;
    private int hair_style;
    private int hair_color;
    private int face;
    private int gm_commands;
    private int fame;
    private int clan_id;
    private int _isClanLeader;
    private int clan_crest_id;
    private int ally_id;
    private int ally_crest_id;
    private int large_clan_crest_id;
    private int private_store;
    private int can_crystalize;
    private int pk_kills;
    private int pvp_kills;
    private int class_id;
    private int agathion;
    private int _partySubstitute;
    private int hero;
    private int mount_id;
    private int name_color;
    private int running;
    private int pledge_class;
    private int pledge_type;
    private int title_color;
    private int defenceFire;
    private int defenceWater;
    private int defenceWind;
    private int defenceEarth;
    private int defenceHoly;
    private int defenceUnholy;
    private int mount_type;
    private String _name;
    private String _title;
    private Cubic[] cubics;
    private Element attackElement;
    private int attackElementValue;
    private int _moveType;
    private int talismans;
    private int _jewelsLimit;
    private boolean _activeMainAgathionSlot;
    private int _subAgathionsLimit;
    private double _expPercent;
    private TeamType _team;
    private final boolean _hideHeadAccessories;
    private final byte[] _masks = new byte[]{0, 0, 0};
    private int _initSize = 5;

    public UIPacket(Player player) {
        this(player, true);
    }

    public UIPacket(Player player, boolean addAll) {
        this._name = player.getVisibleName(player);
        this.name_color = player.getVisibleNameColor(player);
        this._title = player.getVisibleTitle(player);
        this.title_color = player.getVisibleTitleColor(player);
        if (player.isPledgeVisible(player)) {
            Clan clan = player.getClan();
            Alliance alliance = clan == null ? null : clan.getAlliance();
            this.clan_id = clan == null ? 0 : clan.getClanId();
            this._isClanLeader = player.isClanLeader() ? 1 : 0;
            this.clan_crest_id = clan == null ? 0 : clan.getCrestId();
            this.large_clan_crest_id = clan == null ? 0 : clan.getCrestLargeId();
            this.ally_id = alliance == null ? 0 : alliance.getAllyId();
            int n = this.ally_crest_id = alliance == null ? 0 : alliance.getAllyCrestId();
        }
        if (player.isGMInvisible()) {
            this._title = this._title + "[I]";
        }
        if (player.isPolymorphed()) {
            this._title = NpcHolder.getInstance().getTemplate(player.getPolyId()) != null ? this._title + "[" + NpcHolder.getInstance().getTemplate((int)player.getPolyId()).name + "]" : this._title + "[Polymorphed]";
        }
        if (player.isMounted()) {
            this._weaponEnchant = 0;
            this.mount_id = player.getMountNpcId() + 1000000;
            this.mount_type = player.getMountType().ordinal();
        } else {
            this._weaponEnchant = player.getEnchantEffect();
            this.mount_id = 0;
            this.mount_type = 0;
        }
        this._weaponFlag = player.getActiveWeaponInstance() == null ? 20 : 40;
        this.move_speed = player.getMovementSpeedMultiplier();
        this._runSpd = (int)((double)player.getRunSpeed() / this.move_speed);
        this._walkSpd = (int)((double)player.getWalkSpeed() / this.move_speed);
        this._flRunSpd = 0;
        this._flWalkSpd = 0;
        if (player.isFlying()) {
            this._flyRunSpd = this._runSpd;
            this._flyWalkSpd = this._walkSpd;
        } else {
            this._flyRunSpd = 0;
            this._flyWalkSpd = 0;
        }
        this._swimRunSpd = (int)((double)player.getSwimRunSpeed() / this.move_speed);
        this._swimWalkSpd = (int)((double)player.getSwimWalkSpeed() / this.move_speed);
        Party party = player.getParty();
        if (party != null) {
            this._relation |= 8;
            if (party.isLeader(player)) {
                this._relation |= 0x10;
            }
        }
        if (player.getClan() != null) {
            this._relation |= 0x20;
            if (player.isClanLeader()) {
                this._relation |= 0x40;
            }
        }
        for (Event e : player.getEvents()) {
            this._relation = e.getUserRelation(player, this._relation);
        }
        this._loc = player.getLoc();
        this.obj_id = player.getObjectId();
        this.vehicle_obj_id = player.isInBoat() ? player.getBoat().getBoatId() : 0;
        this._race = player.getRace().ordinal();
        this.sex = player.getSex().ordinal();
        this.base_class = ClassId.VALUES[player.getBaseClassId()].getFirstParent(this.sex).getId();
        this.level = player.getLevel();
        this._exp = player.getExp();
        this._expPercent = Experience.getExpPercent(player.getLevel(), player.getExp());
        this._str = player.getSTR();
        this._dex = player.getDEX();
        this._con = player.getCON();
        this._int = player.getINT();
        this._wit = player.getWIT();
        this._men = player.getMEN();
        this.curHp = (int)player.getCurrentHp();
        this.maxHp = player.getMaxHp();
        this.curMp = (int)player.getCurrentMp();
        this.maxMp = player.getMaxMp();
        this.curLoad = player.getCurrentLoad();
        this.maxLoad = player.getMaxLoad();
        this._sp = player.getSp();
        this._patk = player.getPAtk(null);
        this._patkspd = player.getPAtkSpd();
        this._pdef = player.getPDef(null);
        this._pEvasion = player.getPEvasionRate(null);
        this._pAccuracy = player.getPAccuracy();
        this._pCrit = player.getPCriticalHit(null);
        this._mEvasion = player.getMEvasionRate(null);
        this._mAccuracy = player.getMAccuracy();
        this._mCrit = player.getMCriticalHit(null, null);
        this._matk = player.getMAtk(null, null);
        this._matkspd = player.getMAtkSpd();
        this._mdef = player.getMDef(null, null);
        this.pvp_flag = player.getPvpFlag();
        this.karma = player.getKarma();
        this.attack_speed = player.getAttackSpeedMultiplier();
        this.col_radius = player.getCurrentCollisionRadius();
        this.col_height = player.getCurrentCollisionHeight();
        this.hair_style = player.getInventory().getPaperdollItemId(15) > 0 ? this.sex : (player.getBeautyHairStyle() > 0 ? player.getBeautyHairStyle() : player.getHairStyle());
        this.hair_color = player.getBeautyHairColor() > 0 ? player.getBeautyHairColor() : player.getHairColor();
        this.face = player.getBeautyFace() > 0 ? player.getBeautyFace() : player.getFace();
        this.gm_commands = player.isGM() || player.getPlayerAccess().CanUseAltG ? 1 : 0;
        this.clan_id = player.getClanId();
        this.ally_id = player.getAllyId();
        this.private_store = player.isInBuffStore() ? 0 : player.getPrivateStoreType();
        this.can_crystalize = player.getSkillLevel(248) > 0 ? 1 : 0;
        this.pk_kills = player.getPkKills();
        this.pvp_kills = player.getPvpKills();
        this.cubics = player.getCubics().toArray(new Cubic[player.getCubics().size()]);
        this.ClanPrivs = player.getClanPrivileges();
        this.rec_left = player.getRecomLeft();
        this.rec_have = player.getRecomHave();
        this.InventoryLimit = player.getInventoryLimit();
        this.class_id = player.getClassId().getId();
        this.maxCp = player.getMaxCp();
        this.curCp = (int)player.getCurrentCp();
        this._team = player.getTeam();
        this.hero = player.isHero() || player.isGM() && Config.GM_HERO_AURA ? 1 : 0;
        this.running = player.isRunning() ? 1 : 0;
        this.pledge_class = player.getPledgeRank().ordinal();
        this.pledge_type = player.getPledgeType();
        this.attackElement = player.getAttackElement();
        this.attackElementValue = player.getAttack(this.attackElement);
        this.defenceFire = player.getDefence(Element.FIRE);
        this.defenceWater = player.getDefence(Element.WATER);
        this.defenceWind = player.getDefence(Element.WIND);
        this.defenceEarth = player.getDefence(Element.EARTH);
        this.defenceHoly = player.getDefence(Element.HOLY);
        this.defenceUnholy = player.getDefence(Element.UNHOLY);
        this.agathion = player.getAgathionNpcId();
        this.fame = player.getFame();
        boolean bl = this.partyRoom = player.getMatchingRoom() != null && player.getMatchingRoom().getType() == MatchingRoom.PARTY_MATCHING && player.getMatchingRoom().getLeader() == player;
        this._moveType = player.isInFlyingTransform() ? 2 : (player.isInWater() ? 1 : 0);
        this.talismans = player.getTalismanCount();
        this._jewelsLimit = player.getJewelsLimit();
        this._activeMainAgathionSlot = player.isActiveMainAgathionSlot();
        this._subAgathionsLimit = player.getSubAgathionsLimit();
        this._partySubstitute = player.isPartySubstituteStarted() ? 1 : 0;
        this._hideHeadAccessories = player.hideHeadAccessories();
        this._armorSetEnchant = player.getArmorSetEnchant();
        this._canWrite = true;
        if (addAll) {
            this.addComponentType(UserInfoType.values());
        }
    }

    @Override
    protected byte[] getMasks() {
        return this._masks;
    }

    @Override
    protected void onNewMaskAdded(UserInfoType component) {
        this.calcBlockSize(component);
    }

    private void calcBlockSize(UserInfoType type) {
        switch (type) {
            case BASIC_INFO: {
                this._initSize += type.getBlockLength() + this._name.length() * 2;
                break;
            }
            case CLAN: {
                this._initSize += type.getBlockLength() + this._title.length() * 2;
                break;
            }
            default: {
                this._initSize += type.getBlockLength();
            }
        }
    }

    @Override
    protected boolean canWrite() {
        return this._canWrite;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.obj_id);
        this.writeD(this._initSize);
        this.writeH(23);
        this.writeB(this._masks);
        if (this.containsMask(UserInfoType.RELATION)) {
            this.writeD(this._relation);
        }
        if (this.containsMask(UserInfoType.BASIC_INFO)) {
            this.writeH(UserInfoType.BASIC_INFO.getBlockLength() + this._name.length() * 2);
            this.writeString(this._name);
            this.writeC(this.gm_commands);
            this.writeC(this._race);
            this.writeC(this.sex);
            this.writeD(this.base_class);
            this.writeD(this.class_id);
            this.writeC(this.level);
        }
        if (this.containsMask(UserInfoType.BASE_STATS)) {
            this.writeH(UserInfoType.BASE_STATS.getBlockLength());
            this.writeH(this._str);
            this.writeH(this._dex);
            this.writeH(this._con);
            this.writeH(this._int);
            this.writeH(this._wit);
            this.writeH(this._men);
            this.writeH(0);
            this.writeH(0);
        }
        if (this.containsMask(UserInfoType.MAX_HPCPMP)) {
            this.writeH(UserInfoType.MAX_HPCPMP.getBlockLength());
            this.writeD(this.maxHp);
            this.writeD(this.maxMp);
            this.writeD(this.maxCp);
        }
        if (this.containsMask(UserInfoType.CURRENT_HPMPCP_EXP_SP)) {
            this.writeH(UserInfoType.CURRENT_HPMPCP_EXP_SP.getBlockLength());
            this.writeD(this.curHp);
            this.writeD(this.curMp);
            this.writeD(this.curCp);
            this.writeQ(this._sp);
            this.writeQ(this._exp);
            this.writeF(this._expPercent);
        }
        if (this.containsMask(UserInfoType.ENCHANTLEVEL)) {
            this.writeH(UserInfoType.ENCHANTLEVEL.getBlockLength());
            this.writeC(this._weaponEnchant);
            this.writeC(this._armorSetEnchant);
        }
        if (this.containsMask(UserInfoType.APPAREANCE)) {
            this.writeH(UserInfoType.APPAREANCE.getBlockLength());
            this.writeD(this.hair_style);
            this.writeD(this.hair_color);
            this.writeD(this.face);
            this.writeC(!this._hideHeadAccessories);
        }
        if (this.containsMask(UserInfoType.STATUS)) {
            this.writeH(UserInfoType.STATUS.getBlockLength());
            this.writeC(this.mount_type);
            this.writeC(this.private_store);
            this.writeC(this.can_crystalize);
            this.writeC(0);
        }
        if (this.containsMask(UserInfoType.STATS)) {
            this.writeH(UserInfoType.STATS.getBlockLength());
            this.writeH(this._weaponFlag);
            this.writeD(this._patk);
            this.writeD(this._patkspd);
            this.writeD(this._pdef);
            this.writeD(this._pEvasion);
            this.writeD(this._pAccuracy);
            this.writeD(this._pCrit);
            this.writeD(this._matk);
            this.writeD(this._matkspd);
            this.writeD(this._patkspd);
            this.writeD(this._mEvasion);
            this.writeD(this._mdef);
            this.writeD(this._mAccuracy);
            this.writeD(this._mCrit);
        }
        if (this.containsMask(UserInfoType.ELEMENTALS)) {
            this.writeH(UserInfoType.ELEMENTALS.getBlockLength());
            this.writeH(this.defenceFire);
            this.writeH(this.defenceWater);
            this.writeH(this.defenceWind);
            this.writeH(this.defenceEarth);
            this.writeH(this.defenceHoly);
            this.writeH(this.defenceUnholy);
        }
        if (this.containsMask(UserInfoType.POSITION)) {
            this.writeH(UserInfoType.POSITION.getBlockLength());
            this.writeD(this._loc.x);
            this.writeD(this._loc.y);
            this.writeD(this._loc.z);
            this.writeD(this.vehicle_obj_id);
        }
        if (this.containsMask(UserInfoType.SPEED)) {
            this.writeH(UserInfoType.SPEED.getBlockLength());
            this.writeH(this._runSpd);
            this.writeH(this._walkSpd);
            this.writeH(this._swimRunSpd);
            this.writeH(this._swimWalkSpd);
            this.writeH(this._flRunSpd);
            this.writeH(this._flWalkSpd);
            this.writeH(this._flyRunSpd);
            this.writeH(this._flyWalkSpd);
        }
        if (this.containsMask(UserInfoType.MULTIPLIER)) {
            this.writeH(UserInfoType.MULTIPLIER.getBlockLength());
            this.writeF(this.move_speed);
            this.writeF(this.attack_speed);
        }
        if (this.containsMask(UserInfoType.COL_RADIUS_HEIGHT)) {
            this.writeH(UserInfoType.COL_RADIUS_HEIGHT.getBlockLength());
            this.writeF(this.col_radius);
            this.writeF(this.col_height);
        }
        if (this.containsMask(UserInfoType.ATK_ELEMENTAL)) {
            this.writeH(UserInfoType.ATK_ELEMENTAL.getBlockLength());
            this.writeC(this.attackElement.getId());
            this.writeH(this.attackElementValue);
        }
        if (this.containsMask(UserInfoType.CLAN)) {
            this.writeH(UserInfoType.CLAN.getBlockLength() + this._title.length() * 2);
            this.writeString(this._title);
            this.writeH(this.pledge_type);
            this.writeD(this.clan_id);
            this.writeD(this.large_clan_crest_id);
            this.writeD(this.clan_crest_id);
            this.writeD(this.ClanPrivs);
            this.writeC(this._isClanLeader);
            this.writeD(this.ally_id);
            this.writeD(this.ally_crest_id);
            this.writeC(this.partyRoom ? 1 : 0);
        }
        if (this.containsMask(UserInfoType.SOCIAL)) {
            this.writeH(UserInfoType.SOCIAL.getBlockLength());
            this.writeC(this.pvp_flag);
            this.writeD(this.karma);
            this.writeC(0);
            this.writeC(this.hero);
            this.writeC(this.pledge_class);
            this.writeD(this.pk_kills);
            this.writeD(this.pvp_kills);
            this.writeH(this.rec_left);
            this.writeH(this.rec_have);
        }
        if (this.containsMask(UserInfoType.VITA_FAME)) {
            this.writeH(UserInfoType.VITA_FAME.getBlockLength());
            this.writeD(0);
            this.writeC(0);
            this.writeD(this.fame);
            this.writeD(0);
        }
        if (this.containsMask(UserInfoType.SLOTS)) {
            this.writeH(UserInfoType.SLOTS.getBlockLength());
            this.writeC(this.talismans);
            this.writeC(this._jewelsLimit);
            this.writeC(this._team.ordinal());
            this.writeC(0);
            this.writeC(0);
            this.writeC(0);
            this.writeC(0);
            this.writeC(this._activeMainAgathionSlot);
            this.writeC(this._subAgathionsLimit);
        }
        if (this.containsMask(UserInfoType.MOVEMENTS)) {
            this.writeH(UserInfoType.MOVEMENTS.getBlockLength());
            this.writeC(this._moveType);
            this.writeC(this.running);
        }
        if (this.containsMask(UserInfoType.COLOR)) {
            this.writeH(UserInfoType.COLOR.getBlockLength());
            this.writeD(this.name_color);
            this.writeD(this.title_color);
        }
        if (this.containsMask(UserInfoType.INVENTORY_LIMIT)) {
            this.writeH(UserInfoType.INVENTORY_LIMIT.getBlockLength());
            this.writeH(0);
            this.writeH(0);
            this.writeH(this.InventoryLimit);
            this.writeC(0);
        }
        if (this.containsMask(UserInfoType.UNK_3)) {
            this.writeH(UserInfoType.UNK_3.getBlockLength());
            this.writeD(0);
            this.writeH(0);
            this.writeC(0);
        }
    }
}

