/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.TreeIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.VIPTemplate;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public class VIPDataHolder
extends AbstractHolder {
    private static final VIPDataHolder _instance = new VIPDataHolder();
    private final IntObjectMap<VIPTemplate> _vipTemplates = new TreeIntObjectMap();

    public static VIPDataHolder getInstance() {
        return _instance;
    }

    public void addVIPTemplate(VIPTemplate vipData) {
        this._vipTemplates.put(vipData.getLevel(), vipData);
    }

    public VIPTemplate getVIPTemplate(int level) {
        if (level == 0 && !this._vipTemplates.containsKey(level)) {
            return VIPTemplate.DEFAULT_VIP_TEMPLATE;
        }
        return (VIPTemplate)this._vipTemplates.get(level);
    }

    public VIPTemplate getVIPTemplateByPoints(long points) {
        VIPTemplate result = VIPTemplate.DEFAULT_VIP_TEMPLATE;
        for (VIPTemplate vipData : this.getVIPDatas()) {
            if (vipData.getPoints() > points || result.getLevel() >= vipData.getLevel()) continue;
            result = vipData;
        }
        return result;
    }

    public Collection<VIPTemplate> getVIPDatas() {
        return this._vipTemplates.valueCollection();
    }

    public int size() {
        return this._vipTemplates.size();
    }

    public void clear() {
        this._vipTemplates.clear();
    }

    public void log() {
        this.info(String.format("loaded %d VIP data(s) count.", this.size()));
    }
}

