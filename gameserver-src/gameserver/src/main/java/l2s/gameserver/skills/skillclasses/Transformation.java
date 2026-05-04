/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class Transformation
extends Skill {
    public final boolean isDispell;

    public Transformation(StatsSet set) {
        super(set);
        this.isDispell = set.getBool("is_dispel", false);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        Player player = activeChar.getPlayer();
        if (player == null || player.getActiveWeaponFlagAttachment() != null) {
            return false;
        }
        if (player.isTransformed() && !this.isDispell) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ALREADY_POLYMORPHED_AND_CANNOT_POLYMORPH_AGAIN);
            return false;
        }
        if (!(this.getId() != 840 && this.getId() != 841 && this.getId() != 842 || player.getX() <= -166168 && player.getZ() > 0 && player.getZ() < 6000 && !player.hasServitor() && player.getReflection().isMain())) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
            return false;
        }
        if (player.isInFlyingTransform() && this.isDispell && Math.abs(player.getZ() - player.getLoc().correctGeoZ((int)player.getGeoIndex()).z) > 333) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
            return false;
        }
        if (!Config.ALT_USE_TRANSFORM_IN_EPIC_ZONE && !this.isDispell && player.isInZone(Zone.ZoneType.epic)) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
            return false;
        }
        if (player.isInWater()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_INTO_THE_DESIRED_FORM_IN_WATER);
            return false;
        }
        if (player.isMounted()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHILE_RIDING_A_PET);
            return false;
        }
        if (player.getAbnormalList().contains(1411)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHILE_UNDER_THE_EFFECT_OF_A_SPECIAL_SKILL);
            return false;
        }
        if (player.isInBoat()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_POLYMORPH_WHILE_RIDING_A_BOAT);
            return false;
        }
        return true;
    }
}

