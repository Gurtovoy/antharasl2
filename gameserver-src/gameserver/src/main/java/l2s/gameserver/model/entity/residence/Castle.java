/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.residence;

import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.math.SafeMath;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CastleDAO;
import l2s.gameserver.dao.CastleHiredGuardDAO;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.model.items.ClanWarehouse;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.ExCastleState;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.support.MerchantGuard;
import l2s.gameserver.utils.Log;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Castle
extends Residence {
    private static final Logger _log = LoggerFactory.getLogger(Castle.class);
    private final IntObjectMap<MerchantGuard> _merchantGuards = new HashIntObjectMap();
    private long _treasury;
    private long _collectedShops;
    private final NpcString _npcStringName;
    private ResidenceSide _residenceSide = ResidenceSide.NEUTRAL;
    private static final SkillEntry LIGHT_SIDE_SKILL = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 19032, 1);
    private static final SkillEntry DARK_SIDE_SKILL = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 19033, 1);
    private Set<ItemInstance> _spawnMerchantTickets = new CopyOnWriteArraySet<ItemInstance>();

    public Castle(StatsSet set) {
        super(set);
        this._npcStringName = NpcString.valueOf(1001000 + this.getId());
    }

    @Override
    public ResidenceType getType() {
        return ResidenceType.CASTLE;
    }

    @Override
    public void changeOwner(Clan newOwner) {
        Castle oldCastle;
        if (newOwner != null && newOwner.getCastle() != 0 && (oldCastle = ResidenceHolder.getInstance().getResidence(Castle.class, newOwner.getCastle())) != null) {
            oldCastle.changeOwner(null);
        }
        Clan oldOwner = null;
        if (this.getOwnerId() > 0 && (newOwner == null || newOwner.getClanId() != this.getOwnerId())) {
            this.removeSkills();
            this.cancelCycleTask();
            oldOwner = this.getOwner();
            if (oldOwner != null) {
                ClanWarehouse warehouse;
                long amount = this.getTreasury();
                if (amount > 0L && (warehouse = oldOwner.getWarehouse()) != null) {
                    warehouse.addItem(57, amount);
                    this.addToTreasuryNoTax(-amount, false);
                    Log.add(this.getName() + "|" + -amount + "|Castle:changeOwner", "treasury");
                }
                for (Player clanMember : oldOwner.getOnlineMembers()) {
                    if (clanMember == null || clanMember.getInventory() == null) continue;
                    clanMember.getInventory().validateItems();
                }
                oldOwner.setHasCastle(0);
            }
        }
        this.setOwner(newOwner);
        this.removeFunctions();
        if (newOwner != null) {
            newOwner.setHasCastle(this.getId());
            newOwner.broadcastClanStatus(true, false, false);
        }
        this.rewardSkills();
        this.setJdbcState(JdbcEntityState.UPDATED);
        this.update();
    }

    @Override
    protected void loadData() {
        this._treasury = 0L;
        CastleDAO.getInstance().select(this);
        CastleHiredGuardDAO.getInstance().load(this);
    }

    public void setTreasury(long t) {
        this._treasury = t;
    }

    public long getCollectedShops() {
        return this._collectedShops;
    }

    public void setCollectedShops(long value) {
        this._collectedShops = value;
    }

    public void addToTreasury(long amount, boolean shop) {
        Castle royal;
        if (this.getOwnerId() <= 0) {
            return;
        }
        if (amount == 0L) {
            return;
        }
        double deleteAmount = 0.4;
        if (this.getId() == 3) {
            deleteAmount = 0.75;
        } else if (this.getId() == 6) {
            deleteAmount = 0.0;
        }
        amount = (long)Math.max(0.0, (double)amount - (double)amount * deleteAmount);
        if (amount > 1L && this.getId() != 5 && this.getId() != 8 && (royal = ResidenceHolder.getInstance().getResidence(Castle.class, this.getId() >= 7 ? 8 : 5)) != null) {
            double royalTaxRate = 0.25;
            if (this.getId() == 3) {
                royalTaxRate = 0.5;
            }
            long royalTax = (long)((double)amount * royalTaxRate);
            if (royal.getOwnerId() > 0) {
                royal.addToTreasury(royalTax, shop);
                if (this.getId() == 5) {
                    Log.add("Aden|" + royalTax + "|Castle:adenTax", "treasury");
                } else if (this.getId() == 8) {
                    Log.add("Rune|" + royalTax + "|Castle:runeTax", "treasury");
                }
            }
            amount -= royalTax;
        }
        this.addToTreasuryNoTax(amount, shop);
    }

    public void addToTreasuryNoTax(long amount, boolean shop) {
        if (this.getOwnerId() <= 0) {
            return;
        }
        if (amount == 0L) {
            return;
        }
        this._treasury = SafeMath.addAndLimit((long)this._treasury, (long)amount);
        if (shop) {
            this._collectedShops += amount;
        }
        this.setJdbcState(JdbcEntityState.UPDATED);
        this.update();
    }

    public int getSellTaxPercent() {
        if (this.getResidenceSide() == ResidenceSide.LIGHT) {
            return Config.LIGHT_CASTLE_SELL_TAX_PERCENT;
        }
        if (this.getResidenceSide() == ResidenceSide.DARK) {
            return Config.DARK_CASTLE_SELL_TAX_PERCENT;
        }
        return 0;
    }

    public double getSellTaxRate() {
        return (double)this.getSellTaxPercent() / 100.0;
    }

    public int getBuyTaxPercent() {
        if (this.getResidenceSide() == ResidenceSide.LIGHT) {
            return Config.LIGHT_CASTLE_BUY_TAX_PERCENT;
        }
        if (this.getResidenceSide() == ResidenceSide.DARK) {
            return Config.DARK_CASTLE_BUY_TAX_PERCENT;
        }
        return 0;
    }

    public double getBuyTaxRate() {
        return (double)this.getBuyTaxPercent() / 100.0;
    }

    public long getTreasury() {
        return this._treasury;
    }

    public void update() {
        CastleDAO.getInstance().update(this);
    }

    public NpcString getNpcStringName() {
        return this._npcStringName;
    }

    public void addMerchantGuard(MerchantGuard merchantGuard) {
        this._merchantGuards.put(merchantGuard.getItemId(), merchantGuard);
    }

    public MerchantGuard getMerchantGuard(int itemId) {
        return (MerchantGuard)this._merchantGuards.get(itemId);
    }

    public IntObjectMap<MerchantGuard> getMerchantGuards() {
        return this._merchantGuards;
    }

    public Set<ItemInstance> getSpawnMerchantTickets() {
        return this._spawnMerchantTickets;
    }

    @Override
    public void startCycleTask() {
    }

    @Override
    public void setResidenceSide(ResidenceSide side, boolean onRestore) {
        if (!onRestore && this._residenceSide == side) {
            return;
        }
        this._residenceSide = side;
        this.removeSkills();
        switch (this._residenceSide) {
            case LIGHT: {
                this.removeSkill(DARK_SIDE_SKILL);
                this.addSkill(LIGHT_SIDE_SKILL);
                break;
            }
            case DARK: {
                this.removeSkill(LIGHT_SIDE_SKILL);
                this.addSkill(DARK_SIDE_SKILL);
                break;
            }
            default: {
                this.removeSkill(LIGHT_SIDE_SKILL);
                this.removeSkill(DARK_SIDE_SKILL);
            }
        }
        this.rewardSkills();
        if (!onRestore) {
            this.setJdbcState(JdbcEntityState.UPDATED);
            this.update();
            CastleSiegeEvent siege = (CastleSiegeEvent)((Object)this.getSiegeEvent());
            if (siege != null) {
                siege.actActions("change_castle_side");
            }
        }
    }

    @Override
    public ResidenceSide getResidenceSide() {
        return this._residenceSide;
    }

    @Override
    public void broadcastResidenceState() {
        Announcements.announceToAll(new ExCastleState(this));
    }
}

