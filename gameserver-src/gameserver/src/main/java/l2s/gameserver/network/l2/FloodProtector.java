/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2;

import java.util.Arrays;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.gameserver.config.FloodProtectorConfig;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.gs2as.ChangeAccessLevel;
import l2s.gameserver.network.l2.GameClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class FloodProtector {
    private static final Logger LOGGER = LoggerFactory.getLogger((String)"floodprotector");
    private final GameClient _client;
    private final FloodProtectorConfig _config;
    private volatile long _nextTime = System.currentTimeMillis();
    private final AtomicInteger _count = new AtomicInteger(0);
    private boolean _logged;
    private volatile boolean _punishmentInProgress;

    public FloodProtector(GameClient client, FloodProtectorConfig config) {
        this._client = client;
        this._config = config;
    }

    public boolean tryPerformAction(String command) {
        long curTime = System.currentTimeMillis();
        if (this._client.getActiveChar() != null && this._client.getActiveChar().getPlayerAccess().CanIgnoreFloodProtector) {
            return true;
        }
        if (curTime < this._nextTime || this._punishmentInProgress) {
            if (this._config.LOG_FLOODING && !this._logged) {
                this.log("called command ", command, " ~", String.valueOf((long)this._config.FLOOD_PROTECTION_INTERVAL - (this._nextTime - curTime)), " ms after previous command");
                this._logged = true;
            }
            this._count.incrementAndGet();
            if (!this._punishmentInProgress && this._config.PUNISHMENT_LIMIT > 0 && this._count.get() >= this._config.PUNISHMENT_LIMIT && this._config.PUNISHMENT_TYPE != null) {
                this._punishmentInProgress = true;
                if ("kick".equals(this._config.PUNISHMENT_TYPE)) {
                    this.kickPlayer();
                } else if ("ban".equals(this._config.PUNISHMENT_TYPE)) {
                    this.banAccount();
                } else if ("jail".equals(this._config.PUNISHMENT_TYPE)) {
                    this.jailChar();
                }
                this._punishmentInProgress = false;
            }
            return false;
        }
        if (this._count.get() > 0 && this._config.LOG_FLOODING) {
            this.log("issued ", String.valueOf(this._count), " extra requests within ~", String.valueOf(this._config.FLOOD_PROTECTION_INTERVAL), " ms");
        }
        this._nextTime = curTime + (long)this._config.FLOOD_PROTECTION_INTERVAL;
        this._logged = false;
        this._count.set(0);
        return true;
    }

    private void kickPlayer() {
        Player player = this._client.getActiveChar();
        if (player != null) {
            player.kick();
            this.log("kicked for flooding");
        }
    }

    private void banAccount() {
        int accessLevel = 0;
        int banExpire = 0;
        if (this._config.PUNISHMENT_TIME > 0L) {
            banExpire = (int)((System.currentTimeMillis() + this._config.PUNISHMENT_TIME) / 1000L);
        } else {
            accessLevel = -100;
        }
        AuthServerCommunication.getInstance().sendPacket(new ChangeAccessLevel(this._client.getLogin(), accessLevel, banExpire));
        Player player = this._client.getActiveChar();
        if (player != null) {
            player.kick();
        }
        this.log("banned for flooding ", this._config.PUNISHMENT_TIME <= 0L ? "forever" : "for " + this._config.PUNISHMENT_TIME / 60000L + " mins");
    }

    private void jailChar() {
        Player player = this._client.getActiveChar();
        if (player != null) {
            player.toJail((int)(this._config.PUNISHMENT_TIME / 60000L));
            this.log("jailed for flooding ", this._config.PUNISHMENT_TIME <= 0L ? "forever" : "for " + this._config.PUNISHMENT_TIME / 60000L + " mins");
        }
    }

    private void log(String ... lines) {
        StringBuilder output = new StringBuilder(100);
        output.append(this._config.FLOOD_PROTECTOR_TYPE);
        output.append(": ");
        switch (this._client.getState()) {
            case IN_GAME: {
                if (this._client.getActiveChar() != null) {
                    output.append(this._client.getActiveChar().getName());
                    output.append("(");
                    output.append(this._client.getActiveChar().getObjectId());
                    output.append(") ");
                }
                break;
            }
            case AUTHED: {
                if (this._client.getLogin() != null) {
                    output.append(this._client.getLogin());
                    output.append(" ");
                }
                break;
            }
            case CONNECTED: {
                String address = this._client.getIpAddr();
                if (address != null) {
                    output.append(address);
                    output.append(" ");
                }
                break;
            }
            default: {
                throw new IllegalStateException("Missing state on switch");
            }
        }
        Arrays.stream(lines).forEach(output::append);
        LOGGER.info(output.toString());
    }
}

