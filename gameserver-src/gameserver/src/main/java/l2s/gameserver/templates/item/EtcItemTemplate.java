/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.templates.item;

import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.items.ItemHandler;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.ItemType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class EtcItemTemplate
extends ItemTemplate {
    private static final Logger _log = LoggerFactory.getLogger(EtcItemTemplate.class);
    private final String _handlerName;
    private final int _reuseDelay;
    private IItemHandler _handler;

    public EtcItemTemplate(StatsSet set) {
        super(set);
        this._handlerName = set.getString("handler", null);
        this._reuseDelay = set.getInteger("reuse_delay", 0);
        this._type = (ItemType)((Object)set.getEnum("type", EtcItemType.class, EtcItemType.OTHER));
        this._type1 = 4;
        switch (this.getItemType()) {
            case QUEST: {
                this._type2 = 3;
                break;
            }
            case CURRENCY: {
                this._type2 = 4;
                break;
            }
            default: {
                this._type2 = 5;
            }
        }
        this._handler = this.getItemType().getHandler();
        this._exType = (ExItemType)set.getEnum("ex_type", ExItemType.class, this.getItemType().getExType());
        if (this._handlerName != null && !this._handlerName.isEmpty()) {
            this._handler = ItemHandler.getInstance().getItemHandler(this._handlerName);
            if (this._handler == null) {
                _log.warn("Cannot find item handler: " + this._handlerName + " for item ID[" + this.getItemId() + "]!");
            }
        }
    }

    @Override
    public EtcItemType getItemType() {
        return (EtcItemType)super.getItemType();
    }

    @Override
    public long getItemMask() {
        return this.getItemType().mask();
    }

    @Override
    public final boolean isShadowItem() {
        return false;
    }

    @Override
    public boolean isEnchantable() {
        return false;
    }

    @Override
    public boolean isAugmentable() {
        return false;
    }

    @Override
    public boolean isCrystallizable() {
        return false;
    }

    @Override
    public IItemHandler getHandler() {
        return this._handler;
    }

    @Override
    public int getReuseDelay() {
        return this._reuseDelay;
    }

    public static enum EtcItemType implements ItemType
    {
        OTHER(ItemHandler.DEFAULT_HANDLER, ExItemType.OTHER_ITEMS),
        QUEST(null, ExItemType.NONE_0),
        CURRENCY(ItemHandler.DEFAULT_HANDLER, ExItemType.NONE_0),
        ARROW(ItemHandler.EQUIPABLE_HANDLER, ExItemType.OTHER_ITEMS),
        POTION(ItemHandler.SKILL_REDUCE_ITEM_HANDLER, ExItemType.POTION),
        SCROLL_ENCHANT_WEAPON(ItemHandler.ENCHANT_SCROLL_HANDLER, ExItemType.SCROLL_ENCHANT_WEAPON),
        SCROLL_ENCHANT_ARMOR(ItemHandler.ENCHANT_SCROLL_HANDLER, ExItemType.SCROLL_ENCHANT_ARMOR),
        SCROLL(ItemHandler.SKILL_REDUCE_ITEM_HANDLER, ExItemType.SCROLL_OTHER),
        RECIPE(ItemHandler.RECIPE_HANDLER, ExItemType.RECIPE),
        MATERIAL(ItemHandler.DEFAULT_HANDLER, ExItemType.CRAFTING_MAIN_INGRIDIENTS),
        PET_COLLAR(ItemHandler.PET_SUMMON_HANDLER, ExItemType.PET_SUPPLIES),
        DYE(ItemHandler.DEFAULT_HANDLER, ExItemType.DYES),
        LURE(ItemHandler.EQUIPABLE_HANDLER, ExItemType.OTHER_ITEMS),
        BOLT(ItemHandler.EQUIPABLE_HANDLER, ExItemType.OTHER_ITEMS),
        WEAPON_ENCHANT_STONE(ItemHandler.DEFAULT_HANDLER, ExItemType.WEAPON_ENCHANT_STONE),
        ARMOR_ENCHANT_STONE(ItemHandler.DEFAULT_HANDLER, ExItemType.ARMOR_ENCHANT_STONE),
        RUNE_SELECT(ItemHandler.DEFAULT_HANDLER, ExItemType.OTHER_ITEMS),
        RUNE(ItemHandler.DEFAULT_HANDLER, ExItemType.OTHER_ITEMS),
        SOULSHOT(ItemHandler.SOULSHOT_HANDLER, ExItemType.SOULSHOT),
        SPIRITSHOT(ItemHandler.SPIRITSHOT_HANDLER, ExItemType.SPIRITSHOT),
        BLESSED_SPIRITSHOT(ItemHandler.BLESSED_SPIRITSHOT_HANDLER, ExItemType.SPIRITSHOT),
        BEAST_SOULSHOT(ItemHandler.BEAST_SOULSHOT_HANDLER, ExItemType.SOULSHOT),
        BEAST_SPIRITSHOT(ItemHandler.BEAST_SPIRITSHOT_HANDLER, ExItemType.SPIRITSHOT),
        BEAST_BLESSED_SPIRITSHOT(ItemHandler.BEAST_BLESSED_SPIRITSHOT_HANDLER, ExItemType.SPIRITSHOT),
        FISHSHOT(ItemHandler.FISHSHOT_HANDLER, ExItemType.SOULSHOT),
        PET_SUPPLIES(ItemHandler.SKILL_REDUCE_ITEM_HANDLER, ExItemType.PET_SUPPLIES),
        EXTRACTABLE(ItemHandler.CAPSULED_ITEM_HANDLER, ExItemType.OTHER_ITEMS),
        CRYSTAL(ItemHandler.DEFAULT_HANDLER, ExItemType.CRYSTAL),
        LIFE_STONE(ItemHandler.DEFAULT_HANDLER, ExItemType.LIFE_STONE),
        ACC_LIFE_STONE(ItemHandler.DEFAULT_HANDLER, ExItemType.LIFE_STONE),
        SPELLBOOK(ItemHandler.DEFAULT_HANDLER, ExItemType.SPELLBOOK),
        FORGOTTEN_SPELLBOOK(ItemHandler.SKILL_REDUCE_ITEM_HANDLER, ExItemType.SPELLBOOK),
        GEMSTONE(ItemHandler.DEFAULT_HANDLER, ExItemType.GEMSTONE),
        POUCH(ItemHandler.DEFAULT_HANDLER, ExItemType.POUCH),
        PIN(ItemHandler.DEFAULT_HANDLER, ExItemType.PIN),
        MAGIC_RUNE_CLIP(ItemHandler.DEFAULT_HANDLER, ExItemType.MAGIC_RUNE_CLIP),
        MAGIC_ORNAMENT(ItemHandler.DEFAULT_HANDLER, ExItemType.MAGIC_ORNAMENT),
        HERB(ItemHandler.DEFAULT_HANDLER, ExItemType.NONE_0),
        ARROW_QUIVER(ItemHandler.EQUIPABLE_HANDLER, ExItemType.OTHER_ITEMS),
        BOLT_QUIVER(ItemHandler.EQUIPABLE_HANDLER, ExItemType.OTHER_ITEMS),
        APPEARANCE_STONE(ItemHandler.APPEARANCE_STONE_HANDLER, ExItemType.OTHER_ITEMS),
        MERCENARY_TICKET(ItemHandler.MERCENARY_TICKET_HANDLER, ExItemType.OTHER_ITEMS);

        private final IItemHandler _handler;
        private final ExItemType _exType;

        private EtcItemType(IItemHandler handler, ExItemType exType) {
            this._handler = handler;
            this._exType = exType;
        }

        @Override
        public long mask() {
            return 0L;
        }

        @Override
        public IItemHandler getHandler() {
            return this._handler;
        }

        @Override
        public ExItemType getExType() {
            return this._exType;
        }

        public String toString() {
            return super.toString().toLowerCase();
        }
    }
}

