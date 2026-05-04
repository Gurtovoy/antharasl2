/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import gnu.trove.iterator.TIntLongIterator;
import gnu.trove.map.hash.TIntLongHashMap;
import java.util.ArrayList;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.LuckyGameHolder;
import l2s.gameserver.instancemanager.ServerVariables;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExBettingLuckyGameResult;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.luckygame.LuckyGameData;
import l2s.gameserver.templates.luckygame.LuckyGameItem;
import l2s.gameserver.templates.luckygame.LuckyGameType;
import l2s.gameserver.utils.ItemFunctions;

public class RequestLuckyGamePlay
extends L2GameClientPacket {
    private int _typeId;
    private int _gamesCount;

    @Override
    protected boolean readImpl() {
        this._typeId = this.readD();
        this._gamesCount = Math.min(this.readD(), 50);
        return true;
    }

    /*
     * Enabled aggressive block sorting
     */
    @Override
    protected void runImpl() {
        int playedGamesCount;
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (this._gamesCount <= 0) {
            return;
        }
        if (!Config.ALLOW_LUCKY_GAME_EVENT) {
            return;
        }
        if (this._typeId < 0 || this._typeId >= LuckyGameType.VALUES.length) {
            return;
        }
        LuckyGameData gameData = LuckyGameHolder.getInstance().getData(LuckyGameType.VALUES[this._typeId]);
        if (gameData == null) {
            return;
        }
        if (player.getWeightPenalty() >= 3 || (double)player.getInventoryLimit() * 0.8 < (double)player.getInventory().getSize()) {
            player.sendPacket((IBroadcastPacket)new ExBettingLuckyGameResult(-2, gameData.getType()));
            player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_INVENTORY_IS_EITHER_FULL_OR_OVERWEIGHT);
            return;
        }
        int gamesLimit = gameData.getGamesLimit();
        if (gamesLimit > 0) {
            playedGamesCount = player.getVarInt("@played_lucky_games" + gameData.getType().ordinal(), 0);
            this._gamesCount = Math.min(this._gamesCount, gamesLimit - playedGamesCount);
            if (this._gamesCount <= 0) {
                return;
            }
        } else {
            playedGamesCount = 0;
        }
        if (gameData.getFeeItemId() == -1) {
            this._gamesCount = Math.min(this._gamesCount, (int)(player.getPremiumPoints() / gameData.getFeeItemCount()));
            if (this._gamesCount <= 0) {
                return;
            }
            int consumePointsCount = (int)((long)this._gamesCount * gameData.getFeeItemCount());
            if (!player.reducePremiumPoints(consumePointsCount)) {
                player.sendPacket((IBroadcastPacket)new ExBettingLuckyGameResult(-1, gameData.getType()));
                return;
            }
            if (gameData.getType() == LuckyGameType.LUXURY) {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.ROUND_S1_OF_LUXURY_FORTUNE_READING_COMPLETE).addInteger(this._gamesCount));
            } else {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.ROUND_S1_OF_FORTUNE_READING_COMPLETE).addInteger(this._gamesCount));
            }
        } else {
            this._gamesCount = Math.min(this._gamesCount, (int)(ItemFunctions.getItemCount(player, gameData.getFeeItemId()) / gameData.getFeeItemCount()));
            if (this._gamesCount <= 0) {
                return;
            }
            long consumeItemsCount = (long)this._gamesCount * gameData.getFeeItemCount();
            if (!ItemFunctions.deleteItem((Playable)player, gameData.getFeeItemId(), consumeItemsCount, false)) {
                player.sendPacket((IBroadcastPacket)new ExBettingLuckyGameResult(-1, gameData.getType()));
                return;
            }
            if (gameData.getType() == LuckyGameType.LUXURY) {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.ROUND_S1_OF_LUXURY_FORTUNE_READING_COMPLETE).addInteger(this._gamesCount));
            } else {
                player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.ROUND_S1_OF_FORTUNE_READING_COMPLETE).addInteger(this._gamesCount));
            }
            player.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(gameData.getFeeItemId(), consumeItemsCount));
        }
        if (gamesLimit > 0) {
            SchedulingPattern reusePattern = gameData.getReusePattern();
            player.setVar("@played_lucky_games" + gameData.getType().ordinal(), playedGamesCount + this._gamesCount, reusePattern == null ? -1L : reusePattern.next(System.currentTimeMillis()));
        }
        int serverGamesCount = ServerVariables.getInt("@lucky_games_count" + gameData.getType().ordinal(), 0);
        ServerVariables.set("@lucky_games_count" + gameData.getType().ordinal(), serverGamesCount + this._gamesCount);
        int personalGamesCount = player.getVarInt("@lucky_games_count" + gameData.getType().ordinal(), 0);
        player.setVar("@lucky_games_count" + gameData.getType().ordinal(), personalGamesCount + this._gamesCount);
        TIntLongHashMap rewardsMap = new TIntLongHashMap();
        ArrayList<LuckyGameItem> rewards = new ArrayList<LuckyGameItem>();
        for (int i = 1; i <= this._gamesCount; ++i) {
            boolean uniqueReward = (serverGamesCount + i) % Config.LUCKY_GAME_UNIQUE_REWARD_GAMES_COUNT == 0;
            boolean additionalReward = (personalGamesCount + i) % Config.LUCKY_GAME_ADDITIONAL_REWARD_GAMES_COUNT == 0;
            LuckyGameItem reward = null;
            if (uniqueReward && (reward = LuckyGameData.rollItem(gameData.getUniqueRewards(), true)) != null) {
                SystemMessagePacket sm = gameData.getType() == LuckyGameType.LUXURY ? new SystemMessagePacket(SystemMsg.CONGRATULATIONS_C1_HAS_OBTAINED_S2_OF_S3_IN_THE_LUXURY_FORTUNE_READING) : new SystemMessagePacket(SystemMsg.CONGRATULATIONS_C1_HAS_OBTAINED_S2_OF_S3_THROUGH_FORTUNE_READING);
                sm.addName(player);
                sm.addItemName(reward.getId());
                sm.addLong(reward.getCount());
                Announcements.announceToAll(sm);
            }
            if (reward == null && additionalReward) {
                reward = LuckyGameData.rollItem(gameData.getAdditionalRewards(), true);
            }
            if (reward == null) {
                reward = LuckyGameData.rollItem(gameData.getCommonRewards(), false);
            }
            if (reward == null) continue;
            rewards.add(reward);
            rewardsMap.put(reward.getId(), rewardsMap.get(reward.getId()) + reward.getCount());
        }
        TIntLongIterator iterator = rewardsMap.iterator();
        while (true) {
            if (!iterator.hasNext()) {
                player.sendPacket((IBroadcastPacket)new ExBettingLuckyGameResult(player, gameData, rewards));
                return;
            }
            iterator.advance();
            ItemFunctions.addItem(player, iterator.key(), iterator.value());
        }
    }
}

