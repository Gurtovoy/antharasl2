/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.LuckyGameHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.luckygame.LuckyGameData;
import l2s.gameserver.templates.luckygame.LuckyGameType;
import l2s.gameserver.utils.ItemFunctions;

public class ReciveVipLuckyGameInfo
extends L2GameServerPacket {
    private final boolean _enabled;
    private long _availableNormalGames = 0L;
    private long _availablePremiumGames = 0L;

    public ReciveVipLuckyGameInfo(Player player) {
        if (Config.ALLOW_LUCKY_GAME_EVENT) {
            int playedGamesCount;
            int gamesLimit;
            this._enabled = true;
            LuckyGameData data = LuckyGameHolder.getInstance().getData(LuckyGameType.NORMAL);
            if (data != null) {
                this._availableNormalGames = data.getFeeItemId() == -1 ? player.getPremiumPoints() / data.getFeeItemCount() : ItemFunctions.getItemCount(player, data.getFeeItemId()) / data.getFeeItemCount();
                gamesLimit = data.getGamesLimit();
                if (gamesLimit > 0) {
                    playedGamesCount = player.getVarInt("@played_lucky_games" + data.getType().ordinal(), 0);
                    this._availableNormalGames = Math.max(0L, Math.min(this._availableNormalGames, (long)(gamesLimit - playedGamesCount)));
                }
            }
            if ((data = LuckyGameHolder.getInstance().getData(LuckyGameType.LUXURY)) != null) {
                this._availablePremiumGames = data.getFeeItemId() == -1 ? player.getPremiumPoints() / data.getFeeItemCount() : ItemFunctions.getItemCount(player, data.getFeeItemId()) / data.getFeeItemCount();
                gamesLimit = data.getGamesLimit();
                if (gamesLimit > 0) {
                    playedGamesCount = player.getVarInt("@played_lucky_games" + data.getType().ordinal(), 0);
                    this._availablePremiumGames = Math.max(0L, Math.min(this._availablePremiumGames, (long)(gamesLimit - playedGamesCount)));
                }
            }
        } else {
            this._enabled = false;
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._enabled);
        this.writeD((int)this._availableNormalGames);
        this.writeD((int)this._availablePremiumGames);
    }
}

