/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.net.utils;

import java.util.ArrayList;
import java.util.Iterator;
import l2s.commons.net.utils.Net;

public final class NetList
extends ArrayList<Net> {
    private static final long serialVersionUID = 4266033257195615387L;

    public boolean matches(String address) {
        for (Net net : this) {
            if (!net.matches(address)) continue;
            return true;
        }
        return false;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        Iterator itr = this.iterator();
        while (itr.hasNext()) {
            sb.append(itr.next());
            if (!itr.hasNext()) continue;
            sb.append(',');
        }
        return sb.toString();
    }
}

