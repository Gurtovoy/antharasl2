package l2s.gameserver.model.items.listeners;

import java.util.List;
import l2s.gameserver.listener.inventory.OnEquipListener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.skills.SkillEntry;
import org.napile.primitive.maps.IntObjectMap;

public abstract class AbstractSkillListener
implements OnEquipListener {
    @Override
    public int onUnequip(int slot, ItemInstance item, Playable actor) {
        return this.removeSkills(actor, item.removeEquippedSkills(this));
    }

    protected int refreshSkills(Playable actor, ItemInstance item, List<SkillEntry> skills) {
        int flags = 0;
        IntObjectMap<SkillEntry> removedSkills = item.removeEquippedSkills(this);
        for (SkillEntry skillEntry : skills) {
            if (this.canAddSkill(actor, item, skillEntry) && actor.addSkill(skillEntry) != skillEntry) {
                flags |= this.onAddSkill(actor, item, skillEntry);
                flags |= 3;
            }
            item.addEquippedSkill(this, skillEntry);
            if (removedSkills == null) continue;
            removedSkills.remove(skillEntry.getId());
        }
        return flags |= this.removeSkills(actor, removedSkills);
    }

    protected boolean canAddSkill(Playable actor, ItemInstance item, SkillEntry skillEntry) {
        return true;
    }

    protected int onAddSkill(Playable actor, ItemInstance item, SkillEntry skillEntry) {
        return 0;
    }

    protected int removeSkills(Playable actor, IntObjectMap<SkillEntry> skillsMap) {
        if (skillsMap == null) {
            return 0;
        }
        int flags = 0;
        for (SkillEntry skillEntry : skillsMap.valueCollection()) {
            SkillEntry temp = actor.getKnownSkill(skillEntry.getId());
            if (temp != skillEntry || actor.removeSkill(skillEntry) == null) continue;
            flags |= 3;
        }
        return flags;
    }
}

