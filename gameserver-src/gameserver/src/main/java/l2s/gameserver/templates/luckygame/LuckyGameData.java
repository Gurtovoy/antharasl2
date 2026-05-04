package l2s.gameserver.templates.luckygame;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.commons.util.Rnd;
import l2s.gameserver.templates.luckygame.LuckyGameItem;
import l2s.gameserver.templates.luckygame.LuckyGameType;

public class LuckyGameData {
    public static final String LUCKY_GAMES_COUNT_VAR = "@lucky_games_count";
    public static final String PLAYED_LUCKY_GAMES_VAR = "@played_lucky_games";
    public static final String LAST_LUCKY_GAME_TIME_VAR = "@last_lucky_game_time";
    private final LuckyGameType _type;
    private final int _feeItemId;
    private final long _feeItemCount;
    private final int _gamesLimit;
    private final SchedulingPattern _reusePattern;
    private final List<LuckyGameItem> _commonRewards = new ArrayList<LuckyGameItem>();
    private final List<LuckyGameItem> _uniqueRewards = new ArrayList<LuckyGameItem>();
    private final List<LuckyGameItem> _additionalRewards = new ArrayList<LuckyGameItem>();

    public LuckyGameData(LuckyGameType type, int feeItemId, long feeItemCount, int gamesLimit, String reuse) {
        this._type = type;
        this._feeItemId = feeItemId;
        this._feeItemCount = feeItemCount;
        this._gamesLimit = gamesLimit;
        this._reusePattern = reuse == null ? null : new SchedulingPattern(reuse);
    }

    public LuckyGameType getType() {
        return this._type;
    }

    public int getFeeItemId() {
        return this._feeItemId;
    }

    public long getFeeItemCount() {
        return this._feeItemCount;
    }

    public int getGamesLimit() {
        return this._gamesLimit;
    }

    public SchedulingPattern getReusePattern() {
        return this._reusePattern;
    }

    public void addCommonRewards(List<LuckyGameItem> items) {
        this._commonRewards.addAll(items);
    }

    public List<LuckyGameItem> getCommonRewards() {
        return this._commonRewards;
    }

    public void addUniqueRewards(List<LuckyGameItem> items) {
        this._uniqueRewards.addAll(items);
    }

    public List<LuckyGameItem> getUniqueRewards() {
        return this._uniqueRewards;
    }

    public void addAdditionalRewards(List<LuckyGameItem> items) {
        this._additionalRewards.addAll(items);
    }

    public List<LuckyGameItem> getAdditionalRewards() {
        return this._additionalRewards;
    }

    public static LuckyGameItem rollItem(List<LuckyGameItem> items, boolean fantastic) {
        if (items.isEmpty()) {
            return null;
        }
        double chancesAmount = 0.0;
        for (LuckyGameItem item : items) {
            chancesAmount += item.getChance();
        }
        double chanceMod = (100.0 - chancesAmount) / (double)items.size();
        ArrayList<LuckyGameItem> successItems = new ArrayList<LuckyGameItem>();
        int tryCount = 0;
        while (successItems.isEmpty()) {
            ++tryCount;
            for (LuckyGameItem item : items) {
                if (tryCount % 10 == 0) {
                    chanceMod += 1.0;
                }
                if (!Rnd.chance((double)(item.getChance() + chanceMod))) continue;
                successItems.add(item);
            }
        }
        LuckyGameItem item = (LuckyGameItem)Rnd.get(successItems);
        return new LuckyGameItem(item.getId(), Rnd.get((long)item.getMinCount(), (long)item.getMaxCount()), fantastic);
    }
}

