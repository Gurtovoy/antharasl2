/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.luckygame.LuckyGameData;
import l2s.gameserver.templates.luckygame.LuckyGameItem;
import l2s.gameserver.templates.luckygame.LuckyGameType;
import l2s.gameserver.utils.ItemFunctions;

public class ExBettingLuckyGameResult
extends L2GameServerPacket {
    public static final int INVALID_CAPACITY = -2;
    public static final int INVALID_ITEM_COUNT = -1;
    public static final int DISABLED = 0;
    public static final int SUCCESS = 1;
    private final int _result;
    private final int _type;
    private long _availableGamesCount;
    private final List<LuckyGameItem> _items;

    public ExBettingLuckyGameResult(Player player, LuckyGameData data, List<LuckyGameItem> items) {
        this._result = 1;
        this._type = data.getType().ordinal();
        this._availableGamesCount = data.getFeeItemId() == -1 ? player.getPremiumPoints() / data.getFeeItemCount() : ItemFunctions.getItemCount(player, data.getFeeItemId()) / data.getFeeItemCount();
        int gamesLimit = data.getGamesLimit();
        if (gamesLimit > 0) {
            int playedGamesCount = player.getVarInt("@played_lucky_games" + data.getType().ordinal(), 0);
            this._availableGamesCount = Math.max(0L, Math.min(this._availableGamesCount, (long)(gamesLimit - playedGamesCount)));
        }
        this._items = items;
    }

    public ExBettingLuckyGameResult(int result, LuckyGameType type) {
        this._result = result;
        this._type = type.ordinal();
        this._availableGamesCount = 0L;
        this._items = Collections.emptyList();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
        this.writeD(this._type);
        this.writeD((int)this._availableGamesCount);
        this.writeD(this._items.size());
        for (LuckyGameItem item : this._items) {
            this.writeD(item.isFantastic() ? 2 : 0);
            this.writeD(item.getId());
            this.writeD((int)item.getCount());
        }
    }
}

