/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.FishDataHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExAutoFishAvailable;
import l2s.gameserver.network.l2.s2c.ExFishingEndPacket;
import l2s.gameserver.network.l2.s2c.ExUserInfoFishing;
import l2s.gameserver.templates.fish.FishRewardTemplate;
import l2s.gameserver.templates.fish.FishRewardsTemplate;
import l2s.gameserver.templates.fish.FishTemplate;
import l2s.gameserver.templates.fish.LureTemplate;
import l2s.gameserver.templates.fish.RodTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.PositionUtils;

public class Fishing {
    private static final int MIN_BAIT_DISTANCE = 90;
    private static final int MAX_BAIT_DISTANCE = 250;
    private final Player _owner;
    private boolean _started = false;
    private boolean _inProcess = false;
    private Location _hookLoc = new Location();
    private RodTemplate _rod = null;
    private LureTemplate _lure = null;
    private ScheduledFuture<?> _processTask = null;

    public Fishing(Player owner) {
        this._owner = owner;
    }

    public boolean inStarted() {
        return this._started;
    }

    public boolean isInProcess() {
        return this._inProcess;
    }

    public Location getHookLocation() {
        return this._hookLoc;
    }

    public void start(RodTemplate rod, LureTemplate lure, Location hookLoc) {
        this._started = true;
        this._rod = rod;
        this._lure = lure;
        this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAST_YOUR_LINE_AND_START_TO_FISH);
        this.throwHook(true, hookLoc);
    }

    public void stop() {
        this._started = false;
        this._inProcess = false;
        this._hookLoc = new Location();
        this._rod = null;
        this._lure = null;
        this.stopProcessTask();
        this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_REEL_YOUR_LINE_IN_AND_STOP_FISHING);
        this._owner.sendPacket((IBroadcastPacket)ExAutoFishAvailable.REMOVE);
        this._owner.broadcastPacket(new ExUserInfoFishing(this._owner));
        this._owner.broadcastPacket(new ExFishingEndPacket(this._owner, 2));
    }

    private boolean throwHook(boolean start, Location hookLoc) {
        WeaponTemplate weaponItem = this._owner.getActiveWeaponTemplate();
        if (weaponItem == null || weaponItem.getItemType() != WeaponTemplate.WeaponType.ROD) {
            return false;
        }
        if (this._rod.getId() != weaponItem.getItemId()) {
            return false;
        }
        ItemInstance lureItem = this._owner.getInventory().getPaperdollItem(8);
        if (lureItem == null || lureItem.getCount() < (long)this._rod.getShotConsumeCount()) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_BAIT);
            return false;
        }
        if (this._lure.getId() != lureItem.getItemId()) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_BAIT);
            return false;
        }
        List<FishTemplate> fishes = this._lure.getFishes();
        if (fishes.isEmpty()) {
            return false;
        }
        if (!ItemFunctions.deleteItem((Playable)this._owner, lureItem, (long)this._rod.getShotConsumeCount(), false)) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_BAIT);
            return false;
        }
        double shotPower = 1.0 + this._owner.getChargedFishshotPower() / 100.0;
        double chancesAmount = 0.0;
        for (FishTemplate fish : fishes) {
            chancesAmount += fish.getChance() / (fish.getId() == -1 ? shotPower : 1.0);
        }
        double chanceMod = (100.0 - chancesAmount) / (double)fishes.size();
        ArrayList<FishTemplate> successFishes = new ArrayList<FishTemplate>();
        int tryCount = 0;
        while (successFishes.isEmpty()) {
            ++tryCount;
            for (FishTemplate fish : fishes) {
                if (tryCount % 10 == 0) {
                    chanceMod += 1.0;
                }
                if (!Rnd.chance((double)(fish.getChance() / (fish.getId() == 0 ? shotPower : 1.0) + chanceMod))) continue;
                successFishes.add(fish);
            }
        }
        FishTemplate fish = (FishTemplate)Rnd.get(successFishes);
        if (fish == null) {
            return false;
        }
        Location location = this._hookLoc = hookLoc == null ? this.findHookLocation() : hookLoc;
        if (this._hookLoc == null) {
            return false;
        }
        if (!start) {
            this._owner.unChargeFishShot();
        }
        this.stopProcessTask();
        this._owner.sendPacket((IBroadcastPacket)ExAutoFishAvailable.FISHING);
        this._owner.broadcastPacket(new ExUserInfoFishing(this._owner));
        this._inProcess = true;
        this._processTask = ThreadPoolManager.getInstance().schedule(new FishingTask(fish), (long)((double)fish.getDuration() * this._rod.getDurationModifier() * 1000.0));
        return true;
    }

    private void stopProcessTask() {
        if (this._processTask != null) {
            this._processTask.cancel(false);
            this._processTask = null;
        }
    }

    public Location findHookLocation() {
        int waterZ;
        int distance = Rnd.get((int)90, (int)250);
        double angle = PositionUtils.convertHeadingToDegree(this._owner.getHeading());
        double radian = Math.toRadians(angle);
        double sin = Math.sin(radian);
        double cos = Math.cos(radian);
        int baitX = (int)((double)this._owner.getX() + cos * (double)distance);
        int baitY = (int)((double)this._owner.getY() + sin * (double)distance);
        int baitZ = this._owner.getZ() + (int)this._owner.getCurrentCollisionHeight() * 2 + 50;
        HashSet<Zone> zones = new HashSet<Zone>();
        if (GeoEngine.canSeeCoord(this._owner, baitX, baitY, baitZ, true)) {
            World.getZones(zones, baitX, baitY, this._owner.getReflection());
            for (Zone zone : zones) {
                if (zone.getType() != Zone.ZoneType.water || !GeoEngine.canSeeCoord(baitX, baitY, baitZ, true, baitX, baitY, waterZ = zone.getTerritory().getZmax(), true, this._owner.getGeoIndex(), false)) continue;
                return new Location(baitX, baitY, waterZ);
            }
        }
        for (distance = 250; distance >= 90; --distance) {
            baitX = (int)((double)this._owner.getX() + cos * (double)distance);
            if (!GeoEngine.canSeeCoord(this._owner, baitX, baitY = (int)((double)this._owner.getY() + sin * (double)distance), baitZ, true)) continue;
            zones.clear();
            World.getZones(zones, baitX, baitY, this._owner.getReflection());
            for (Zone zone : zones) {
                if (zone.getType() != Zone.ZoneType.water || !GeoEngine.canSeeCoord(baitX, baitY, baitZ, true, baitX, baitY, waterZ = zone.getTerritory().getZmax(), true, this._owner.getGeoIndex(), false)) continue;
                return new Location(baitX, baitY, waterZ);
            }
        }
        return null;
    }

    private class ThrowHookTask
    implements Runnable {
        private ThrowHookTask() {
        }

        @Override
        public void run() {
            if (!Fishing.this.throwHook(false, null)) {
                Fishing.this.stop();
            }
        }
    }

    private class FishingTask
    implements Runnable {
        private final FishTemplate _fish;

        public FishingTask(FishTemplate fish) {
            this._fish = fish;
        }

        @Override
        public void run() {
            Fishing.this._inProcess = false;
            if (this._fish.getId() == -1) {
                Fishing.this._owner.sendPacket((IBroadcastPacket)SystemMsg.THE_BAIT_HAS_BEEN_LOST_BECAUSE_THE_FISH_GOT_AWAY);
                Fishing.this._owner.broadcastPacket(new ExUserInfoFishing(Fishing.this._owner));
                Fishing.this._owner.broadcastPacket(new ExFishingEndPacket(Fishing.this._owner, 0));
                Fishing.this._owner.getListeners().onFishing(false);
            } else {
                FishRewardsTemplate rewards = FishDataHolder.getInstance().getRewards(this._fish.getRewardType());
                if (rewards != null) {
                    long exp = 0L;
                    long sp = 0L;
                    for (FishRewardTemplate reward : rewards.getRewards()) {
                        if (Fishing.this._owner.getLevel() < reward.getMinLevel() || Fishing.this._owner.getLevel() > reward.getMaxLevel()) continue;
                        exp += reward.getExp();
                        sp += reward.getSp();
                    }
                    exp = (long)((double)exp * Fishing.this._rod.getRewardModifier() * Config.RATE_XP_BY_LVL[Fishing.this._owner.getLevel()] * Fishing.this._owner.getPremiumAccount().getFishingExpRate() * Fishing.this._owner.getVIP().getTemplate().getFishingExpRate());
                    sp = (long)((double)sp * Fishing.this._rod.getRewardModifier() * Config.RATE_SP_BY_LVL[Fishing.this._owner.getLevel()] * Fishing.this._owner.getPremiumAccount().getFishingSpRate() * Fishing.this._owner.getVIP().getTemplate().getFishingSpRate());
                    Fishing.this._owner.addExpAndSp(exp, sp, 0L, 0L, false, false, false, false, true);
                }
                ItemFunctions.addItem(Fishing.this._owner, this._fish.getId(), Config.RATE_FISH_DROP_COUNT * 1, true);
                Fishing.this._owner.broadcastPacket(new ExUserInfoFishing(Fishing.this._owner));
                Fishing.this._owner.broadcastPacket(new ExFishingEndPacket(Fishing.this._owner, 1));
                Fishing.this._owner.getListeners().onFishing(true);
            }
            Fishing.this._processTask = ThreadPoolManager.getInstance().schedule(new ThrowHookTask(), 15000L);
        }
    }
}

