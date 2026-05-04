package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.ai.NpcAI;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.s2c.DiePacket;
import l2s.gameserver.templates.npc.NpcTemplate;

public class DeadManInstance
extends NpcInstance {
    public DeadManInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
        this.setAI(new NpcAI(this));
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.setCurrentHp(0.0, false);
        this.broadcastPacket(new DiePacket(this));
        this.setWalking();
    }

    @Override
    public void reduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean canReflectAndAbsorb, boolean transferDamage, boolean isDot, boolean sendReceiveMessage, boolean sendGiveMessage, boolean crit, boolean miss, boolean shld) {
    }

    @Override
    public boolean isBlocked() {
        return true;
    }
}

