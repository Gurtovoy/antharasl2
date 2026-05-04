package l2s.commons.net.nio;

import l2s.commons.net.nio.AbstractPacket;

public abstract class ReceivablePacket<T>
extends AbstractPacket<T>
implements Runnable {
    protected int getAvaliableBytes() {
        return this.getByteBuffer().remaining();
    }

    protected void readB(byte[] dst) {
        this.getByteBuffer().get(dst);
    }

    protected void readB(byte[] dst, int offset, int len) {
        this.getByteBuffer().get(dst, offset, len);
    }

    protected int readC() {
        return this.getByteBuffer().get() & 0xFF;
    }

    protected int readH() {
        return this.getByteBuffer().getShort() & 0xFFFF;
    }

    protected int readD() {
        return this.getByteBuffer().getInt();
    }

    protected long readQ() {
        return this.getByteBuffer().getLong();
    }

    protected double readF() {
        return this.getByteBuffer().getDouble();
    }

    protected String readS() {
        char ch;
        StringBuilder sb = new StringBuilder();
        while ((ch = this.getByteBuffer().getChar()) != '\u0000') {
            sb.append(ch);
        }
        return sb.toString();
    }

    protected abstract boolean read();
}

