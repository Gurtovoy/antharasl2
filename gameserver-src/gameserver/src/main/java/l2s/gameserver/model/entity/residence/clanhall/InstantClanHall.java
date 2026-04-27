/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.CHashIntObjectMap
 */
package l2s.gameserver.model.entity.residence.clanhall;

import java.util.Calendar;
import java.util.Collection;
import l2s.gameserver.dao.InstantClanHallDAO;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.listener.reflection.OnReflectionCollapseListener;
import l2s.gameserver.listener.zone.impl.ResidenceEnterLeaveListenerImpl;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.entity.residence.ClanHallType;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.templates.InstantZone;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.utils.TimeUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;

public class InstantClanHall
extends ClanHall {
    private final long _rentalFee;
    private final int _commissionPercent;
    private final int _rentalPeriod;
    private final int _applyPeriod;
    private final Calendar _firstLotteryDate;
    private final int _minPledgeLevel;
    private final InstantZone _instantZone;
    private final IntObjectMap<Clan> _owners = new CHashIntObjectMap();
    private final IntObjectMap<Reflection> _reflections = new CHashIntObjectMap();
    private final OnReflectionCollapseListener _reflectionListener = new ReflectionCollapseListener();

    public InstantClanHall(StatsSet set) {
        super(set);
        this._rentalFee = set.getLong("rental_fee", 0L);
        this._commissionPercent = set.getInteger("comission", 0);
        this._rentalPeriod = set.getInteger("rental_period");
        this._applyPeriod = set.getInteger("apply_period");
        this._firstLotteryDate = TimeUtils.getCalendarFromString(set.getString("first_lottery_date", "2000/01/01"), "yyyy/MM/dd");
        this._minPledgeLevel = set.getInteger("min_pledge_level", 0);
        this._instantZone = InstantZoneHolder.getInstance().getInstantZone(set.getInteger("instant_zone"));
    }

    @Override
    public void init() {
        this.initEvent();
        this.loadData();
    }

    @Override
    protected void initZone() {
    }

    @Override
    public int getId() {
        return Residence.getInstantResidenceId(super.getId());
    }

    @Override
    public boolean isInstant() {
        return true;
    }

    @Override
    public int getInstantId() {
        return super.getId();
    }

    @Override
    public void changeOwner(Clan clan) {
        throw new UnsupportedOperationException();
    }

    @Override
    protected void loadData() {
        InstantClanHallDAO.getInstance().select(this);
    }

    @Override
    public void update() {
        InstantClanHallDAO.getInstance().update(this);
    }

    @Override
    public int getInstantZoneId() {
        return this._instantZone.getId();
    }

    @Override
    public long getRentalFee() {
        return this._rentalFee;
    }

    @Override
    protected void loadFunctions() {
        throw new UnsupportedOperationException();
    }

    @Override
    public boolean updateFunctions(ResidenceFunctionType type, int level) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void removeFunction(ResidenceFunctionType type) {
        throw new UnsupportedOperationException();
    }

    @Override
    public void removeFunctions() {
        throw new UnsupportedOperationException();
    }

    @Override
    public void banishForeigner(int clanId) {
        Reflection reflection = this.getReflection(clanId);
        if (reflection == null) {
            return;
        }
        for (Player player : reflection.getPlayers()) {
            if (player.getClanId() == clanId) continue;
            player.teleToLocation(this.getBanishPoint());
        }
    }

    @Override
    public Location getBanishPoint() {
        return this._instantZone.getReturnCoords();
    }

    @Override
    public Location getOwnerRestartPoint() {
        return this._instantZone.getTeleportCoord();
    }

    @Override
    public int getOwnerId() {
        throw new UnsupportedOperationException();
    }

    @Override
    public Clan getOwner() {
        throw new UnsupportedOperationException();
    }

    @Override
    public boolean isOwner(int clanId) {
        return this._owners.containsKey(clanId);
    }

    @Override
    public Reflection getReflection(int clanId) {
        if (!this.isOwner(clanId)) {
            return null;
        }
        Reflection reflection = (Reflection)this._reflections.get(clanId);
        if (reflection == null) {
            reflection = new Reflection();
            reflection.setVariable("clan_owner_id", clanId);
            reflection.setVariable("instant_clanhall", this);
            reflection.addListener(this._reflectionListener);
            reflection.init(this._instantZone);
            this._reflections.put(clanId, reflection);
            for (Zone zone : reflection.getZones()) {
                zone.setParam("residence", this);
                zone.addListener(ResidenceEnterLeaveListenerImpl.STATIC);
            }
        }
        return reflection;
    }

    public int getCommissionPercent() {
        return this._commissionPercent;
    }

    public int getRentalPeriod() {
        return this._rentalPeriod;
    }

    public int getApplyPeriod() {
        return this._applyPeriod;
    }

    public int getMinPledgeLevel() {
        return this._minPledgeLevel;
    }

    public Calendar getFirstLotteryDate() {
        return this._firstLotteryDate;
    }

    public InstantZone getInstantZone() {
        return this._instantZone;
    }

    public int getMaxCount() {
        return this._instantZone.getMaxChannels();
    }

    public Collection<Clan> getOwners() {
        return this._owners.valueCollection();
    }

    public boolean addOwner(Clan owner, boolean store) {
        if (owner == null) {
            return false;
        }
        if (this._owners.containsKey(owner.getClanId())) {
            return false;
        }
        if (store && !InstantClanHallDAO.getInstance().insert(this, owner)) {
            return false;
        }
        this._owners.put(owner.getClanId(), owner);
        return true;
    }

    public boolean removeOwner(Clan owner, boolean store) {
        if (this._owners.remove(owner.getClanId()) == null) {
            return false;
        }
        if (store && !InstantClanHallDAO.getInstance().delete(this, owner)) {
            return false;
        }
        this._owners.remove(owner.getClanId());
        return true;
    }

    @Override
    public ClanHallType getClanHallType() {
        return ClanHallType.OTHER;
    }

    private class ReflectionCollapseListener
    implements OnReflectionCollapseListener {
        private ReflectionCollapseListener() {
        }

        @Override
        public void onReflectionCollapse(Reflection reflection) {
            InstantClanHall.this._reflections.remove(reflection.getVariables().getInteger("clan_owner_id"));
        }
    }
}

