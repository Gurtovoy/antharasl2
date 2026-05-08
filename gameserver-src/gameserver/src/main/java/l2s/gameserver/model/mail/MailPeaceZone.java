package l2s.gameserver.model.mail;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public final class MailPeaceZone {
    private MailPeaceZone() {
    }

    /**
     * Blocks the mail packet when {@link Config#MAIL_PEACE_ZONE_ONLY} is on and the player is not in a peace zone.
     *
     * @return {@code true} if handling should stop (player has been notified).
     */
    public static boolean blockIfPeaceOnly(Player player, SystemMsg denyMsg, boolean sendActionFailed) {
        if (!Config.MAIL_PEACE_ZONE_ONLY) {
            return false;
        }
        if (player.isInPeaceZone()) {
            return false;
        }
        player.sendPacket((IBroadcastPacket)denyMsg);
        if (sendActionFailed) {
            player.sendActionFailed();
        }
        return true;
    }
}
