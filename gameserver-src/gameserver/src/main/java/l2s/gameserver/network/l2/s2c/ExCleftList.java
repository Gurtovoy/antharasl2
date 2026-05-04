/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCleftList
extends L2GameServerPacket {
    public static final int CleftType_Close = -1;
    public static final int CleftType_Total = 0;
    public static final int CleftType_Add = 1;
    public static final int CleftType_Remove = 2;
    public static final int CleftType_TeamChange = 3;
    private int CleftType = 0;

    @Override
    protected void writeImpl() {
        this.writeD(this.CleftType);
        switch (this.CleftType) {
            case 0: {
                break;
            }
            case 1: {
                break;
            }
            case 2: {
                break;
            }
            case 3: {
                break;
            }
        }
    }
}

