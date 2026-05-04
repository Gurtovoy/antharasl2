/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items;

import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.support.Ensoul;

public class ItemInfo {
    private int ownerId;
    private int lastChange;
    private int type1;
    private int objectId;
    private int itemId;
    private long count;
    private int type2;
    private int customType1;
    private boolean isEquipped;
    private long bodyPart;
    private int enchantLevel;
    private int customType2;
    private int _variationStoneId;
    private int _variation1Id;
    private int _variation2Id;
    private int shadowLifeTime;
    private int equipSlot;
    private int temporalLifeTime;
    private int[] enchantOptions = ItemInstance.EMPTY_ENCHANT_OPTIONS;
    private int _visualId;
    private int _attrFire;
    private int _attrWater;
    private int _attrWind;
    private int _attrEarth;
    private int _attrHoly;
    private int _attrUnholy;
    private boolean _isBlocked;
    private Ensoul[] _normalEnsouls = ItemInstance.EMPTY_ENSOULS_ARRAY;
    private Ensoul[] _specialEnsouls = ItemInstance.EMPTY_ENSOULS_ARRAY;
    private ItemTemplate item;

    public ItemInfo() {
    }

    public ItemInfo(ItemInstance item) {
        this(item, false);
    }

    public ItemInfo(ItemInstance item, boolean isBlocked) {
        this.setOwnerId(item.getOwnerId());
        this.setObjectId(item.getObjectId());
        this.setItemId(item.getItemId());
        this.setCount(item.getCount());
        this.setCustomType1(item.getCustomType1());
        this.setEquipped(item.isEquipped());
        this.setEnchantLevel(item.getEnchantLevel());
        this.setCustomType2(item.getCustomType2());
        this.setVariationStoneId(item.getVariationStoneId());
        this.setVariation1Id(item.getVariation1Id());
        this.setVariation2Id(item.getVariation2Id());
        this.setShadowLifeTime(item.getShadowLifeTime());
        this.setEquipSlot(item.getEquipSlot());
        this.setTemporalLifeTime(item.getTemporalLifeTime());
        this.setEnchantOptions(item.getEnchantOptions());
        this.setAttributeFire(item.getAttributeElementValue(Element.FIRE, true));
        this.setAttributeWater(item.getAttributeElementValue(Element.WATER, true));
        this.setAttributeWind(item.getAttributeElementValue(Element.WIND, true));
        this.setAttributeEarth(item.getAttributeElementValue(Element.EARTH, true));
        this.setAttributeHoly(item.getAttributeElementValue(Element.HOLY, true));
        this.setAttributeUnholy(item.getAttributeElementValue(Element.UNHOLY, true));
        this.setIsBlocked(isBlocked);
        this.setVisualId(item.getVisualId());
        this.setNormalEnsouls(item.getNormalEnsouls());
        this.setSpecialEnsouls(item.getSpecialEnsouls());
    }

