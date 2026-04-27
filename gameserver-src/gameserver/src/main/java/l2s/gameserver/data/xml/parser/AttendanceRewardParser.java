/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  l2s.commons.data.xml.AbstractParser
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.AttendanceRewardHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.templates.item.data.AttendanceRewardData;
import org.dom4j.Element;

public final class AttendanceRewardParser
extends AbstractParser<AttendanceRewardHolder> {
    private static final AttendanceRewardParser _instance = new AttendanceRewardParser();

    public static AttendanceRewardParser getInstance() {
        return _instance;
    }

    private AttendanceRewardParser() {
        super(AttendanceRewardHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/attendance_rewards.xml");
    }

    public String getDTDFileName() {
        return "attendance_rewards.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            AttendanceRewardData reward;
            Element subElement;
            Iterator subIterator;
            Element element = (Element)iterator.next();
            if ("config".equalsIgnoreCase(element.getName())) {
                if (element.attributeValue("reward_by_account") == null) continue;
                Config.VIP_ATTENDANCE_REWARDS_REWARD_BY_ACCOUNT = Boolean.parseBoolean(element.attributeValue("reward_by_account"));
                continue;
            }
            if ("normal_account_rewards".equalsIgnoreCase(element.getName())) {
                subIterator = element.elementIterator("item");
                while (subIterator.hasNext()) {
                    subElement = (Element)subIterator.next();
                    reward = this.parseReward(subElement);
                    if (reward == null) continue;
                    ((AttendanceRewardHolder)this.getHolder()).addNormalReward(reward);
                }
                continue;
            }
            if (!"premium_account_rewards".equalsIgnoreCase(element.getName())) continue;
            subIterator = element.elementIterator("item");
            while (subIterator.hasNext()) {
                subElement = (Element)subIterator.next();
                reward = this.parseReward(subElement);
                if (reward == null) continue;
                ((AttendanceRewardHolder)this.getHolder()).addPremiumReward(reward);
            }
        }
    }

    private AttendanceRewardData parseReward(Element element) {
        int id = Integer.parseInt(element.attributeValue("id"));
        if (ItemHolder.getInstance().getTemplate(id) == null) {
            this.warn("Cannot find item template ID[" + id + "]!");
            return null;
        }
        int count = Integer.parseInt(element.attributeValue("count"));
        boolean unknown = element.attributeValue("unknown") == null ? true : Boolean.parseBoolean(element.attributeValue("unknown"));
        boolean is_best = element.attributeValue("is_best") == null ? false : Boolean.parseBoolean(element.attributeValue("is_best"));
        return new AttendanceRewardData(id, count, unknown, is_best);
    }
}

