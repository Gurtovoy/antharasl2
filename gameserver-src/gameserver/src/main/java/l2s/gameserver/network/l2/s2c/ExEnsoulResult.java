package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.support.Ensoul;

public class ExEnsoulResult
extends L2GameServerPacket {
    public static final L2GameServerPacket FAIL = new ExEnsoulResult();
    private final boolean _success;
    private final Ensoul[] _normalEnsouls;
    private final Ensoul[] _specialEnsouls;

    private ExEnsoulResult() {
        this._success = false;
        this._normalEnsouls = null;
        this._specialEnsouls = null;
    }

    public ExEnsoulResult(Ensoul[] normalEnsouls, Ensoul[] specialEnsouls) {
        this._success = true;
        this._normalEnsouls = normalEnsouls;
        this._specialEnsouls = specialEnsouls;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._success);
        if (this._success) {
            this.writeC(this._normalEnsouls.length);
            for (Ensoul ensoul : this._normalEnsouls) {
                this.writeD(ensoul.getId());
            }
            this.writeC(this._specialEnsouls.length);
            for (Ensoul ensoul : this._specialEnsouls) {
                this.writeD(ensoul.getId());
            }
        }
    }
}

