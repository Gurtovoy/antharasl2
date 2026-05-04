/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.recorder;

import l2s.commons.collections.CollectionUtils;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.recorder.CharStatsChangeRecorder;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExChangeMPCost;
import l2s.gameserver.network.l2.s2c.ExStorageMaxCountPacket;
import l2s.gameserver.network.l2.s2c.ExUserInfoAbnormalVisualEffect;
import l2s.gameserver.network.l2.s2c.ExUserInfoEquipSlot;
import l2s.gameserver.network.l2.s2c.ExUserInfoInvenWeight;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;

public final class PlayerStatsChangeRecorder
extends CharStatsChangeRecorder<Player> {
    public static final int BROADCAST_KARMA = 64;
    public static final int SEND_STORAGE_INFO = 128;
    public static final int SEND_INVENTORY_LOAD = 256;
    public static final int BROADCAST_CHAR_INFO2 = 512;
    public static final int FORCE_SEND_CHAR_INFO = 1024;
    public static final int CHAGE_MP_COST_PHYSIC = 2048;
    public static final int CHAGE_MP_COST_MAGIC = 4096;
    public static final int CHAGE_MP_COST_MUSIC = 8192;
    public static final int BROADCAST_EQUIP_SLOT = 16384;
    private int _maxCp;
    private int _maxLoad;
    private int _curLoad;
    private int[] _attackElement = new int[6];
    private int[] _defenceElement = new int[6];
    private long _exp;
    private long _sp;
    private int _karma;
    private int _pk;
    private int _pvp;
    private int _fame;
    private int _inventory;
    private int _warehouse;
    private int _clan;
    private int _trade;
    private int _recipeDwarven;
    private int _recipeCommon;
    private int _partyRoom;
    private double _physicMPCost;
    private double _magicMPCost;
    private double _musicMPCost;
    private String _title = "";
    private int _cubicsHash;
    private int _weaponEnchant;
    private int _armorSetEnchant;
    private int _weaponVariation1;
    private int _weaponVariation2;

    public PlayerStatsChangeRecorder(Player activeChar) {
        super(activeChar);
    }

    @Override
    protected void refreshStats() {
        this._maxCp = this.set(4, this._maxCp, ((Player)this._activeChar).getMaxCp());
        super.refreshStats();
        this._maxLoad = this.set(256, this._maxLoad, ((Player)this._activeChar).getMaxLoad());
        this._curLoad = this.set(256, this._curLoad, ((Player)this._activeChar).getCurrentLoad());
        for (Element e : Element.VALUES) {
            this._attackElement[e.getId()] = this.set(2, this._attackElement[e.getId()], ((Player)this._activeChar).getAttack(e));
            this._defenceElement[e.getId()] = this.set(2, this._defenceElement[e.getId()], ((Player)this._activeChar).getDefence(e));
        }
        this._exp = this.set(2, this._exp, ((Player)this._activeChar).getExp());
        this._sp = this.set(2, this._sp, ((Player)this._activeChar).getSp());
        this._pk = this.set(2, this._pk, ((Player)this._activeChar).getPkKills());
        this._pvp = this.set(2, this._pvp, ((Player)this._activeChar).getPvpKills());
        this._fame = this.set(2, this._fame, ((Player)this._activeChar).getFame());
        this._karma = this.set(64, this._karma, ((Player)this._activeChar).getKarma());
        this._inventory = this.set(128, this._inventory, ((Player)this._activeChar).getInventoryLimit());
        this._warehouse = this.set(128, this._warehouse, ((Player)this._activeChar).getWarehouseLimit());
        this._clan = this.set(128, this._clan, Config.WAREHOUSE_SLOTS_CLAN);
        this._trade = this.set(128, this._trade, ((Player)this._activeChar).getTradeLimit());
        this._recipeDwarven = this.set(128, this._recipeDwarven, ((Player)this._activeChar).getDwarvenRecipeLimit());
        this._recipeCommon = this.set(128, this._recipeCommon, ((Player)this._activeChar).getCommonRecipeLimit());
        this._cubicsHash = this.set(1, this._cubicsHash, CollectionUtils.hashCode(((Player)this._activeChar).getCubics()));
        this._partyRoom = this.set(1, this._partyRoom, ((Player)this._activeChar).getMatchingRoom() != null && ((Player)this._activeChar).getMatchingRoom().getType() == MatchingRoom.PARTY_MATCHING && ((Player)this._activeChar).getMatchingRoom().getLeader() == this._activeChar ? ((Player)this._activeChar).getMatchingRoom().getId() : 0);
        this._team = this.set(512, this._team, ((Player)this._activeChar).getTeam());
        this._title = this.set(1, this._title, ((Player)this._activeChar).getTitle());
        this._physicMPCost = this.set(2048, this._physicMPCost, ((Player)this._activeChar).getMPCostDiff(Skill.SkillMagicType.PHYSIC));
        this._magicMPCost = this.set(4096, this._magicMPCost, ((Player)this._activeChar).getMPCostDiff(Skill.SkillMagicType.MAGIC));
        this._musicMPCost = this.set(8192, this._musicMPCost, ((Player)this._activeChar).getMPCostDiff(Skill.SkillMagicType.MUSIC));
        this._weaponEnchant = this.set(1, this._weaponEnchant, ((Player)this._activeChar).getEnchantEffect());
        this._armorSetEnchant = this.set(1, this._armorSetEnchant, ((Player)this._activeChar).getArmorSetEnchant());
        this._weaponVariation1 = this.set(16384, this._weaponVariation1, ((Player)this._activeChar).getVariation1Id());
        this._weaponVariation2 = this.set(16384, this._weaponVariation2, ((Player)this._activeChar).getVariation2Id());
    }

    @Override
    protected void onSendChanges() {
        super.onSendChanges();
        if ((this._changes & 0x20) == 32) {
            ((Player)this._activeChar).broadcastUserInfo(true);
        } else if ((this._changes & 1) == 1 || (this._changes & 0x200) == 512 || (this._changes & 8) == 8) {
            if ((this._changes & 0x400) == 1024) {
                ((Player)this._activeChar).broadcastUserInfo(true);
            } else {
                ((Player)this._activeChar).broadcastCharInfo();
            }
        } else if ((this._changes & 0x400) == 1024) {
            if ((this._changes & 0x4000) == 16384) {
                ((Player)this._activeChar).broadcastUserInfo(true);
            } else {
                ((Player)this._activeChar).sendUserInfo(true);
            }
        } else if ((this._changes & 2) == 2) {
            if ((this._changes & 0x4000) == 16384) {
                ((Player)this._activeChar).broadcastCharInfo();
            } else {
                ((Player)this._activeChar).sendUserInfo();
            }
        }
        if ((this._changes & 0x200) == 512) {
            for (Servitor servitor : ((Player)this._activeChar).getServitors()) {
                servitor.broadcastCharInfo();
            }
        }
        if ((this._changes & 0x10) == 16) {
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExUserInfoEquipSlot((Player)this._activeChar));
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExUserInfoAbnormalVisualEffect((Player)this._activeChar));
        } else {
            if ((this._changes & 0x4000) == 16384) {
                ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExUserInfoEquipSlot((Player)this._activeChar));
                ((Player)this._activeChar).broadcastCharInfoImpl(new IUpdateTypeComponent[0]);
            }
            if ((this._changes & 8) == 8) {
                ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExUserInfoAbnormalVisualEffect((Player)this._activeChar));
            }
        }
        if ((this._changes & 0x100) == 256) {
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExUserInfoInvenWeight((Player)this._activeChar));
        }
        if ((this._changes & 0x40) == 64) {
            ((Player)this._activeChar).sendStatusUpdate(true, false, 27);
        }
        if ((this._changes & 0x80) == 128) {
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExStorageMaxCountPacket((Player)this._activeChar));
        }
        if ((this._changes & 0x800) == 2048) {
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExChangeMPCost(Skill.SkillMagicType.PHYSIC, this._physicMPCost));
        }
        if ((this._changes & 0x1000) == 4096) {
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExChangeMPCost(Skill.SkillMagicType.MAGIC, this._magicMPCost));
        }
        if ((this._changes & 0x2000) == 8192) {
            ((Player)this._activeChar).sendPacket((IBroadcastPacket)new ExChangeMPCost(Skill.SkillMagicType.MUSIC, this._musicMPCost));
        }
    }
}

