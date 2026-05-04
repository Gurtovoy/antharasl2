package l2s.gameserver.utils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.math.SafeMath;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.instancemanager.OfflineBufferManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.item.ItemTemplate;

public final class TradeHelper {
    public static boolean checksIfCanOpenStore(Player player, int storeType) {
        if (player.getLevel() < Config.SERVICES_TRADE_MIN_LEVEL) {
            player.sendMessage(new CustomMessage("trade.NotHavePermission").addNumber(Config.SERVICES_TRADE_MIN_LEVEL));
            return false;
        }
        String tradeBan = player.getVar("tradeBan");
        if (tradeBan != null && (tradeBan.equals("-1") || Long.parseLong(tradeBan) >= System.currentTimeMillis())) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_CURRENTLY_BLOCKED_FROM_USING_THE_PRIVATE_STORE_AND_PRIVATE_WORKSHOP);
            return false;
        }
        if (storeType != 20) {
            String BLOCK_ZONE;
            if (Config.ALLOWED_TRADE_ZONES.length > 0) {
                boolean inTradeZone = false;
                for (String zoneName : Config.ALLOWED_TRADE_ZONES) {
                    if (!player.isInZone(zoneName)) continue;
                    inTradeZone = true;
                    break;
                }
                if (!inTradeZone) {
                    player.sendPacket((IBroadcastPacket)(storeType == 5 ? SystemMsg.YOU_CANNOT_OPEN_A_PRIVATE_WORKSHOP_HERE : SystemMsg.YOU_CANNOT_OPEN_A_PRIVATE_STORE_HERE));
                    return false;
                }
            }
            String string = BLOCK_ZONE = storeType == 5 ? "open_private_workshop" : "open_private_store";
            if (player.isActionBlocked(BLOCK_ZONE) && (!Config.SERVICES_NO_TRADE_ONLY_OFFLINE || Config.SERVICES_NO_TRADE_ONLY_OFFLINE && player.isInOfflineMode())) {
                player.sendPacket((IBroadcastPacket)(storeType == 5 ? SystemMsg.YOU_CANNOT_OPEN_A_PRIVATE_WORKSHOP_HERE : SystemMsg.YOU_CANNOT_OPEN_A_PRIVATE_STORE_HERE));
                return false;
            }
        }
        if (player.isCastingNow()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.A_PRIVATE_STORE_MAY_NOT_BE_OPENED_WHILE_USING_A_SKILL);
            return false;
        }
        if (player.isInCombat()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.WHILE_YOU_ARE_ENGAGED_IN_COMBAT_YOU_CANNOT_OPERATE_A_PRIVATE_STORE_OR_PRIVATE_WORKSHOP);
            return false;
        }
        if (player.isActionsDisabled() || player.isMounted() || player.isInOlympiadMode() || player.isInDuel() || player.isProcessingRequest()) {
            return false;
        }
        if (Config.SERVICES_TRADE_ONLY_FAR) {
            boolean tradenear = false;
            for (Player p : World.getAroundPlayers(player, Config.SERVICES_TRADE_RADIUS, 200)) {
                if (!p.isInStoreMode()) continue;
                tradenear = true;
                break;
            }
            if (World.getAroundNpc(player, Config.SERVICES_TRADE_RADIUS + 100, 200).size() > 0) {
                tradenear = true;
            }
            if (tradenear) {
                player.sendMessage(new CustomMessage("trade.OtherTradersNear"));
                return false;
            }
        }
        return true;
    }

    public static boolean validateStore(Player player) {
        return TradeHelper.validateStore(player, 0L);
    }

    public static boolean validateStore(Player player, long adena) {
        String BLOCK_ZONE;
        if (player.isDead()) {
            return false;
        }
        if (player.getLevel() < Config.SERVICES_TRADE_MIN_LEVEL) {
            return false;
        }
        String tradeBan = player.getVar("tradeBan");
        if (tradeBan != null && (tradeBan.equals("-1") || Long.parseLong(tradeBan) >= System.currentTimeMillis())) {
            return false;
        }
        String string = BLOCK_ZONE = player.getPrivateStoreType() == 5 ? "open_private_workshop" : "open_private_store";
        if (player.isActionBlocked(BLOCK_ZONE) && (!Config.SERVICES_NO_TRADE_ONLY_OFFLINE || Config.SERVICES_NO_TRADE_ONLY_OFFLINE && player.isInOfflineMode())) {
            return false;
        }
        switch (player.getPrivateStoreType()) {
            case 3: {
                return TradeHelper.validateBuyStore(player, adena);
            }
            case 1: 
            case 8: {
                return true;
            }
            case 5: {
                return true;
            }
        }
        if (Config.SERVICES_TRADE_ONLY_FAR) {
            for (Creature c : World.getAroundCharacters(player, Config.SERVICES_TRADE_RADIUS, 200)) {
                Player p;
                if (c.isNpc()) {
                    return false;
                }
                if (!c.isPlayer() || !(p = c.getPlayer()).isInStoreMode()) continue;
                return false;
            }
        }
        return false;
    }

    public static boolean validateBuyStore(Player player, long adena) {
        List<TradeItem> buyList = player.getBuyList();
        if (buyList.isEmpty()) {
            return false;
        }
        if (buyList.size() > player.getTradeLimit()) {
            return false;
        }
        long totalCost = adena;
        int slots = 0;
        long weight = 0L;
        try {
            for (TradeItem item : buyList) {
                ItemTemplate template = item.getItem();
                totalCost = SafeMath.addAndCheck((long)totalCost, (long)SafeMath.mulAndCheck((long)item.getCount(), (long)item.getOwnersPrice()));
                weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)item.getCount(), (long)template.getWeight()));
                if (template.isStackable() && player.getInventory().getItemByItemId(item.getItemId()) != null) continue;
                ++slots;
            }
        }
        catch (ArithmeticException ae) {
            return false;
        }
        if (totalCost > player.getAdena()) {
            return false;
        }
        if (!player.getInventory().validateWeight(weight)) {
            return false;
        }
        return player.getInventory().validateCapacity(slots);
    }

    public static final void purchaseItem(Player buyer, Player seller, TradeItem item) {
        long price = item.getCount() * item.getOwnersPrice();
        if (!item.getItem().isStackable()) {
            if (item.getEnchantLevel() > 0) {
                seller.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2S3_HAS_BEEN_SOLD_TO_C1_AT_THE_PRICE_OF_S4_ADENA).addName(buyer)).addInteger(item.getEnchantLevel())).addItemName(item.getItemId())).addLong(price));
                buyer.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2S3_HAS_BEEN_PURCHASED_FROM_C1_AT_THE_PRICE_OF_S4_ADENA).addName(seller)).addInteger(item.getEnchantLevel())).addItemName(item.getItemId())).addLong(price));
            } else {
                seller.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_IS_SOLD_TO_C1_FOR_THE_PRICE_OF_S3_ADENA).addName(buyer)).addItemName(item.getItemId())).addLong(price));
                buyer.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_HAS_BEEN_PURCHASED_FROM_C1_AT_THE_PRICE_OF_S3_ADENA).addName(seller)).addItemName(item.getItemId())).addLong(price));
            }
        } else {
            seller.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_S3_HAVE_BEEN_SOLD_TO_C1_FOR_S4_ADENA).addName(buyer)).addItemName(item.getItemId())).addLong(item.getCount())).addLong(price));
            buyer.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S3_S2_HAS_BEEN_PURCHASED_FROM_C1_FOR_S4_ADENA).addName(seller)).addItemName(item.getItemId())).addLong(item.getCount())).addLong(price));
        }
    }

    public static final long getTax(Player seller, long price) {
        long tax = (long)((double)price * Config.SERVICES_TRADE_TAX / 100.0);
        if (seller.isInZone(Zone.ZoneType.offshore)) {
            tax = (long)((double)price * Config.SERVICES_OFFSHORE_TRADE_TAX / 100.0);
        }
        if (Config.SERVICES_TRADE_TAX_ONLY_OFFLINE && !seller.isInOfflineMode()) {
            tax = 0L;
        }
        if (Config.SERVICES_PARNASSUS_NOTAX && seller.getReflection() == ReflectionManager.PARNASSUS) {
            tax = 0L;
        }
        return tax;
    }

    public static void cancelStore(Player activeChar) {
        activeChar.setPrivateStoreType(0);
        activeChar.storePrivateStore();
        if (activeChar.isInOfflineMode()) {
            activeChar.setOfflineMode(false);
            activeChar.kick();
        } else {
            activeChar.broadcastCharInfo();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static int restoreOfflineTraders() throws Exception {
        int count = 0;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_variables WHERE name = 'offline' AND value < ?");
            statement.setInt(1, (int)(System.currentTimeMillis() / 1000L));
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_variables WHERE name = 'offline' AND obj_id IN (SELECT obj_id FROM characters WHERE accessLevel < 0)");
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("SELECT obj_id, value FROM character_variables WHERE name = 'offline'");
            rset = statement.executeQuery();
            while (rset.next()) {
                int objectId = rset.getInt("obj_id");
                int expireTimeSecs = rset.getInt("value");
                Player p = Player.restore(objectId, false);
                if (p == null) continue;
                if (!TradeHelper.validateStore(p)) {
                    p.setPrivateStoreType(0);
                    p.storePrivateStore();
                    p.setOfflineMode(false);
                    p.kick();
                    continue;
                }
                p.startAbnormalEffect(Config.SERVICES_OFFLINE_TRADE_ABNORMAL_EFFECT);
                p.setOfflineMode(true);
                p.setOnlineStatus(true);
                p.entering = false;
                p.spawnMe();
                if (p.getClan() != null && p.getClan().getAnyMember(p.getObjectId()) != null) {
                    p.getClan().getAnyMember(p.getObjectId()).setPlayerInstance(p, false);
                }
                if (expireTimeSecs != Integer.MAX_VALUE) {
                    p.startKickTask((long)expireTimeSecs * 1000L - System.currentTimeMillis());
                }
                ++count;
            }
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement, rset);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return count;
    }

    public static int getOfflineTradersCount() {
        return GameObjectsStorage.getOfflinePlayers().size();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static int restoreOfflineBuffers() throws Exception {
        int count = 0;
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_variables WHERE name = 'offlinebuff' AND value < ?");
            statement.setInt(1, (int)(System.currentTimeMillis() / 1000L));
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_variables WHERE name = 'offlinebuff' AND obj_id IN (SELECT obj_id FROM characters WHERE accessLevel < 0)");
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("SELECT c1.obj_id obj_id, c1.value expire_time, c2.value price, c3.value skills, c4.value title FROM character_variables AS c1 INNER JOIN character_variables AS c2 ON c1.obj_id = c2.obj_id AND c2.name = 'offlinebuff_price' INNER JOIN character_variables AS c3 ON c1.obj_id = c3.obj_id AND c3.name = 'offlinebuff_skills' LEFT JOIN character_variables AS c4 ON c1.obj_id = c4.obj_id AND c4.name = 'offlinebuff_title' WHERE c1.name = 'offlinebuff'");
            rset = statement.executeQuery();
            while (rset.next()) {
                int objectId = rset.getInt("obj_id");
                int expireTimeSecs = rset.getInt("expire_time");
                long price = rset.getLong("price");
                int[] skills = StringArrayUtils.stringToIntArray((String)rset.getString("skills"), (String)",");
                String title = rset.getString("title");
                Player p = Player.restore(objectId, false);
                if (p == null) continue;
                p.startAbnormalEffect(Config.SERVICES_OFFLINE_TRADE_ABNORMAL_EFFECT);
                p.setOfflineMode(true);
                p.setOnlineStatus(true);
                p.setPrivateStoreType(20);
                p.setSitting(true);
                p.entering = false;
                p.spawnMe();
                if (p.getClan() != null && p.getClan().getAnyMember(p.getObjectId()) != null) {
                    p.getClan().getAnyMember(p.getObjectId()).setPlayerInstance(p, false);
                }
                if (expireTimeSecs != Integer.MAX_VALUE) {
                    p.startKickTask((long)expireTimeSecs * 1000L - System.currentTimeMillis());
                }
                OfflineBufferManager.BufferData buffer = new OfflineBufferManager.BufferData(p, title, price, null);
                for (int skillId : skills) {
                    SkillEntry skill = p.getKnownSkill(skillId);
                    if (skill == null) continue;
                    buffer.getBuffs().put(skill.getId(), skill);
                }
                OfflineBufferManager.getInstance().getBuffStores().put(p.getObjectId(), buffer);
                ++count;
            }
        }
        catch (Throwable throwable) {
            DbUtils.closeQuietly((Connection)con, statement, rset);
            throw throwable;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return count;
    }
}

