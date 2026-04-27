/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.items.attachment;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.attachment.PickableAttachment;

public interface FlagItemAttachment
extends PickableAttachment {
    public void onLogout(Player var1);

    public void onDeath(Player var1, Creature var2);

    public void onLeaveSiegeZone(Player var1);

    public boolean canAttack(Player var1);

    public boolean canCast(Player var1, Skill var2);
}

