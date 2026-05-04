package l2s.commons.net.nio.impl;

import java.nio.ByteBuffer;
import l2s.commons.net.nio.impl.MMOClient;
import l2s.commons.net.nio.impl.SelectorThread;

public abstract class SendablePacket<T extends MMOClient>
extends l2s.commons.net.nio.SendablePacket<T> {
    @Override
    protected ByteBuffer getByteBuffer() {
        return ((SelectorThread)Thread.currentThread()).getWriteBuffer();
    }

    @SuppressWarnings("unchecked")
    @Override
    public T getClient() {
        return (T)((SelectorThread)Thread.currentThread()).getWriteClient();
    }

    @Override
    protected abstract boolean write();
}

