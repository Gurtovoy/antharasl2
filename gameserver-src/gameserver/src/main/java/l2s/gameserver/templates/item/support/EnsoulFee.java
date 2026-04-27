/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 */
package l2s.gameserver.templates.item.support;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collections;
import java.util.List;

public class EnsoulFee {
    private TIntObjectMap<TIntObjectMap<EnsoulFeeInfo>> _ensoulsFee = null;

    public void addFeeInfo(int type, int id, EnsoulFeeInfo feeInfo) {
        TIntObjectMap ensoulFeeInfos;
        if (this._ensoulsFee == null) {
            this._ensoulsFee = new TIntObjectHashMap();
        }
        if ((ensoulFeeInfos = (TIntObjectMap)this._ensoulsFee.get(type)) == null) {
            ensoulFeeInfos = new TIntObjectHashMap();
            this._ensoulsFee.put(type, ensoulFeeInfos);
        }
        ensoulFeeInfos.put(id, feeInfo);
    }

    public EnsoulFeeInfo getFeeInfo(int type, int id) {
        if (this._ensoulsFee == null) {
            return null;
        }
        TIntObjectMap ensoulFeeInfos = (TIntObjectMap)this._ensoulsFee.get(type);
        if (ensoulFeeInfos == null) {
            return null;
        }
        return (EnsoulFeeInfo)ensoulFeeInfos.get(id);
    }

    public static class EnsoulFeeItem {
        private final int _id;
        private final long _count;

        public EnsoulFeeItem(int id, long count) {
            this._id = id;
            this._count = count;
        }

        public int getId() {
            return this._id;
        }

        public long getCount() {
            return this._count;
        }
    }

    public static class EnsoulFeeInfo {
        private List<EnsoulFeeItem> _insertFee = Collections.emptyList();
        private List<EnsoulFeeItem> _changeFee = Collections.emptyList();
        private List<EnsoulFeeItem> _removeFee = Collections.emptyList();

        public void setInsertFee(List<EnsoulFeeItem> value) {
            this._insertFee = value;
        }

        public List<EnsoulFeeItem> getInsertFee() {
            return this._insertFee;
        }

        public void setChangeFee(List<EnsoulFeeItem> value) {
            this._changeFee = value;
        }

        public List<EnsoulFeeItem> getChangeFee() {
            return this._changeFee;
        }

        public void setRemoveFee(List<EnsoulFeeItem> value) {
            this._removeFee = value;
        }

        public List<EnsoulFeeItem> getRemoveFee() {
            return this._removeFee;
        }
    }
}

