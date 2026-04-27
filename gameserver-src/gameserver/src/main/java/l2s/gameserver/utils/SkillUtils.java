/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.utils;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;

public final class SkillUtils {
    public static int getSkillPTSHash(int skillId, int skillLevelMask) {
        return skillLevelMask | skillId << 16;
    }

    public static int getSkillIdFromPTSHash(int hash) {
        int mask = 65535;
        return 0xFFFF & hash >>> 16;
    }

    public static int getSkillLevelFromPTSHash(int hash) {
        int mask = 65535;
        return 0xFFFF & hash;
    }

    public static long getSkillPTSLongHash(int skillId, int skillLevelMask) {
        return (long)skillLevelMask | (long)skillId << 32;
    }

    public static int getSkillIdFromPTSLongHash(long hash) {
        int mask = 65535;
        return (int)(0xFFFFL & hash >>> 32);
    }

    public static int getSkillLevelFromPTSLongHash(long hash) {
        int mask = 65535;
        return (int)(0xFFFFL & hash);
    }

    public static boolean checkSkill(Player player, SkillEntry skillEntry) {
        SkillLearn learn2;
        int i;
        int lvlDiff;
        if (!Config.ALT_REMOVE_SKILLS_ON_DELEVEL) {
            return false;
        }
        SkillLearn learn = SkillAcquireHolder.getInstance().getSkillLearn(player, skillEntry.getId(), skillEntry.getLevel(), AcquireType.NORMAL);
        if (learn == null) {
            return false;
        }
        boolean update = false;
        int n = lvlDiff = learn.isFreeAutoGet(AcquireType.NORMAL) ? 1 : 4;
        if (learn.getMinLevel() >= player.getLevel() + lvlDiff) {
            player.removeSkill(skillEntry, true);
            for (i = skillEntry.getLevel() - 1; i != 0; --i) {
                SkillEntry newSkillEntry;
                int lvlDiff2;
                learn2 = SkillAcquireHolder.getInstance().getSkillLearn(player, skillEntry.getId(), i, AcquireType.NORMAL);
                if (learn2 == null) continue;
                int n2 = lvlDiff2 = learn2.isFreeAutoGet(AcquireType.NORMAL) ? 1 : 4;
                if (learn2.getMinLevel() >= player.getLevel() + lvlDiff2 || (newSkillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillEntry.getId(), i)) == null) continue;
                player.addSkill(newSkillEntry, true);
                break;
            }
            update = true;
        }
        if (player.isTransformed()) {
            learn = player.getTransform().getAdditionalSkill(skillEntry.getId(), skillEntry.getLevel());
            if (learn == null) {
                return false;
            }
            if (learn.getMinLevel() >= player.getLevel() + 1) {
                player.removeTransformSkill(skillEntry);
                player.removeSkill(skillEntry, false);
                for (i = skillEntry.getLevel() - 1; i != 0; --i) {
                    SkillEntry newSkillEntry;
                    learn2 = player.getTransform().getAdditionalSkill(skillEntry.getId(), i);
                    if (learn2 == null || learn2.getMinLevel() >= player.getLevel() + 1 || (newSkillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillEntry.getId(), i)) == null) continue;
                    player.addTransformSkill(newSkillEntry);
                    player.addSkill(newSkillEntry, false);
                    break;
                }
                update = true;
            }
        }
        return update;
    }
}

