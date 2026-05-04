package l2s.gameserver.skills.effects;

import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectTasks;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ChangeWaitTypePacket;
import l2s.gameserver.network.l2.s2c.RevivePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectFakeDeath
extends EffectHandler {
    public EffectFakeDeath(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isPlayer()) {
            if (effected.isInvisible(null)) {
                return false;
            }
            Player player = effected.getPlayer();
            return player.getActiveWeaponFlagAttachment() == null;
        }
        return false;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        Player player = effected.getPlayer();
        player.setFakeDeath(true);
        player.getAI().notifyEvent(CtrlEvent.EVT_FAKE_DEATH, null, null);
        player.broadcastPacket(new ChangeWaitTypePacket(player, 2));
        player.broadcastCharInfo();
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        Player player = effected.getPlayer();
        player.setNonAggroTime(System.currentTimeMillis() + 5000L);
        player.broadcastPacket(new ChangeWaitTypePacket(player, 3));
        if (this.getSkill().getId() == 10528) {
            player.setTargetable(true);
        }
        player.broadcastPacket(new RevivePacket(player));
        player.broadcastCharInfo();
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.EndBreakFakeDeathTask(player), 2500L);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isDead()) {
            return false;
        }
        double manaDam = this.getValue();
        if (manaDam > effected.getCurrentMp() && this.getSkill().isToggle()) {
            effected.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
            effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(this.getSkill().getId(), this.getSkill().getDisplayLevel()));
            return false;
        }
        effected.reduceCurrentMp(manaDam, null);
        return true;
    }
}

