package l2s.gameserver.network.authcomm.as2gs;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;
import l2s.gameserver.instancemanager.AuthBanManager;
import l2s.gameserver.instancemanager.GameBanManager;
import l2s.gameserver.network.authcomm.ReceivablePacket;

public class CheckBans
extends ReceivablePacket {
    private BanBindType bindType;
    private Map<String, BanInfo> bans;

    @Override
    public boolean readImpl() {
        try {
            this.bindType = BanBindType.VALUES[this.readC()];
        }
        catch (Exception e) {
            return false;
        }
        int size = this.readH();
        this.bans = new HashMap<String, BanInfo>(size);
        for (int i = 0; i < size; ++i) {
            String bindValue = this.readS();
            int endTime = this.readD();
            String reason = this.readS();
            this.bans.put(bindValue, new BanInfo(endTime, reason));
        }
        return true;
    }

    @Override
    protected void runImpl() {
        if (!this.bindType.isAuth()) {
            return;
        }
        AuthBanManager.getInstance().getCachedBans().put(this.bindType, this.bans);
        for (Map.Entry<String, BanInfo> entry : this.bans.entrySet()) {
            GameBanManager.onBan(this.bindType, entry.getKey(), entry.getValue(), true);
        }
    }
}

