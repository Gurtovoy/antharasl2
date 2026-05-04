package l2s.gameserver.model.actor.recorder;

import l2s.gameserver.model.actor.recorder.CharStatsChangeRecorder;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.s2c.NpcInfoAbnormalVisualEffect;

public class NpcStatsChangeRecorder
extends CharStatsChangeRecorder<NpcInstance> {
    public NpcStatsChangeRecorder(NpcInstance actor) {
        super(actor);
    }

    @Override
    protected void onSendChanges() {
        super.onSendChanges();
        if ((this._changes & 1) == 1 || (this._changes & 0x20) == 32) {
            ((NpcInstance)this._activeChar).broadcastCharInfo();
        }
        if ((this._changes & 8) == 8 || (this._changes & 0x10) == 16) {
            ((NpcInstance)this._activeChar).broadcastPacket(new NpcInfoAbnormalVisualEffect(this._activeChar));
        }
    }
}

