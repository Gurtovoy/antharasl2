/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.data.xml.holder.CubicHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.cubic.CubicTemplate;
import l2s.gameserver.templates.skill.EffectTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class i_summon_cubic
extends i_abstract_effect {
    private static final Logger _log = LoggerFactory.getLogger(i_summon_cubic.class);
    private final CubicTemplate _template;

    public i_summon_cubic(EffectTemplate template) {
        super(template);
        int cubicId = this.getTemplate().getParams().getInteger("id");
        int cubicLevel = this.getTemplate().getParams().getInteger("level");
        this._template = CubicHolder.getInstance().getTemplate(cubicId, cubicLevel);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        if (!effected.isPlayer()) {
            return false;
        }
        if (this._template == null) {
            _log.warn(this.getClass().getSimpleName() + ": Cannot find cubic template for skill: ID[" + this.getSkill().getId() + "], LEVEL[" + this.getSkill().getLevel() + "]!");
            return false;
        }
        Player player = effected.getPlayer();
        if (player.getCubic(this._template.getSlot()) != null) {
            return true;
        }
        int size = (int)player.getStat().calc(Stats.CUBICS_LIMIT, 1.0);
        if (player.getCubics().size() >= size) {
            if (effector == player) {
                player.sendPacket((IBroadcastPacket)SystemMsg.CUBIC_SUMMONING_FAILED);
            }
            return false;
        }
        return true;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Player player = effected.getPlayer();
        if (player == null) {
            return;
        }
        Cubic cubic = new Cubic(player, this._template, this.getSkill());
        cubic.init();
    }
}

