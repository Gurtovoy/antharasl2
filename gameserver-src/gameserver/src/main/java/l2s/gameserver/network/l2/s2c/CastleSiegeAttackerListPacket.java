package l2s.gameserver.network.l2.s2c;

import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CastleSiegeAttackerListPacket
extends L2GameServerPacket {
    private int _id;
    private int _registrationValid;
    private List<SiegeClanObject> _clans = Collections.emptyList();

    public CastleSiegeAttackerListPacket(Residence residence) {
        this._id = residence.getId();
        Object siegeEvent = residence.getSiegeEvent();
        if (siegeEvent != null) {
            this._registrationValid = !((SiegeEvent)((Object)siegeEvent)).isRegistrationOver() ? 1 : 0;
            this._clans = ((Event)((Object)siegeEvent)).getObjects("attackers");
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._id);
        this.writeD(0);
        this.writeD(this._registrationValid);
        this.writeD(0);
        this.writeD(this._clans.size());
        this.writeD(this._clans.size());
        for (SiegeClanObject siegeClan : this._clans) {
            Clan clan = siegeClan.getClan();
            this.writeD(clan.getClanId());
            this.writeS(clan.getName());
            this.writeS(clan.getLeaderName());
            this.writeD(clan.getCrestId());
            this.writeD((int)(siegeClan.getDate() / 1000L));
            Alliance alliance = clan.getAlliance();
            this.writeD(clan.getAllyId());
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
}

