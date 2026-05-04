package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CastleSiegeDefenderListPacket
extends L2GameServerPacket {
    public static int OWNER = 1;
    public static int WAITING = 2;
    public static int ACCEPTED = 3;
    public static int REFUSE = 4;
    private int _id;
    private int _registrationValid;
    private List<DefenderClan> _defenderClans = Collections.emptyList();

    public CastleSiegeDefenderListPacket(Castle castle) {
        this._id = castle.getId();
        CastleSiegeEvent siegeEvent = (CastleSiegeEvent)((Object)castle.getSiegeEvent());
        if (siegeEvent != null) {
            this._registrationValid = !siegeEvent.isRegistrationOver() && castle.getOwner() != null ? 1 : 0;
            List<SiegeClanObject> defenders = siegeEvent.getObjects("defenders");
            List<SiegeClanObject> defendersWaiting = siegeEvent.getObjects("defenders_waiting");
            List<SiegeClanObject> defendersRefused = siegeEvent.getObjects("defenders_refused");
            this._defenderClans = new ArrayList<DefenderClan>(defenders.size() + defendersWaiting.size() + defendersRefused.size());
            if (castle.getOwner() != null) {
                this._defenderClans.add(new DefenderClan(castle.getOwner(), OWNER, 0));
            }
            for (SiegeClanObject siegeClan : defenders) {
                this._defenderClans.add(new DefenderClan(siegeClan.getClan(), ACCEPTED, (int)(siegeClan.getDate() / 1000L)));
            }
            for (SiegeClanObject siegeClan : defendersWaiting) {
                this._defenderClans.add(new DefenderClan(siegeClan.getClan(), WAITING, (int)(siegeClan.getDate() / 1000L)));
            }
            for (SiegeClanObject siegeClan : defendersRefused) {
                this._defenderClans.add(new DefenderClan(siegeClan.getClan(), REFUSE, (int)(siegeClan.getDate() / 1000L)));
            }
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._id);
        this.writeD(0);
        this.writeD(this._registrationValid);
        this.writeD(0);
        this.writeD(this._defenderClans.size());
        this.writeD(this._defenderClans.size());
        for (DefenderClan defenderClan : this._defenderClans) {
            Clan clan = defenderClan._clan;
            this.writeD(clan.getClanId());
            this.writeS(clan.getName());
            this.writeS(clan.getLeaderName());
            this.writeD(clan.getCrestId());
            this.writeD(defenderClan._time);
            this.writeD(defenderClan._type);
            this.writeD(clan.getAllyId());
            Alliance alliance = clan.getAlliance();
            if (alliance != null) {
                this.writeS(alliance.getAllyName());
                this.writeS(alliance.getAllyLeaderName());
                this.writeD(alliance.getAllyCrestId());
                continue;
            }
            this.writeS("");
            this.writeS("");
            this.writeD(0);
        }
    }

    private static class DefenderClan {
        private Clan _clan;
        private int _type;
        private int _time;

        public DefenderClan(Clan clan, int type, int time) {
            this._clan = clan;
            this._type = type;
            this._time = time;
        }
    }
}

