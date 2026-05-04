package l2s.gameserver.skills.effects.instant;

import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_spoil
extends i_abstract_effect {
    public i_spoil(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        if (!effector.isPlayer()) {
            return false;
        }
        if (effected.isDead()) {
            return false;
        }
        return effected.isMonster();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        MonsterInstance monster = (MonsterInstance)effected;
        if (monster.isSpoiled()) {
            effector.sendPacket((IBroadcastPacket)SystemMsg.IT_HAS_ALREADY_BEEN_SPOILED);
            return;
        }
        Player player = effector.getPlayer();
        int monsterLevel = monster.getLevel();
        int modifier = Math.abs(monsterLevel - player.getLevel());
        double rateOfSpoil = Config.BASE_SPOIL_RATE;
        if (modifier > 8) {
            rateOfSpoil -= rateOfSpoil * (double)(modifier - 8) * 9.0 / 100.0;
        }
        if ((rateOfSpoil = rateOfSpoil * (double)this.getSkill().getMagicLevel() / (double)monsterLevel) < Config.MINIMUM_SPOIL_RATE) {
            rateOfSpoil = Config.MINIMUM_SPOIL_RATE;
        } else if (rateOfSpoil > 99.0) {
            rateOfSpoil = 99.0;
        }
        if (player.isGM()) {
            player.sendMessage(new CustomMessage("l2s.gameserver.skills.skillclasses.Spoil.Chance").addNumber((long)rateOfSpoil));
        }
        this.doSpoil(effector, effected, Rnd.chance((double)rateOfSpoil));
    }

    protected void doSpoil(Creature effector, Creature effected, boolean success) {
        if (success) {
            ((MonsterInstance)effected).setSpoiled(effector.getPlayer());
            effector.sendPacket((IBroadcastPacket)SystemMsg.THE_SPOIL_CONDITION_HAS_BEEN_ACTIVATED);
        } else {
            effector.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_FAILED).addSkillName(this.getSkill()));
        }
    }
}

