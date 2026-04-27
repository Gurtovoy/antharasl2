/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 */
package l2s.gameserver.listener.actor.player.impl;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.model.Player;

public class ReviveAnswerListener
implements OnAnswerListener {
    private HardReference<Player> _playerRef;
    private double _power;
    private boolean _forPet;

    public ReviveAnswerListener(Player player, double power, boolean forPet) {
        this._playerRef = player.getRef();
        this._forPet = forPet;
        this._power = power;
    }

    @Override
    public void sayYes() {
        Player player = (Player)this._playerRef.get();
        if (player == null) {
            return;
        }
        if (!player.isDead() && !this._forPet || this._forPet && player.getPet() != null && !player.getPet().isDead()) {
            return;
        }
        if (!this._forPet) {
            player.doRevive(this._power);
        } else if (player.getPet() != null) {
            player.getPet().doRevive(this._power);
        }
    }

    @Override
    public void sayNo() {
    }

    public double getPower() {
        return this._power;
    }

    public boolean isForPet() {
        return this._forPet;
    }
}

