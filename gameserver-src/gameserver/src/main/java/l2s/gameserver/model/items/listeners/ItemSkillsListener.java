package l2s.gameserver.model.items.listeners;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.listeners.AbstractSkillListener;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.agathion.AgathionData;
import l2s.gameserver.templates.agathion.AgathionEnchantData;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.support.Ensoul;

public final class ItemSkillsListener
extends AbstractSkillListener {
    private static final ItemSkillsListener _instance = new ItemSkillsListener();

    public static ItemSkillsListener getInstance() {
        return _instance;
    }

    public int onEquip(int slot, ItemInstance item, Playable actor, boolean refresh) {
        ArrayList<SkillEntry> addedSkills;
        int flags = 0;
        block14: {
            if (!actor.isPlayer()) {
                return 0;
            }
            Player player = actor.getPlayer();
            ItemTemplate template = item.getTemplate();
            if (!refresh) {
                player.removeTriggers(template);
            }
            addedSkills = new ArrayList<SkillEntry>();
            if (template.getType2() == 0 && player.getWeaponsExpertisePenalty() != 0) break block14;
            if (!refresh) {
                player.addTriggers(template);
            }
            if (template.getItemType() == EtcItemTemplate.EtcItemType.RUNE_SELECT) {
                for (SkillEntry itemSkillEntry : template.getAttachedSkills()) {
                    int skillsCount = 1;
                    block1: for (ItemInstance ii : player.getInventory().getItems()) {
                        ItemTemplate it;
                        if (ii == item || (it = ii.getTemplate()).getItemType() != EtcItemTemplate.EtcItemType.RUNE_SELECT) continue;
                        for (SkillEntry se : it.getAttachedSkills()) {
                            if (se != itemSkillEntry) continue;
                            ++skillsCount;
                            continue block1;
                        }
                    }
                    int skillLevel = Math.min(itemSkillEntry.getTemplate().getMaxLevel(), skillsCount);
                    SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, itemSkillEntry.getId(), skillLevel);
                    if (skillEntry == null) continue;
                    addedSkills.add(skillEntry);
                }
            } else {
                AgathionData agathionData;
                addedSkills.addAll(Arrays.asList(template.getAttachedSkills()));
                for (int e = item.getFixedEnchantLevel(player); e >= 0; --e) {
                    List<SkillEntry> enchantSkills = template.getEnchantSkills(e);
                    if (enchantSkills == null) continue;
                    addedSkills.addAll(enchantSkills);
                    break;
                }
                if ((agathionData = item.getTemplate().getAgathionData()) != null) {
                    for (int e = item.getFixedEnchantLevel(player); e >= 0; --e) {
                        AgathionEnchantData agathionItemEnchant = agathionData.getEnchant(e);
                        if (agathionItemEnchant == null) continue;
                        if (item.getEquipSlot() == 19) {
                            addedSkills.addAll(agathionItemEnchant.getMainSkills());
                        }
                        addedSkills.addAll(agathionItemEnchant.getSubSkills());
                        break;
                    }
                }
                addedSkills.addAll(item.getAppearanceStoneSkills());
                for (Ensoul ensoul : item.getNormalEnsouls()) {
                    addedSkills.addAll(ensoul.getSkills());
                }
                for (Ensoul ensoul : item.getSpecialEnsouls()) {
                    addedSkills.addAll(ensoul.getSkills());
                }
            }
        }
        return flags |= this.refreshSkills(actor, item, addedSkills);
    }

    @Override
    protected boolean canAddSkill(Playable actor, ItemInstance item, SkillEntry skillEntry) {
        if (item.getTemplate().getItemType() == EtcItemTemplate.EtcItemType.RUNE_SELECT) {
            return true;
        }
        if (skillEntry.getLevel() < actor.getSkillLevel(skillEntry.getId())) {
            for (ItemInstance tempItem : actor.getInventory().getItems()) {
                int tempSkillLevel;
                if (tempItem == item || (tempSkillLevel = tempItem.getEquippedSkillLevel(skillEntry.getId())) <= skillEntry.getLevel()) continue;
                return false;
            }
            return true;
        }
        return skillEntry.getLevel() > actor.getSkillLevel(skillEntry.getId());
    }

    @Override
    protected int onAddSkill(Playable actor, ItemInstance item, SkillEntry skillEntry) {
        Skill itemSkill = skillEntry.getTemplate();
        if (itemSkill.isActive() && !actor.isSkillDisabled(itemSkill)) {
            long reuseDelay = Formulas.calcSkillReuseDelay(actor, itemSkill);
            if ((reuseDelay = Math.min(reuseDelay, 30000L)) > 0L) {
                actor.disableSkill(itemSkill, reuseDelay);
            }
        }
        return 0;
    }

    @Override
    public int onEquip(int slot, ItemInstance item, Playable actor) {
        return this.onEquip(slot, item, actor, false);
    }

    @Override
    public int onUnequip(int slot, ItemInstance item, Playable actor) {
        if (!actor.isPlayer()) {
            return 0;
        }
        actor.removeTriggers(item.getTemplate());
        return super.onUnequip(slot, item, actor);
    }

    @Override
    public int onRefreshEquip(ItemInstance item, Playable actor) {
        return this.onEquip(item.getEquipSlot(), item, actor, true);
    }
}

