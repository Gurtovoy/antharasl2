package l2s.commons.lang.reference;

import l2s.commons.lang.reference.HardReference;

public class AbstractHardReference<T>
implements HardReference<T> {
    private T reference;

    public AbstractHardReference(T reference) {
        this.reference = reference;
    }

    @Override
    public T get() {
        return this.reference;
    }

    @Override
    public void clear() {
        this.reference = null;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (!(o instanceof AbstractHardReference)) {
            return false;
        }
        if (((AbstractHardReference)o).get() == null) {
            return false;
        }
        return ((AbstractHardReference)o).get().equals(this.get());
    }

    public int hashCode() {
        return 17 * this.get().hashCode() + 16410;
    }
}

