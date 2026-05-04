/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.items;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.items.impl.AppearanceStoneHandler;
import l2s.gameserver.handler.items.impl.BeastBlessedSpiritShotItemHandler;
import l2s.gameserver.handler.items.impl.BeastSoulShotItemHandler;
import l2s.gameserver.handler.items.impl.BeastSpiritShotItemHandler;
import l2s.gameserver.handler.items.impl.BlessedSpiritShotItemHandler;
import l2s.gameserver.handler.items.impl.CalculatorItemHandler;
import l2s.gameserver.handler.items.impl.CapsuledItemHandler;
import l2s.gameserver.handler.items.impl.DefaultItemHandler;
import l2s.gameserver.handler.items.impl.EnchantScrollItemHandler;
import l2s.gameserver.handler.items.impl.EquipableItemHandler;
import l2s.gameserver.handler.items.impl.FishShotItemHandler;
import l2s.gameserver.handler.items.impl.HarvesterItemHandler;
import l2s.gameserver.handler.items.impl.KeyItemHandler;
import l2s.gameserver.handler.items.impl.MercenaryTicketItemHandler;
import l2s.gameserver.handler.items.impl.NameColorItemHandler;
import l2s.gameserver.handler.items.impl.PetSummonItemHandler;
import l2s.gameserver.handler.items.impl.RecipeItemHandler;
import l2s.gameserver.handler.items.impl.RollingDiceItemHandler;
import l2s.gameserver.handler.items.impl.SkillsItemHandler;
import l2s.gameserver.handler.items.impl.SkillsReduceItemHandler;
import l2s.gameserver.handler.items.impl.SoulShotItemHandler;
import l2s.gameserver.handler.items.impl.SpiritShotItemHandler;
import l2s.gameserver.handler.items.impl.WorldMapItemHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ItemHandler
extends AbstractHolder {
    private static final Logger _log = LoggerFactory.getLogger(ItemHandler.class);
    public static final IItemHandler DEFAULT_HANDLER = new DefaultItemHandler();
    public static final IItemHandler EQUIPABLE_HANDLER = new EquipableItemHandler();
    public static final IItemHandler ENCHANT_SCROLL_HANDLER = new EnchantScrollItemHandler();
    public static final IItemHandler FISHSHOT_HANDLER = new FishShotItemHandler();
    public static final IItemHandler APPEARANCE_STONE_HANDLER = new AppearanceStoneHandler();
    public static final IItemHandler SOULSHOT_HANDLER = new SoulShotItemHandler();
    public static final IItemHandler SPIRITSHOT_HANDLER = new SpiritShotItemHandler();
    public static final IItemHandler BLESSED_SPIRITSHOT_HANDLER = new BlessedSpiritShotItemHandler();
    public static final IItemHandler BEAST_SOULSHOT_HANDLER = new BeastSoulShotItemHandler();
    public static final IItemHandler BEAST_SPIRITSHOT_HANDLER = new BeastSpiritShotItemHandler();
    public static final IItemHandler BEAST_BLESSED_SPIRITSHOT_HANDLER = new BeastBlessedSpiritShotItemHandler();
    public static final IItemHandler SKILL_ITEM_HANDLER = new SkillsItemHandler();
    public static final IItemHandler SKILL_REDUCE_ITEM_HANDLER = new SkillsReduceItemHandler();
    public static final IItemHandler CAPSULED_ITEM_HANDLER = new CapsuledItemHandler();
    public static final IItemHandler PET_SUMMON_HANDLER = new PetSummonItemHandler();
    public static final IItemHandler RECIPE_HANDLER = new RecipeItemHandler();
    public static final IItemHandler MERCENARY_TICKET_HANDLER = new MercenaryTicketItemHandler();
    private static final ItemHandler _instance = new ItemHandler();
    private final Map<String, IItemHandler> _handlers = new HashMap<String, IItemHandler>();

    public static ItemHandler getInstance() {
        return _instance;
    }

    private ItemHandler() {
        this.registerItemHandler(DEFAULT_HANDLER);
        this.registerItemHandler(ENCHANT_SCROLL_HANDLER);
        this.registerItemHandler(EQUIPABLE_HANDLER);
        this.registerItemHandler(FISHSHOT_HANDLER);
        this.registerItemHandler(APPEARANCE_STONE_HANDLER);
        this.registerItemHandler(SOULSHOT_HANDLER);
        this.registerItemHandler(SPIRITSHOT_HANDLER);
        this.registerItemHandler(BLESSED_SPIRITSHOT_HANDLER);
        this.registerItemHandler(BEAST_SOULSHOT_HANDLER);
        this.registerItemHandler(BEAST_SPIRITSHOT_HANDLER);
        this.registerItemHandler(BEAST_BLESSED_SPIRITSHOT_HANDLER);
        this.registerItemHandler(SKILL_ITEM_HANDLER);
        this.registerItemHandler(SKILL_REDUCE_ITEM_HANDLER);
        this.registerItemHandler(CAPSULED_ITEM_HANDLER);
        this.registerItemHandler(PET_SUMMON_HANDLER);
        this.registerItemHandler(RECIPE_HANDLER);
        this.registerItemHandler(MERCENARY_TICKET_HANDLER);
        this.registerItemHandler(new CalculatorItemHandler());
        this.registerItemHandler(new HarvesterItemHandler());
        this.registerItemHandler(new KeyItemHandler());
        this.registerItemHandler(new NameColorItemHandler());
        this.registerItemHandler(new RollingDiceItemHandler());
        this.registerItemHandler(new WorldMapItemHandler());
    }

    public void registerItemHandler(IItemHandler handler) {
        this._handlers.put(handler.getClass().getSimpleName().replace("ItemHandler", ""), handler);
    }

    public void removeHandler(IItemHandler handler) {
        this._handlers.remove(handler.getClass().getSimpleName().replace("ItemHandler", ""));
    }

    public IItemHandler getItemHandler(String handler) {
        if (handler.contains("ItemHandler")) {
            handler = handler.replace("ItemHandler", "");
        }
        if (this._handlers.isEmpty() || !this._handlers.containsKey(handler)) {
            _log.warn("ItemHandler: Cannot find handler [" + handler + "]!");
            return DEFAULT_HANDLER;
        }
        return this._handlers.get(handler);
    }

    public int size() {
        return this._handlers.size();
    }

    public void clear() {
        this._handlers.clear();
    }
}

