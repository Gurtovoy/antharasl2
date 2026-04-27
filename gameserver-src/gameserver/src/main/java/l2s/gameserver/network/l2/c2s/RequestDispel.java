/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestDispel
extends L2GameClientPacket {
    private int _objectId;
    private int _id;
    private int _level;

    @Override
    protected boolean readImpl() throws Exception {
        this._objectId = this.readD();
        this._id = this.readD();
        this._level = this.readD();
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getObjectId() != this._objectId && !activeChar.isMyServitor(this._objectId)) {
            return;
        }
        Playable target = activeChar;
        if (activeChar.getObjectId() != this._objectId) {
            target = activeChar.getServitor(this._objectId);
        }
        for (Abnormal e : target.getAbnormalList()) {
            if (e.getDisplayId() != this._id || e.getDisplayLevel() != this._level) continue;
            if (e.getSkill().getId() == 11541 || e.isSelfDispellable()) {
                e.exit();
                continue;
            }
            return;
        }
    }
}

