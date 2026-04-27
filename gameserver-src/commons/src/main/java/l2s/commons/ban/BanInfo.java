/*
 * Decompiled with CFR 0.152.
 */
package l2s.commons.ban;

public class BanInfo {
    private final int endTime;
    private final String reason;

    public BanInfo(int endTime, String reason) {
        this.endTime = endTime;
        this.reason = reason;
    }

    public int getEndTime() {
        return this.endTime;
    }

    public String getReason() {
        return this.reason;
    }
}

