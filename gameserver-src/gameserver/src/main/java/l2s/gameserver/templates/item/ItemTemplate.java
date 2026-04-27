/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.ArrayUtils
 *  org.apache.commons.lang3.ArrayUtils
 *  org.napile.primitive.Containers
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.templates.item;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.string.ItemNameHolder;
import l2s.gameserver.data.xml.holder.AgathionHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.items.impl.EquipableItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.conditions.ConditionPlayerOlympiad;
import l2s.gameserver.stats.funcs.FuncAdd;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.agathion.AgathionData;
import l2s.gameserver.templates.agathion.AgathionTemplate;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemFlags;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemQuality;
import l2s.gameserver.templates.item.ItemReuseType;
import l2s.gameserver.templates.item.ItemType;
import l2s.gameserver.templates.item.WeaponFightType;
import l2s.gameserver.templates.item.data.CapsuledItemData;
import org.napile.primitive.Containers;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public abstract class ItemTemplate
extends StatTemplate {
    public static final int ITEM_ID_PC_BANG_POINTS = -100;
    public static final int ITEM_ID_CLAN_REPUTATION_SCORE = -200;
    public static final int ITEM_ID_FAME = -300;
    public static final int ITEM_ID_ADENA = 57;
    public static final int ITEM_ID_FORMAL_WEAR = 6408;
    public static final int ITEM_ID_HERO_WING = 6842;
    public static final int ITEM_ID_HERO_CLOAK = 30372;
    public static final int ITEM_ID_FAME_CLOAK = 30373;
    public static final int[] HERO_WEAPON_IDS = new int[]{6611, 6612, 6613, 6614, 6616, 6617, 6618, 6619, 6620, 6621};
    public static final int TYPE1_WEAPON_RING_EARRING_NECKLACE = 0;
    public static final int TYPE1_SHIELD_ARMOR = 1;
    public static final int TYPE1_OTHER = 2;
    public static final int TYPE1_ITEM_QUESTITEM_ADENA = 4;
    public static final int TYPE2_WEAPON = 0;
    public static final int TYPE2_SHIELD_ARMOR = 1;
    public static final int TYPE2_ACCESSORY = 2;
    public static final int TYPE2_QUEST = 3;
    public static final int TYPE2_MONEY = 4;
    public static final int TYPE2_OTHER = 5;
    public static final int PET_EQUIP_TYPE_WOLF = 1;
    public static final int PET_EQUIP_TYPE_HATCHLING = 2;
    public static final int PET_EQUIP_TYPE_STRIDER = 3;
    public static final int PET_EQUIP_TYPE_GREAT_WOLF = 4;
    public static final int PET_EQUIP_TYPE_PENDANT = 5;
    public static final int PET_EQUIP_TYPE_BABY = 6;
    public static final long SLOT_NONE = 0L;
    public static final long SLOT_PENDANT = 1L;
    public static final long SLOT_R_EAR = 2L;
    public static final long SLOT_L_EAR = 4L;
    public static final long SLOT_NECK = 8L;
    public static final long SLOT_R_FINGER = 16L;
    public static final long SLOT_L_FINGER = 32L;
    public static final long SLOT_HEAD = 64L;
    public static final long SLOT_R_HAND = 128L;
    public static final long SLOT_L_HAND = 256L;
    public static final long SLOT_GLOVES = 512L;
    public static final long SLOT_CHEST = 1024L;
    public static final long SLOT_LEGS = 2048L;
    public static final long SLOT_FEET = 4096L;
    public static final long SLOT_BACK = 8192L;
    public static final long SLOT_LR_HAND = 16384L;
    public static final long SLOT_FULL_ARMOR = 32768L;
    public static final long SLOT_HAIR = 65536L;
    public static final long SLOT_FORMAL_WEAR = 131072L;
    public static final long SLOT_DHAIR = 262144L;
    public static final long SLOT_HAIRALL = 524288L;
    public static final long SLOT_R_BRACELET = 0x100000L;
    public static final long SLOT_L_BRACELET = 0x200000L;
    public static final long SLOT_DECO = 0x400000L;
    public static final long SLOT_DECO2 = 0x800000L;
    public static final long SLOT_DECO3 = 0x1000000L;
    public static final long SLOT_DECO4 = 0x2000000L;
    public static final long SLOT_DECO5 = 0x4000000L;
    public static final long SLOT_DECO6 = 0x8000000L;
    public static final long SLOT_BELT = 0x10000000L;
    public static final long SLOT_BROOCH = 0x20000000L;
    public static final long SLOT_JEWEL = 0x40000000L;
    public static final long SLOT_JEWEL2 = 0x80000000L;
    public static final long SLOT_JEWEL3 = 0x100000000L;
    public static final long SLOT_JEWEL4 = 0x200000000L;
    public static final long SLOT_JEWEL5 = 0x400000000L;
    public static final long SLOT_JEWEL6 = 0x800000000L;
    public static final long SLOT_AGATHION = 0x3000000000L;
    public static final long SLOT_AGATHION_MAIN = 0x1000000000L;
    public static final long SLOT_AGATHION_1 = 0x2000000000L;
    public static final long SLOT_AGATHION_2 = 0x4000000000L;
    public static final long SLOT_AGATHION_3 = 0x8000000000L;
    public static final long SLOT_AGATHION_4 = 0x10000000000L;
    public static final long SLOTS_ARMOR = 40769L;
    public static final long SLOTS_JEWELRY = 62L;
    public static final int CRYSTAL_NONE = 0;
    public static final int CRYSTAL_D = 1458;
    public static final int CRYSTAL_C = 1459;
    public static final int CRYSTAL_B = 1460;
    public static final int CRYSTAL_A = 1461;
    public static final int CRYSTAL_S = 1462;
    public static final int CRYSTAL_R = 17371;
    private final int _itemId;
    private final String _name;
    private final String _addname;
    private final String _icon;
    private final int _weight;
    private final int _referencePrice;
    private final int _durability;
    private final boolean _temporal;
    private final ItemGrade _grade;
    private int _flags;
    protected ItemType _type;
    protected int _type1;
    protected int _type2;
    protected ExItemType _exType = ExItemType.OTHER_ITEMS;
    protected int _petType;
    protected SkillEntry[] _skills;
    private IntObjectMap<List<SkillEntry>> _enchantSkills = new HashIntObjectMap(0);
    private final List<Condition> _conditions = new ArrayList<Condition>();
    private final boolean _stackable;
    private final ItemReuseType _reuseType;
    private final int _reuseGroup;
    private final List<CapsuledItemData> _capsuledItems = new ArrayList<CapsuledItemData>();
    protected long _bodyPart;
    private final int _crystalCount;
    private int[] _baseAttributes = new int[6];
    private IntObjectMap<int[]> _enchantOptions = Containers.emptyIntObjectMap();
    private final boolean _isPvP;
    private final ItemQuality _quality;
    private final int _baseEnchantLevel;
    private final long _priceLimit;
    private final int _variationGroupId;
    private int _pAtk = 0;
    private int _mAtk = 0;
    private int _pDef = 0;
    private int _mDef = 0;
    private final AgathionTemplate _agathionTemplate;

    protected ItemTemplate(StatsSet set) {
        this._itemId = set.getInteger("item_id");
        this._name = set.getString("name");
        this._addname = set.getString("add_name", "");
        this._icon = set.getString("icon", "");
        this._weight = set.getInteger("weight", 0);
        this._referencePrice = set.getInteger("price", 0);
        this._stackable = set.getBool("stackable", false);
        this._durability = this._stackable ? -1 : set.getInteger("durability", -1);
        this._temporal = this._stackable ? false : set.getBool("temporal", false);
        this._grade = (ItemGrade)set.getEnum("crystal_type", ItemGrade.class, ItemGrade.NONE);
        this._bodyPart = set.getLong("bodypart", 0L);
        this._reuseType = (ItemReuseType)set.getEnum("reuse_type", ItemReuseType.class, ItemReuseType.NORMAL);
        this._reuseGroup = set.getInteger("delay_share_group", -this._itemId);
        this._isPvP = set.getBool("is_pvp", false);
        this._baseEnchantLevel = set.getInteger("enchanted", 0);
        this._crystalCount = set.getInteger("crystal_count", 0);
        this._priceLimit = set.getLong("price_limit", 0L);
        this._quality = (ItemQuality)set.getEnum("item_quality", ItemQuality.class, ItemQuality.NORMAL);
        this._variationGroupId = set.getInteger("variation_group_id", 0);
        for (ItemFlags f : ItemFlags.VALUES) {
            boolean flag = set.getBool(f.name().toLowerCase(), f.getDefaultValue());
            if (!flag) continue;
            this.activeFlag(f);
        }
        this._funcTemplates = FuncTemplate.EMPTY_ARRAY;
        this._skills = SkillEntry.EMPTY_ARRAY;
        this._agathionTemplate = AgathionHolder.getInstance().getTemplateByItemId(this._itemId);
        if (!set.getBool("is_olympiad_can_use", true)) {
            ConditionPlayerOlympiad cond = new ConditionPlayerOlympiad(false);
            cond.setSystemMsg(1508);
            this.addCondition(cond);
        }
    }

    protected void initEnchantFuncs() {
        if (this.isWeapon()) {
            this.attachFunc(FuncTemplate.makeTemplate(null, "Enchant", Stats.POWER_ATTACK, 12, 0.0));
            this.attachFunc(FuncTemplate.makeTemplate(null, "Enchant", Stats.MAGIC_ATTACK, 12, 0.0));
        } else if (this.isArmor()) {
            if (this._exType == ExItemType.SHIELD) {
                this.attachFunc(FuncTemplate.makeTemplate(null, "Enchant", Stats.SHIELD_DEFENCE, 12, 0.0));
            } else {
                this.attachFunc(FuncTemplate.makeTemplate(null, "Enchant", Stats.POWER_DEFENCE, 12, 0.0));
            }
            this.attachFunc(FuncTemplate.makeTemplate(null, "Enchant", Stats.MAX_HP, 128, 0.0));
        } else if (this.isAccessory()) {
            this.attachFunc(FuncTemplate.makeTemplate(null, "Enchant", Stats.MAGIC_DEFENCE, 12, 0.0));
        }
    }

    public final int getItemId() {
        return this._itemId;
    }

    public final String getName() {
        return this._name;
    }

    public final String getName(Player player) {
        String name = ItemNameHolder.getInstance().getItemName(player, this.getItemId());
        return name == null ? this._name : name;
    }

    public final String getAdditionalName() {
        return this._addname;
    }

    public final String getIcon() {
        return this._icon;
    }

    public final int getWeight() {
        return this._weight;
    }

    public final int getReferencePrice() {
        return this._referencePrice;
    }

    public final int getDurability() {
        return this._durability;
    }

    public final boolean isTemporal() {
        return this._temporal;
    }

    public ItemType getItemType() {
        return this._type;
    }

    public final int getType1() {
        return this._type1;
    }

    public final int getType2() {
        return this._type2;
    }

    public final ItemGrade getGrade() {
        return this._grade;
    }

    public abstract long getItemMask();

    public int getBaseAttributeValue(Element element) {
        if (element == Element.NONE) {
            return 0;
        }
        return this._baseAttributes[element.getId()];
    }

    public final void setBaseAtributeElements(int[] val) {
        this._baseAttributes = val;
    }

    public int getBaseEnchantLevel() {
        return this._baseEnchantLevel;
    }

    public boolean isCrystallizable() {
        if (Config.DISABLE_CRYSTALIZATION_ITEMS) {
            return false;
        }
        return this.isDestroyable() && this.getGrade() != ItemGrade.NONE && this.getCrystalCount() > 0;
    }

    public int getCrystalCount() {
        return this._crystalCount;
    }

    public final long getBodyPart() {
        return this._bodyPart;
    }

    public boolean isStackable() {
        return this._stackable;
    }

    public boolean isForHatchling() {
        return this._petType == 2;
    }

    public boolean isForStrider() {
        return this._petType == 3;
    }

    public boolean isForWolf() {
        return this._petType == 1;
    }

    public boolean isForPetBaby() {
        return this._petType == 6;
    }

    public boolean isForGWolf() {
        return this._petType == 4;
    }

    public boolean isPetPendant() {
        return this._petType == 5;
    }

    public boolean isForPet() {
        return this.getExType() == ExItemType.PET_EQUIPMENT;
    }

    public void attachSkill(Skill skill) {
        IItemHandler handler = this.getHandler();
        if (handler != null) {
            handler.attachSkill(this, skill);
            return;
        }
        this.addAttachedSkill(SkillEntry.makeSkillEntry(SkillEntryType.ITEM, skill));
    }

    public void addAttachedSkill(SkillEntry skillEntry) {
        this._skills = (SkillEntry[])ArrayUtils.add((Object[])this._skills, (Object)skillEntry);
    }

    public SkillEntry[] getAttachedSkills() {
        return this._skills;
    }

    public SkillEntry getFirstSkill() {
        if (this._skills.length > 0) {
            return this._skills[0];
        }
        return null;
    }

    public List<SkillEntry> getEnchantSkills(int enchant) {
        return (List)this._enchantSkills.get(enchant);
    }

    public IntObjectMap<List<SkillEntry>> getEnchantSkills() {
        return this._enchantSkills;
    }

    public String toString() {
        return this._itemId + " " + this._name;
    }

    public boolean isShadowItem() {
        return this._durability > 0 && !this.isTemporal();
    }

    public final boolean isCommonItem() {
        return this._quality == ItemQuality.COMMON;
    }

    public final boolean isAdena() {
        return this._itemId == 57;
    }

    public final boolean isEquipment() {
        return this._type1 != 4;
    }

    public final boolean isKeyMatherial() {
        return this._type == EtcItemTemplate.EtcItemType.MATERIAL;
    }

    public final boolean isRecipe() {
        return this._type == EtcItemTemplate.EtcItemType.RECIPE;
    }

    public final boolean isRune() {
        return this._type == EtcItemTemplate.EtcItemType.RUNE || this._type == EtcItemTemplate.EtcItemType.RUNE_SELECT;
    }

    public final boolean isTerritoryAccessory() {
        return this._itemId >= 13740 && this._itemId <= 13748 || this._itemId >= 14592 && this._itemId <= 14600 || this._itemId >= 14664 && this._itemId <= 14672 || this._itemId >= 14801 && this._itemId <= 14809 || this._itemId >= 15282 && this._itemId <= 15299;
    }

    public final boolean isArrow() {
        return this._type == EtcItemTemplate.EtcItemType.ARROW;
    }

    public final boolean isBolt() {
        return this._type == EtcItemTemplate.EtcItemType.BOLT;
    }

    public final boolean isQuiver() {
        return this._type == EtcItemTemplate.EtcItemType.ARROW_QUIVER || this._type == EtcItemTemplate.EtcItemType.BOLT_QUIVER;
    }

    public final boolean isBelt() {
        return this._bodyPart == 0x10000000L;
    }

    public final boolean isBracelet() {
        return this._bodyPart == 0x100000L || this._bodyPart == 0x200000L;
    }

    public final boolean isCloak() {
        return this._bodyPart == 8192L;
    }

    public final boolean isTalisman() {
        return this._bodyPart == 0x400000L;
    }

    public final boolean isAgathion() {
        return this._bodyPart == 0x3000000000L;
    }

    public final boolean isBrooch() {
        return this._bodyPart == 0x20000000L;
    }

    public final boolean isJewel() {
        return this._bodyPart == 0x40000000L;
    }

    public final boolean isHerb() {
        return this._type == EtcItemTemplate.EtcItemType.HERB;
    }

    public final boolean isLifeStone() {
        return this._type == EtcItemTemplate.EtcItemType.LIFE_STONE;
    }

    public final boolean isAccessoryLifeStone() {
        return this._type == EtcItemTemplate.EtcItemType.ACC_LIFE_STONE;
    }

    public final boolean isHeroWeapon() {
        return org.apache.commons.lang3.ArrayUtils.contains((int[])HERO_WEAPON_IDS, (int)this._itemId);
    }

    public boolean isHeroItem() {
        return this.isHeroWeapon() || this._itemId == 6842 || this._itemId == 30372;
    }

    public boolean isOlympiadItem() {
        return this.isHeroItem() || this._itemId == 30373;
    }

    public boolean isCrystall() {
        return this._itemId == 1458 || this._itemId == 1459 || this._itemId == 1460 || this._itemId == 1461 || this._itemId == 1462 || this._itemId == 17371;
    }

    public boolean isWeapon() {
        return this.getType2() == 0;
    }

    public boolean isArmor() {
        return this.getType2() == 1;
    }

    public boolean isAccessory() {
        return this.getType2() == 2;
    }

    public boolean isOther() {
        return this.getType2() == 5;
    }

    public boolean isQuest() {
        return this.getType2() == 3;
    }

    public boolean isJewelry() {
        return this.getExType() == ExItemType.RING || this.getExType() == ExItemType.EARRING || this.getExType() == ExItemType.NECKLACE;
    }

    public boolean isHairAccessory() {
        return this.getExType() == ExItemType.HAIR_ACCESSORY;
    }

    public boolean canBeEnchanted() {
        return this.isEnchantable();
    }

    public boolean canBeAppearance() {
        if (this.isArmor() ? this._exType != ExItemType.UPPER_PIECE && this._exType != ExItemType.LOWER_PIECE && this._exType != ExItemType.FULL_BODY && this._exType != ExItemType.GLOVES && this._exType != ExItemType.FEET && this._exType != ExItemType.SHIELD && this._exType != ExItemType.SIGIL : (this.isAccessory() ? this._exType != ExItemType.HAIR_ACCESSORY : this.isWeapon() && this._exType == ExItemType.OTHER_WEAPON)) {
            return false;
        }
        return this.isAppearanceable();
    }

    public boolean canBeEnsoul(int ensoulId) {
        return false;
    }

    public boolean isEquipable() {
        return this.getBodyPart() > 0L && this.getHandler() instanceof EquipableItemHandler;
    }

    public void addEnchantSkill(int enchant, Skill skill) {
        ArrayList<SkillEntry> skills = (ArrayList<SkillEntry>)this._enchantSkills.get(enchant);
        if (skills == null) {
            skills = new ArrayList<SkillEntry>();
            this._enchantSkills.put(enchant, skills);
        }
        skills.add(SkillEntry.makeSkillEntry(SkillEntryType.ITEM, skill));
    }

    public boolean testCondition(Playable playable, ItemInstance instance, boolean sendMsg) {
        if (this._conditions.isEmpty()) {
            return true;
        }
        SystemMsg msg = this.getHandler().checkCondition(playable, instance);
        if (msg != null) {
            if (sendMsg && playable.isPlayer()) {
                if (msg.size() > 0) {
                    playable.sendPacket((IBroadcastPacket)new SystemMessagePacket(msg).addItemName(this.getItemId()));
                } else {
                    playable.sendPacket((IBroadcastPacket)msg);
                }
            }
            return false;
        }
        Env env = new Env();
        env.character = playable;
        env.item = instance;
        for (Condition condition : this._conditions) {
            if (condition.test(env)) continue;
            if (sendMsg && playable.isPlayer() && condition.getSystemMsg() != null) {
                if (condition.getSystemMsg().size() > 0) {
                    playable.sendPacket((IBroadcastPacket)new SystemMessagePacket(condition.getSystemMsg()).addItemName(this.getItemId()));
                } else {
                    playable.sendPacket((IBroadcastPacket)condition.getSystemMsg());
                }
            }
            return false;
        }
        return true;
    }

    public boolean isBlocked(Playable playable, ItemInstance instance) {
        if (this._conditions.isEmpty()) {
            return false;
        }
        Env env = new Env();
        env.character = playable;
        env.item = instance;
        for (Condition condition : this._conditions) {
            if (condition.test(env) || condition.getSystemMsg() != null) continue;
            return true;
        }
        return false;
    }

    public void addCondition(Condition condition) {
        this._conditions.add(condition);
    }

    public boolean isEnchantable() {
        return this.hasFlag(ItemFlags.ENCHANTABLE);
    }

    public boolean isAugmentable() {
        return this.getVariationGroupId() > 0;
    }

    public final boolean isTradeable() {
        return this.hasFlag(ItemFlags.TRADEABLE);
    }

    public final boolean isPrivatestoreable() {
        return this.hasFlag(ItemFlags.PRIVATESTOREABLE);
    }

    public final boolean isDestroyable() {
        return this.hasFlag(ItemFlags.DESTROYABLE);
    }

    public final boolean isAppearanceable() {
        return this.hasFlag(ItemFlags.APPEARANCEABLE);
    }

    public final boolean isDropable() {
        return this.hasFlag(ItemFlags.DROPABLE);
    }

    public final boolean isSellable() {
        return this.hasFlag(ItemFlags.SELLABLE);
    }

    public final boolean isStoreable() {
        return this.hasFlag(ItemFlags.STOREABLE);
    }

    public final boolean isFreightable() {
        return this.hasFlag(ItemFlags.FREIGHTABLE);
    }

    public final boolean isEnsoulable() {
        return this.hasFlag(ItemFlags.ENSOULABLE);
    }

    public boolean hasFlag(ItemFlags f) {
        return (this._flags & f.mask()) == f.mask();
    }

    private void activeFlag(ItemFlags f) {
        this._flags |= f.mask();
    }

    public IItemHandler getHandler() {
        return null;
    }

    public int getReuseDelay() {
        return 0;
    }

    public int getReuseGroup() {
        return this._reuseGroup;
    }

    public int getDisplayReuseGroup() {
        return this._reuseGroup < 0 ? -1 : this._reuseGroup;
    }

    public AgathionTemplate getAgathionTemplate() {
        return this._agathionTemplate;
    }

    public int getAgathionEnergy() {
        return this._agathionTemplate == null ? 0 : this._agathionTemplate.getEnergy();
    }

    public int getAgathionMaxEnergy() {
        return this._agathionTemplate == null ? 0 : this._agathionTemplate.getMaxEnergy();
    }

    public void addEnchantOptions(int level, int[] options) {
        if (this._enchantOptions.isEmpty()) {
            this._enchantOptions = new HashIntObjectMap();
        }
        this._enchantOptions.put(level, options);
    }

    public IntObjectMap<int[]> getEnchantOptions() {
        return this._enchantOptions;
    }

    public ItemReuseType getReuseType() {
        return this._reuseType;
    }

    public boolean isMagicWeapon() {
        return false;
    }

    public final List<CapsuledItemData> getCapsuledItems() {
        return this._capsuledItems;
    }

    public void addCapsuledItem(CapsuledItemData ci) {
        this._capsuledItems.add(ci);
    }

    public ItemQuality getQuality() {
        return this._quality;
    }

    public boolean isPvP() {
        return this._isPvP;
    }

    public ExItemType getExType() {
        return this._exType;
    }

    public long getPriceLimitForItem() {
        return this._priceLimit;
    }

    public int getVariationGroupId() {
        return this._variationGroupId;
    }

    public WeaponFightType getWeaponFightType() {
        return WeaponFightType.WARRIOR;
    }

    @Override
    public void attachFunc(FuncTemplate f) {
        if (this.isForPet()) {
            super.attachFunc(f);
            return;
        }
        if (this.isWeapon()) {
            if (f._stat == Stats.POWER_ATTACK && f._func == FuncAdd.class && f._order == 16) {
                this._pAtk = (int)f._value;
                return;
            }
            if (f._stat == Stats.MAGIC_ATTACK && f._func == FuncAdd.class && f._order == 16) {
                this._mAtk = (int)f._value;
                return;
            }
        } else if (this.isArmor()) {
            switch (this._exType) {
                case HELMET: 
                case UPPER_PIECE: 
                case LOWER_PIECE: 
                case FULL_BODY: 
                case GLOVES: 
                case FEET: 
                case PENDANT: 
                case CLOAK: {
                    if (f._stat != Stats.POWER_DEFENCE || f._func != FuncAdd.class || f._order != 16) break;
                    this._pDef = (int)f._value;
                    return;
                }
            }
        } else if (this.isAccessory()) {
            switch (this._exType) {
                case RING: 
                case EARRING: 
                case NECKLACE: {
                    if (f._stat != Stats.MAGIC_DEFENCE || f._func != FuncAdd.class || f._order != 16) break;
                    this._mDef = (int)f._value;
                    return;
                }
            }
        }
        super.attachFunc(f);
    }

    public final int getPAtk() {
        return this._pAtk;
    }

    public final int getMAtk() {
        return this._mAtk;
    }

    public final int getPDef() {
        return this._pDef;
    }

    public final int getMDef() {
        return this._mDef;
    }

    public boolean useItem(Playable playable, ItemInstance item, boolean ctrlPressed, boolean force) {
        Player player;
        if (playable == null || item == null || item.getTemplate() != this) {
            return false;
        }
        if (playable.isPlayer()) {
            if (item.getLocation() != ItemInstance.ItemLocation.INVENTORY && item.getLocation() != ItemInstance.ItemLocation.PAPERDOLL) {
                return false;
            }
        } else if (playable.isPet()) {
            if (item.getLocation() != ItemInstance.ItemLocation.PET_INVENTORY && item.getLocation() != ItemInstance.ItemLocation.PET_PAPERDOLL) {
                return false;
            }
        } else {
            return false;
        }
        if ((player = playable.getPlayer()) == null || player.getObjectId() != item.getOwnerId()) {
            return false;
        }
        IItemHandler handler = this.getHandler();
        if (handler == null) {
            return false;
        }
        if (force) {
            return handler.forceUseItem(playable, item, ctrlPressed);
        }
        return handler.useItem(playable, item, ctrlPressed);
    }

    public boolean dropItem(Player player, ItemInstance item, long count, Location loc) {
        if (player == null || item == null || count <= 0L) {
            return false;
        }
        IItemHandler handler = this.getHandler();
        if (handler == null) {
            return false;
        }
        handler.dropItem(player, item, count, loc);
        return true;
    }

    public void setAgathionData(AgathionData agathionData) {
    }

    public AgathionData getAgathionData() {
        return null;
    }
}

