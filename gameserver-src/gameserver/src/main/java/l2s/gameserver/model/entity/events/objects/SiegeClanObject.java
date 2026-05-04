package l2s.gameserver.model.entity.events.objects;

import java.util.Comparator;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.utils.TimeUtils;

public class SiegeClanObject {
    private String _type;
    private Clan _clan;
    private NpcInstance _flag;
    private final long _date;

    public SiegeClanObject(String type, Clan clan, long param) {
        this(type, clan, 0L, System.currentTimeMillis());
    }

    public SiegeClanObject(String type, Clan clan, long param, long date) {
        this._type = type;
        this._clan = clan;
        this._date = date;
    }

    public int getObjectId() {
        return this._clan.getClanId();
    }

    public Clan getClan() {
        return this._clan;
    }

    public NpcInstance getFlag() {
        return this._flag;
    }

    public void deleteFlag() {
        if (this._flag != null) {
            this._flag.deleteMe();
            this._flag = null;
        }
    }

    public void setFlag(NpcInstance npc) {
        this._flag = npc;
    }

    public void setType(String type) {
        this._type = type;
    }

    public String getType() {
        return this._type;
    }

    public void broadcast(IBroadcastPacket ... packet) {
        this.getClan().broadcastToOnlineMembers(packet);
    }

    public void setEvent(boolean start, SiegeEvent<?, ?> event) {
        if (start) {
            for (Player player : this._clan.getOnlineMembers()) {
                player.addEvent(event);
                player.broadcastCharInfo();
            }
        } else {
            for (Player player : this._clan.getOnlineMembers()) {
                player.removeEvent(event);
                player.getAbnormalList().stop(5660);
                player.broadcastCharInfo();
            }
        }
    }

    public boolean isParticle(Player player) {
        return true;
    }

    public long getParam() {
        return 0L;
    }

    public long getDate() {
        return this._date;
    }

    public String toString() {
        return this.getClass().getSimpleName() + "[" + this.getClan().getName() + ", reg: " + TimeUtils.toSimpleFormat(this.getDate()) + ", param: " + this.getParam() + ", type: " + this._type + "]";
    }

    public static class SiegeClanComparatorImpl
    implements Comparator<SiegeClanObject> {
        private static final SiegeClanComparatorImpl _instance = new SiegeClanComparatorImpl();

        public static SiegeClanComparatorImpl getInstance() {
            return _instance;
        }

        @Override
        public int compare(SiegeClanObject o1, SiegeClanObject o2) {
            return o2.getParam() < o1.getParam() ? -1 : (o2.getParam() == o1.getParam() ? 0 : 1);
        }
    }
}

