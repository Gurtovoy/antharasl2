/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.net.nio.impl;

import java.nio.ByteBuffer;
import l2s.commons.net.nio.impl.MMOClient;

public abstract class ReceivablePacket<T extends MMOClient>
extends l2s.commons.net.nio.ReceivablePacket<T> {
    protected T _client;
    protected ByteBuffer _buf;

    protected void setByteBuffer(ByteBuffer buf) {
        this._buf = buf;
    }

    @Override
    protected ByteBuffer getByteBuffer() {
        return this._buf;
    }

    protected void setClient(T client) {
        this._client = client;
    }

    @Override
    public T getClient() {
        return this._client;
    }

    @Override
    protected abstract boolean read();
}

