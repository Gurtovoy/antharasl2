/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item;

import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.items.ItemHandler;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.agathion.AgathionData;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.ItemType;

public final class ArmorTemplate
extends ItemTemplate {
    private AgathionData agathionData = null;

    public ArmorTemplate(StatsSet set) {
        super(set);
        this._type = (ItemType)((Object)set.getEnum("type", ArmorType.class));
        this._type1 = (0x3EL & this._bodyPart) == this._bodyPart ? 0 : (this._bodyPart == 65536L || this._bodyPart == 262144L || this._bodyPart == 524288L ? 2 : 1);
        if (this._type == ArmorType.SIGIL) {
            this._exType = ExItemType.SIGIL;
        } else if (this._bodyPart == 64L) {
            this._exType = ExItemType.HELMET;
        } else if (this._bodyPart == 1024L) {
            this._exType = ExItemType.UPPER_PIECE;
        } else if (this._bodyPart == 2048L) {
            this._exType = ExItemType.LOWER_PIECE;
        } else if (this._bodyPart == 32768L || this._bodyPart == 131072L) {
            this._exType = ExItemType.FULL_BODY;
        } else if (this._bodyPart == 512L) {
            this._exType = ExItemType.GLOVES;
        } else if (this._bodyPart == 4096L) {
            this._exType = ExItemType.FEET;
        } else if (this._bodyPart == 1L) {
            this._exType = ExItemType.PENDANT;
        } else if (this._bodyPart == 8192L) {
            this._exType = ExItemType.CLOAK;
        } else if ((this._bodyPart & 0x10L) == 16L || (this._bodyPart & 0x20L) == 32L) {
            this._exType = ExItemType.RING;
        } else if ((this._bodyPart & 2L) == 2L || (this._bodyPart & 4L) == 4L) {
            this._exType = ExItemType.EARRING;
        } else if (this._bodyPart == 8L) {
            this._exType = ExItemType.NECKLACE;
        } else if (this._bodyPart == 0x10000000L) {
            this._exType = ExItemType.BELT;
        } else if (this._bodyPart == 0x100000L || this._bodyPart == 0x200000L) {
            this._exType = ExItemType.BRACELET;
        } else if (this._bodyPart == 65536L || this._bodyPart == 262144L || this._bodyPart == 524288L) {
            this._exType = ExItemType.HAIR_ACCESSORY;
        }
        this._type2 = this._exType == ExItemType.OTHER_ITEMS ? 2 : this._exType.mask();
        this.initEnchantFuncs();
    }

    @Override
    public IItemHandler getHandler() {
        return ItemHandler.EQUIPABLE_HANDLER;
    }

    @Override
    public ArmorType getItemType() {
        return (ArmorType)super.getItemType();
    }

    @Override
    public final long getItemMask() {
        return this.getItemType().mask();
    }

    @Override
    public void setAgathionData(AgathionData agathionData) {
        this.agathionData = agathionData;
    }

    @Override
    public AgathionData getAgathionData() {
        return this.agathionData;
    }

    public static enum ArmorType implements ItemType
    {
        NONE("None"),
        LIGHT("Light"),
        HEAVY("Heavy"),
        MAGIC("Magic"),
        SIGIL("Sigil");

        public static final ArmorType[] VALUES;
        private final long _mask = 1L << this.ordinal();
        private final String _name;

        private ArmorType(String name) {
            this._name = name;
        }

        @Override
        public long mask() {
            return this._mask;
        }

        @Override
        public IItemHandler getHandler() {
            return null;
        }

        @Override
        public ExItemType getExType() {
            return null;
        }

        public String toString() {
            return this._name;
        }

        static {
            VALUES = ArmorType.values();
        }
    }
}

