/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.LazyArrayList
 *  l2s.commons.dao.JdbcEntity
 *  l2s.commons.dao.JdbcEntityState
 *  l2s.commons.listener.Listener
 *  org.napile.primitive.Containers
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 *  org.napile.primitive.sets.IntSet
 *  org.napile.primitive.sets.impl.HashIntSet
 */
package l2s.gameserver.model.items;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.dao.JdbcEntity;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.listener.Listener;
import l2s.gameserver.Config;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.dao.HidenItemsDAO;
import l2s.gameserver.dao.ItemsDAO;
import l2s.gameserver.dao.ItemsEnsoulDAO;
import l2s.gameserver.data.xml.holder.AppearanceStoneHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.inventory.OnEquipListener;
import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.PlayerGroup;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemAttributes;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.model.items.attachment.ItemAttachment;
import l2s.gameserver.network.l2.s2c.DropItemPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.SpawnItemPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.taskmanager.ItemsAutoDestroy;
import l2s.gameserver.taskmanager.LazyPrecisionTaskManager;
import l2s.gameserver.templates.OptionDataTemplate;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.ItemType;
import l2s.gameserver.templates.item.support.AppearanceStone;
import l2s.gameserver.templates.item.support.Ensoul;
import l2s.gameserver.utils.ItemFunctions;
import org.napile.primitive.Containers;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;

