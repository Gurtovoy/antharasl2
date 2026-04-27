/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.base;

public enum FenceState {
    HIDDEN(0),
    OPENED(1),
    CLOSED(2),
    CLOSED_HIDDEN(0);

    public static final FenceState[] VALUES;
    final int _clientId;

    private FenceState(int clientId) {
        this._clientId = clientId;
    }

    public int getClientId() {
        return this._clientId;
    }

    public boolean isGeodataEnabled() {
        return this == CLOSED_HIDDEN || this == CLOSED;
    }

    static {
        VALUES = FenceState.values();
    }
}

