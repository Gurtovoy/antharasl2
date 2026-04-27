/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class MacroListPacket
extends L2GameServerPacket {
    private final int _macroId;
    private final int _count;
    private final Action _action;
    private final Macro _macro;

    public MacroListPacket(int macroId, Action action, int count, Macro macro) {
        this._macroId = macroId;
        this._action = action;
        this._count = count;
        this._macro = macro;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._action.ordinal());
        this.writeD(this._macroId);
        this.writeC(this._count);
        if (this._macro != null) {
            this.writeC(1);
            this.writeD(this._macro.getId());
            this.writeS(this._macro.getName());
            this.writeS(this._macro.getDescr());
            this.writeS(this._macro.getAcronym());
            this.writeD(this._macro.getIcon());
            this.writeC(this._macro.getCommands().length);
            for (int i = 0; i < this._macro.getCommands().length; ++i) {
                Macro.L2MacroCmd cmd = this._macro.getCommands()[i];
                this.writeC(i + 1);
                this.writeC(cmd.getType());
                this.writeD(cmd.getParam1());
                this.writeC(cmd.getParam2());
                this.writeS(cmd.getCmd());
            }
        } else {
            this.writeC(0);
        }
    }

    public static enum Action {
        DELETE,
        ADD,
        UPDATE;

    }
}

