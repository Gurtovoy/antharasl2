/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.set.hash.TIntHashSet
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.instances;

import gnu.trove.set.hash.TIntHashSet;
import java.util.HashSet;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.npc.NpcTemplate;

public class OlympiadBufferInstance
extends NpcInstance {
    private TIntHashSet buffs = new TIntHashSet();

    public OlympiadBufferInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public void onMenuSelect(Player player, int ask, long reply, int state) {
        if (ask == -301) {
            int buffId = (int)reply - 1;
            if (buffId < 0 || buffId >= Olympiad.BUFFS_LIST.length) {
                return;
            }
            int[] buff = Olympiad.BUFFS_LIST[buffId];
            int id = buff[0];
            int lvl = buff[1];
            Skill skill = SkillHolder.getInstance().getSkill(id, lvl);
            HashSet<Creature> targets = new HashSet<Creature>();
            targets.add(player);
            if (!skill.isNotBroadcastable()) {
                this.broadcastPacket(new MagicSkillUse(this, player, id, lvl, 0, 0L));
            }
            this.callSkill(player, SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), targets, true, false);
            this.buffs.add(id);
            this.showChatWindow(player, 0, false, new Object[0]);
        } else {
            super.onMenuSelect(player, ask, reply, state);
        }
    }

    @Override
    public String getHtmlDir(String filename, Player player) {
        return "olympiad/";
    }

    @Override
    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... replace) {
        if (val == 0) {
            if (this.buffs.size() > 4) {
                this.showChatWindow(player, "olympiad/olympiad_master003.htm", firstTalk, replace);
            } else if (this.buffs.size() > 0) {
                this.showChatWindow(player, "olympiad/olympiad_master002.htm", firstTalk, replace);
            } else {
                this.showChatWindow(player, "olympiad/olympiad_master001.htm", firstTalk, replace);
            }
        } else {
            super.showChatWindow(player, val, firstTalk, replace);
        }
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return Config.OLYMPIAD_CANATTACK_BUFFER;
    }
}