public final class ItemInstance
extends GameObject
implements JdbcEntity {
    public static final int[] EMPTY_ENCHANT_OPTIONS = new int[3];
    public static final Ensoul[] EMPTY_ENSOULS_ARRAY = new Ensoul[0];
    private static final ItemsDAO _itemsDAO = ItemsDAO.getInstance();
    public static final int FLAG_NO_DROP = 1;
    public static final int FLAG_NO_TRADE = 2;
    public static final int FLAG_NO_TRANSFER = 4;
    public static final int FLAG_NO_CRYSTALLIZE = 8;
    public static final int FLAG_NO_ENCHANT = 16;
    public static final int FLAG_NO_DESTROY = 32;
    public static final int FLAG_NO_SHAPE_SHIFTING = 64;
    public static final int FLAG_LIFE_TIME = 64;
    private int ownerId;
    private int itemId;
    private long count;
    private int enchantLevel = -1;
    private ItemLocation loc;
    private int locData;
    private int customType1;
    private int customType2;
    private int lifeTime;
    private int customFlags;
    private ItemAttributes attrs = new ItemAttributes();
    private int[] _enchantOptions = EMPTY_ENCHANT_OPTIONS;
    private ItemTemplate template;
    private boolean isEquipped;
    private long _dropTime;
    private IntSet _dropPlayers = Containers.EMPTY_INT_SET;
    private long _dropTimeOwner;
    private double _chargedSoulshotPower = 0.0;
    private double _chargedSpiritshotPower = 0.0;
    private double _chargedSpiritshotHealBonus = 0.0;
    private double _chargedFishshotPower = 0.0;
    private int _agathionEnergy;
    private int _visualId;
    private int _variationStoneId = 0;
    private int _variation1Id = 0;
    private int _variation2Id = 0;
    private ItemAttachment _attachment;
    private JdbcEntityState _state = JdbcEntityState.CREATED;
    private int _appearanceStoneId = 0;
    private List<SkillEntry> _appearanceStoneSkills = null;
    private Map<Integer, Ensoul> _normalEnsouls = null;
    private Map<Integer, Ensoul> _specialEnsouls = null;
    private final Lock _onEquipUnequipLock = new ReentrantLock();
    private Map<Object, IntObjectMap<SkillEntry>> _equippedSkills = null;
    private Map<Object, IntObjectMap<OptionDataTemplate>> _equippedOptionDatas = null;
    private ScheduledFuture<?> _manaConsumeTask;

    public ItemInstance(int objectId) {
        super(objectId);
    }

    public ItemInstance(int objectId, int itemId) {
        super(objectId);
        this.setItemId(itemId);
        this.setLifeTime(-1);
        this.setAgathionEnergy(this.getTemplate().getAgathionEnergy());
        this.setLocData(-1);
        this.setEnchantLevel(this.getTemplate().getBaseEnchantLevel());
    }

    public int getOwnerId() {
        return this.ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public int getItemId() {
        return this.itemId;
    }

    public void setItemId(int id) {
        this.itemId = id;
        this.template = ItemHolder.getInstance().getTemplate(id);
        this.setCustomFlags(this.getCustomFlags());
    }

    public long getCount() {
        return this.count;
    }

    public void setCount(long count) {
        if (count < 0L) {
            count = 0L;
        }
        if (!this.isStackable() && count > 1L) {
            this.count = 1L;
            return;
        }
        this.count = count;
    }

    public int getEnchantLevel() {
        return this.enchantLevel;
    }

    public int getFixedEnchantLevel(Player owner) {
        if (owner != null && this.enchantLevel > 0 && Config.OLYMPIAD_ENABLE_ENCHANT_LIMIT && owner.isInOlympiadMode()) {
            if (this.isWeapon()) {
                return Math.min(Config.OLYMPIAD_WEAPON_ENCHANT_LIMIT, this.enchantLevel);
            }
            if (this.isArmor()) {
                return Math.min(Config.OLYMPIAD_ARMOR_ENCHANT_LIMIT, this.enchantLevel);
            }
            if (this.isAccessory()) {
                return Math.min(Config.OLYMPIAD_JEWEL_ENCHANT_LIMIT, this.enchantLevel);
            }
        }
        return this.enchantLevel;
    }

    public void setEnchantLevel(int value) {
        int old = this.enchantLevel;
        this.enchantLevel = Math.max(this.getTemplate().getBaseEnchantLevel(), value);
        this._enchantOptions = EMPTY_ENCHANT_OPTIONS;
        if (old != this.enchantLevel && this.getTemplate().getEnchantOptions().size() > 0) {
            int[] enchantOptions = null;
            for (int i = this.enchantLevel; i >= 0; --i) {
                enchantOptions = (int[])this.getTemplate().getEnchantOptions().get(this.enchantLevel);
                if (enchantOptions == null) continue;
                this._enchantOptions = enchantOptions;
                break;
            }
        }
    }

    public void setLocName(String loc) {
        this.loc = ItemLocation.valueOf(loc);
    }

    public String getLocName() {
        return this.loc.name();
    }

    public void setLocation(ItemLocation loc) {
        this.loc = loc;
    }

    public ItemLocation getLocation() {
        return this.loc;
    }

    public void setLocData(int locData) {
        this.locData = locData;
    }

    public int getLocData() {
        return this.locData;
    }

    public int getCustomType1() {
        return this.customType1;
    }

    public void setCustomType1(int newtype) {
        this.customType1 = newtype;
    }

    public int getCustomType2() {
        return this.customType2;
    }

    public void setCustomType2(int newtype) {
        this.customType2 = newtype;
    }

    public int getLifeTime() {
        return this.lifeTime;
    }

    public void setLifeTime(int lifeTime) {
        this.lifeTime = lifeTime == -1 ? (this.getTemplate().isTemporal() ? (int)(System.currentTimeMillis() / 1000L) + this.getTemplate().getDurability() * 60 : (this.getTemplate().isShadowItem() ? this.getTemplate().getDurability() : -1)) : Math.max(0, lifeTime);
    }

    public int getCustomFlags() {
        return this.customFlags;
    }

    public void setCustomFlags(int flags) {
        this.customFlags = flags;
    }

    public ItemAttributes getAttributes() {
        return this.attrs;
    }

    public void setAttributes(ItemAttributes attrs) {
        this.attrs = attrs;
    }

    public int getShadowLifeTime() {
        if (!this.isShadowItem()) {
            return -1;
        }
        return this.getLifeTime();
    }

    public int getTemporalLifeTime() {
        if (this.getVisualId() > 0 && this.getLifeTime() >= 0 || this.isTemporalItem() || this.isFlagLifeTime()) {
            return this.getLifeTime() - (int)(System.currentTimeMillis() / 1000L);
        }
        return -9999;
    }

    public void startManaConsumeTask(PcInventory.ManaConsumeTask r) {
        if (this._manaConsumeTask == null) {
            this._manaConsumeTask = LazyPrecisionTaskManager.getInstance().scheduleAtFixedRate(r, 0L, 60000L);
        }
    }

    public void stopManaConsumeTask() {
        if (this._manaConsumeTask != null) {
            this._manaConsumeTask.cancel(false);
            this._manaConsumeTask = null;
        }
    }

    public boolean isEquipable() {
        return this.template.isEquipable();
    }

    public boolean isEquipped() {
        return this.isEquipped;
    }

    public void setEquipped(boolean isEquipped) {
        this.isEquipped = isEquipped;
    }

    public long getBodyPart() {
        return this.template.getBodyPart();
    }

    public int getEquipSlot() {
        return this.getLocData();
    }

    public ItemTemplate getTemplate() {
        return this.template;
    }

    public void setDropTime(long time) {
        this._dropTime = time;
    }

    public long getLastDropTime() {
        return this._dropTime;
    }

    public long getDropTimeOwner() {
        return this._dropTimeOwner;
    }

    public ItemType getItemType() {
        return this.template.getItemType();
    }

    public boolean isArmor() {
        return this.template.isArmor();
    }

    public boolean isAccessory() {
        return this.template.isAccessory();
    }

    public boolean isOther() {
        return this.template.isOther();
    }

    public boolean isWeapon() {
        return this.template.isWeapon();
    }

    public int getReferencePrice() {
        return this.template.getReferencePrice();
    }

    public boolean isStackable() {
        return this.template.isStackable();
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, ItemInstance.class, this, true)) {
            return;
        }
        player.getAI().setIntention(CtrlIntention.AI_INTENTION_PICK_UP, this, null);
    }

    public boolean isAugmented() {
        return this.getVariation1Id() != 0 || this.getVariation2Id() != 0;
    }

    public int getVariation1Id() {
        return this._variation1Id;
    }

    public void setVariation1Id(int val) {
        this._variation1Id = val;
    }

    public int getVariation2Id() {
        return this._variation2Id;
    }

    public void setVariation2Id(int val) {
        this._variation2Id = val;
    }

    public Func[] getStatFuncs() {
        Func[] result = Func.EMPTY_FUNC_ARRAY;
        LazyArrayList funcs = LazyArrayList.newInstance();
        if (this.template.getAttachedFuncs().length > 0) {
            for (FuncTemplate funcTemplate : this.template.getAttachedFuncs()) {
                Func f = funcTemplate.getFunc(this);
                if (f == null) continue;
                funcs.add(f);
            }
        }
        for (Element element : Element.VALUES) {
            if (this.isWeapon()) {
                funcs.add(new FuncAttack(element, 64, this));
            }
            if (!this.isArmor()) continue;
            funcs.add(new FuncDefence(element, 64, this));
        }
        if (!funcs.isEmpty()) {
            result = (Func[])funcs.toArray((Object[])new Func[funcs.size()]);
        }
        LazyArrayList.recycle((LazyArrayList)funcs);
        return result;
    }

    public boolean isHeroWeapon() {
        return this.template.isHeroWeapon();
    }

    public boolean isHeroItem() {
        return this.template.isHeroItem();
    }

    public boolean isOlympiadItem() {
        return this.template.isOlympiadItem();
    }

    public boolean canBeDestroyed(Player player) {
        if ((this.customFlags & 0x20) == 32) {
            return false;
        }
        if (this.isHeroItem()) {
            return false;
        }
        if (player.getMountControlItemObjId() == this.getObjectId()) {
            return false;
        }
        if (player.getPetControlItem() == this) {
            return false;
        }
        if (player.getEnchantScroll() == this) {
            return false;
        }
        return this.template.isDestroyable();
    }

    public boolean canBeDropped(Player player, boolean pk) {
        if (player.isGM()) {
            return true;
        }
        if (HidenItemsDAO.isHidden(this)) {
            return false;
        }
        if ((this.customFlags & 1) == 1) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (!(!this.isAugmented() || pk && Config.DROP_ITEMS_AUGMENTED || Config.ALT_ALLOW_DROP_AUGMENTED)) {
            return false;
        }
        if (!ItemFunctions.checkIfCanDiscard(player, this)) {
            return false;
        }
        return this.template.isDropable();
    }

    public boolean canBeTraded(Player player) {
        if (this.isEquipped()) {
            return false;
        }
        if (player.isGM() || Config.LIST_OF_TRABLE_ITEMS.equals(this.getItemId())) {
            return true;
        }
        if (HidenItemsDAO.isHidden(this)) {
            return false;
        }
        if ((this.customFlags & 2) == 2) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (this.isAugmented() && !Config.ALT_ALLOW_DROP_AUGMENTED) {
            return false;
        }
        if (!ItemFunctions.checkIfCanDiscard(player, this)) {
            return false;
        }
        return this.template.isTradeable();
    }

    public boolean canBePrivateStore(Player player) {
        if (this.getItemId() == 57) {
            return false;
        }
        if (!this.canBeTraded(player)) {
            return false;
        }
        return this.template.isPrivatestoreable();
    }

    public boolean canBeSold(Player player) {
        if ((this.customFlags & 0x20) == 32) {
            return false;
        }
        if ((this.customFlags & 2) == 2) {
            return false;
        }
        if (this.getItemId() == 57) {
            return false;
        }
        if (HidenItemsDAO.isHidden(this)) {
            return false;
        }
        if (Config.LIST_OF_SELLABLE_ITEMS.equals(this.getItemId())) {
            return true;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (this.isAugmented() && !Config.ALT_ALLOW_DROP_AUGMENTED) {
            return false;
        }
        if (this.isEquipped()) {
            return false;
        }
        if (!ItemFunctions.checkIfCanDiscard(player, this)) {
            return false;
        }
        if (!this.template.isDestroyable()) {
            return false;
        }
        return this.template.isSellable();
    }

    public boolean canBeStored(Player player, boolean privatewh) {
        if ((this.customFlags & 4) == 4) {
            return false;
        }
        if (!this.getTemplate().isStoreable()) {
            return false;
        }
        if (!privatewh && (this.isShadowItem() || this.isTemporalItem())) {
            return false;
        }
        if (!privatewh && this.isAugmented() && !Config.ALT_ALLOW_DROP_AUGMENTED) {
            return false;
        }
        if (this.isEquipped()) {
            return false;
        }
        if (!ItemFunctions.checkIfCanDiscard(player, this)) {
            return false;
        }
        if (HidenItemsDAO.isHidden(this)) {
            return false;
        }
        return privatewh || this.template.isTradeable();
    }

    public boolean canBeCrystallized(Player player) {
        if (this.isFlagNoCrystallize()) {
            return false;
        }
        if (this.isHeroItem()) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (!ItemFunctions.checkIfCanDiscard(player, this)) {
            return false;
        }
        return this.template.isCrystallizable();
    }

    public boolean canBeEnchanted() {
        if ((this.customFlags & 0x10) == 16) {
            return false;
        }
        if (this.isHeroItem()) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (this.isCommonItem()) {
            return false;
        }
        return this.template.canBeEnchanted();
    }

    public boolean canBeAppearance() {
        if (!this.isEquipable()) {
            return false;
        }
        if (this.isHeroItem()) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (this.isCommonItem()) {
            return false;
        }
        return this.template.canBeAppearance();
    }

    public boolean canBeAugmented(Player player) {
        if (!this.getTemplate().isAugmentable()) {
            return false;
        }
        if (this.isAugmented()) {
            return false;
        }
        if (this.isHeroItem()) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (this.isCommonItem()) {
            return false;
        }
        return !this.template.isPvP();
    }

    public boolean canBeExchanged(Player player) {
        if ((this.customFlags & 0x20) == 32) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (!ItemFunctions.checkIfCanDiscard(player, this)) {
            return false;
        }
        if (HidenItemsDAO.isHidden(this)) {
            return false;
        }
        return this.template.isDestroyable();
    }

    public boolean canBeEnsoul(int ensoulId) {
        if (this.isHeroItem()) {
            return false;
        }
        if (this.isShadowItem()) {
            return false;
        }
        if (this.isTemporalItem()) {
            return false;
        }
        if (this.isCommonItem()) {
            return false;
        }
        return this.template.canBeEnsoul(ensoulId);
    }

    public boolean isShadowItem() {
        return this.template.isShadowItem();
    }

    public boolean isTemporalItem() {
        return this.template.isTemporal();
    }

    public boolean isCommonItem() {
        return this.template.isCommonItem();
    }

    public boolean isHiddenItem() {
        return HidenItemsDAO.isHidden(this);
    }

    public void dropToTheGround(Player lastAttacker, NpcInstance fromNpc) {
        Creature dropper = fromNpc;
        if (dropper == null) {
            dropper = lastAttacker;
        }
        Location pos = Location.findAroundPosition(dropper, 100);
        if (lastAttacker != null) {
            Player ccLeader;
            this._dropPlayers = new HashIntSet(1, 2.0f);
            PlayerGroup group = lastAttacker.getParty();
            if (group == null) {
                group = lastAttacker;
            }
            if (fromNpc != null && fromNpc.isBoss() && (group = lastAttacker.getPlayerGroup()) != null && group instanceof CommandChannel && (ccLeader = group.getGroupLeader()) != null && (group = ccLeader.getParty()) == null) {
                group = lastAttacker;
            }
            for (Player $member : group) {
                this._dropPlayers.add($member.getObjectId());
            }
            this._dropTimeOwner = System.currentTimeMillis() + Config.NONOWNER_ITEM_PICKUP_DELAY + (long)(fromNpc != null && fromNpc.isRaid() ? 285000 : 0);
        }
        this.dropMe(dropper, pos);
    }

    public void dropToTheGround(Creature dropper, Location dropPos) {
        if (GeoEngine.canMoveToCoord(dropper.getX(), dropper.getY(), dropper.getZ(), dropPos.x, dropPos.y, dropPos.z, dropper.getGeoIndex())) {
            this.dropMe(dropper, dropPos);
        } else {
            this.dropMe(dropper, dropper.getLoc());
        }
    }

    public void dropToTheGround(Playable dropper, Location dropPos) {
        this.setLocation(ItemLocation.VOID);
        if (this.getJdbcState().isPersisted()) {
            this.setJdbcState(JdbcEntityState.UPDATED);
            this.update();
        }
        if (GeoEngine.canMoveToCoord(dropper.getX(), dropper.getY(), dropper.getZ(), dropPos.x, dropPos.y, dropPos.z, dropper.getGeoIndex())) {
            this.dropMe(dropper, dropPos);
        } else {
            this.dropMe(dropper, dropper.getLoc());
        }
    }

    public void dropMe(Creature dropper, Location loc) {
        if (dropper != null) {
            this.setReflection(dropper.getReflection());
        }
        this.spawnMe0(loc, dropper);
        if (dropper != null && dropper.isPlayable()) {
            if (Config.AUTODESTROY_PLAYER_ITEM_AFTER > 0) {
                ItemsAutoDestroy.getInstance().addPlayerItem(this);
            }
        } else if (this.isHerb()) {
            ItemsAutoDestroy.getInstance().addHerb(this);
        } else if (Config.AUTODESTROY_ITEM_AFTER > 0) {
            ItemsAutoDestroy.getInstance().addItem(this);
        }
    }

    public final void pickupMe() {
        this.decayMe();
        this.setReflection(ReflectionManager.MAIN);
    }

    private int getDefence(Element element) {
        return this.isArmor() ? this.getAttributeElementValue(element, true) : 0;
    }

    public int getDefenceFire() {
        return this.getDefence(Element.FIRE);
    }

    public int getDefenceWater() {
        return this.getDefence(Element.WATER);
    }

    public int getDefenceWind() {
        return this.getDefence(Element.WIND);
    }

    public int getDefenceEarth() {
        return this.getDefence(Element.EARTH);
    }

    public int getDefenceHoly() {
        return this.getDefence(Element.HOLY);
    }

    public int getDefenceUnholy() {
        return this.getDefence(Element.UNHOLY);
    }

    public int getAttributeElementValue(Element element, boolean withBase) {
        return this.attrs.getValue(element) + (withBase ? this.template.getBaseAttributeValue(element) : 0);
    }

    public Element getAttributeElement() {
        return this.attrs.getElement();
    }

    public int getAttributeElementValue() {
        return this.attrs.getValue();
    }

    public Element getAttackElement() {
        Element element;
        Element element2 = element = this.isWeapon() ? this.getAttributeElement() : Element.NONE;
        if (element == Element.NONE) {
            for (Element e : Element.VALUES) {
                if (this.template.getBaseAttributeValue(e) <= 0) continue;
                return e;
            }
        }
        return element;
    }

    public int getAttackElementValue() {
        return this.isWeapon() ? this.getAttributeElementValue(this.getAttackElement(), true) : 0;
    }

    public void setAttributeElement(Element element, int value) {
        this.attrs.setValue(element, value);
    }

    public boolean isHerb() {
        return this.getTemplate().isHerb();
    }

    public long getPriceLimitForItem() {
        return this.getTemplate().getPriceLimitForItem();
    }

    public ItemGrade getGrade() {
        return this.template.getGrade();
    }

    @Override
    public String getName() {
        return this.getTemplate().getName();
    }

    public String getName(Player player) {
        return this.getTemplate().getName(player);
    }

    public void save() {
        _itemsDAO.save(this);
    }

    public void update() {
        _itemsDAO.update(this);
    }

    public void delete() {
        _itemsDAO.delete(this);
        ItemsEnsoulDAO.getInstance().delete(this.getObjectId());
        this.stopManaConsumeTask();
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        L2GameServerPacket packet = null;
        packet = dropper != null ? new DropItemPacket(this, dropper.getObjectId()) : new SpawnItemPacket(this);
        return Collections.singletonList(packet);
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.getTemplate().getItemId());
        sb.append(" ");
        if (this.getEnchantLevel() > 0) {
            sb.append("+");
            sb.append(this.getEnchantLevel());
            sb.append(" ");
        }
        sb.append(this.getTemplate().getName());
        if (!this.getTemplate().getAdditionalName().isEmpty()) {
            sb.append(" ");
            sb.append("\\").append(this.getTemplate().getAdditionalName()).append("\\");
        }
        sb.append(" ");
        sb.append("(");
        sb.append(this.getCount());
        sb.append(")");
        sb.append("[");
        sb.append(this.getObjectId());
        sb.append("]");
        return sb.toString();
    }

    public void setJdbcState(JdbcEntityState state) {
        this._state = state;
    }

    public JdbcEntityState getJdbcState() {
        return this._state;
    }

    @Override
    public boolean isItem() {
        return true;
    }

    public ItemAttachment getAttachment() {
        return this._attachment;
    }

    public void setAttachment(ItemAttachment attachment) {
        ItemAttachment old = this._attachment;
        this._attachment = attachment;
        if (this._attachment != null) {
            this._attachment.setItem(this);
        }
        if (old != null) {
            old.setItem(null);
        }
    }

    public int getAgathionEnergy() {
        return this._agathionEnergy;
    }

    public void setAgathionEnergy(int agathionEnergy) {
        this._agathionEnergy = agathionEnergy;
    }

    public int getVisualId() {
        return this._visualId;
    }

    public void setVisualId(int val) {
        this._visualId = val;
    }

    public int getAppearanceStoneId() {
        return this._appearanceStoneId;
    }

    public void setAppearanceStoneId(int val) {
        AppearanceStone stone;
        if (val == this._appearanceStoneId) {
            return;
        }
        this._appearanceStoneId = val;
        if (this._appearanceStoneSkills != null) {
            this._appearanceStoneSkills.clear();
        }
        if (this._appearanceStoneId > 0 && (stone = AppearanceStoneHolder.getInstance().getAppearanceStone(this._appearanceStoneId)) != null) {
            if (this._appearanceStoneSkills == null) {
                this._appearanceStoneSkills = new ArrayList<SkillEntry>();
            }
            this._appearanceStoneSkills.addAll(stone.getSkills());
        }
    }

    public List<SkillEntry> getAppearanceStoneSkills() {
        if (this._appearanceStoneSkills == null) {
            return Collections.emptyList();
        }
        return this._appearanceStoneSkills;
    }

    public int[] getEnchantOptions() {
        return this._enchantOptions;
    }

    public IntSet getDropPlayers() {
        return this._dropPlayers;
    }

    public int getCrystalCountOnCrystallize() {
        int crystalsAdd = ItemFunctions.getCrystallizeCrystalAdd(this);
        return this.template.getCrystalCount() + crystalsAdd;
    }

    public int getCrystalCountOnEchant() {
        int defaultCrystalCount = this.template.getCrystalCount();
        if (defaultCrystalCount > 0) {
            int crystalsAdd = ItemFunctions.getCrystallizeCrystalAdd(this);
            return (int)Math.ceil((double)defaultCrystalCount / 2.0) + crystalsAdd;
        }
        return 0;
    }

    public ExItemType getExType() {
        return this.getTemplate().getExType();
    }

    public void setVariationStoneId(int id) {
        this._variationStoneId = id;
    }

    public int getVariationStoneId() {
        return this._variationStoneId;
    }

    public double getChargedSoulshotPower() {
        return this._chargedSoulshotPower;
    }

    public void setChargedSoulshotPower(double val) {
        this._chargedSoulshotPower = val;
    }

    public double getChargedSpiritshotPower() {
        return this._chargedSpiritshotPower;
    }

    public double getChargedSpiritshotHealBonus() {
        return this._chargedSpiritshotHealBonus;
    }

    public void setChargedSpiritshotPower(double power, int unk, double healBonus) {
        this._chargedSpiritshotPower = power;
        this._chargedSpiritshotHealBonus = healBonus;
    }

    public double getChargedFishshotPower() {
        return this._chargedFishshotPower;
    }

    public void setChargedFishshotPower(double val) {
        this._chargedFishshotPower = val;
    }

    public Ensoul[] getNormalEnsouls() {
        if (this._normalEnsouls == null) {
            return EMPTY_ENSOULS_ARRAY;
        }
        return this._normalEnsouls.values().toArray(new Ensoul[this._normalEnsouls.size()]);
    }

    public Ensoul[] getSpecialEnsouls() {
        if (this._specialEnsouls == null) {
            return EMPTY_ENSOULS_ARRAY;
        }
        return this._specialEnsouls.values().toArray(new Ensoul[this._specialEnsouls.size()]);
    }

    public void restoreEnsoul() {
        ItemsEnsoulDAO.getInstance().restore(this);
    }

    public boolean containsEnsoul(int type, int id) {
        return this.getEnsoul(type, id) != null;
    }

    public Ensoul getEnsoul(int type, int id) {
        if (type == 1) {
            if (this._normalEnsouls != null) {
                return this._normalEnsouls.get(id);
            }
        } else if (type == 2 && this._specialEnsouls != null) {
            return this._specialEnsouls.get(id);
        }
        return null;
    }

    public void addEnsoul(int type, int id, Ensoul ensoul, boolean store) {
        if (!this.canBeEnsoul(ensoul.getItemId())) {
            return;
        }
        if (type == 1) {
            if (this._normalEnsouls == null) {
                this._normalEnsouls = new TreeMap<Integer, Ensoul>();
            }
            this._normalEnsouls.put(id, ensoul);
        } else if (type == 2) {
            if (this._specialEnsouls == null) {
                this._specialEnsouls = new TreeMap<Integer, Ensoul>();
            }
            this._specialEnsouls.put(id, ensoul);
        } else {
            return;
        }
        if (store) {
            ItemsEnsoulDAO.getInstance().insert(this.getObjectId(), type, id, ensoul.getId());
        }
    }

    public Ensoul removeEnsoul(int type, int id, boolean store) {
        Ensoul ensoul = null;
        if (type == 1) {
            if (this._normalEnsouls != null) {
                ensoul = this._normalEnsouls.remove(id);
            }
        } else if (type == 2 && this._specialEnsouls != null) {
            ensoul = this._specialEnsouls.remove(id);
        }
        if (store && ensoul != null) {
            ItemsEnsoulDAO.getInstance().delete(this.getObjectId(), type, id);
        }
        return ensoul;
    }

    public boolean isFlagLifeTime() {
        return (this.customFlags & 0x40) == 64;
    }

    public boolean isFlagNoCrystallize() {
        return (this.customFlags & 8) == 8;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void onEquip(int slot, Playable actor) {
        if (!this.isEquipped() && !this.getTemplate().isRune()) {
            return;
        }
        this._onEquipUnequipLock.lock();
        try {
            int flags = 0;
            for (Listener listener : actor.getInventory().getListeners()) {
                flags |= ((OnEquipListener)listener).onEquip(slot, this, actor);
            }
            if ((flags & 1) != 0) {
                actor.updateStats();
            }
            if ((flags & 3) == 3 && actor.isPlayer()) {
                actor.getPlayer().sendSkillList();
            }
        }
        finally {
            this._onEquipUnequipLock.unlock();
        }
    }

    public void onEquip(Playable actor) {
        this.onEquip(this.getEquipSlot(), actor);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void onUnequip(int slot, Playable actor, boolean refreshEquip) {
        if (!this.isEquipable() && !this.getTemplate().isRune()) {
            return;
        }
        this._onEquipUnequipLock.lock();
        try {
            int flags = 0;
            for (Listener listener : actor.getInventory().getListeners()) {
                flags |= ((OnEquipListener)listener).onUnequip(slot, this, actor);
            }
            if (refreshEquip) {
                for (ItemInstance item : actor.getInventory().getItems()) {
                    if (item == this) continue;
                    flags |= item.onRefreshEquip(actor, false);
                }
            }
            if ((flags & 1) != 0) {
                actor.updateStats();
            }
            if ((flags & 3) == 3 && actor.isPlayer()) {
                actor.getPlayer().sendSkillList();
            }
        }
        finally {
            this._onEquipUnequipLock.unlock();
        }
    }

    public void onUnequip(int slot, Playable actor) {
        this.onUnequip(slot, actor, true);
    }

    public void onUnequip(Playable actor) {
        this.onUnequip(this.getEquipSlot(), actor);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int onRefreshEquip(Playable actor, boolean update) {
        if (!this.isEquipped() && !this.getTemplate().isRune()) {
            return 0;
        }
        this._onEquipUnequipLock.lock();
        try {
            int flags = 0;
            for (Listener listener : actor.getInventory().getListeners()) {
                flags |= ((OnEquipListener)listener).onRefreshEquip(this, actor);
            }
            if (update) {
                if ((flags & 1) != 0) {
                    actor.updateStats();
                }
                if ((flags & 3) == 3 && actor.isPlayer()) {
                    actor.getPlayer().sendSkillList();
                }
            }
            int n = flags;
            return n;
        }
        finally {
            this._onEquipUnequipLock.unlock();
        }
    }

    public int onRefreshEquip(Playable actor) {
        return this.onRefreshEquip(actor, true);
    }

    public SkillEntry addEquippedSkill(Object owner, SkillEntry skill) {
        if (this._equippedSkills == null) {
            this._equippedSkills = new ConcurrentHashMap<Object, IntObjectMap<SkillEntry>>();
        }
        IntObjectMap skillsMap = this._equippedSkills.computeIfAbsent(owner, m -> new HashIntObjectMap());
        return (SkillEntry)skillsMap.put(skill.getId(), skill);
    }

    public IntObjectMap<SkillEntry> removeEquippedSkills(Object owner) {
        if (this._equippedSkills == null) {
            return null;
        }
        return this._equippedSkills.remove(owner);
    }

    public int getEquippedSkillLevel(int skillId) {
        if (this._equippedSkills == null) {
            return 0;
        }
        int skillLevel = 0;
        for (IntObjectMap<SkillEntry> skillsMap : this._equippedSkills.values()) {
            SkillEntry skillEntry = (SkillEntry)skillsMap.get(skillId);
            if (skillEntry == null || skillEntry.getLevel() <= skillLevel) continue;
            skillLevel = skillEntry.getLevel();
        }
        return skillLevel;
    }

    public OptionDataTemplate addEquippedOptionData(Object owner, OptionDataTemplate optionData) {
        if (this._equippedOptionDatas == null) {
            this._equippedOptionDatas = new ConcurrentHashMap<Object, IntObjectMap<OptionDataTemplate>>();
        }
        IntObjectMap optionDataMap = this._equippedOptionDatas.computeIfAbsent(owner, m -> new HashIntObjectMap());
        return (OptionDataTemplate)optionDataMap.put(optionData.getId(), optionData);
    }

    public IntObjectMap<OptionDataTemplate> removeEquippedOptionDatas(Object owner) {
        if (this._equippedOptionDatas == null) {
            return null;
        }
        return this._equippedOptionDatas.remove(owner);
    }

    public class FuncDefence
    extends Func {
        private final Element element;

        public FuncDefence(Element element, int order, Object owner) {
            super(element.getDefence(), order, owner);
            this.element = element;
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += (double)ItemInstance.this.getAttributeElementValue(this.element, true);
        }
    }

    public class FuncAttack
    extends Func {
        private final Element element;

        public FuncAttack(Element element, int order, Object owner) {
            super(element.getAttack(), order, owner);
            this.element = element;
        }

        @Override
        public void calc(Env env, StatModifierType modifierType) {
            env.value += (double)ItemInstance.this.getAttributeElementValue(this.element, true);
        }
    }

    public static enum ItemLocation {
        VOID,
        INVENTORY,
        PAPERDOLL,
        PET_INVENTORY,
        PET_PAPERDOLL,
        WAREHOUSE,
        CLANWH,
        FREIGHT,
        LEASE,
        MAIL;

    }
}

