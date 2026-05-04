package l2s.gameserver.model.actor.recorder;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.actor.recorder.CharStatsChangeRecorder;

public class ServitorStatsChangeRecorder
extends CharStatsChangeRecorder<Servitor> {
    public ServitorStatsChangeRecorder(Servitor actor) {
        super(actor);
    }

    @Override
    protected void onSendChanges() {
        super.onSendChanges();
        if ((this._changes & 2) == 2) {
            ((Servitor)this._activeChar).sendPetInfo();
        } else if ((this._changes & 1) == 1 || (this._changes & 0x20) == 32 || (this._changes & 8) == 8 || (this._changes & 0x10) == 16) {
            ((Servitor)this._activeChar).broadcastCharInfo();
        }
    }
}

