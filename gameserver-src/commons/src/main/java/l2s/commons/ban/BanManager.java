package l2s.commons.ban;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.ban.BanBindType;
import l2s.commons.ban.BanInfo;
import org.apache.commons.lang3.StringUtils;

public class BanManager {
    private final Map<BanBindType, Map<String, BanInfo>> cachedBans = new HashMap<BanBindType, Map<String, BanInfo>>();

    public Map<BanBindType, Map<String, BanInfo>> getCachedBans() {
        return this.cachedBans;
    }

    public BanInfo getBanInfoIfBanned(BanBindType bindType, Object bindValueObj) {
        String bindValue = String.valueOf(bindValueObj);
        if (StringUtils.isEmpty((CharSequence)bindValue)) {
            return null;
        }
        Map<String, BanInfo> bans = this.getCachedBans().get((Object)bindType);
        if (bans == null) {
            return null;
        }
        BanInfo banInfo = bans.get(bindValue);
        if (banInfo == null) {
            return null;
        }
        if (banInfo.getEndTime() != -1 && (long)banInfo.getEndTime() < System.currentTimeMillis() / 1000L) {
            return null;
        }
        return banInfo;
    }

    public boolean isBanned(BanBindType bindType, Object bindValueObj) {
        return this.getBanInfoIfBanned(bindType, bindValueObj) != null;
    }
}

