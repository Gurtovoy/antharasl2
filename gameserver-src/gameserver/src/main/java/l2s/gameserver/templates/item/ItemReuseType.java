/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.TimeUtils;

public enum ItemReuseType {
    NORMAL(new SystemMsg[]{SystemMsg.THERE_ARE_S2_SECONDS_REMAINING_IN_S1S_REUSE_TIME, SystemMsg.THERE_ARE_S2_MINUTES_S3_SECONDS_REMAINING_IN_S1S_REUSE_TIME, SystemMsg.THERE_ARE_S2_HOURS_S3_MINUTES_AND_S4_SECONDS_REMAINING_IN_S1S_REUSE_TIME}){

        @Override
        public long next(ItemInstance item) {
            return System.currentTimeMillis() + (long)item.getTemplate().getReuseDelay();
        }
    }
    ,
    EVERY_DAY_AT_6_30(new SystemMsg[]{SystemMsg.THERE_ARE_S2_SECONDS_REMAINING_FOR_S1S_REUSE_TIME, SystemMsg.THERE_ARE_S2_MINUTES_S3_SECONDS_REMAINING_FOR_S1S_REUSE_TIME, SystemMsg.THERE_ARE_S2_HOURS_S3_MINUTES_S4_SECONDS_REMAINING_FOR_S1S_REUSE_TIME}){

        @Override
        public long next(ItemInstance item) {
            return TimeUtils.DAILY_DATE_PATTERN.next(System.currentTimeMillis());
        }
    };

    public static final ItemReuseType[] VALUES;
    private SystemMsg[] _messages;

    private ItemReuseType(SystemMsg ... msg) {
        this._messages = msg;
    }

    public abstract long next(ItemInstance var1);

    public SystemMsg[] getMessages() {
        return this._messages;
    }

    static {
        VALUES = ItemReuseType.values();
    }
}

