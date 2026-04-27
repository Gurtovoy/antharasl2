/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.math.random;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.util.Rnd;

public class RndSelector<E> {
    private int totalWeight = 0;
    protected final List<RndNode<E>> nodes;

    public RndSelector(boolean concurrent) {
        this.nodes = concurrent ? new CopyOnWriteArrayList() : new ArrayList();
    }

    public RndSelector() {
        this(false);
    }

    public RndSelector(int initialCapacity) {
        this.nodes = new ArrayList<RndNode<E>>(initialCapacity);
    }

    public void add(E value, int weight) {
        if (value == null || weight <= 0) {
            return;
        }
        this.totalWeight += weight;
        this.nodes.add(new RndNode<E>(value, weight));
    }

    public E chance(int maxWeight) {
        if (maxWeight <= 0) {
            return null;
        }
        Collections.sort(this.nodes);
        int r = Rnd.get(maxWeight);
        int weight = 0;
        for (int i = 0; i < this.nodes.size(); ++i) {
            if ((weight += ((RndNode)this.nodes.get(i)).weight) <= r) continue;
            return (E)((RndNode)this.nodes.get(i)).value;
        }
        return null;
    }

    public E chance() {
        return this.chance(100);
    }

    public E select() {
        return this.chance(this.totalWeight);
    }

    public void clear() {
        this.totalWeight = 0;
        this.nodes.clear();
    }

    protected class RndNode<T>
    implements Comparable<RndNode<T>> {
        private final T value;
        private final int weight;

        public RndNode(T value, int weight) {
            this.value = value;
            this.weight = weight;
        }

        @Override
        public int compareTo(RndNode<T> o) {
            return this.weight - this.weight;
        }
    }
}

