/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.crypt;

import java.math.BigInteger;
import java.security.KeyPair;
import java.security.interfaces.RSAPublicKey;

public class ScrambledKeyPair {
    private KeyPair _pair;
    private byte[] _scrambledModulus;

    public ScrambledKeyPair(KeyPair pPair) {
        this._pair = pPair;
        this._scrambledModulus = ScrambledKeyPair.scrambleModulus(((RSAPublicKey)this._pair.getPublic()).getModulus());
    }

    public KeyPair getKeyPair() {
        return this._pair;
    }

    public byte[] getScrambledModulus() {
        return this._scrambledModulus;
    }

    private static final byte[] scrambleModulus(BigInteger modulus) {
        int i;
        byte[] scrambledMod = modulus.toByteArray();
        if (scrambledMod.length == 129 && scrambledMod[0] == 0) {
            byte[] temp = new byte[128];
            System.arraycopy(scrambledMod, 1, temp, 0, 128);
            scrambledMod = temp;
        }
        for (i = 0; i < 4; ++i) {
            byte temp = scrambledMod[i];
            scrambledMod[i] = scrambledMod[77 + i];
            scrambledMod[77 + i] = temp;
        }
        for (i = 0; i < 64; ++i) {
            scrambledMod[i] = (byte)(scrambledMod[i] ^ scrambledMod[64 + i]);
        }
        for (i = 0; i < 4; ++i) {
            scrambledMod[13 + i] = (byte)(scrambledMod[13 + i] ^ scrambledMod[52 + i]);
        }
        for (i = 0; i < 64; ++i) {
            scrambledMod[64 + i] = (byte)(scrambledMod[64 + i] ^ scrambledMod[i]);
        }
        return scrambledMod;
    }
}

