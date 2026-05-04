package l2s.gameserver.model.items.listeners;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.ArmorSetsHolder;
import l2s.gameserver.model.ArmorSet;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.listeners.AbstractSkillListener;
import l2s.gameserver.skills.SkillEntry;

public final class ArmorSetListener
extends AbstractSkillListener {
    private static final ArmorSetListener _instance = new ArmorSetListener();

    public static ArmorSetListener getInstance() {
        return _instance;
    }

    @Override
    public int onEquip(int slot, ItemInstance item, Playable actor) {
        if (!item.isEquipable()) {
            return 0;
        }
        if (!actor.isPlayer()) {
            return 0;
        }
        List<ArmorSet> armorSets = ArmorSetsHolder.getInstance().getArmorSets(item.getItemId());
        if (armorSets == null || armorSets.isEmpty()) {
            return 0;
        }
        Player player = actor.getPlayer();
        int armorSetEnchant = 0;
        int flags = 0;
        ArrayList<SkillEntry> addedSkills = new ArrayList<SkillEntry>();
        for (ArmorSet armorSet : armorSets) {
            List<SkillEntry> skills;
            if (armorSet.containItem(slot, item.getItemId())) {
                int enchantLevel;
                skills = armorSet.getSkills(armorSet.getEquipedSetPartsCount(player));
                for (SkillEntry skillEntry : skills) {
                    addedSkills.add(skillEntry);
                }
                if (!armorSet.containAll(player)) continue;
                if (armorSet.containShield(player)) {
                    skills = armorSet.getShieldSkills();
                    for (SkillEntry skillEntry : skills) {
                        addedSkills.add(skillEntry);
                    }
                }
                if ((enchantLevel = armorSet.getEnchantLevel(player)) >= 6) {
                    skills = armorSet.getEnchant6skills();
                    for (SkillEntry skillEntry : skills) {
                        addedSkills.add(skillEntry);
                    }
                }
                if (enchantLevel >= 7) {
                    skills = armorSet.getEnchant7skills();
                    for (SkillEntry skillEntry : skills) {
                        addedSkills.add(skillEntry);
                    }
                }
                if (enchantLevel >= 8) {
                    skills = armorSet.getEnchant8skills();
                    for (SkillEntry skillEntry : skills) {
                        addedSkills.add(skillEntry);
                    }
                }
                if (enchantLevel >= 9) {
                    skills = armorSet.getEnchant9skills();
                    for (SkillEntry skillEntry : skills) {
                        addedSkills.add(skillEntry);
                    }
                }
                if (enchantLevel >= 10) {
                    skills = armorSet.getEnchant10skills();
                    for (SkillEntry skillEntry : skills) {
                        addedSkills.add(skillEntry);
                    }
                }
                if (enchantLevel <= armorSetEnchant) continue;
                armorSetEnchant = enchantLevel;
                continue;
            }
            if (!armorSet.containShield(item.getItemId()) || !armorSet.containAll(player)) continue;
            skills = armorSet.getShieldSkills();
            for (SkillEntry skillEntry : skills) {
                addedSkills.add(skillEntry);
            }
        }
        player.setArmorSetEnchant(armorSetEnchant);
        return flags |= this.refreshSkills(player, item, addedSkills);
    }

    @Override
    public int onUnequip(int slot, ItemInstance item, Playable actor) {
        if (!item.isEquipable()) {
            return 0;
        }
        if (!actor.isPlayer()) {
            return 0;
        }
        List<ArmorSet> armorSets = ArmorSetsHolder.getInstance().getArmorSets(item.getItemId());
        if (armorSets == null || armorSets.isEmpty()) {
            return 0;
        }
        Player player = actor.getPlayer();
        int flags = super.onUnequip(slot, item, actor);
        int armorSetEnchant = 0;
        for (ArmorSet armorSet : armorSets) {
            int enchantLevel;
            boolean remove = false;
            List<SkillEntry> removeSkillId1 = new ArrayList();
            List<SkillEntry> removeSkillId2 = new ArrayList();
            List<SkillEntry> removeSkillId3 = new ArrayList();
            List<SkillEntry> removeSkillId4 = new ArrayList();
            List<SkillEntry> removeSkillId5 = new ArrayList();
            List<SkillEntry> removeSkillId6 = new ArrayList();
            List<SkillEntry> removeSkillId7 = new ArrayList();
            if (armorSet.containItem(slot, item.getItemId())) {
                remove = true;
                removeSkillId1 = armorSet.getSkillsToRemove();
                removeSkillId2 = armorSet.getShieldSkills();
                removeSkillId3 = armorSet.getEnchant6skills();
                removeSkillId4 = armorSet.getEnchant7skills();
                removeSkillId5 = armorSet.getEnchant8skills();
                removeSkillId6 = armorSet.getEnchant9skills();
                removeSkillId7 = armorSet.getEnchant10skills();
            } else if (armorSet.containShield(item.getItemId())) {
                remove = true;
                removeSkillId2 = armorSet.getShieldSkills();
            }
            if (remove) {
                for (SkillEntry skillEntry : removeSkillId1) {
                    if (player.removeSkill(skillEntry, false) == null) continue;
                    flags |= 3;
                }
                for (SkillEntry skillEntry : removeSkillId2) {
                    if (player.removeSkill(skillEntry) == null) continue;
                    flags |= 3;
                }
                for (SkillEntry skillEntry : removeSkillId3) {
                    if (player.removeSkill(skillEntry) == null) continue;
                    flags |= 3;
                }
                for (SkillEntry skillEntry : removeSkillId4) {
                    if (player.removeSkill(skillEntry) == null) continue;
                    flags |= 3;
                }
                for (SkillEntry skillEntry : removeSkillId5) {
                    if (player.removeSkill(skillEntry) == null) continue;
                    flags |= 3;
                }
                for (SkillEntry skillEntry : removeSkillId6) {
                    if (player.removeSkill(skillEntry) == null) continue;
                    flags |= 3;
                }
                for (SkillEntry skillEntry : removeSkillId7) {
                    if (player.removeSkill(skillEntry) == null) continue;
                    flags |= 3;
                }
            }
            if ((enchantLevel = armorSet.getEnchantLevel(player)) > armorSetEnchant) {
                armorSetEnchant = enchantLevel;
            }
            List<SkillEntry> list = armorSet.getSkills(armorSet.getEquipedSetPartsCount(player));
            for (SkillEntry skillEntry : list) {
                if (player.addSkill(skillEntry, false) != skillEntry) {
                    flags |= 3;
                }
                item.addEquippedSkill(armorSet, skillEntry);
            }
        }
        player.setArmorSetEnchant(armorSetEnchant);
        return flags;
    }

    @Override
    public int onRefreshEquip(ItemInstance item, Playable actor) {
        return this.onEquip(item.getEquipSlot(), item, actor);
    }
}

