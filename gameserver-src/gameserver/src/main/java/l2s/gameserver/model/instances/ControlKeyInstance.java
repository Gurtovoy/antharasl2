/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 */
package l2s.gameserver.model.instances;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.reference.L2Reference;

public class ControlKeyInstance
extends GameObject {
    protected HardReference<ControlKeyInstance> reference = new L2Reference<ControlKeyInstance>(this);

    public ControlKeyInstance() {
        super(IdFactory.getInstance().getNextId());
    }

    public HardReference<ControlKeyInstance> getRef() {
        return this.reference;
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (player.getTarget() != this) {
            player.setTarget(this);
            return;
        }
        player.sendActionFailed();
    }
}

