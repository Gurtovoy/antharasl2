package l2s.gameserver.model.entity.events.objects;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.dao.SiegePlayerDAO;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.pledge.Clan;

public class CTBSiegeClanObject
extends SiegeClanObject {
    private List<Integer> _players = new ArrayList<Integer>();
    private long _npcId;

    public CTBSiegeClanObject(String type, Clan clan, long param, long date) {
        super(type, clan, param, date);
        this._npcId = param;
    }

    public CTBSiegeClanObject(String type, Clan clan, long param) {
        this(type, clan, param, System.currentTimeMillis());
    }

    public void select(Residence r) {
        this._players.addAll(SiegePlayerDAO.getInstance().select(r, this.getObjectId()));
    }

    public List<Integer> getPlayers() {
        return this._players;
    }

    @Override
    public void setEvent(boolean start, SiegeEvent<?, ?> event) {
        for (int i : this.getPlayers()) {
            Player player = GameObjectsStorage.getPlayer(i);
            if (player == null) continue;
            if (start) {
                player.addEvent(event);
            } else {
                player.removeEvent(event);
            }
            player.broadcastCharInfo();
        }
    }

    @Override
    public boolean isParticle(Player player) {
        return this._players.contains(player.getObjectId());
    }

    @Override
    public long getParam() {
        return this._npcId;
    }

    public void setParam(int npcId) {
        this._npcId = npcId;
    }
}

