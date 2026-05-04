/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.support;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;

public class Ensoul {
    private final int _id;
    private final int _itemId;
    private final int _extractionItemId;
    private final List<SkillEntry> _skills = new ArrayList<SkillEntry>();

    public Ensoul(int id, int itemId, int extractionItemId) {
        this._id = id;
        this._itemId = itemId;
        this._extractionItemId = extractionItemId;
    }

    public int getId() {
        return this._id;
    }

    public int getItemId() {
        return this._itemId;
    }

    public int getExtractionItemId() {
        return this._extractionItemId;
    }

    public void addSkill(int id, int level) {
        SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.ITEM, id, level);
        if (skillEntry != null) {
            this._skills.add(skillEntry);
        }
    }

    public List<SkillEntry> getSkills() {
        return this._skills;
    }
}

