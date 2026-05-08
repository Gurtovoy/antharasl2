package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;

public class ExSetCompassZoneCode
extends L2GameServerPacket {
    public static final int ZONE_ALTERED = 8;
    public static final int ZONE_ALTERED2 = 9;
    public static final int ZONE_REMINDER = 10;
    public static final int ZONE_SIEGE = 11;
    public static final int ZONE_PEACE = 12;
    public static final int ZONE_SSQ = 13;
    public static final int ZONE_PVP = 14;
    public static final int ZONE_GENERAL_FIELD = 15;
    public static final int ZONE_PVP_FLAG = 16384;
    public static final int ZONE_ALTERED_FLAG = 256;
    public static final int ZONE_SIEGE_FLAG = 2048;
    public static final int ZONE_PEACE_FLAG = 4096;
    public static final int ZONE_SSQ_FLAG = 8192;
    private final int _zone;

    public ExSetCompassZoneCode(Player player) {
        this._zone = ExSetCompassZoneCode.resolveZoneType(ExSetCompassZoneCode.adjustMaskForMailClient(player.getZoneMask()));
    }

    /**
     * Raw mask from {@link Player#getZoneMask()} without mail-client adjustment (for callers that build the packet from a mask directly).
     */
    public ExSetCompassZoneCode(int zoneMask) {
        this._zone = ExSetCompassZoneCode.resolveZoneType(zoneMask);
    }

    private static int adjustMaskForMailClient(int zoneMask) {
        if (!Config.MAIL_CLIENT_COMPASS_PEACE_OPEN_WORLD) {
            return zoneMask;
        }
        // Siege and PvP-flag zones: keep real compass code (and client may keep mail restrictions).
        if ((zoneMask & ZONE_SIEGE_FLAG) != 0 || (zoneMask & ZONE_PVP_FLAG) != 0) {
            return zoneMask;
        }
        /*
         * resolveZoneType checks ALTERED (danger / CHANGED_ZONE, mask 0x100) before PEACE.
         * Hunting areas almost always have 0x100 set, so OR-ing PEACE alone still yields ZONE_ALTERED (8) and the client blocks post with items.
         * Strip altered for this packet so PEACE (12) wins; real zone flags on the player are unchanged.
         */
        return (zoneMask & ~ZONE_ALTERED_FLAG) | ZONE_PEACE_FLAG;
    }

    private static int resolveZoneType(int zoneMask) {
        return (zoneMask & 0x100) == 256 ? 8 : ((zoneMask & 0x800) == 2048 ? 11 : ((zoneMask & 0x4000) == 16384 ? 14 : ((zoneMask & 0x1000) == 4096 ? 12 : ((zoneMask & 0x2000) == 8192 ? 13 : 15))));
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._zone);
    }
}
