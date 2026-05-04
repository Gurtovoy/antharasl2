/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances.residences.clanhall;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.entity.events.impl.ClanHallTeamBattleEvent;
import l2s.gameserver.model.entity.events.objects.CTBSiegeClanObject;
import l2s.gameserver.model.entity.events.objects.CTBTeamObject;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.npc.NpcTemplate;

public abstract class CTBBossInstance
extends MonsterInstance {
    public static final SkillEntry SKILL = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 5456, 1);
    private CTBTeamObject _matchTeamObject;

    public CTBBossInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
        this.setHasChatWindow(false);
    }

    @Override
    public void reduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean canReflectAndAbsorb, boolean transferDamage, boolean isDot, boolean sendReceiveMessage, boolean sendGiveMessage, boolean crit, boolean miss, boolean shld) {
        if (attacker.getLevel() > this.getLevel() + 8 && !attacker.getAbnormalList().contains(SKILL.getId())) {
            this.doCast(SKILL, attacker, false);
            return;
        }
        super.reduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, canReflectAndAbsorb, transferDamage, isDot, sendReceiveMessage, sendGiveMessage, crit, miss, shld);
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        Player player;
        CTBSiegeClanObject clan = this._matchTeamObject.getSiegeClan();
        return clan == null || !attacker.isPlayable() || (player = attacker.getPlayer()).getClan() != clan.getClan();
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        return this.isAttackable(attacker);
    }

    @Override
    public void onDeath(Creature killer) {
        ClanHallTeamBattleEvent event = this.getEvent(ClanHallTeamBattleEvent.class);
        event.processStep(this._matchTeamObject);
        super.onDeath(killer);
    }

    @Override
    public String getTitle() {
        CTBSiegeClanObject clan = this._matchTeamObject.getSiegeClan();
        return clan == null ? "" : clan.getClan().getName();
    }

    public void setMatchTeamObject(CTBTeamObject matchTeamObject) {
        this._matchTeamObject = matchTeamObject;
    }
}

