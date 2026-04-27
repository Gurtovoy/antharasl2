package l2s.gameserver.instancemanager;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import l2s.commons.geometry.Point3D;
import l2s.commons.util.Rnd;
import l2s.gameserver.dao.AutobotsDAO;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.dao.TradeBotsDAO;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.autobot.AutobotInfo;
import l2s.gameserver.model.autobot.TradeZoneInfo;
import l2s.gameserver.model.autobot.TraderInfo;
import l2s.gameserver.model.autobot.TraderInfo.TradeItemConfig;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.c2s.CharacterCreate;
import l2s.gameserver.network.l2.c2s.EnterWorld;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AutobotsManager
{
	private static final Logger _log = LoggerFactory.getLogger(AutobotsManager.class);
	private static final AutobotsManager _instance = new AutobotsManager();

	private final ConcurrentHashMap<Integer, Player> _activeBots = new ConcurrentHashMap<>();
	private final ConcurrentHashMap<String, Integer> _nameIndex = new ConcurrentHashMap<>();
	private final ConcurrentHashMap<Integer, TraderInfo> _activeTraders = new ConcurrentHashMap<>(); // traderId -> TraderInfo
	private final Set<Integer> _spawningTraders = ConcurrentHashMap.newKeySet();
	private final Object _tradeLock = new Object();
	private int _registeredCount = 0;

	public static AutobotsManager getInstance()
	{
		return _instance;
	}

	private AutobotsManager()
	{
	}

	public void init()
	{
		List<AutobotInfo> allBots = AutobotsDAO.getInstance().loadAll();
		_registeredCount = allBots.size();

		// Reset online status for all bots on startup
		for(AutobotInfo info : allBots)
		{
			if(info.isOnline())
			{
				AutobotsDAO.getInstance().updateOnlineStatus(info.getObjId(), false);
			}
		}

		_log.info("AutobotsManager: Loaded " + _registeredCount + " registered autobots.");
	}

	/**
	 * Spawn a single bot by object ID.
	 * Uses the same spawn pattern as FakePlayersTable: Player.create() + CharacterCreate.initNewChar() + Player.restore() + EnterWorld.onEnterWorld().
	 * If the bot already exists in the characters table, it will be restored directly.
	 */
	public Player spawnBot(int objId)
	{
		return spawnBot(objId, true);
	}

	/**
	 * Spawn a single bot by object ID.
	 * @param objId bot object ID
	 * @param fake if true, uses FakeAI (autonomous behavior); if false, uses PlayerAI (passive, for trade bots)
	 */
	public Player spawnBot(int objId, boolean fake)
	{
		if(_activeBots.containsKey(objId))
		{
			_log.warn("AutobotsManager: Bot " + objId + " is already active, skipping spawn.");
			return _activeBots.get(objId);
		}

		AutobotInfo info = AutobotsDAO.getInstance().loadById(objId);
		if(info == null)
		{
			_log.warn("AutobotsManager: Bot " + objId + " not found in database.");
			return null;
		}

		try
		{
			// Check if already in world (e.g. logged in via other means)
			Player existing = GameObjectsStorage.getPlayer(objId);
			if(existing != null)
			{
				_log.warn("AutobotsManager: Player " + objId + " already exists in GameObjectsStorage, registering as active bot.");
				_activeBots.put(objId, existing);
				_nameIndex.put(info.getName().toLowerCase(), objId);
				AutobotsDAO.getInstance().updateOnlineStatus(objId, true);
				return existing;
			}

			// Try to restore from characters table first
			Player player = Player.restore(objId, fake);

			// If not in characters table, create the character first (like FakePlayersTable)
			if(player == null)
			{
				_log.info("AutobotsManager: Bot " + info.getName() + " not found in characters table, creating...");
				player = Player.create(
					info.getClassId(),
					info.getSex(),
					"#autobot_account",
					info.getName(),
					info.getHairStyle(),
					info.getHairColor(),
					info.getFace()
				);
				if(player == null)
				{
					_log.warn("AutobotsManager: Player.create() failed for bot " + info.getName() + " (classId=" + info.getClassId() + ").");
					return null;
				}

				CharacterCreate.initNewChar(player);

				// Update the autobots table objId to match the ID assigned by Player.create()/IdFactory
				int newObjId = player.getObjectId();
				if(newObjId != objId)
				{
					_log.info("AutobotsManager: Updating bot objId from " + objId + " to " + newObjId + " for " + info.getName());
					AutobotsDAO.getInstance().updateObjId(objId, newObjId);
					objId = newObjId;
				}

				// Now restore the fully-created character
				player = Player.restore(newObjId, fake);
				if(player == null)
				{
					_log.warn("AutobotsManager: Player.restore() failed after create for bot " + info.getName() + " (objId=" + newObjId + ").");
					return null;
				}
			}

			EnterWorld.onEnterWorld(player);

			_activeBots.put(objId, player);
			_nameIndex.put(info.getName().toLowerCase(), objId);
			AutobotsDAO.getInstance().updateOnlineStatus(objId, true);

			_log.info("AutobotsManager: Spawned bot " + info.getName() + " (objId=" + objId + ").");
			return player;
		}
		catch(Exception e)
		{
			_log.error("AutobotsManager: Error spawning bot " + objId + " (" + info.getName() + "): " + e.getMessage(), e);
			return null;
		}
	}

	/**
	 * Spawn a bot by name.
	 */
	public Player spawnBotByName(String name)
	{
		if(name == null || name.isEmpty())
		{
			return null;
		}

		AutobotInfo info = AutobotsDAO.getInstance().loadByName(name);
		if(info == null)
		{
			_log.warn("AutobotsManager: Bot with name '" + name + "' not found in database.");
			return null;
		}

		return spawnBot(info.getObjId());
	}

	/**
	 * Despawn a single bot by object ID.
	 */
	public boolean despawnBot(int objId)
	{
		Player player = _activeBots.remove(objId);
		if(player == null)
		{
			return false;
		}

		try
		{
			// Remove from name index
			String name = player.getName();
			if(name != null)
			{
				_nameIndex.remove(name.toLowerCase());
			}

			// Logout the player (handles world removal, saving, etc.)
			player.logout();

			AutobotsDAO.getInstance().updateOnlineStatus(objId, false);

			_log.info("AutobotsManager: Despawned bot " + name + " (objId=" + objId + ").");
			return true;
		}
		catch(Exception e)
		{
			_log.error("AutobotsManager: Error despawning bot " + objId + ": " + e.getMessage(), e);
			AutobotsDAO.getInstance().updateOnlineStatus(objId, false);
			return false;
		}
	}

	/**
	 * Despawn all active bots.
	 */
	public void despawnAll()
	{
		List<Integer> botIds = new ArrayList<>(_activeBots.keySet());
		for(int objId : botIds)
		{
			try
			{
				despawnBot(objId);
			}
			catch(Exception e)
			{
				_log.error("AutobotsManager: Error despawning bot " + objId + " during despawnAll: " + e.getMessage(), e);
			}
		}
		_log.info("AutobotsManager: All bots despawned.");
	}

	/**
	 * Spawn N random offline bots with staggered delays.
	 */
	public void spawnRandom(int count)
	{
		if(count <= 0)
		{
			return;
		}

		List<AutobotInfo> allBots = AutobotsDAO.getInstance().loadAll();
		List<Integer> offlineBotIds = new ArrayList<>();
		for(AutobotInfo info : allBots)
		{
			if(!_activeBots.containsKey(info.getObjId()))
			{
				offlineBotIds.add(info.getObjId());
			}
		}

		Collections.shuffle(offlineBotIds);
		int toSpawn = Math.min(count, offlineBotIds.size());

		_log.info("AutobotsManager: Scheduling spawn of " + toSpawn + " random bots...");

		for(int i = 0; i < toSpawn; i++)
		{
			final int objId = offlineBotIds.get(i);
			ThreadPoolManager.getInstance().schedule(() -> {
				try
				{
					spawnBot(objId);
				}
				catch(Exception e)
				{
					_log.error("AutobotsManager: Error in scheduled spawn of bot " + objId + ": " + e.getMessage(), e);
				}
			}, (long) i * 1000L);
		}
	}

	/**
	 * Despawn N random online bots with staggered delays.
	 */
	public void despawnRandom(int count)
	{
		if(count <= 0)
		{
			return;
		}

		List<Integer> activeBotIds = new ArrayList<>(_activeBots.keySet());
		Collections.shuffle(activeBotIds);
		int toDespawn = Math.min(count, activeBotIds.size());

		_log.info("AutobotsManager: Scheduling despawn of " + toDespawn + " random bots...");

		for(int i = 0; i < toDespawn; i++)
		{
			final int objId = activeBotIds.get(i);
			ThreadPoolManager.getInstance().schedule(() -> {
				try
				{
					despawnBot(objId);
				}
				catch(Exception e)
				{
					_log.error("AutobotsManager: Error in scheduled despawn of bot " + objId + ": " + e.getMessage(), e);
				}
			}, (long) i * 1000L);
		}
	}

	/**
	 * Get an active bot by object ID.
	 */
	public Player getActiveBot(int objId)
	{
		return _activeBots.get(objId);
	}

	/**
	 * Get an active bot by name (case-insensitive).
	 */
	public Player getActiveBotByName(String name)
	{
		if(name == null)
		{
			return null;
		}
		Integer objId = _nameIndex.get(name.toLowerCase());
		if(objId == null)
		{
			return null;
		}
		return _activeBots.get(objId);
	}

	/**
	 * Get an unmodifiable collection of all active bots.
	 */
	public Collection<Player> getActiveBots()
	{
		return Collections.unmodifiableCollection(_activeBots.values());
	}

	/**
	 * Get the count of currently active bots.
	 */
	public int getActiveBotCount()
	{
		return _activeBots.size();
	}

	/**
	 * Check if a bot is currently active.
	 */
	public boolean isActive(int objId)
	{
		return _activeBots.containsKey(objId);
	}

	/**
	 * Get the total number of registered bots.
	 */
	public int getRegisteredCount()
	{
		return _registeredCount;
	}

	// DAO delegation methods

	public List<AutobotInfo> searchBots(String nameFilter, int page, int pageSize)
	{
		return AutobotsDAO.getInstance().searchBots(nameFilter, page, pageSize);
	}

	public AutobotInfo getBotInfo(int objId)
	{
		return AutobotsDAO.getInstance().loadById(objId);
	}

	public void saveBotInfo(AutobotInfo info)
	{
		AutobotsDAO.getInstance().save(info);
	}

	public void deleteBotInfo(int objId)
	{
		// Despawn if active
		if(_activeBots.containsKey(objId))
		{
			despawnBot(objId);
		}
		AutobotsDAO.getInstance().delete(objId);
	}

	/**
	 * Shutdown the manager — despawn all bots and stop the scheduler.
	 */
	public void shutdown()
	{
		_log.info("AutobotsManager: Shutting down...");
		// Despawn all active traders first
		for(TraderInfo trader : new ArrayList<>(_activeTraders.values()))
		{
			try
			{
				despawnTrader(trader.getId());
			}
			catch(Exception e)
			{
				_log.error("AutobotsManager: Error despawning trader " + trader.getId() + " during shutdown: " + e.getMessage(), e);
			}
		}
		despawnAll();
		_log.info("AutobotsManager: Shutdown complete.");
	}

	// ==================== Trade Bot System ====================

	/**
	 * Calculate grid slot position within a trade zone.
	 */
	public Point3D calculateSlotPosition(TradeZoneInfo zone, int slotIndex)
	{
		int MIN_SPACING = 80;

		int zoneWidth = zone.getX2() - zone.getX1();
		int zoneHeight = zone.getY2() - zone.getY1();

		// Calculate max traders that fit with minimum spacing
		int maxCols = Math.max(1, zoneWidth / MIN_SPACING + 1);
		int maxRows = Math.max(1, zoneHeight / MIN_SPACING + 1);
		int effectiveMax = Math.min(zone.getMaxTraders(), maxCols * maxRows);

		int cols = (int) Math.ceil(Math.sqrt(effectiveMax));
		int rows = (int) Math.ceil((double) effectiveMax / cols);

		// Ensure cols/rows don't exceed what fits
		cols = Math.min(cols, maxCols);
		rows = Math.min(rows, maxRows);

		int col = slotIndex % cols;
		int row = slotIndex / cols;

		int dx = cols > 1 ? zoneWidth / (cols - 1) : 0;
		int dy = rows > 1 ? zoneHeight / (rows - 1) : 0;

		// Enforce minimum spacing
		dx = Math.max(dx, MIN_SPACING);
		dy = Math.max(dy, MIN_SPACING);

		int x = zone.getX1() + col * dx;
		int y = zone.getY1() + row * dy;
		return new Point3D(x, y, zone.getZ());
	}

	/**
	 * Find the next available slot index in a zone.
	 */
	private int findNextAvailableSlot(int zoneId, TradeZoneInfo zone)
	{
		List<TraderInfo> traders = TradeBotsDAO.getInstance().loadTradersByZone(zoneId);
		Set<Integer> usedSlots = new HashSet<>();
		for(TraderInfo t : traders)
		{
			if(t.getSlotIndex() >= 0)
			{
				usedSlots.add(t.getSlotIndex());
			}
		}
		for(int i = 0; i < zone.getMaxTraders(); i++)
		{
			if(!usedSlots.contains(i))
			{
				return i;
			}
		}
		return -1; // no available slot
	}

	/**
	 * Spawn and activate a trade bot.
	 * Does NOT hold _tradeLock during heavy operations to avoid blocking other spawns.
	 */
	public boolean spawnTrader(int traderId)
	{
		// Quick check: already active?
		if(_activeTraders.containsKey(traderId))
		{
			_log.warn("AutobotsManager: Trader " + traderId + " is already active.");
			return true;
		}

		// Prevent concurrent spawn of the same trader
		if(!_spawningTraders.add(traderId))
		{
			_log.warn("AutobotsManager: Trader " + traderId + " is already being spawned.");
			return false;
		}

		try
		{
			TraderInfo trader = TradeBotsDAO.getInstance().loadTrader(traderId);
			if(trader == null)
			{
				_log.warn("AutobotsManager: Trader " + traderId + " not found in database.");
				return false;
			}

			TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(trader.getZoneId());
			if(zone == null)
			{
				_log.warn("AutobotsManager: Trade zone " + trader.getZoneId() + " not found for trader " + traderId + ".");
				return false;
			}

			// Auto-assign slot if needed (synchronized for slot allocation safety)
			if(trader.getSlotIndex() < 0)
			{
				synchronized(_tradeLock)
				{
					int slot = findNextAvailableSlot(trader.getZoneId(), zone);
					if(slot < 0)
					{
						_log.warn("AutobotsManager: No available slots in zone " + zone.getName() + " for trader " + traderId + ".");
						return false;
					}
					trader.setSlotIndex(slot);
					TradeBotsDAO.getInstance().saveTrader(trader);
				}
			}

			// If bot is already active as non-trader, despawn first
			if(_activeBots.containsKey(trader.getBotId()))
			{
				_log.info("AutobotsManager: Bot " + trader.getBotId() + " is already active, despawning before trade spawn.");
				despawnBot(trader.getBotId());
			}

			// 1. Spawn the bot as NON-FAKE (PlayerAI, no autonomous behavior)
			// Trade bots only need to sit and have a store — FakeAI would interfere by making them walk/fight
			Player bot = spawnBot(trader.getBotId(), false);
			if(bot == null)
			{
				_log.warn("AutobotsManager: Failed to spawn bot " + trader.getBotId() + " for trader " + traderId + ".");
				return false;
			}

			try
			{
				_log.info("AutobotsManager: [TRADER " + traderId + "] Bot " + bot.getName() + " (objId=" + bot.getObjectId() + ") spawned. isFake=" + bot.isFakePlayer() + ", isVisible=" + bot.isVisible() + ", inventory=" + bot.getInventory() + ", invSize=" + bot.getInventory().getSize());

				// 2. Calculate position and teleport
				Point3D pos = calculateSlotPosition(zone, trader.getSlotIndex());
				bot.teleToLocation(pos.getX(), pos.getY(), pos.getZ());
				// teleToLocation() calls decayMe() which removes the bot from the world grid.
				// For real clients, onTeleported() is triggered by a client confirmation packet.
				// For fake players (isFake=true), it's called automatically in Creature.teleToLocation().
				// Trade bots use isFake=false (no FakeAI), so we must call onTeleported() manually
				// to trigger spawnMe() and make the bot visible again.
				if(!bot.isFakePlayer())
				{
					bot.onTeleported();
				}

				_log.info("AutobotsManager: [TRADER " + traderId + "] Teleported to (" + pos.getX() + ", " + pos.getY() + ", " + pos.getZ() + "). isVisible=" + bot.isVisible() + ", loc=" + bot.getLoc());

				// 3. Give inventory items based on trade type
				List<TradeItemConfig> items = trader.getItems();
				_log.info("AutobotsManager: [TRADER " + traderId + "] Trade type=" + trader.getTradeType() + ", items count=" + items.size() + ", itemsJson=" + (trader.getItemsJson() != null ? trader.getItemsJson().substring(0, Math.min(200, trader.getItemsJson().length())) : "null"));

				if(items.isEmpty())
				{
					_log.warn("AutobotsManager: [TRADER " + traderId + "] WARNING: items list is EMPTY! Store will have nothing to trade. itemsJson='" + trader.getItemsJson() + "'");
				}

				if("sell".equals(trader.getTradeType()))
				{
					// SELL store: give ONLY the items the bot is selling + adena for change
					// Each item is added exactly once; stackable items merge automatically
					for(TradeItemConfig item : items)
					{
						List<ItemInstance> addResult = ItemFunctions.addItem(bot, item.getItemId(), item.getCount(), false);
						if(addResult == null || addResult.isEmpty())
						{
							_log.warn("AutobotsManager: [TRADER " + traderId + "] addItem FAILED for itemId=" + item.getItemId() + ", count=" + item.getCount() + " — returned empty/null!");
						}
						else
						{
							_log.info("AutobotsManager: [TRADER " + traderId + "] addItem(" + item.getItemId() + ", count=" + item.getCount() + ") OK, returned " + addResult.size() + " items");
						}
					}
					// Give adena for making change (buyers pay adena, bot needs to hold some)
					ItemFunctions.addItem(bot, 57, 9999999999L, false);

					_log.info("AutobotsManager: [TRADER " + traderId + "] Inventory AFTER adding trade items: size=" + bot.getInventory().getSize());

					setupSellStore(bot, trader, items);
				}
				else
				{
					// BUY store: give ONLY adena (the bot needs money to buy from players)
					ItemFunctions.addItem(bot, 57, 9999999999L, false);
					_log.info("AutobotsManager: [TRADER " + traderId + "] BUY store: added adena only. Adena=" + bot.getAdena());

					setupBuyStore(bot, trader, items);
				}

				// Persist inventory to DB as safety measure
				bot.getInventory().store();

				_log.info("AutobotsManager: [TRADER " + traderId + "] Store type=" + bot.getPrivateStoreType() + ", sellList size=" + bot.getSellList().size() + ", buyList size=" + bot.getBuyList().size());

				// 5. Store + broadcast + sit (correct sequence from SetPrivateStoreSellList/SetPrivateStoreBuyList)
				bot.storePrivateStore();
				bot.broadcastPrivateStoreInfo();
				bot.sitDown(null);
				bot.broadcastCharInfo();

				// 6. Update active status
				trader.setActive(true);
				TradeBotsDAO.getInstance().updateTraderActive(traderId, true);
				_activeTraders.put(traderId, trader);

				_log.info("AutobotsManager: Trader " + traderId + " (bot " + trader.getBotId() + ") activated in zone " + zone.getName() + " slot " + trader.getSlotIndex() + ". Final storeType=" + bot.getPrivateStoreType() + ", isVisible=" + bot.isVisible() + ", invSize=" + bot.getInventory().getSize() + ", adena=" + bot.getAdena());
				return true;
			}
			catch(Exception e)
			{
				_log.error("AutobotsManager: Error setting up trader " + traderId + ": " + e.getMessage(), e);
				// Clean up: despawn the bot if setup failed
				despawnBot(trader.getBotId());
				return false;
			}
		}
		finally
		{
			_spawningTraders.remove(traderId);
		}
	}

	/**
	 * Set up a sell private store for a bot.
	 */
	private void setupSellStore(Player bot, TraderInfo trader, List<TradeItemConfig> items)
	{
		Map<Integer, TradeItem> sellList = new LinkedHashMap<>();
		bot.getInventory().writeLock();
		try
		{
			for(TradeItemConfig cfg : items)
			{
				ItemInstance item = bot.getInventory().getItemByItemId(cfg.getItemId());
				if(item == null)
				{
					_log.warn("AutobotsManager: [SELL SETUP] Item " + cfg.getItemId() + " NOT FOUND in bot " + bot.getObjectId() + " (" + bot.getName() + ") inventory. InvSize=" + bot.getInventory().getSize());
					// Log all items in inventory for debugging
					for(ItemInstance inv : bot.getInventory().getItems())
					{
						_log.warn("AutobotsManager: [SELL SETUP]   inv item: objId=" + inv.getObjectId() + ", itemId=" + inv.getItemId() + ", count=" + inv.getCount() + ", loc=" + inv.getLocation());
					}
					continue;
				}
				TradeItem tradeItem = new TradeItem(item);
				tradeItem.setCount(cfg.getCount());
				tradeItem.setOwnersPrice(cfg.getPrice());
				sellList.put(item.getObjectId(), tradeItem);
				_log.info("AutobotsManager: [SELL SETUP] Added to sellList: itemId=" + cfg.getItemId() + ", objId=" + item.getObjectId() + ", count=" + cfg.getCount() + ", price=" + cfg.getPrice());
			}
		}
		finally
		{
			bot.getInventory().writeUnlock();
		}

		if(!sellList.isEmpty())
		{
			bot.setSellList(false, sellList);
			bot.setSellStoreName(trader.getStoreName());
			bot.setPrivateStoreType(1); // SELL
			_log.info("AutobotsManager: [SELL SETUP] Store configured: sellList size=" + sellList.size() + ", storeName='" + trader.getStoreName() + "', storeType=SELL(1)");
		}
		else
		{
			_log.error("AutobotsManager: [SELL SETUP] CRITICAL: sellList is EMPTY for bot " + bot.getObjectId() + " (" + bot.getName() + ")! Store type will NOT be set. Items config count=" + items.size());
		}
	}

	/**
	 * Set up a buy private store for a bot.
	 */
	private void setupBuyStore(Player bot, TraderInfo trader, List<TradeItemConfig> items)
	{
		CopyOnWriteArrayList<TradeItem> buyList = new CopyOnWriteArrayList<>();
		for(TradeItemConfig cfg : items)
		{
			TradeItem tradeItem = new TradeItem();
			tradeItem.setItemId(cfg.getItemId());
			tradeItem.setCount(cfg.getCount());
			tradeItem.setOwnersPrice(cfg.getPrice());
			tradeItem.setEnchantLevel(0);
			tradeItem.setObjectId(0);
			buyList.add(tradeItem);
		}

		if(!buyList.isEmpty())
		{
			bot.setBuyList(buyList);
			bot.setBuyStoreName(trader.getStoreName());
			bot.setPrivateStoreType(3); // BUY
			_log.info("AutobotsManager: [BUY SETUP] Store configured: buyList size=" + buyList.size() + ", storeName='" + trader.getStoreName() + "', storeType=BUY(3)");
		}
		else
		{
			_log.error("AutobotsManager: [BUY SETUP] CRITICAL: buyList is EMPTY for bot " + bot.getObjectId() + " (" + bot.getName() + ")! Store type will NOT be set. Items config count=" + items.size());
		}
	}

	/**
	 * Despawn and deactivate a trade bot.
	 */
	public boolean despawnTrader(int traderId)
	{
		synchronized(_tradeLock)
		{
			TraderInfo trader = _activeTraders.get(traderId);
			if(trader == null)
			{
				// Not in memory, but try to update DB anyway
				TradeBotsDAO.getInstance().updateTraderActive(traderId, false);
				return false;
			}

			try
			{
				Player bot = _activeBots.get(trader.getBotId());
				if(bot != null)
				{
					// Stand up and clear store
					bot.standUp();
					bot.setPrivateStoreType(0);
					bot.broadcastCharInfo();

					// Despawn bot
					despawnBot(trader.getBotId());
				}

				TradeBotsDAO.getInstance().updateTraderActive(traderId, false);

				_log.info("AutobotsManager: Trader " + traderId + " (bot " + trader.getBotId() + ") deactivated.");
				return true;
			}
			catch(Exception e)
			{
				_log.error("AutobotsManager: Error despawning trader " + traderId + ": " + e.getMessage(), e);
				TradeBotsDAO.getInstance().updateTraderActive(traderId, false);
				return false;
			}
			finally
			{
				_activeTraders.remove(traderId);
				_spawningTraders.remove(traderId);
			}
		}
	}

	/**
	 * Spawn a trader asynchronously on the game server thread pool.
	 * Returns immediately — result is logged.
	 */
	public void spawnTraderAsync(int traderId)
	{
		ThreadPoolManager.getInstance().execute(() -> {
			try
			{
				spawnTrader(traderId);
			}
			catch(Exception e)
			{
				_log.error("AutobotsManager: Error in async trader spawn " + traderId + ": " + e.getMessage(), e);
			}
		});
	}

	/**
	 * Activate all traders in a zone asynchronously on the game server thread pool.
	 */
	public void activateZoneAsync(int zoneId)
	{
		ThreadPoolManager.getInstance().execute(() -> {
			try
			{
				activateZone(zoneId);
			}
			catch(Exception e)
			{
				_log.error("AutobotsManager: Error in async zone activation " + zoneId + ": " + e.getMessage(), e);
			}
		});
	}

	/**
	 * Activate all traders in a zone.
	 */
	public int activateZone(int zoneId)
	{
		List<TraderInfo> traders = TradeBotsDAO.getInstance().loadTradersByZone(zoneId);
		int count = 0;
		for(TraderInfo trader : traders)
		{
			if(!trader.isActive() && !_activeTraders.containsKey(trader.getId()) && spawnTrader(trader.getId()))
			{
				count++;
			}
		}
		return count;
	}

	/**
	 * Deactivate all traders in a zone.
	 */
	public int deactivateZone(int zoneId)
	{
		List<TraderInfo> traders = TradeBotsDAO.getInstance().loadTradersByZone(zoneId);
		int count = 0;
		for(TraderInfo trader : traders)
		{
			if(trader.isActive() && despawnTrader(trader.getId()))
			{
				count++;
			}
		}
		return count;
	}

	/**
	 * Get count of active traders in a zone.
	 */
	public int getActiveTraderCountInZone(int zoneId)
	{
		int count = 0;
		for(TraderInfo trader : _activeTraders.values())
		{
			if(trader.getZoneId() == zoneId)
			{
				count++;
			}
		}
		return count;
	}

	/**
	 * Check if a trader is currently active.
	 */
	public boolean isTraderActive(int traderId)
	{
		return _activeTraders.containsKey(traderId);
	}
}