    public ItemTemplate getItem() {
        return this.item;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public void setLastChange(int lastChange) {
        this.lastChange = lastChange;
    }

    public void setType1(int type1) {
        this.type1 = type1;
    }

    public void setObjectId(int objectId) {
        this.objectId = objectId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
        this.item = itemId > 0 ? ItemHolder.getInstance().getTemplate(this.getItemId()) : null;
        if (this.item != null) {
            this.setType1(this.item.getType1());
            this.setType2(this.item.getType2());
            this.setBodyPart(this.item.getBodyPart());
        }
    }

    public void setCount(long count) {
        this.count = count;
    }

    public void setType2(int type2) {
        this.type2 = type2;
    }

    public void setCustomType1(int customType1) {
        this.customType1 = customType1;
    }

    public void setEquipped(boolean isEquipped) {
        this.isEquipped = isEquipped;
    }

    public void setBodyPart(long bodyPart) {
        this.bodyPart = bodyPart;
    }

    public void setEnchantLevel(int enchantLevel) {
        this.enchantLevel = enchantLevel;
    }

    public void setCustomType2(int customType2) {
        this.customType2 = customType2;
    }

    public void setVariationStoneId(int val) {
        this._variationStoneId = val;
    }

    public void setVariation1Id(int val) {
        this._variation1Id = val;
    }

    public void setVariation2Id(int val) {
        this._variation2Id = val;
    }

    public void setShadowLifeTime(int shadowLifeTime) {
        this.shadowLifeTime = shadowLifeTime;
    }

    public void setEquipSlot(int equipSlot) {
        this.equipSlot = equipSlot;
    }

    public void setTemporalLifeTime(int temporalLifeTime) {
        this.temporalLifeTime = temporalLifeTime;
    }

    public void setIsBlocked(boolean val) {
        this._isBlocked = val;
    }

    public void setVisualId(int val) {
        this._visualId = val;
    }

    public int getOwnerId() {
        return this.ownerId;
    }

    public int getLastChange() {
        return this.lastChange;
    }

    public int getType1() {
        return this.type1;
    }

    public int getObjectId() {
        return this.objectId;
    }

    public int getItemId() {
        return this.itemId;
    }

    public long getCount() {
        return this.count;
    }

    public int getType2() {
        return this.type2;
    }

    public int getCustomType1() {
        return this.customType1;
    }

    public boolean isEquipped() {
        return this.isEquipped;
    }

    public long getBodyPart() {
        return this.bodyPart;
    }

    public int getEnchantLevel() {
        return this.enchantLevel;
    }

    public int getVariationStoneId() {
        return this._variationStoneId;
    }

    public int getVariation1Id() {
        return this._variation1Id;
    }

    public int getVariation2Id() {
        return this._variation2Id;
    }

    public int getShadowLifeTime() {
        return this.shadowLifeTime;
    }

    public int getCustomType2() {
        return this.customType2;
    }

    public int getEquipSlot() {
        return this.equipSlot;
    }

    public int getTemporalLifeTime() {
        return this.temporalLifeTime;
    }

    public boolean isBlocked() {
        return this._isBlocked;
    }

    public int getVisualId() {
        return this._visualId;
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (this.getClass() != obj.getClass()) {
            return false;
        }
        if (this.getObjectId() == 0) {
            return this.getItemId() == ((ItemInfo)obj).getItemId();
        }
        return this.getObjectId() == ((ItemInfo)obj).getObjectId();
    }

    public int hashCode() {
        int hash = this.getItemId();
        hash = 89 * hash + this.getObjectId();
        return hash;
    }

    public int[] getEnchantOptions() {
        return this.enchantOptions;
    }

    public void setEnchantOptions(int[] enchantOptions) {
        this.enchantOptions = enchantOptions;
    }

    public int getAttributeFire() {
        return this._attrFire;
    }

    public void setAttributeFire(int val) {
        this._attrFire = val;
    }

    public int getAttributeWater() {
        return this._attrWater;
    }

    public void setAttributeWater(int val) {
        this._attrWater = val;
    }

    public int getAttributeWind() {
        return this._attrWind;
    }

    public void setAttributeWind(int val) {
        this._attrWind = val;
    }

    public int getAttributeEarth() {
        return this._attrEarth;
    }

    public void setAttributeEarth(int val) {
        this._attrEarth = val;
    }

    public int getAttributeHoly() {
        return this._attrHoly;
    }

    public void setAttributeHoly(int val) {
        this._attrHoly = val;
    }

    public int getAttributeUnholy() {
        return this._attrUnholy;
    }

    public void setAttributeUnholy(int val) {
        this._attrUnholy = val;
    }

    private int[] getAttackElementInfo() {
        if (this.getItem().isWeapon()) {
            if (this._attrFire > 0) {
                return new int[]{Element.FIRE.getId(), this._attrFire};
            }
            if (this._attrWater > 0) {
                return new int[]{Element.WATER.getId(), this._attrWater};
            }
            if (this._attrWind > 0) {
                return new int[]{Element.WIND.getId(), this._attrWind};
            }
            if (this._attrEarth > 0) {
                return new int[]{Element.EARTH.getId(), this._attrEarth};
            }
            if (this._attrHoly > 0) {
                return new int[]{Element.HOLY.getId(), this._attrHoly};
            }
            if (this._attrUnholy > 0) {
                return new int[]{Element.UNHOLY.getId(), this._attrUnholy};
            }
        }
        return new int[]{Element.NONE.getId(), 0};
    }

    public int getAttackElement() {
        return this.getAttackElementInfo()[0];
    }

    public int getAttackElementValue() {
        return this.getAttackElementInfo()[1];
    }

    public int getDefenceFire() {
        return this.getItem().isWeapon() ? 0 : this._attrFire;
    }

    public int getDefenceWater() {
        return this.getItem().isWeapon() ? 0 : this._attrWater;
    }

    public int getDefenceWind() {
        return this.getItem().isWeapon() ? 0 : this._attrWind;
    }

    public int getDefenceEarth() {
        return this.getItem().isWeapon() ? 0 : this._attrEarth;
    }

    public int getDefenceHoly() {
        return this.getItem().isWeapon() ? 0 : this._attrHoly;
    }

    public int getDefenceUnholy() {
        return this.getItem().isWeapon() ? 0 : this._attrUnholy;
    }

    public Ensoul[] getNormalEnsouls() {
        return this._normalEnsouls;
    }

    public void setNormalEnsouls(Ensoul[] ensouls) {
        this._normalEnsouls = ensouls;
    }

    public Ensoul[] getSpecialEnsouls() {
        return this._specialEnsouls;
    }

    public void setSpecialEnsouls(Ensoul[] ensouls) {
        this._specialEnsouls = ensouls;
    }
}

