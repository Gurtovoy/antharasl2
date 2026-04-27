/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.templates.skill.restoration;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.util.Rnd;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.skill.restoration.RestorationGroup;
import l2s.gameserver.templates.skill.restoration.RestorationItem;

public final class RestorationInfo {
    private final int _itemConsumeId;
    private final int _itemConsumeCount;
    private final SystemMsg _onFailMessage;
    private final List<RestorationGroup> _restorationGroups;

    public RestorationInfo(int itemConsumeId, int itemConsumeCount, int onFailMessage) {
        this._itemConsumeId = itemConsumeId;
        this._itemConsumeCount = itemConsumeCount;
        this._onFailMessage = onFailMessage > 0 ? SystemMsg.valueOf(onFailMessage) : null;
        this._restorationGroups = new ArrayList<RestorationGroup>();
    }

    public int getItemConsumeId() {
        return this._itemConsumeId;
    }

    public int getItemConsumeCount() {
        return this._itemConsumeCount;
    }

    public SystemMsg getOnFailMessage() {
        return this._onFailMessage;
    }

    public void addRestorationGroup(RestorationGroup group) {
        this._restorationGroups.add(group);
    }

    public List<RestorationItem> getRandomGroupItems() {
        double chancesAmount = 0.0;
        for (RestorationGroup group : this._restorationGroups) {
            chancesAmount += group.getChance();
        }
        if (Rnd.chance((double)chancesAmount)) {
            double chanceMod = (100.0 - chancesAmount) / (double)this._restorationGroups.size();
            ArrayList<RestorationGroup> successGroups = new ArrayList<RestorationGroup>();
            int tryCount = 0;
            while (successGroups.isEmpty()) {
                ++tryCount;
                for (RestorationGroup group : this._restorationGroups) {
                    if (tryCount % 10 == 0) {
                        chanceMod += 1.0;
                    }
                    if (!Rnd.chance((double)(group.getChance() + chanceMod))) continue;
                    successGroups.add(group);
                }
            }
            RestorationGroup[] groupsArray = successGroups.toArray(new RestorationGroup[successGroups.size()]);
            return groupsArray[Rnd.get((int)groupsArray.length)].getRestorationItems();
        }
        return new ArrayList<RestorationItem>(0);
    }
}

