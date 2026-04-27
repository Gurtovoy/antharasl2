/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.crypt;

import java.io.IOException;
import l2s.authserver.crypt.BlowfishEngine;

public class NewCrypt {
    private final BlowfishEngine _crypt = new BlowfishEngine();
    private final BlowfishEngine _decrypt;

    public NewCrypt(byte[] blowfishKey) {
        this._crypt.init(true, blowfishKey);
        this._decrypt = new BlowfishEngine();
        this._decrypt.init(false, blowfishKey);
    }

    public NewCrypt(String key) {
        this(key.getBytes());
    }

    public static boolean verifyChecksum(byte[] raw) {
        return NewCrypt.verifyChecksum(raw, 0, raw.length);
    }

    public static boolean verifyChecksum(byte[] raw, int offset, int size) {
        int i;
        if ((size & 3) != 0 || size <= 4) {
            return false;
        }
        long chksum = 0L;
        int count = size - 4;
        long check = -1L;
        for (i = offset; i < count; i += 4) {
            check = raw[i] & 0xFF;
            check |= (long)(raw[i + 1] << 8 & 0xFF00);
            check |= (long)(raw[i + 2] << 16 & 0xFF0000);
            chksum ^= (check |= (long)(raw[i + 3] << 24 & 0xFF000000));
        }
        check = raw[i] & 0xFF;
        check |= (long)(raw[i + 1] << 8 & 0xFF00);
        check |= (long)(raw[i + 2] << 16 & 0xFF0000);
        return (check |= (long)(raw[i + 3] << 24 & 0xFF000000)) == chksum;
    }

    public static void appendChecksum(byte[] raw) {
        NewCrypt.appendChecksum(raw, 0, raw.length);
    }

    public static void appendChecksum(byte[] raw, int offset, int size) {
        long ecx;
        int i;
        long chksum = 0L;
        int count = size - 4;
        for (i = offset; i < count; i += 4) {
            ecx = raw[i] & 0xFF;
            ecx |= (long)(raw[i + 1] << 8 & 0xFF00);
            ecx |= (long)(raw[i + 2] << 16 & 0xFF0000);
            chksum ^= (ecx |= (long)(raw[i + 3] << 24 & 0xFF000000));
        }
        ecx = raw[i] & 0xFF;
        ecx |= (long)(raw[i + 1] << 8 & 0xFF00);
        ecx |= (long)(raw[i + 2] << 16 & 0xFF0000);
        ecx |= (long)(raw[i + 3] << 24 & 0xFF000000);
        raw[i] = (byte)(chksum & 0xFFL);
        raw[i + 1] = (byte)(chksum >> 8 & 0xFFL);
        raw[i + 2] = (byte)(chksum >> 16 & 0xFFL);
        raw[i + 3] = (byte)(chksum >> 24 & 0xFFL);
    }

    public static void encXORPass(byte[] raw, int key) {
        NewCrypt.encXORPass(raw, 0, raw.length, key);
    }

    public static void encXORPass(byte[] raw, int offset, int size, int key) {
        int stop = size - 8;
        int pos = 4 + offset;
        int ecx = key;
        while (pos < stop) {
            int edx = raw[pos] & 0xFF;
            edx |= (raw[pos + 1] & 0xFF) << 8;
            edx |= (raw[pos + 2] & 0xFF) << 16;
            ecx += (edx |= (raw[pos + 3] & 0xFF) << 24);
            raw[pos++] = (byte)((edx ^= ecx) & 0xFF);
            raw[pos++] = (byte)(edx >> 8 & 0xFF);
            raw[pos++] = (byte)(edx >> 16 & 0xFF);
            raw[pos++] = (byte)(edx >> 24 & 0xFF);
        }
        raw[pos++] = (byte)(ecx & 0xFF);
        raw[pos++] = (byte)(ecx >> 8 & 0xFF);
        raw[pos++] = (byte)(ecx >> 16 & 0xFF);
        raw[pos] = (byte)(ecx >> 24 & 0xFF);
    }

    public byte[] decrypt(byte[] raw) throws IOException {
        byte[] result = new byte[raw.length];
        int count = raw.length / 8;
        for (int i = 0; i < count; ++i) {
            this._decrypt.processBlock(raw, i * 8, result, i * 8);
        }
        return result;
    }

    public void decrypt(byte[] raw, int offset, int size) throws IOException {
        byte[] result = new byte[size];
        int count = size / 8;
        for (int i = 0; i < count; ++i) {
            this._decrypt.processBlock(raw, offset + i * 8, result, i * 8);
        }
        System.arraycopy(result, 0, raw, offset, size);
    }

    public byte[] crypt(byte[] raw) throws IOException {
        int count = raw.length / 8;
        byte[] result = new byte[raw.length];
        for (int i = 0; i < count; ++i) {
            this._crypt.processBlock(raw, i * 8, result, i * 8);
        }
        return result;
    }

    public void crypt(byte[] raw, int offset, int size) throws IOException {
        int count = size / 8;
        byte[] result = new byte[size];
        for (int i = 0; i < count; ++i) {
            this._crypt.processBlock(raw, offset + i * 8, result, i * 8);
        }
        System.arraycopy(result, 0, raw, offset, size);
    }
}

