/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.utils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.templates.InstantZone;
import l2s.gameserver.utils.ItemFunctions;

public class ReflectionUtils {
    public static DoorInstance getDoor(int id) {
        return ReflectionManager.MAIN.getDoor(id);
    }

    public static Zone getZone(String name) {
        return ReflectionManager.MAIN.getZone(name);
    }

    public static List<Zone> getZonesByType(Zone.ZoneType zoneType) {
        Collection<Zone> zones = ReflectionManager.MAIN.getZones();
        if (zones.isEmpty()) {
            return Collections.emptyList();
        }
        ArrayList<Zone> zones2 = new ArrayList<Zone>(5);
        for (Zone z : zones) {
            if (z.getType() != zoneType) continue;
            zones2.add(z);
        }
        return zones2;
    }

    public static Reflection enterReflection(Player invoker, int instancedZoneId) {
        InstantZone iz = InstantZoneHolder.getInstance().getInstantZone(instancedZoneId);
        return ReflectionUtils.enterReflection(invoker, new Reflection(), iz);
    }

    public static Reflection enterReflection(Player invoker, Reflection r, int instancedZoneId) {
        InstantZone iz = InstantZoneHolder.getInstance().getInstantZone(instancedZoneId);
        return ReflectionUtils.enterReflection(invoker, r, iz);
    }

    public static Reflection enterReflection(Player invoker, Reflection r, InstantZone iz) {
        r.init(iz);
        if (r.getReturnLoc() == null) {
            r.setReturnLoc(invoker.getLoc());
        }
        switch (iz.getEntryType(invoker)) {
            case SOLO: {
                if (iz.getRemovedItemId() > 0) {
                    ItemFunctions.deleteItem((Playable)invoker, iz.getRemovedItemId(), (long)iz.getRemovedItemCount(), true);
                }
                if (iz.getGiveItemId() > 0) {
                    ItemFunctions.addItem(invoker, iz.getGiveItemId(), iz.getGiveItemCount(), true);
                }
                if (iz.isDispelBuffs()) {
                    invoker.dispelBuffs();
                }
                if (iz.getSetReuseUponEntry() && iz.getResetReuse().next(System.currentTimeMillis()) > System.currentTimeMillis()) {
                    invoker.setInstanceReuse(iz.getId(), System.currentTimeMillis(), iz.isNotifyOnSetReuse());
                }
                invoker.setVar("backCoords", invoker.getLoc().toXYZString(), -1L);
                if (iz.getTeleportCoord() == null) break;
                invoker.teleToLocation((ILocation)iz.getTeleportCoord(), r);
                break;
            }
            case PARTY: {
                Party party = invoker.getParty();
                party.setReflection(r);
                r.setParty(party);
                for (Player member : party.getPartyMembers()) {
                    if (iz.getRemovedItemId() > 0) {
                        ItemFunctions.deleteItem((Playable)member, iz.getRemovedItemId(), (long)iz.getRemovedItemCount(), true);
                    }
                    if (iz.getGiveItemId() > 0) {
                        ItemFunctions.addItem(member, iz.getGiveItemId(), iz.getGiveItemCount(), true);
                    }
                    if (iz.isDispelBuffs()) {
                        member.dispelBuffs();
                    }
                    if (iz.getSetReuseUponEntry() && iz.getResetReuse().next(System.currentTimeMillis()) > System.currentTimeMillis()) {
                        member.setInstanceReuse(iz.getId(), System.currentTimeMillis(), iz.isNotifyOnSetReuse());
                    }
                    member.setVar("backCoords", member.getLoc().toXYZString(), -1L);
                    if (iz.getTeleportCoord() == null) continue;
                    member.teleToLocation((ILocation)iz.getTeleportCoord(), r);
                }
                break;
            }
            case COMMAND_CHANNEL: {
                for (Player member : invoker.getParty().getCommandChannel()) {
                    if (iz.getRemovedItemId() > 0) {
                        ItemFunctions.deleteItem((Playable)member, iz.getRemovedItemId(), (long)iz.getRemovedItemCount(), true);
                    }
                    if (iz.getGiveItemId() > 0) {
                        ItemFunctions.addItem(member, iz.getGiveItemId(), iz.getGiveItemCount(), true);
                    }
                    if (iz.isDispelBuffs()) {
                        member.dispelBuffs();
                    }
                    if (iz.getSetReuseUponEntry() && iz.getResetReuse().next(System.currentTimeMillis()) > System.currentTimeMillis()) {
                        member.setInstanceReuse(iz.getId(), System.currentTimeMillis(), iz.isNotifyOnSetReuse());
                    }
                    member.setVar("backCoords", member.getLoc().toXYZString(), -1L);
                    member.teleToLocation((ILocation)iz.getTeleportCoord(), r);
                }
                break;
            }
        }
        return r;
    }
}

