package l2s.authserver.network.gamecomm.as2gs;

import java.util.Map;
import l2s.authserver.network.gamecomm.SendablePacket;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;

public class CheckBans
extends SendablePacket {
    private final BanBindType bindType;
    private final Map<String, BanInfo> bans;

    public CheckBans(BanBindType bindType, Map<String, BanInfo> bans) {
        this.bindType = bindType;
        this.bans = bans;
    }

    @Override
    protected void writeImpl() {
        this.writeC(7);
        this.writeC(this.bindType.ordinal());
        this.writeH(this.bans.size());
        for (Map.Entry<String, BanInfo> entry : this.bans.entrySet()) {
            this.writeS(entry.getKey());
            this.writeD(entry.getValue().getEndTime());
            this.writeS(entry.getValue().getReason());
        }
    }
}

