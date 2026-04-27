/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.BlockListPacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestBlock
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestBlock.class);
    private static final int BLOCK = 0;
    private static final int UNBLOCK = 1;
    private static final int BLOCKLIST = 2;
    private static final int ALLBLOCK = 3;
    private static final int ALLUNBLOCK = 4;
    private Integer _type;
    private String targetName = null;

    @Override
    protected boolean readImpl() {
        this._type = this.readD();
        if (this._type == 0 || this._type == 1) {
            this.targetName = this.readS(16);
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        switch (this._type) {
            case 0: {
                activeChar.getBlockList().add(this.targetName);
                break;
            }
            case 1: {
                activeChar.getBlockList().remove(this.targetName);
                break;
            }
            case 2: {
                activeChar.sendPacket((IBroadcastPacket)new BlockListPacket(activeChar));
                break;
            }
            case 3: {
                activeChar.setBlockAll(true);
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOW_BLOCKING_EVERYTHING);
                activeChar.sendEtcStatusUpdate();
                break;
            }
            case 4: {
                activeChar.setBlockAll(false);
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NO_LONGER_BLOCKING_EVERYTHING);
                activeChar.sendEtcStatusUpdate();
                break;
            }
            default: {
                _log.info("Unknown 0x0a block type: " + this._type);
            }
        }
    }
}

