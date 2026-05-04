/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.entity.events.impl.ClanHallSiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.Privilege;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.CastleSiegeAttackerListPacket;
import l2s.gameserver.network.l2.s2c.CastleSiegeDefenderListPacket;

public class RequestJoinCastleSiege
extends L2GameClientPacket {
    private int _id;
    private boolean _isAttacker;
    private boolean _isJoining;

    @Override
    protected boolean readImpl() {
        this._id = this.readD();
        this._isAttacker = this.readD() == 1;
        this._isJoining = this.readD() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (!player.hasPrivilege(Privilege.CS_FS_SIEGE_WAR)) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT);
            return;
        }
        Object residence = ResidenceHolder.getInstance().getResidence(this._id);
        if (residence == null) {
            player.sendActionFailed();
            return;
        }
        if (((Residence)residence).getType() == ResidenceType.CASTLE) {
            RequestJoinCastleSiege.registerAtCastle(player, (Castle)residence, this._isAttacker, this._isJoining);
        } else if (((Residence)residence).getType() == ResidenceType.CLANHALL && this._isAttacker) {
            RequestJoinCastleSiege.registerAtClanHall(player, (ClanHall)residence, this._isJoining);
        }
    }

    private static void registerAtCastle(Player player, Castle castle, boolean attacker, boolean join) {
        CastleSiegeEvent siegeEvent = (CastleSiegeEvent)((Object)castle.getSiegeEvent());
        if (siegeEvent == null) {
            return;
        }
        Clan playerClan = player.getClan();
        if (playerClan.isPlacedForDisband()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REQUESTED_THE_DISSOLUTION_OF_YOUR_CLAN);
            return;
        }
        if (join) {
            Residence registeredCastle = null;
            for (Residence residence : ResidenceHolder.getInstance().getResidenceList(Castle.class)) {
                CastleSiegeEvent residenceSiegeEvent = (CastleSiegeEvent)((Object)residence.getSiegeEvent());
                if (residenceSiegeEvent == null) continue;
                Object tempCastle = residenceSiegeEvent.getSiegeClan("attackers", playerClan);
                if (tempCastle == null) {
                    tempCastle = residenceSiegeEvent.getSiegeClan("defenders", playerClan);
                }
                if (tempCastle == null) {
                    tempCastle = residenceSiegeEvent.getSiegeClan("defenders_waiting", playerClan);
                }
                if (tempCastle == null) continue;
                registeredCastle = residence;
            }
            if (!siegeEvent.canRegisterOnSiege(player, playerClan, attacker)) {
                return;
            }
            if (Config.ONLY_ONE_SIEGE_PER_CLAN && registeredCastle != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REQUESTED_A_CASTLE_SIEGE);
                return;
            }
            if (castle.getSiegeDate().getTimeInMillis() == 0L) {
                player.sendPacket((IBroadcastPacket)SystemMsg.THIS_IS_NOT_THE_TIME_FOR_SIEGE_REGISTRATION_AND_SO_REGISTRATION_AND_CANCELLATION_CANNOT_BE_DONE);
                return;
            }
            if (siegeEvent.isRegistrationOver()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_TOO_LATE_THE_REGISTRATION_PERIOD_IS_OVER);
                return;
            }
            if (attacker) {
                int allSize = siegeEvent.getObjects("attackers").size();
                if (allSize >= CastleSiegeEvent.MAX_SIEGE_CLANS) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.NO_MORE_REGISTRATIONS_MAY_BE_ACCEPTED_FOR_THE_ATTACKER_SIDE);
                    return;
                }
                SiegeClanObject siegeClanObject = new SiegeClanObject("attackers", playerClan, 0L);
                siegeEvent.addObject("attackers", siegeClanObject);
                SiegeClanDAO.getInstance().insert(castle, siegeClanObject);
                player.sendPacket((IBroadcastPacket)new CastleSiegeAttackerListPacket(castle));
            } else {
                SiegeClanObject siegeClan = new SiegeClanObject("defenders_waiting", playerClan, 0L);
                siegeEvent.addObject("defenders_waiting", siegeClan);
                SiegeClanDAO.getInstance().insert(castle, siegeClan);
                player.sendPacket((IBroadcastPacket)new CastleSiegeDefenderListPacket(castle));
            }
        } else {
            SiegeClanObject siegeClan = null;
            if (attacker) {
                siegeClan = (SiegeClanObject)siegeEvent.getSiegeClan("attackers", playerClan);
            } else {
                siegeClan = (SiegeClanObject)siegeEvent.getSiegeClan("defenders", playerClan);
                if (siegeClan == null) {
                    siegeClan = (SiegeClanObject)siegeEvent.getSiegeClan("defenders_waiting", playerClan);
                }
                if (siegeClan == null) {
                    siegeClan = siegeEvent.getSiegeClan("defenders_refused", playerClan);
                }
            }
            if (siegeClan == null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_YET_REGISTERED_FOR_THE_CASTLE_SIEGE);
                return;
            }
            if (siegeEvent.isRegistrationOver()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_TOO_LATE_THE_REGISTRATION_PERIOD_IS_OVER);
                return;
            }
            siegeEvent.removeObject(siegeClan.getType(), siegeClan);
            SiegeClanDAO.getInstance().delete(castle, siegeClan);
            if (siegeClan.getType() == "attackers") {
                player.sendPacket((IBroadcastPacket)new CastleSiegeAttackerListPacket(castle));
            } else {
                player.sendPacket((IBroadcastPacket)new CastleSiegeDefenderListPacket(castle));
            }
        }
    }

    private static void registerAtClanHall(Player player, ClanHall clanHall, boolean join) {
        ClanHallSiegeEvent siegeEvent = (ClanHallSiegeEvent)((Object)clanHall.getSiegeEvent());
        if (siegeEvent == null) {
            return;
        }
        Clan playerClan = player.getClan();
        Object siegeClan = siegeEvent.getSiegeClan("attackers", playerClan);
        if (join) {
            if (playerClan.getHasHideout() != 0) {
                player.sendPacket((IBroadcastPacket)SystemMsg.A_CLAN_THAT_OWNS_A_CLAN_HALL_MAY_NOT_PARTICIPATE_IN_A_CLAN_HALL_SIEGE);
                return;
            }
            if (siegeClan != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REQUESTED_A_CASTLE_SIEGE);
                return;
            }
            if (playerClan.getLevel() < 4) {
                player.sendPacket((IBroadcastPacket)SystemMsg.ONLY_CLANS_WHO_ARE_LEVEL_4_OR_ABOVE_CAN_REGISTER_FOR_BATTLE_AT_DEVASTATED_CASTLE_AND_FORTRESS_OF_THE_DEAD);
                return;
            }
            if (siegeEvent.isRegistrationOver()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_TOO_LATE_THE_REGISTRATION_PERIOD_IS_OVER);
                return;
            }
            int allSize = siegeEvent.getObjects("attackers").size();
            if (allSize >= CastleSiegeEvent.MAX_SIEGE_CLANS) {
                player.sendPacket((IBroadcastPacket)SystemMsg.NO_MORE_REGISTRATIONS_MAY_BE_ACCEPTED_FOR_THE_ATTACKER_SIDE);
                return;
            }
            siegeClan = new SiegeClanObject("attackers", playerClan, 0L);
            siegeEvent.addObject("attackers", siegeClan);
            SiegeClanDAO.getInstance().insert(clanHall, (SiegeClanObject)siegeClan);
        } else {
            if (siegeClan == null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_YET_REGISTERED_FOR_THE_CASTLE_SIEGE);
                return;
            }
            if (siegeEvent.isRegistrationOver()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_TOO_LATE_THE_REGISTRATION_PERIOD_IS_OVER);
                return;
            }
            siegeEvent.removeObject(((SiegeClanObject)siegeClan).getType(), siegeClan);
            SiegeClanDAO.getInstance().delete(clanHall, (SiegeClanObject)siegeClan);
        }
        player.sendPacket((IBroadcastPacket)new CastleSiegeAttackerListPacket(clanHall));
    }
}

