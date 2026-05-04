package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.item.ArmorTemplate;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import org.napile.primitive.Containers;
import org.napile.primitive.collections.IntCollection;
import org.napile.primitive.lists.IntList;
import org.napile.primitive.lists.impl.ArrayIntList;

public class FakeItemHolder
extends AbstractHolder {
    private static FakeItemHolder ourInstance = new FakeItemHolder();
    private final Map<ItemGrade, Map<WeaponTemplate.WeaponType, IntList>> weapons = new HashMap<ItemGrade, Map<WeaponTemplate.WeaponType, IntList>>();
    private final Map<ItemGrade, Map<ArmorTemplate.ArmorType, List<IntList>>> armors = new HashMap<ItemGrade, Map<ArmorTemplate.ArmorType, List<IntList>>>();
    private final Map<ItemGrade, List<IntList>> accessorys = new HashMap<ItemGrade, List<IntList>>();
    private final Map<Integer, ClassWeaponAndArmor> classWeaponAndArmors = new HashMap<Integer, ClassWeaponAndArmor>();
    private final IntList _hairAccessories = new ArrayIntList();
    private final IntList _cloaks = new ArrayIntList();

    public static FakeItemHolder getInstance() {
        return ourInstance;
    }

    public void addWeapons(ItemGrade grade, IntList list) {
        HashMap<WeaponTemplate.WeaponType, ArrayIntList> map = new HashMap<WeaponTemplate.WeaponType, ArrayIntList>();
        for (int itemId : list.toArray()) {
            ItemTemplate template = ItemHolder.getInstance().getTemplate(itemId);
            if (template == null || !template.isWeapon()) continue;
            WeaponTemplate.WeaponType weaponType = ((WeaponTemplate)template).getItemType();
            if (template.isMagicWeapon()) {
                weaponType = WeaponTemplate.WeaponType.MAGIC;
            }
            if (map.get(weaponType) == null) {
                map.put(weaponType, new ArrayIntList());
            }
            ((IntList)map.get(weaponType)).add(itemId);
        }
        this.weapons.put(grade, (Map<WeaponTemplate.WeaponType, IntList>)(Map<?,?>)map);
    }

    public void addArmors(ItemGrade grade, Map<ArmorTemplate.ArmorType, List<IntList>> map) {
        this.armors.put(grade, map);
    }

    public void addAccessorys(ItemGrade grade, List<IntList> list) {
        this.accessorys.put(grade, list);
    }

    public void addClassWeaponAndArmors(int classId, String weaponTypes, String armorTypes) {
        this.classWeaponAndArmors.put(classId, new ClassWeaponAndArmor(classId, weaponTypes, armorTypes));
    }

    public void addHairAccessories(IntList list) {
        this._hairAccessories.addAll((IntCollection)list);
    }

    public IntList getHairAccessories() {
        return this._hairAccessories;
    }

    public void addCloaks(IntList list) {
        this._cloaks.addAll((IntCollection)list);
    }

    public IntList getCloaks() {
        return this._cloaks;
    }

    public IntList getRandomItems(Player player, String type, int expertiseIndex) {
        ItemGrade grade = ItemGrade.values()[expertiseIndex];
        IntList result = null;
        switch (type) {
            case "Accessory": {
                List<IntList> packs = this.accessorys.get(grade);
                if (packs == null || packs.isEmpty()) {
                    return Containers.EMPTY_INT_LIST;
                }
                result = packs.get(Rnd.get((int)packs.size()));
                break;
            }
            case "Armor": {
                try {
                    ClassWeaponAndArmor classWeaponAndArmor = this.classWeaponAndArmors.get(player.getClassId().getId());
                    if (classWeaponAndArmor == null) {
                        return Containers.EMPTY_INT_LIST;
                    }
                    Map<ArmorTemplate.ArmorType, List<IntList>> packs = this.armors.get(grade);
                    if (packs == null || packs.isEmpty()) {
                        return Containers.EMPTY_INT_LIST;
                    }
                    List<IntList> armors = packs.get(classWeaponAndArmor.getRandomArmorType());
                    result = (IntList)Rnd.get(armors);
                }
                catch (Exception e) {
                    System.out.println(player.getClassId().getId());
                }
                break;
            }
            case "Weapon": {
                ClassWeaponAndArmor classWeaponAndArmor = this.classWeaponAndArmors.get(player.getClassId().getId());
                if (classWeaponAndArmor == null) {
                    return Containers.EMPTY_INT_LIST;
                }
                Map<WeaponTemplate.WeaponType, IntList> packs = this.weapons.get(grade);
                if (packs == null || packs.isEmpty()) {
                    return Containers.EMPTY_INT_LIST;
                }
                result = new ArrayIntList();
                while (result.isEmpty()) {
                    IntList list = packs.get(classWeaponAndArmor.getRandomWeaponType());
                    if (list == null) continue;
                    result.add(list.get(list.size() - 1));
                }
                break;
            }
        }
        if (result != null) {
            return result;
        }
        return Containers.EMPTY_INT_LIST;
    }

    public void log() {
        this.info("loaded fake items.");
    }

    public int size() {
        return 0;
    }

    public void clear() {
    }

    private static class ClassWeaponAndArmor {
        private final int classId;
        private final List<WeaponTemplate.WeaponType> weaponTypes = new ArrayList<WeaponTemplate.WeaponType>();
        private final List<ArmorTemplate.ArmorType> armorTypes = new ArrayList<ArmorTemplate.ArmorType>();

        public ClassWeaponAndArmor(int classId, String weaponTypes, String armorTypes) {
            this.classId = classId;
            for (String s : weaponTypes.split(";")) {
                this.weaponTypes.add(WeaponTemplate.WeaponType.valueOf(s));
            }
            for (String s : armorTypes.split(";")) {
                this.armorTypes.add(ArmorTemplate.ArmorType.valueOf(s));
            }
        }

        public WeaponTemplate.WeaponType getRandomWeaponType() {
            return this.weaponTypes.get(Rnd.get((int)this.weaponTypes.size()));
        }

        public ArmorTemplate.ArmorType getRandomArmorType() {
            return this.armorTypes.get(Rnd.get((int)this.armorTypes.size()));
        }
    }
}

