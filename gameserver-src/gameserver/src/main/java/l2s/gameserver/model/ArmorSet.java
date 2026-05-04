package l2s.gameserver.model;

import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.hash.TIntHashSet;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;

public final class ArmorSet {
    private final TIntHashSet _chests = new TIntHashSet();
    private final TIntHashSet _legs = new TIntHashSet();
    private final TIntHashSet _head = new TIntHashSet();
    private final TIntHashSet _gloves = new TIntHashSet();
    private final TIntHashSet _feet = new TIntHashSet();
    private final TIntHashSet _shield = new TIntHashSet();
    private final TIntObjectHashMap<List<SkillEntry>> _skills = new TIntObjectHashMap();
    private final List<SkillEntry> _shieldSkills = new ArrayList<SkillEntry>();
    private final List<SkillEntry> _enchant6skills = new ArrayList<SkillEntry>();
    private final List<SkillEntry> _enchant7skills = new ArrayList<SkillEntry>();
    private final List<SkillEntry> _enchant8skills = new ArrayList<SkillEntry>();
    private final List<SkillEntry> _enchant9skills = new ArrayList<SkillEntry>();
    private final List<SkillEntry> _enchant10skills = new ArrayList<SkillEntry>();

    public ArmorSet(String[] chests, String[] legs, String[] head, String[] gloves, String[] feet, String[] shield, String[] shield_skills, String[] enchant6skills, String[] enchant7skills, String[] enchant8skills, String[] enchant9skills, String[] enchant10skills) {
        int skillLvl;
        int skillId;
        StringTokenizer st;
        this._chests.addAll(ArmorSet.parseItemIDs(chests));
        this._legs.addAll(ArmorSet.parseItemIDs(legs));
        this._head.addAll(ArmorSet.parseItemIDs(head));
        this._gloves.addAll(ArmorSet.parseItemIDs(gloves));
        this._feet.addAll(ArmorSet.parseItemIDs(feet));
        this._shield.addAll(ArmorSet.parseItemIDs(shield));
        if (shield_skills != null) {
            for (String skill : shield_skills) {
                st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                skillId = Integer.parseInt(st.nextToken());
                skillLvl = Integer.parseInt(st.nextToken());
                this._shieldSkills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
        if (enchant6skills != null) {
            for (String skill : enchant6skills) {
                st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                skillId = Integer.parseInt(st.nextToken());
                skillLvl = Integer.parseInt(st.nextToken());
                this._enchant6skills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
        if (enchant7skills != null) {
            for (String skill : enchant7skills) {
                st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                skillId = Integer.parseInt(st.nextToken());
                skillLvl = Integer.parseInt(st.nextToken());
                this._enchant7skills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
        if (enchant8skills != null) {
            for (String skill : enchant8skills) {
                st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                skillId = Integer.parseInt(st.nextToken());
                skillLvl = Integer.parseInt(st.nextToken());
                this._enchant8skills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
        if (enchant9skills != null) {
            for (String skill : enchant9skills) {
                st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                skillId = Integer.parseInt(st.nextToken());
                skillLvl = Integer.parseInt(st.nextToken());
                this._enchant9skills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
        if (enchant10skills != null) {
            for (String skill : enchant10skills) {
                st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                skillId = Integer.parseInt(st.nextToken());
                skillLvl = Integer.parseInt(st.nextToken());
                this._enchant10skills.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
    }

    private static int[] parseItemIDs(String[] items) {
        TIntHashSet result = new TIntHashSet();
        if (items != null) {
            for (String s_id : items) {
                int id = Integer.parseInt(s_id);
                if (id <= 0) continue;
                result.add(id);
            }
        }
        return result.toArray();
    }

    public void addSkills(int partsCount, String[] skills) {
        ArrayList<SkillEntry> skillList = new ArrayList<SkillEntry>();
        if (skills != null) {
            for (String skill : skills) {
                StringTokenizer st = new StringTokenizer(skill, "-");
                if (!st.hasMoreTokens()) continue;
                int skillId = Integer.parseInt(st.nextToken());
                int skillLvl = Integer.parseInt(st.nextToken());
                skillList.add(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillId, skillLvl));
            }
        }
        this._skills.put(partsCount, skillList);
    }

    public boolean containAll(Player player) {
        PcInventory inv = player.getInventory();
        ItemInstance chestItem = inv.getPaperdollItem(10);
        ItemInstance legsItem = inv.getPaperdollItem(11);
        ItemInstance headItem = inv.getPaperdollItem(6);
        ItemInstance glovesItem = inv.getPaperdollItem(9);
        ItemInstance feetItem = inv.getPaperdollItem(12);
        int chest = 0;
        int legs = 0;
        int head = 0;
        int gloves = 0;
        int feet = 0;
        if (chestItem != null) {
            chest = chestItem.getItemId();
        }
        if (legsItem != null) {
            legs = legsItem.getItemId();
        }
        if (headItem != null) {
            head = headItem.getItemId();
        }
        if (glovesItem != null) {
            gloves = glovesItem.getItemId();
        }
        if (feetItem != null) {
            feet = feetItem.getItemId();
        }
        return this.containAll(chest, legs, head, gloves, feet);
    }

    public boolean containAll(int chest, int legs, int head, int gloves, int feet) {
        if (!this._chests.isEmpty() && !this._chests.contains(chest)) {
            return false;
        }
        if (!this._legs.isEmpty() && !this._legs.contains(legs)) {
            return false;
        }
        if (!this._head.isEmpty() && !this._head.contains(head)) {
            return false;
        }
        if (!this._gloves.isEmpty() && !this._gloves.contains(gloves)) {
            return false;
        }
        return this._feet.isEmpty() || this._feet.contains(feet);
    }

    public boolean containItem(int slot, int itemId) {
        switch (slot) {
            case 10: {
                return this._chests.contains(itemId);
            }
            case 11: {
                return this._legs.contains(itemId);
            }
            case 6: {
                return this._head.contains(itemId);
            }
            case 9: {
                return this._gloves.contains(itemId);
            }
            case 12: {
                return this._feet.contains(itemId);
            }
        }
        return false;
    }

    public int getEquipedSetPartsCount(Player player) {
        PcInventory inv = player.getInventory();
        ItemInstance chestItem = inv.getPaperdollItem(10);
        ItemInstance legsItem = inv.getPaperdollItem(11);
        ItemInstance headItem = inv.getPaperdollItem(6);
        ItemInstance glovesItem = inv.getPaperdollItem(9);
        ItemInstance feetItem = inv.getPaperdollItem(12);
        int chest = 0;
        int legs = 0;
        int head = 0;
        int gloves = 0;
        int feet = 0;
        if (chestItem != null) {
            chest = chestItem.getItemId();
        }
        if (legsItem != null) {
            legs = legsItem.getItemId();
        }
        if (headItem != null) {
            head = headItem.getItemId();
        }
        if (glovesItem != null) {
            gloves = glovesItem.getItemId();
        }
        if (feetItem != null) {
            feet = feetItem.getItemId();
        }
        int result = 0;
        if (!this._chests.isEmpty() && this._chests.contains(chest)) {
            ++result;
        }
        if (!this._legs.isEmpty() && this._legs.contains(legs)) {
            ++result;
        }
        if (!this._head.isEmpty() && this._head.contains(head)) {
            ++result;
        }
        if (!this._gloves.isEmpty() && this._gloves.contains(gloves)) {
            ++result;
        }
        if (!this._feet.isEmpty() && this._feet.contains(feet)) {
            ++result;
        }
        return result;
    }

    public List<SkillEntry> getSkills(int partsCount) {
        if (this._skills.get(partsCount) == null) {
            return new ArrayList<SkillEntry>();
        }
        return (List)this._skills.get(partsCount);
    }

    public List<SkillEntry> getSkillsToRemove() {
        ArrayList<SkillEntry> result = new ArrayList<SkillEntry>();
        for (int i : this._skills.keys()) {
            List skills = (List)this._skills.get(i);
            if (skills == null) continue;
            for (SkillEntry skill : (List<SkillEntry>)skills) {
                result.add(skill);
            }
        }
        return result;
    }

    public List<SkillEntry> getShieldSkills() {
        return this._shieldSkills;
    }

    public List<SkillEntry> getEnchant6skills() {
        return this._enchant6skills;
    }

    public List<SkillEntry> getEnchant7skills() {
        return this._enchant7skills;
    }

    public List<SkillEntry> getEnchant8skills() {
        return this._enchant8skills;
    }

    public List<SkillEntry> getEnchant9skills() {
        return this._enchant9skills;
    }

    public List<SkillEntry> getEnchant10skills() {
        return this._enchant10skills;
    }

    public boolean containShield(Player player) {
        PcInventory inv = player.getInventory();
        ItemInstance shieldItem = inv.getPaperdollItem(8);
        return shieldItem != null && this._shield.contains(shieldItem.getItemId());
    }

    public boolean containShield(int shield_id) {
        if (this._shield.isEmpty()) {
            return false;
        }
        return this._shield.contains(shield_id);
    }

    public int getEnchantLevel(Player player) {
        if (!this.containAll(player)) {
            return 0;
        }
        PcInventory inv = player.getInventory();
        ItemInstance chestItem = inv.getPaperdollItem(10);
        ItemInstance legsItem = inv.getPaperdollItem(11);
        ItemInstance headItem = inv.getPaperdollItem(6);
        ItemInstance glovesItem = inv.getPaperdollItem(9);
        ItemInstance feetItem = inv.getPaperdollItem(12);
        int value = -1;
        if (!this._chests.isEmpty()) {
            int n = value = value > -1 ? Math.min(value, chestItem.getFixedEnchantLevel(player)) : chestItem.getFixedEnchantLevel(player);
        }
        if (!this._legs.isEmpty()) {
            int n = value = value > -1 ? Math.min(value, legsItem.getFixedEnchantLevel(player)) : legsItem.getFixedEnchantLevel(player);
        }
        if (!this._gloves.isEmpty()) {
            int n = value = value > -1 ? Math.min(value, glovesItem.getFixedEnchantLevel(player)) : glovesItem.getFixedEnchantLevel(player);
        }
        if (!this._head.isEmpty()) {
            int n = value = value > -1 ? Math.min(value, headItem.getFixedEnchantLevel(player)) : headItem.getFixedEnchantLevel(player);
        }
        if (!this._feet.isEmpty()) {
            value = value > -1 ? Math.min(value, feetItem.getFixedEnchantLevel(player)) : feetItem.getFixedEnchantLevel(player);
        }
        return value;
    }

    public int[] getChestIds() {
        return this._chests.toArray();
    }

    public int[] getLegIds() {
        return this._legs.toArray();
    }

    public int[] getHeadIds() {
        return this._head.toArray();
    }

    public int[] getGlovesIds() {
        return this._gloves.toArray();
    }

    public int[] getFeetIds() {
        return this._feet.toArray();
    }

    public int[] getShieldIds() {
        return this._shield.toArray();
    }
}

