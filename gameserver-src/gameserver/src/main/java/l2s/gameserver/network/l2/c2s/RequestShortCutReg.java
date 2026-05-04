package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ShortCutRegisterPacket;

public class RequestShortCutReg
extends L2GameClientPacket {
    private ShortCut.ShortCutType _type;
    private int _id;
    private int _slot;
    private int _page;
    private int _lvl;
    private int _characterType;

    @Override
    protected boolean readImpl() {
        try {
            this._type = ShortCut.ShortCutType.VALUES[this.readD()];
        }
        catch (Exception e) {
            return false;
        }
        int slot = this.readD();
        this._id = this.readD();
        this._lvl = this.readD();
        this._characterType = this.readD();
        this.readD();
        this.readD();
        this._slot = slot % 12;
        this._page = slot / 12;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._page < 0 || this._page > 21) {
            activeChar.sendActionFailed();
            return;
        }
        ShortCut shortCut = new ShortCut(this._slot, this._page, this._type, this._id, this._lvl, this._characterType);
        activeChar.sendPacket((IBroadcastPacket)new ShortCutRegisterPacket(activeChar, shortCut));
        activeChar.registerShortCut(shortCut);
    }
}

