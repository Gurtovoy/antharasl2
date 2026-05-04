package l2s.gameserver.idfactory;

import java.util.BitSet;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.commons.math.PrimeFinder;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.idfactory.IdFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BitSetIDFactory
extends IdFactory {
    private static final Logger _log = LoggerFactory.getLogger(BitSetIDFactory.class);
    private BitSet freeIds;
    private AtomicInteger freeIdCount;
    private AtomicInteger nextFreeId;

    protected BitSetIDFactory() {
        this.initialize();
        ThreadPoolManager.getInstance().scheduleAtFixedRate(new BitSetCapacityCheck(), 30000L, 30000L);
    }

    private void initialize() {
        try {
            this.freeIds = new BitSet(PrimeFinder.nextPrime((int)100000));
            this.freeIds.clear();
            this.freeIdCount = new AtomicInteger(0x6FFFFFFF);
            for (int usedObjectId : this.extractUsedObjectIDTable()) {
                int objectID = usedObjectId - 0x10000000;
                if (objectID < 0) {
                    _log.warn("Object ID " + usedObjectId + " in DB is less than minimum ID of " + 0x10000000);
                    continue;
                }
                this.freeIds.set(usedObjectId - 0x10000000);
                this.freeIdCount.decrementAndGet();
            }
            this.nextFreeId = new AtomicInteger(this.freeIds.nextClearBit(0));
            this.initialized = true;
            _log.info("IdFactory: " + this.freeIds.size() + " id's available.");
        }
        catch (Exception e) {
            this.initialized = false;
            _log.error("BitSet ID Factory could not be initialized correctly!", (Throwable)e);
        }
    }

    @Override
    public synchronized void releaseId(int objectID) {
        if (objectID - 0x10000000 > -1) {
            this.freeIds.clear(objectID - 0x10000000);
            this.freeIdCount.incrementAndGet();
            super.releaseId(objectID);
        } else {
            _log.warn("BitSet ID Factory: release objectID " + objectID + " failed (< " + 0x10000000 + ")");
        }
    }

    @Override
    public synchronized int getNextId() {
        int newID = this.nextFreeId.get();
        this.freeIds.set(newID);
        this.freeIdCount.decrementAndGet();
        int nextFree = this.freeIds.nextClearBit(newID);
        if (nextFree < 0) {
            nextFree = this.freeIds.nextClearBit(0);
        }
        if (nextFree < 0) {
            if (this.freeIds.size() < 0x6FFFFFFF) {
                this.increaseBitSetCapacity();
            } else {
                throw new NullPointerException("Ran out of valid Id's.");
            }
        }
        this.nextFreeId.set(nextFree);
        return newID + 0x10000000;
    }

    @Override
    public synchronized int size() {
        return this.freeIdCount.get();
    }

    protected synchronized int usedIdCount() {
        return this.size() - 0x10000000;
    }

    protected synchronized boolean reachingBitSetCapacity() {
        return PrimeFinder.nextPrime((int)(this.usedIdCount() * 11 / 10)) > this.freeIds.size();
    }

    protected synchronized void increaseBitSetCapacity() {
        BitSet newBitSet = new BitSet(PrimeFinder.nextPrime((int)(this.usedIdCount() * 11 / 10)));
        newBitSet.or(this.freeIds);
        this.freeIds = newBitSet;
    }

    public class BitSetCapacityCheck
    implements Runnable {
        @Override
        public void run() {
            if (BitSetIDFactory.this.reachingBitSetCapacity()) {
                BitSetIDFactory.this.increaseBitSetCapacity();
            }
        }
    }
}

