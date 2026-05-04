package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.luckygame.LuckyGameData;
import l2s.gameserver.utils.ItemFunctions;

public class ExStartLuckyGame
extends L2GameServerPacket {
    private final int _type;
    private long _availableGamesCount;

    public ExStartLuckyGame(Player player, LuckyGameData data) {
        this._type = data.getType().ordinal();
        this._availableGamesCount = data.getFeeItemId() == -1 ? player.getPremiumPoints() / data.getFeeItemCount() : ItemFunctions.getItemCount(player, data.getFeeItemId()) / data.getFeeItemCount();
        int gamesLimit = data.getGamesLimit();
        if (gamesLimit > 0) {
            int playedGamesCount = player.getVarInt("@played_lucky_games" + data.getType().ordinal(), 0);
            this._availableGamesCount = Math.max(0L, Math.min(this._availableGamesCount, (long)(gamesLimit - playedGamesCount)));
        }
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._type);
        this.writeQ(this._availableGamesCount);
    }
}

