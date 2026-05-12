package l2s.gameserver.model.items;

import java.util.Comparator;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.listener.Listener;
import l2s.commons.listener.ListenerList;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.listener.inventory.OnEquipListener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemContainer;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.listeners.StatsListener;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import org.apache.commons.lang3.ArrayUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Inventory
extends ItemContainer {
    private static final Logger _log = LoggerFactory.getLogger(Inventory.class);
    public static final int PAPERDOLL_PENDANT = 0;
    public static final int PAPERDOLL_REAR = 1;
    public static final int PAPERDOLL_LEAR = 2;
    public static final int PAPERDOLL_NECK = 3;
    public static final int PAPERDOLL_RFINGER = 4;
    public static final int PAPERDOLL_LFINGER = 5;
    public static final int PAPERDOLL_HEAD = 6;
    public static final int PAPERDOLL_RHAND = 7;
    public static final int PAPERDOLL_LHAND = 8;
    public static final int PAPERDOLL_GLOVES = 9;
    public static final int PAPERDOLL_CHEST = 10;
    public static final int PAPERDOLL_LEGS = 11;
    public static final int PAPERDOLL_FEET = 12;
    public static final int PAPERDOLL_BACK = 13;
    public static final int PAPERDOLL_LRHAND = 14;
    public static final int PAPERDOLL_HAIR = 15;
    public static final int PAPERDOLL_DHAIR = 16;
    public static final int PAPERDOLL_RBRACELET = 17;
    public static final int PAPERDOLL_LBRACELET = 18;
    public static final int PAPERDOLL_AGATHION_MAIN = 19;
    public static final int PAPERDOLL_AGATHION_1 = 20;
    public static final int PAPERDOLL_AGATHION_2 = 21;
    public static final int PAPERDOLL_AGATHION_3 = 22;
    public static final int PAPERDOLL_AGATHION_4 = 23;
    public static final int PAPERDOLL_DECO1 = 24;
    public static final int PAPERDOLL_DECO2 = 25;
    public static final int PAPERDOLL_DECO3 = 26;
    public static final int PAPERDOLL_DECO4 = 27;
    public static final int PAPERDOLL_DECO5 = 28;
    public static final int PAPERDOLL_DECO6 = 29;
    public static final int PAPERDOLL_BELT = 30;
    public static final int PAPERDOLL_BROOCH = 31;
    public static final int PAPERDOLL_JEWEL1 = 32;
    public static final int PAPERDOLL_JEWEL2 = 33;
    public static final int PAPERDOLL_JEWEL3 = 34;
    public static final int PAPERDOLL_JEWEL4 = 35;
    public static final int PAPERDOLL_JEWEL5 = 36;
    public static final int PAPERDOLL_JEWEL6 = 37;
    /** Max paperdoll index + 1 ({@code _paperdoll} length). Slots are {@code 0 .. PAPERDOLL_MAX-1}. */
    public static final int PAPERDOLL_MAX = 38;
    public static final int[] PAPERDOLL_ORDER = new int[]{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 19, 20, 21, 22, 23};
    public static final int UPDATE_STATS_FLAG = 1;
    public static final int UPDATE_SKILLS_FLAG = 3;
    protected final int _ownerId;
    protected final ItemInstance[] _paperdoll = new ItemInstance[PAPERDOLL_MAX];
    private final ListenerList<Playable> _listeners = new ListenerList();
    protected int _totalWeight;
    protected long _wearedMask;

    protected Inventory(int ownerId) {
        this._ownerId = ownerId;
        this.addListener(StatsListener.getInstance());
    }

    public abstract Playable getActor();

    protected abstract ItemInstance.ItemLocation getBaseLocation();

    protected abstract ItemInstance.ItemLocation getEquipLocation();

    public int getOwnerId() {
        return this._ownerId;
    }

    protected void onRestoreItem(ItemInstance item) {
        this._totalWeight = (int)((long)this._totalWeight + (long)item.getTemplate().getWeight() * item.getCount());
        IItemHandler handler = item.getTemplate().getHandler();
        if (handler != null) {
            handler.onRestoreItem(this.getActor(), item);
        }
    }

    @Override
    protected void onAddItem(ItemInstance item) {
        item.setOwnerId(this.getOwnerId());
        item.setLocation(this.getBaseLocation());
        item.setLocData(this.findSlot(item.getTemplate().isQuest()));
        if (item.getJdbcState().isSavable()) {
            item.save();
        } else {
            item.setJdbcState(JdbcEntityState.UPDATED);
            item.update();
        }
        this.sendAddItem(item);
        this.refreshWeight();
        IItemHandler handler = item.getTemplate().getHandler();
        if (handler != null) {
            handler.onAddItem(this.getActor(), item);
        }
    }

    @Override
    protected void onModifyItem(ItemInstance item) {
        item.setJdbcState(JdbcEntityState.UPDATED);
        item.update();
        this.sendModifyItem(item);
        this.refreshWeight();
    }

    @Override
    protected void onRemoveItem(ItemInstance item) {
        if (item.isEquipped()) {
            this.unEquipItem(item);
        }
        this.sendRemoveItem(item);
        item.setLocData(-1);
        this.refreshWeight();
        IItemHandler handler = item.getTemplate().getHandler();
        if (handler != null) {
            handler.onRemoveItem(this.getActor(), item);
        }
    }

    @Override
    protected void onDestroyItem(ItemInstance item) {
        item.setCount(0L);
        item.delete();
    }

    protected boolean onEquip(int slot, ItemInstance item) {
        if (!Inventory.checkPaperdollItem(item, slot)) {
            return false;
        }
        item.setLocation(this.getEquipLocation());
        item.setLocData(slot);
        item.setEquipped(true);
        item.setJdbcState(JdbcEntityState.UPDATED);
        item.onEquip(slot, this.getActor());
        this._wearedMask |= item.getTemplate().getItemMask();
        this.sendEquipInfo(slot);
        this.sendModifyItem(item);
        return true;
    }

    protected boolean onReequip(int slot, ItemInstance newItem, ItemInstance oldItem) {
        oldItem.setLocation(this.getBaseLocation());
        oldItem.setLocData(this.findSlot(oldItem.getTemplate().isQuest()));
        oldItem.setEquipped(false);
        oldItem.setJdbcState(JdbcEntityState.UPDATED);
        oldItem.setChargedSoulshotPower(0.0);
        oldItem.setChargedSpiritshotPower(0.0, 0, 0.0);
        oldItem.setChargedFishshotPower(0.0);
        oldItem.onUnequip(slot, this.getActor());
        this._wearedMask &= oldItem.getTemplate().getItemMask() ^ 0xFFFFFFFFFFFFFFFFL;
        if (Inventory.checkPaperdollItem(newItem, slot)) {
            newItem.setLocation(this.getEquipLocation());
            newItem.setLocData(slot);
            newItem.setEquipped(true);
            newItem.setJdbcState(JdbcEntityState.UPDATED);
            newItem.onEquip(slot, this.getActor());
            this._wearedMask |= newItem.getTemplate().getItemMask();
            this.sendEquipInfo(slot);
            this.sendModifyItem(newItem, oldItem);
            return true;
        }
        this.sendEquipInfo(slot);
        this.sendModifyItem(oldItem);
        return false;
    }

    protected void onUnequip(int slot, ItemInstance item) {
        item.setLocation(this.getBaseLocation());
        item.setLocData(this.findSlot(item.getTemplate().isQuest()));
        item.setEquipped(false);
        item.setJdbcState(JdbcEntityState.UPDATED);
        item.setChargedSoulshotPower(0.0);
        item.setChargedSpiritshotPower(0.0, 0, 0.0);
        item.setChargedFishshotPower(0.0);
        item.onUnequip(slot, this.getActor());
        this._wearedMask &= item.getTemplate().getItemMask() ^ 0xFFFFFFFFFFFFFFFFL;
        this.sendEquipInfo(slot);
        this.sendModifyItem(item);
    }

    private int findSlot(boolean quest) {
        int slot = 0;
        block0: for (slot = 0; slot < this._items.size(); ++slot) {
            for (int i = 0; i < this._items.size(); ++i) {
                ItemInstance item = (ItemInstance)this._items.get(i);
                if (!(item.isEquipped() || !quest && item.getTemplate().isQuest() || quest && !item.getTemplate().isQuest() || item.getEquipSlot() != slot)) continue block0;
            }
        }
        return slot;
    }

    public ItemInstance getPaperdollItem(int slot) {
        return this._paperdoll[slot];
    }

    public ItemInstance[] getPaperdollItems() {
        return this._paperdoll;
    }

    public int getPaperdollItemId(int slot) {
        ItemInstance item = this.getPaperdollItem(slot);
        if (item != null) {
            return item.getItemId();
        }
        return 0;
    }

    public int getPaperdollVisualId(int slot) {
        // When formal wear (costume) is in the brooch slot, it visually replaces the chest for observers
        // and the local client (see getActiveCostumeVisualId / packet writers).
        if (slot == PAPERDOLL_CHEST) {
            int costumeVisual = this.getActiveCostumeVisualId();
            if (costumeVisual > 0) {
                return costumeVisual;
            }
        }
        ItemInstance item = this.getPaperdollItem(slot);
        if (item != null && item.getVisualId() > 0) {
            return item.getVisualId();
        }
        return 0;
    }

    /**
     * Formal wear (costume) is stored in the brooch paperdoll slot so the client sees a normal equip slot.
     */
    public ItemInstance getEquippedFormalWearCostume() {
        ItemInstance broochSlot = this._paperdoll[PAPERDOLL_BROOCH];
        if (broochSlot != null && broochSlot.getBodyPart() == ItemTemplate.SLOT_FORMAL_WEAR) {
            return broochSlot;
        }
        return null;
    }

    /**
     * @return item id of the equipped costume if any and if its visibility is not turned off; 0 otherwise.
     *         Default implementation returns 0; PcInventory overrides it to honor the player's hideCostume flag.
     */
    public int getActiveCostumeVisualId() {
        ItemInstance costume = this.getEquippedFormalWearCostume();
        if (costume == null) {
            return 0;
        }
        return costume.getItemId();
    }

    public int getPaperdollObjectId(int slot) {
        ItemInstance item = this._paperdoll[slot];
        if (item != null) {
            return item.getObjectId();
        }
        return 0;
    }

    public void addListener(OnEquipListener listener) {
        this._listeners.add((Listener)listener);
    }

    public void removeListener(OnEquipListener listener) {
        this._listeners.remove((Listener)listener);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public ItemInstance setPaperdollItem(int slot, ItemInstance item) {
        ItemInstance old;
        this.writeLock();
        try {
            old = this._paperdoll[slot];
            if (old != item) {
                if (old != null && item != null) {
                    this._paperdoll[slot] = item;
                    this.onReequip(slot, item, old);
                } else {
                    if (old != null) {
                        this._paperdoll[slot] = null;
                        this.onUnequip(slot, old);
                    }
                    if (item != null) {
                        this._paperdoll[slot] = item;
                        this.onEquip(slot, item);
                    }
                }
            }
        }
        finally {
            this.writeUnlock();
        }
        return old;
    }

    public long getWearedMask() {
        return this._wearedMask;
    }

    public void unEquipItem(ItemInstance item) {
        if (item.isEquipped()) {
            this.unEquipItemInBodySlot(item.getBodyPart(), item);
        }
    }

    public void unEquipItemInBodySlot(long bodySlot) {
        this.unEquipItemInBodySlot(bodySlot, null);
    }

    private void unEquipItemInBodySlot(long bodySlot, ItemInstance item) {
        int pdollSlot = -1;
        if (bodySlot == 8L) {
            pdollSlot = 3;
        } else if (bodySlot == 4L) {
            pdollSlot = 2;
        } else if (bodySlot == 2L) {
            pdollSlot = 1;
        } else if (bodySlot == 6L) {
            if (item == null) {
                return;
            }
            if (this.getPaperdollItem(2) == item) {
                pdollSlot = 2;
            }
            if (this.getPaperdollItem(1) == item) {
                pdollSlot = 1;
            }
        } else if (bodySlot == 32L) {
            pdollSlot = 5;
        } else if (bodySlot == 16L) {
            pdollSlot = 4;
        } else if (bodySlot == 48L) {
            if (item == null) {
                return;
            }
            if (this.getPaperdollItem(5) == item) {
                pdollSlot = 5;
            }
            if (this.getPaperdollItem(4) == item) {
                pdollSlot = 4;
            }
        } else if (bodySlot == 65536L) {
            pdollSlot = 15;
        } else if (bodySlot == 262144L) {
            pdollSlot = 16;
        } else if (bodySlot == 524288L) {
            this.setPaperdollItem(16, null);
            pdollSlot = 15;
        } else if (bodySlot == 64L) {
            pdollSlot = 6;
        } else if (bodySlot == 128L) {
            pdollSlot = 7;
        } else if (bodySlot == 256L) {
            pdollSlot = 8;
        } else if (bodySlot == 512L) {
            pdollSlot = 9;
        } else if (bodySlot == 2048L) {
            pdollSlot = 11;
        } else if (bodySlot == 1024L || bodySlot == 32768L) {
            pdollSlot = 10;
        } else if (bodySlot == 131072L) {
            pdollSlot = PAPERDOLL_BROOCH;
        } else if (bodySlot == 8192L) {
            pdollSlot = 13;
        } else if (bodySlot == 4096L) {
            pdollSlot = 12;
        } else if (bodySlot == 0x10000000L) {
            pdollSlot = 30;
        } else if (bodySlot == 16384L) {
            this.setPaperdollItem(8, null);
            pdollSlot = 7;
        } else if (bodySlot == 1L) {
            pdollSlot = 0;
        } else if (bodySlot == 0x200000L) {
            pdollSlot = 18;
            this.setPaperdollItem(19, null);
            this.setPaperdollItem(20, null);
            this.setPaperdollItem(21, null);
            this.setPaperdollItem(22, null);
            this.setPaperdollItem(23, null);
        } else if (bodySlot == 0x100000L) {
            pdollSlot = 17;
            this.setPaperdollItem(24, null);
            this.setPaperdollItem(25, null);
            this.setPaperdollItem(26, null);
            this.setPaperdollItem(27, null);
            this.setPaperdollItem(28, null);
            this.setPaperdollItem(29, null);
        } else if (bodySlot == 0x400000L) {
            if (item == null) {
                return;
            }
            if (this.getPaperdollItem(24) == item) {
                pdollSlot = 24;
            } else if (this.getPaperdollItem(25) == item) {
                pdollSlot = 25;
            } else if (this.getPaperdollItem(26) == item) {
                pdollSlot = 26;
            } else if (this.getPaperdollItem(27) == item) {
                pdollSlot = 27;
            } else if (this.getPaperdollItem(28) == item) {
                pdollSlot = 28;
            } else if (this.getPaperdollItem(29) == item) {
                pdollSlot = 29;
            }
        } else if (bodySlot == 0x20000000L) {
            pdollSlot = 31;
            this.setPaperdollItem(32, null);
            this.setPaperdollItem(33, null);
            this.setPaperdollItem(34, null);
            this.setPaperdollItem(35, null);
            this.setPaperdollItem(36, null);
            this.setPaperdollItem(37, null);
        } else if (bodySlot == 0x40000000L) {
            if (item == null) {
                return;
            }
            if (this.getPaperdollItem(32) == item) {
                pdollSlot = 32;
            } else if (this.getPaperdollItem(33) == item) {
                pdollSlot = 33;
            } else if (this.getPaperdollItem(34) == item) {
                pdollSlot = 34;
            } else if (this.getPaperdollItem(35) == item) {
                pdollSlot = 35;
            } else if (this.getPaperdollItem(36) == item) {
                pdollSlot = 36;
            } else if (this.getPaperdollItem(37) == item) {
                pdollSlot = 37;
            }
        } else if (bodySlot == 0x3000000000L) {
            if (item == null) {
                return;
            }
            if (this.getPaperdollItem(19) == item) {
                pdollSlot = 19;
            } else if (this.getPaperdollItem(20) == item) {
                pdollSlot = 20;
            } else if (this.getPaperdollItem(21) == item) {
                pdollSlot = 21;
            } else if (this.getPaperdollItem(22) == item) {
                pdollSlot = 22;
            } else if (this.getPaperdollItem(23) == item) {
                pdollSlot = 23;
            }
        } else {
            _log.warn("Requested invalid body slot: " + bodySlot + ", Item: " + item + ", ownerId: '" + this.getOwnerId() + "'");
            return;
        }
        if (pdollSlot >= 0) {
            this.setPaperdollItem(pdollSlot, null);
        }
    }

    public void equipItem(ItemInstance item) {
        long bodySlot = item.getBodyPart();
        double hp = this.getActor().getCurrentHp();
        double mp = this.getActor().getCurrentMp();
        double cp = this.getActor().getCurrentCp();
        if (bodySlot == 16384L) {
            this.setPaperdollItem(8, null);
            this.setPaperdollItem(7, item);
        } else if (bodySlot == 256L) {
            ItemInstance rHandItem = this.getPaperdollItem(7);
            ItemTemplate rHandItemTemplate = rHandItem == null ? null : rHandItem.getTemplate();
            ItemTemplate newItem = item.getTemplate();
            if (newItem.getItemType() == EtcItemTemplate.EtcItemType.ARROW || newItem.getItemType() == EtcItemTemplate.EtcItemType.ARROW_QUIVER) {
                if (rHandItemTemplate == null) {
                    return;
                }
                if (rHandItemTemplate.getItemType() != WeaponTemplate.WeaponType.BOW) {
                    return;
                }
                if (rHandItemTemplate.getGrade().extOrdinal() != newItem.getGrade().extOrdinal()) {
                    return;
                }
            } else if (newItem.getItemType() == EtcItemTemplate.EtcItemType.BOLT || newItem.getItemType() == EtcItemTemplate.EtcItemType.BOLT_QUIVER) {
                if (rHandItemTemplate == null) {
                    return;
                }
                if (rHandItemTemplate.getItemType() != WeaponTemplate.WeaponType.CROSSBOW && rHandItemTemplate.getItemType() != WeaponTemplate.WeaponType.TWOHANDCROSSBOW) {
                    return;
                }
                if (rHandItemTemplate.getGrade().extOrdinal() != newItem.getGrade().extOrdinal()) {
                    return;
                }
            } else if (newItem.getItemType() == EtcItemTemplate.EtcItemType.LURE) {
                if (rHandItemTemplate == null) {
                    return;
                }
                if (rHandItemTemplate.getItemType() != WeaponTemplate.WeaponType.ROD) {
                    return;
                }
            } else if (rHandItemTemplate != null && rHandItemTemplate.getBodyPart() == 16384L) {
                this.setPaperdollItem(7, null);
            }
            this.setPaperdollItem(8, item);
        } else if (bodySlot == 128L) {
            ItemInstance lHandItem = this.getPaperdollItem(8);
            if (lHandItem != null) {
                ItemTemplate lHandItemTemplate = lHandItem.getTemplate();
                ItemTemplate newItem = item.getTemplate();
                if (lHandItemTemplate.getItemType() == EtcItemTemplate.EtcItemType.ARROW || lHandItemTemplate.getItemType() == EtcItemTemplate.EtcItemType.ARROW_QUIVER) {
                    if (newItem.getItemType() != WeaponTemplate.WeaponType.BOW || newItem.getGrade().extOrdinal() != newItem.getGrade().extOrdinal()) {
                        this.setPaperdollItem(8, null);
                    }
                } else if (lHandItemTemplate.getItemType() == EtcItemTemplate.EtcItemType.BOLT || lHandItemTemplate.getItemType() == EtcItemTemplate.EtcItemType.BOLT_QUIVER) {
                    if (newItem.getItemType() != WeaponTemplate.WeaponType.CROSSBOW && newItem.getItemType() != WeaponTemplate.WeaponType.TWOHANDCROSSBOW || newItem.getGrade().extOrdinal() != newItem.getGrade().extOrdinal()) {
                        this.setPaperdollItem(8, null);
                    }
                } else if (lHandItemTemplate.getItemType() == EtcItemTemplate.EtcItemType.LURE && newItem.getItemType() != WeaponTemplate.WeaponType.ROD) {
                    this.setPaperdollItem(8, null);
                }
            }
            this.setPaperdollItem(7, item);
        } else if (bodySlot == 4L || bodySlot == 2L || bodySlot == 6L) {
            if (this._paperdoll[2] == null) {
                this.setPaperdollItem(2, item);
            } else if (this._paperdoll[1] == null) {
                this.setPaperdollItem(1, item);
            } else {
                FuncTemplate[] rEarFuncTemplates;
                FuncTemplate[] lEarFuncTemplates;
                double lEarMDef = 0.0;
                for (FuncTemplate funcTemplate : lEarFuncTemplates = this._paperdoll[2].getTemplate().getAttachedFuncs()) {
                    if (funcTemplate._stat != Stats.MAGIC_DEFENCE) continue;
                    lEarMDef = funcTemplate._value;
                    break;
                }
                double rEarMDef = 0.0;
                for (FuncTemplate func : rEarFuncTemplates = this._paperdoll[1].getTemplate().getAttachedFuncs()) {
                    if (func._stat != Stats.MAGIC_DEFENCE) continue;
                    rEarMDef = func._value;
                    break;
                }
                if (lEarMDef > rEarMDef) {
                    this.setPaperdollItem(1, item);
                } else {
                    this.setPaperdollItem(2, item);
                }
            }
        } else if (bodySlot == 32L || bodySlot == 16L || bodySlot == 48L) {
            if (this._paperdoll[5] == null) {
                this.setPaperdollItem(5, item);
            } else if (this._paperdoll[4] == null) {
                this.setPaperdollItem(4, item);
            } else {
                FuncTemplate[] rFingerFuncTemplates;
                FuncTemplate[] lFingerFuncTemplates;
                double lFingerMDef = 0.0;
                for (FuncTemplate funcTemplate : lFingerFuncTemplates = this._paperdoll[5].getTemplate().getAttachedFuncs()) {
                    if (funcTemplate._stat != Stats.MAGIC_DEFENCE) continue;
                    lFingerMDef = funcTemplate._value;
                    break;
                }
                double rFingerMDef = 0.0;
                for (FuncTemplate func : rFingerFuncTemplates = this._paperdoll[4].getTemplate().getAttachedFuncs()) {
                    if (func._stat != Stats.MAGIC_DEFENCE) continue;
                    rFingerMDef = func._value;
                    break;
                }
                if (lFingerMDef > rFingerMDef) {
                    this.setPaperdollItem(4, item);
                } else {
                    this.setPaperdollItem(5, item);
                }
            }
        } else if (bodySlot == 8L) {
            this.setPaperdollItem(3, item);
        } else if (bodySlot == 32768L) {
            this.setPaperdollItem(11, null);
            this.setPaperdollItem(10, item);
        } else if (bodySlot == 1024L) {
            this.setPaperdollItem(10, item);
        } else if (bodySlot == 2048L) {
            ItemInstance chest = this.getPaperdollItem(10);
            if (chest != null && chest.getBodyPart() == 32768L) {
                this.setPaperdollItem(10, null);
            } else if (this.getPaperdollItemId(10) == 6408) {
                this.setPaperdollItem(10, null);
            }
            this.setPaperdollItem(11, item);
        } else if (bodySlot == 4096L) {
            if (this.getPaperdollItemId(10) == 6408) {
                this.setPaperdollItem(10, null);
            }
            this.setPaperdollItem(12, item);
        } else if (bodySlot == 512L) {
            if (this.getPaperdollItemId(10) == 6408) {
                this.setPaperdollItem(10, null);
            }
            this.setPaperdollItem(9, item);
        } else if (bodySlot == 64L) {
            if (this.getPaperdollItemId(10) == 6408) {
                this.setPaperdollItem(10, null);
            }
            this.setPaperdollItem(6, item);
        } else if (bodySlot == 65536L) {
            this.setPaperdollItem(15, item);
        } else if (bodySlot == 262144L) {
            ItemInstance slot2 = this.getPaperdollItem(15);
            if (slot2 != null && slot2.getBodyPart() == 524288L) {
                this.setPaperdollItem(15, null);
            }
            this.setPaperdollItem(16, item);
        } else if (bodySlot == 524288L) {
            this.setPaperdollItem(15, item);
            this.setPaperdollItem(16, null);
        } else if (bodySlot == 0x100000L) {
            this.setPaperdollItem(17, item);
            for (int p = 24; p <= 29; ++p) {
                this.setPaperdollItem(p, null);
            }
        } else if (bodySlot == 0x200000L) {
            this.setPaperdollItem(18, item);
            for (int p = 19; p <= 23; ++p) {
                this.setPaperdollItem(p, null);
            }
        } else if (bodySlot == 1L) {
            this.setPaperdollItem(0, item);
        } else if (bodySlot == 8192L) {
            this.setPaperdollItem(13, item);
        } else if (bodySlot == 0x10000000L) {
            this.setPaperdollItem(30, item);
        } else if (bodySlot == 0x400000L) {
            for (int p = 24; p <= 29; ++p) {
                if (this._paperdoll[p] != null) continue;
                this.setPaperdollItem(p, item);
                break;
            }
        } else if (bodySlot == 131072L) {
            // Costume (FORMAL_WEAR): use brooch paperdoll slot so the client inventory shows it; chest stats stay on real chest.
            // Same jewel clear as a real brooch when those slots are used.
            this.setPaperdollItem(PAPERDOLL_BROOCH, item);
            for (int p = PAPERDOLL_JEWEL1; p <= PAPERDOLL_JEWEL6; ++p) {
                this.setPaperdollItem(p, null);
            }
        } else if (bodySlot == 0x20000000L) {
            this.setPaperdollItem(31, item);
            for (int p = 32; p <= 37; ++p) {
                this.setPaperdollItem(p, null);
            }
        } else if (bodySlot == 0x40000000L) {
            for (int p = 32; p <= 37; ++p) {
                if (this._paperdoll[p] != null) continue;
                this.setPaperdollItem(p, item);
                break;
            }
        } else if (bodySlot == 0x3000000000L) {
            for (int p = 19; p <= 23; ++p) {
                if (this._paperdoll[p] != null) continue;
                this.setPaperdollItem(p, item);
                break;
            }
        } else {
            _log.warn("unknown body slot:" + bodySlot + " for item id: " + item.getItemId());
            return;
        }
        this.getActor().setCurrentHp(hp, false);
        this.getActor().setCurrentMp(mp);
        this.getActor().setCurrentCp(cp);
        if (this.getActor().isPlayer()) {
            ((Player)this.getActor()).autoShot();
        }
    }

    public abstract void sendAddItem(ItemInstance var1);

    public abstract void sendModifyItem(ItemInstance ... var1);

    public abstract void sendRemoveItem(ItemInstance var1);

    public void sendEquipInfo(int slot) {
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected void refreshWeight() {
        int weight = 0;
        this.readLock();
        try {
            for (int i = 0; i < this._items.size(); ++i) {
                ItemInstance item = (ItemInstance)this._items.get(i);
                weight = (int)((long)weight + (long)item.getTemplate().getWeight() * item.getCount());
            }
        }
        finally {
            this.readUnlock();
        }
        if (this._totalWeight == weight) {
            return;
        }
        this._totalWeight = weight;
        this.onRefreshWeight();
    }

    protected abstract void onRefreshWeight();

    public int getTotalWeight() {
        return this._totalWeight;
    }

    public boolean validateCapacity(ItemInstance item) {
        long slots = 0L;
        if (!item.isStackable() || this.getItemByItemId(item.getItemId()) == null) {
            ++slots;
        }
        return this.validateCapacity(slots);
    }

    public boolean validateCapacity(int itemId, long count) {
        ItemTemplate item = ItemHolder.getInstance().getTemplate(itemId);
        return this.validateCapacity(item, count);
    }

    public boolean validateCapacity(ItemTemplate item, long count) {
        long slots = 0L;
        if (!item.isStackable() || this.getItemByItemId(item.getItemId()) == null) {
            slots = count;
        }
        return this.validateCapacity(slots);
    }

    public boolean validateCapacity(long slots) {
        if (slots == 0L) {
            return true;
        }
        if (slots < Integer.MIN_VALUE || slots > Integer.MAX_VALUE) {
            return false;
        }
        if (this.getSize() + (int)slots < 0) {
            return false;
        }
        return (long)this.getSize() + slots <= (long)this.getActor().getInventoryLimit();
    }

    public boolean validateWeight(ItemInstance item) {
        long weight = (long)item.getTemplate().getWeight() * item.getCount();
        return this.validateWeight(weight);
    }

    public boolean validateWeight(int itemId, long count) {
        ItemTemplate item = ItemHolder.getInstance().getTemplate(itemId);
        return this.validateWeight(item, count);
    }

    public boolean validateWeight(ItemTemplate item, long count) {
        long weight = (long)item.getWeight() * count;
        return this.validateWeight(weight);
    }

    public boolean validateWeight(long weight) {
        if (weight == 0L) {
            return true;
        }
        if (weight < Integer.MIN_VALUE || weight > Integer.MAX_VALUE) {
            return false;
        }
        if (this.getTotalWeight() + (int)weight < 0) {
            return false;
        }
        return (long)this.getTotalWeight() + weight <= (long)this.getActor().getMaxLoad();
    }

    public abstract void restore();

    public abstract void store();

    public static boolean checkPaperdollItem(ItemInstance item, int paperdoll) {
        return ArrayUtils.contains((int[])Inventory.getPaperdollIndexes(item.getBodyPart()), (int)paperdoll);
    }

    public static int[] getPaperdollIndexes(long slot) {
        if (slot == 1L) {
            return new int[]{0};
        }
        if (slot == 2L) {
            return new int[]{1};
        }
        if (slot == 4L) {
            return new int[]{2};
        }
        if (slot == 6L) {
            return new int[]{1, 2};
        }
        if (slot == 8L) {
            return new int[]{3};
        }
        if (slot == 16L) {
            return new int[]{4};
        }
        if (slot == 32L) {
            return new int[]{5};
        }
        if (slot == 48L) {
            return new int[]{4, 5};
        }
        if (slot == 64L) {
            return new int[]{6};
        }
        if (slot == 128L) {
            return new int[]{7};
        }
        if (slot == 256L) {
            return new int[]{8};
        }
        if (slot == 16384L) {
            return new int[]{7, 8, 14};
        }
        if (slot == 512L) {
            return new int[]{9};
        }
        if (slot == 1024L || slot == 32768L) {
            return new int[]{10};
        }
        if (slot == 131072L) {
            return new int[]{PAPERDOLL_BROOCH};
        }
        if (slot == 2048L) {
            return new int[]{11};
        }
        if (slot == 4096L) {
            return new int[]{12};
        }
        if (slot == 8192L) {
            return new int[]{13};
        }
        if (slot == 65536L) {
            return new int[]{15};
        }
        if (slot == 262144L) {
            return new int[]{16};
        }
        if (slot == 524288L) {
            return new int[]{15, 16};
        }
        if (slot == 0x100000L) {
            return new int[]{17};
        }
        if (slot == 0x200000L) {
            return new int[]{18};
        }
        if (slot == 0x400000L) {
            return new int[]{24, 25, 26, 27, 28, 29};
        }
        if (slot == 0x10000000L) {
            return new int[]{30};
        }
        if (slot == 0x20000000L) {
            return new int[]{31};
        }
        if (slot == 0x40000000L) {
            return new int[]{32, 33, 34, 35, 36, 37};
        }
        if (slot == 0x3000000000L) {
            return new int[]{19, 20, 21, 22, 23};
        }
        return new int[]{-1};
    }

    public static int getPaperdollIndex(long slot) {
        if (slot == 1L) {
            return 0;
        }
        if (slot == 2L) {
            return 1;
        }
        if (slot == 4L) {
            return 2;
        }
        if (slot == 8L) {
            return 3;
        }
        if (slot == 16L) {
            return 4;
        }
        if (slot == 32L) {
            return 5;
        }
        if (slot == 64L) {
            return 6;
        }
        if (slot == 128L) {
            return 7;
        }
        if (slot == 256L) {
            return 8;
        }
        if (slot == 512L) {
            return 9;
        }
        if (slot == 1024L || slot == 32768L) {
            return 10;
        }
        if (slot == 131072L) {
            return PAPERDOLL_BROOCH;
        }
        if (slot == 2048L) {
            return 11;
        }
        if (slot == 4096L) {
            return 12;
        }
        if (slot == 8192L) {
            return 13;
        }
        if (slot == 65536L) {
            return 15;
        }
        if (slot == 262144L) {
            return 16;
        }
        if (slot == 0x100000L) {
            return 17;
        }
        if (slot == 0x200000L) {
            return 18;
        }
        if (slot == 0x400000L) {
            return 24;
        }
        if (slot == 0x800000L) {
            return 25;
        }
        if (slot == 0x1000000L) {
            return 26;
        }
        if (slot == 0x2000000L) {
            return 27;
        }
        if (slot == 0x4000000L) {
            return 28;
        }
        if (slot == 0x8000000L) {
            return 29;
        }
        if (slot == 0x10000000L) {
            return 30;
        }
        if (slot == 0x20000000L) {
            return 31;
        }
        if (slot == 0x40000000L) {
            return 32;
        }
        if (slot == 0x80000000L) {
            return 33;
        }
        if (slot == 0x100000000L) {
            return 34;
        }
        if (slot == 0x200000000L) {
            return 35;
        }
        if (slot == 0x400000000L) {
            return 36;
        }
        if (slot == 0x800000000L) {
            return 37;
        }
        if (slot == 0x1000000000L) {
            return 19;
        }
        if (slot == 0x2000000000L) {
            return 20;
        }
        if (slot == 0x4000000000L) {
            return 21;
        }
        if (slot == 0x8000000000L) {
            return 22;
        }
        if (slot == 0x10000000000L) {
            return 23;
        }
        return -1;
    }

    public ListenerList<Playable> getListeners() {
        return this._listeners;
    }

    public static class ItemOrderComparator
    implements Comparator<ItemInstance> {
        private static final Comparator<ItemInstance> instance = new ItemOrderComparator();

        public static final Comparator<ItemInstance> getInstance() {
            return instance;
        }

        @Override
        public int compare(ItemInstance o1, ItemInstance o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            return o1.getLocData() - o2.getLocData();
        }
    }
}

