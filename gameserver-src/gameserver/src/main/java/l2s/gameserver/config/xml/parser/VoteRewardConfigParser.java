/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.config.xml.parser;

import java.io.File;
import java.lang.reflect.Constructor;
import java.util.Iterator;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.config.xml.holder.VoteRewardConfigHolder;
import l2s.gameserver.model.entity.votereward.VoteRewardSite;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.model.reward.RewardType;
import l2s.gameserver.scripts.Scripts;
import org.dom4j.Element;

public final class VoteRewardConfigParser
extends AbstractParser<VoteRewardConfigHolder> {
    private static final VoteRewardConfigParser _instance = new VoteRewardConfigParser();

    public static VoteRewardConfigParser getInstance() {
        return _instance;
    }

    protected VoteRewardConfigParser() {
        super(VoteRewardConfigHolder.getInstance());
    }

    public File getXMLPath() {
        return new File("config/votereward.xml");
    }

    public String getDTDFileName() {
        return "votereward.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator configsIterator = rootElement.elementIterator("configs");
        while (configsIterator.hasNext()) {
            Element configsElement = (Element)configsIterator.next();
            Iterator configIterator = configsElement.elementIterator("config");
            while (configIterator.hasNext()) {
                Element configElement = (Element)configIterator.next();
                String configName = configElement.attributeValue("name");
                String configValue = configElement.attributeValue("value");
                if (!"reward_commands".equalsIgnoreCase(configName)) continue;
                VoteRewardConfigHolder.REWARD_COMMANDS = configValue.split(";");
            }
        }
        Iterator iterator = rootElement.elementIterator("vote_site");
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            String impl = element.attributeValue("impl");
            Class<?> voteRewardSiteClass = null;
            try {
                voteRewardSiteClass = Class.forName("l2s.gameserver.model.entity.votereward.impl." + impl + "Site");
            }
            catch (ClassNotFoundException e) {
                voteRewardSiteClass = Scripts.getInstance().getClasses().get("votereward." + impl + "Site");
            }
            if (voteRewardSiteClass == null) {
                this.info("Not found impl class: " + impl);
                continue;
            }
            boolean enabled = Boolean.parseBoolean(element.attributeValue("enabled"));
            Constructor<?> constructor = voteRewardSiteClass.getConstructor(MultiValueSet.class);
            MultiValueSet parameters = new MultiValueSet();
            parameters.set("name", impl);
            parameters.set("enabled", enabled);
            parameters.set("run_delay", element.attributeValue("run_delay") != null ? Integer.parseInt(element.attributeValue("run_delay")) : 0);
            Iterator parameterIterator = element.elementIterator("parameter");
            while (parameterIterator.hasNext()) {
                Element parameterElement = (Element)parameterIterator.next();
                parameters.set(parameterElement.attributeValue("name"), parameterElement.attributeValue("value"));
            }
            VoteRewardSite voteRewardSite = (VoteRewardSite)constructor.newInstance(parameters);
            Iterator subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                Element subElement = (Element)subIterator.next();
                if (!"rewards".equalsIgnoreCase(subElement.getName())) continue;
                voteRewardSite.addRewardList(RewardList.parseRewardList(this.getLogger(), subElement, RewardType.NOT_RATED_GROUPED, impl));
            }
            ((VoteRewardConfigHolder)this.getHolder()).addVoteRewardSite(voteRewardSite);
        }
    }
}

