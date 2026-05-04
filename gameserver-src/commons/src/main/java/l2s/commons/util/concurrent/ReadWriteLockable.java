package l2s.commons.util.concurrent;

public interface ReadWriteLockable {
    public void writeLock();

    public void writeUnlock();

    public void readLock();

    public void readUnlock();
}

