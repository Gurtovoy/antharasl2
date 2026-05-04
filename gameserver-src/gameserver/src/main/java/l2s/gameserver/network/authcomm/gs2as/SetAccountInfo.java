/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class SetAccountInfo
extends SendablePacket {
    private String _account;
    private int _size;
    private int[] _deleteChars;

    public SetAccountInfo(String account, int size, int[] deleteChars) {
        this._account = account;
        this._size = size;
        this._deleteChars = deleteChars;
    }

    @Override
    protected void writeImpl() {
        this.writeC(5);
        this.writeS(this._account);
        this.writeC(this._size);
        this.writeD(this._deleteChars.length);
        for (int i : this._deleteChars) {
            this.writeD(i);
        }
    }
}

