/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.pool.ObjectPool
 *  org.apache.commons.pool.PoolableObjectFactory
 *  org.apache.commons.pool.impl.GenericObjectPool
 */
package l2s.commons.collections;

import java.lang.reflect.Array;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.RandomAccess;
import org.apache.commons.pool.ObjectPool;
import org.apache.commons.pool.PoolableObjectFactory;
import org.apache.commons.pool.impl.GenericObjectPool;

public class LazyArrayList<E>
implements List<E>,
RandomAccess,
Cloneable {
    private static final int POOL_SIZE = Integer.parseInt(System.getProperty("lazyarraylist.poolsize", "-1"));
    private static final ObjectPool POOL = new GenericObjectPool((PoolableObjectFactory)new PoolableLazyArrayListFactory(), POOL_SIZE, (byte)2, 0L, -1);
    private static final int L = 8;
    private static final int H = 1024;
    protected transient Object[] elementData;
    protected transient int size = 0;
    protected transient int capacity = 8;

    public static <E> LazyArrayList<E> newInstance() {
        try {
            return (LazyArrayList)POOL.borrowObject();
        }
        catch (Exception e) {
            e.printStackTrace();
            return new LazyArrayList<E>();
        }
    }

    public static <E> void recycle(LazyArrayList<E> obj) {
        try {
            POOL.returnObject(obj);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public LazyArrayList(int initialCapacity) {
        if (initialCapacity < 1024) {
            while (this.capacity < initialCapacity) {
                this.capacity <<= 1;
            }
        } else {
            this.capacity = initialCapacity;
        }
    }

    public LazyArrayList() {
        this(8);
    }

    @Override
    public boolean add(E element) {
        this.ensureCapacity(this.size + 1);
        this.elementData[this.size++] = element;
        return true;
    }

    @Override
    public E set(int index, E element) {
        this.rangeCheck(index);
        Object e = null;
        e = this.elementData[index];
        this.elementData[index] = element;
        return (E)e;
    }

    @Override
    public void add(int index, E element) {
        this.rangeCheck(index);
        this.ensureCapacity(this.size + 1);
        System.arraycopy(this.elementData, index, this.elementData, index + 1, this.size - index);
        this.elementData[index] = element;
        ++this.size;
    }

    @Override
    public boolean addAll(int index, Collection<? extends E> c) {
        this.rangeCheck(index);
        if (c == null || c.isEmpty()) {
            return false;
        }
        Object[] a = c.toArray();
        int numNew = a.length;
        this.ensureCapacity(this.size + numNew);
        int numMoved = this.size - index;
        if (numMoved > 0) {
            System.arraycopy(this.elementData, index, this.elementData, index + numNew, numMoved);
        }
        System.arraycopy(a, 0, this.elementData, index, numNew);
        this.size += numNew;
        return true;
    }

    protected void ensureCapacity(int newSize) {
        if (newSize > this.capacity) {
            if (newSize < 1024) {
                while (this.capacity < newSize) {
                    this.capacity <<= 1;
                }
            } else {
                while (this.capacity < newSize) {
                    this.capacity = this.capacity * 3 / 2;
                }
            }
            Object[] elementDataResized = new Object[this.capacity];
            if (this.elementData != null) {
                System.arraycopy(this.elementData, 0, elementDataResized, 0, this.size);
            }
            this.elementData = elementDataResized;
        } else if (this.elementData == null) {
            this.elementData = new Object[this.capacity];
        }
    }

    protected void rangeCheck(int index) {
        if (index < 0 || index >= this.size) {
            throw new IndexOutOfBoundsException("Index: " + index + ", Size: " + this.size);
        }
    }

    @Override
    public E remove(int index) {
        this.rangeCheck(index);
        Object e = null;
        --this.size;
        e = this.elementData[index];
        this.elementData[index] = this.elementData[this.size];
        this.elementData[this.size] = null;
        this.trim();
        return (E)e;
    }

    @Override
    public boolean remove(Object o) {
        if (this.size == 0) {
            return false;
        }
        int index = -1;
        for (int i = 0; i < this.size; ++i) {
            if (this.elementData[i] != o) continue;
            index = i;
            break;
        }
        if (index == -1) {
            return false;
        }
        --this.size;
        this.elementData[index] = this.elementData[this.size];
        this.elementData[this.size] = null;
        this.trim();
        return true;
    }

    @Override
    public boolean contains(Object o) {
        if (this.size == 0) {
            return false;
        }
        for (int i = 0; i < this.size; ++i) {
            if (this.elementData[i] != o) continue;
            return true;
        }
        return false;
    }

    @Override
    public int indexOf(Object o) {
        if (this.size == 0) {
            return -1;
        }
        int index = -1;
        for (int i = 0; i < this.size; ++i) {
            if (this.elementData[i] != o) continue;
            index = i;
            break;
        }
        return index;
    }

    @Override
    public int lastIndexOf(Object o) {
        if (this.size == 0) {
            return -1;
        }
        int index = -1;
        for (int i = 0; i < this.size; ++i) {
            if (this.elementData[i] != o) continue;
            index = i;
        }
        return index;
    }

    protected void trim() {
    }

    @Override
    public E get(int index) {
        this.rangeCheck(index);
        return (E)this.elementData[index];
    }

    public Object clone() {
        LazyArrayList<E> clone = new LazyArrayList<E>();
        if (this.size > 0) {
            clone.capacity = this.capacity;
            clone.elementData = new Object[this.elementData.length];
            System.arraycopy(this.elementData, 0, clone.elementData, 0, this.size);
        }
        return clone;
    }

    @Override
    public void clear() {
        if (this.size == 0) {
            return;
        }
        for (int i = 0; i < this.size; ++i) {
            this.elementData[i] = null;
        }
        this.size = 0;
        this.trim();
    }

    @Override
    public int size() {
        return this.size;
    }

    @Override
    public boolean isEmpty() {
        return this.size == 0;
    }

    public int capacity() {
        return this.capacity;
    }

    @Override
    public boolean addAll(Collection<? extends E> c) {
        if (c == null || c.isEmpty()) {
            return false;
        }
        Object[] a = c.toArray();
        int numNew = a.length;
        this.ensureCapacity(this.size + numNew);
        System.arraycopy(a, 0, this.elementData, this.size, numNew);
        this.size += numNew;
        return true;
    }

    @Override
    public boolean containsAll(Collection<?> c) {
        if (c == null) {
            return false;
        }
        if (c.isEmpty()) {
            return true;
        }
        Iterator<?> e = c.iterator();
        while (e.hasNext()) {
            if (this.contains(e.next())) continue;
            return false;
        }
        return true;
    }

    @Override
    public boolean retainAll(Collection<?> c) {
        if (c == null) {
            return false;
        }
        boolean modified = false;
        Iterator<E> e = this.iterator();
        while (e.hasNext()) {
            if (c.contains(e.next())) continue;
            e.remove();
            modified = true;
        }
        return modified;
    }

    @Override
    public boolean removeAll(Collection<?> c) {
        if (c == null || c.isEmpty()) {
            return false;
        }
        boolean modified = false;
        Iterator<E> e = this.iterator();
        while (e.hasNext()) {
            if (!c.contains(e.next())) continue;
            e.remove();
            modified = true;
        }
        return modified;
    }

    @Override
    public Object[] toArray() {
        Object[] r = new Object[this.size];
        if (this.size > 0) {
            System.arraycopy(this.elementData, 0, r, 0, this.size);
        }
        return r;
    }

    @Override
    public <T> T[] toArray(T[] a) {
        T[] r;
        Object[] objectArray = r = a.length >= this.size ? a : (T[])Array.newInstance(a.getClass().getComponentType(), this.size);
        if (this.size > 0) {
            System.arraycopy(this.elementData, 0, r, 0, this.size);
        }
        if (r.length > this.size) {
            r[this.size] = null;
        }
        return r;
    }

    @Override
    public Iterator<E> iterator() {
        return new LazyItr();
    }

    @Override
    public ListIterator<E> listIterator() {
        return new LazyListItr(0);
    }

    @Override
    public ListIterator<E> listIterator(int index) {
        return new LazyListItr(index);
    }

    public String toString() {
        if (this.size == 0) {
            return "[]";
        }
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        for (int i = 0; i < this.size; ++i) {
            Object e = this.elementData[i];
            sb.append(e == this ? "this" : e);
            if (i == this.size - 1) {
                sb.append(']');
                continue;
            }
            sb.append(", ");
        }
        return sb.toString();
    }

    @Override
    public List<E> subList(int fromIndex, int toIndex) {
        throw new UnsupportedOperationException();
    }

    private class LazyListItr
    extends LazyItr
    implements ListIterator<E> {
        LazyListItr(int index) {
            this.cursor = index;
        }

        @Override
        public boolean hasPrevious() {
            return this.cursor > 0;
        }

        @Override
        public E previous() {
            int i = this.cursor - 1;
            E previous = (E) LazyArrayList.this.get(i);
            this.lastRet = this.cursor = i;
            return previous;
        }

        @Override
        public int nextIndex() {
            return this.cursor;
        }

        @Override
        public int previousIndex() {
            return this.cursor - 1;
        }

        @Override
        public void set(E e) {
            if (this.lastRet == -1) {
                throw new IllegalStateException();
            }
            LazyArrayList.this.set(this.lastRet, e);
        }

        @Override
        public void add(E e) {
            LazyArrayList.this.add(this.cursor++, e);
            this.lastRet = -1;
        }
    }

    private class LazyItr
    implements Iterator<E> {
        int cursor = 0;
        int lastRet = -1;

        private LazyItr() {
        }

        @Override
        public boolean hasNext() {
            return this.cursor < LazyArrayList.this.size();
        }

        @Override
        public E next() {
            E next = (E) LazyArrayList.this.get(this.cursor);
            this.lastRet = this.cursor++;
            return next;
        }

        @Override
        public void remove() {
            if (this.lastRet == -1) {
                throw new IllegalStateException();
            }
            LazyArrayList.this.remove(this.lastRet);
            if (this.lastRet < this.cursor) {
                --this.cursor;
            }
            this.lastRet = -1;
        }
    }

    private static class PoolableLazyArrayListFactory
    implements PoolableObjectFactory {
        private PoolableLazyArrayListFactory() {
        }

        public Object makeObject() throws Exception {
            return new LazyArrayList();
        }

        public void destroyObject(Object obj) throws Exception {
            ((LazyArrayList)obj).clear();
        }

        public boolean validateObject(Object obj) {
            return true;
        }

        public void activateObject(Object obj) throws Exception {
        }

        public void passivateObject(Object obj) throws Exception {
            ((LazyArrayList)obj).clear();
        }
    }
}

