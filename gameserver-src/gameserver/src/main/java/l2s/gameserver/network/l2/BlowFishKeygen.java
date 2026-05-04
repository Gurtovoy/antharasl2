/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2;

import l2s.commons.util.Rnd;

public class BlowFishKeygen {
    private static final int CRYPT_KEYS_SIZE = 20;
    private static final byte[][] CRYPT_KEYS = new byte[20][16];

    private BlowFishKeygen() {
    }

    public static byte[] getRandomKey() {
        return CRYPT_KEYS[Rnd.get((int)20)];
    }

    static {
        for (int i = 0; i < 20; ++i) {
            for (int j = 0; j < CRYPT_KEYS[i].length; ++j) {
                BlowFishKeygen.CRYPT_KEYS[i][j] = (byte)Rnd.get((int)255);
            }
            BlowFishKeygen.CRYPT_KEYS[i][8] = -56;
            BlowFishKeygen.CRYPT_KEYS[i][9] = 39;
            BlowFishKeygen.CRYPT_KEYS[i][10] = -109;
            BlowFishKeygen.CRYPT_KEYS[i][11] = 1;
            BlowFishKeygen.CRYPT_KEYS[i][12] = -95;
            BlowFishKeygen.CRYPT_KEYS[i][13] = 108;
            BlowFishKeygen.CRYPT_KEYS[i][14] = 49;
            BlowFishKeygen.CRYPT_KEYS[i][15] = -105;
        }
    }
}

