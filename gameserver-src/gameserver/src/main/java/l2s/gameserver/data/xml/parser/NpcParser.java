package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.commons.string.StringArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.model.reward.RewardData;
import l2s.gameserver.model.reward.RewardGroup;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.model.reward.RewardType;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.TeleportLocation;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.npc.Faction;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.npc.RandomActions;
import l2s.gameserver.templates.npc.WalkerRoute;
import l2s.gameserver.templates.npc.WalkerRoutePoint;
import l2s.gameserver.templates.npc.WalkerRouteType;

public final class NpcParser
extends AbstractParser<NpcHolder> {
    private static final NpcParser _instance = new NpcParser();

    public static NpcParser getInstance() {
        return _instance;
    }

    private NpcParser() {
        super(NpcHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/npc/");
    }

    public File getCustomXMLPath() {
        return new File(Config.DATAPACK_ROOT, "custom/npc/");
    }

    public String getDTDFileName() {
        return "npc.dtd";
    }

    protected void readData(org.dom4j.Element rootElement) throws Exception {
        Iterator npcIterator = rootElement.elementIterator();
        while (npcIterator.hasNext()) {
            org.dom4j.Element nextElement;
            org.dom4j.Element secondElement;
            org.dom4j.Element npcElement = (org.dom4j.Element)npcIterator.next();
            int npcId = Integer.parseInt(npcElement.attributeValue("id"));
            int templateId = npcElement.attributeValue("template_id") == null ? 0 : Integer.parseInt(npcElement.attributeValue("template_id"));
            String name = npcElement.attributeValue("name");
            String title = npcElement.attributeValue("title");
            StatsSet set = new StatsSet();
            set.set("npcId", npcId);
            set.set("displayId", templateId);
            set.set("name", name);
            set.set("title", title);
            set.set("baseCpReg", 0);
            set.set("baseCpMax", 0);
            Iterator firstIterator = npcElement.elementIterator();
            while (firstIterator.hasNext()) {
                org.dom4j.Element firstElement = (org.dom4j.Element)firstIterator.next();
                if (firstElement.getName().equalsIgnoreCase("set")) {
                    set.set(firstElement.attributeValue("name"), firstElement.attributeValue("value"));
                    continue;
                }
                if (firstElement.getName().equalsIgnoreCase("equip")) {
                    Iterator eIterator = firstElement.elementIterator();
                    while (eIterator.hasNext()) {
                        org.dom4j.Element eElement = (org.dom4j.Element)eIterator.next();
                        set.set(eElement.getName(), eElement.attributeValue("item_id"));
                    }
                    continue;
                }
                if (firstElement.getName().equalsIgnoreCase("ai_params")) {
                    StatsSet ai = new StatsSet();
                    Iterator eIterator = firstElement.elementIterator();
                    while (eIterator.hasNext()) {
                        org.dom4j.Element eElement = (org.dom4j.Element)eIterator.next();
                        ai.set(eElement.attributeValue("name"), eElement.attributeValue("value"));
                    }
                    set.set("aiParams", (Object)ai);
                    continue;
                }
                if (!firstElement.getName().equalsIgnoreCase("attributes")) continue;
                int[] attributeAttack = new int[6];
                int[] attributeDefence = new int[6];
                Iterator eIterator = firstElement.elementIterator();
                while (eIterator.hasNext()) {
                    Element element;
                    org.dom4j.Element eElement = (org.dom4j.Element)eIterator.next();
                    if (eElement.getName().equalsIgnoreCase("defence")) {
                        element = Element.getElementByName(eElement.attributeValue("attribute"));
                        attributeDefence[element.getId()] = Integer.parseInt(eElement.attributeValue("value"));
                        continue;
                    }
                    if (!eElement.getName().equalsIgnoreCase("attack")) continue;
                    element = Element.getElementByName(eElement.attributeValue("attribute"));
                    attributeAttack[element.getId()] = Integer.parseInt(eElement.attributeValue("value"));
                }
                set.set("baseAttributeAttack", attributeAttack);
                set.set("baseAttributeDefence", attributeDefence);
            }
            NpcTemplate template = new NpcTemplate(set);
            Iterator secondIterator = npcElement.elementIterator();
            while (secondIterator.hasNext()) {
                Iterator nextIterator;
                secondElement = (org.dom4j.Element)secondIterator.next();
                String nodeName = secondElement.getName();
                if (nodeName.equalsIgnoreCase("faction")) {
                    String factionNames = secondElement.attributeValue("names");
                    int factionRange = Integer.parseInt(secondElement.attributeValue("range"));
                    Faction faction = new Faction(factionNames, factionRange);
                    nextIterator = secondElement.elementIterator();
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement2 = (org.dom4j.Element)nextIterator.next();
                        int ignoreId = Integer.parseInt(nextElement2.attributeValue("npc_id"));
                        faction.addIgnoreNpcId(ignoreId);
                    }
                    template.setFaction(faction);
                    continue;
                }
                if (nodeName.equalsIgnoreCase("rewardlist")) {
                    template.addRewardList(RewardList.parseRewardList(this.getLogger(), secondElement, RewardType.valueOf(secondElement.attributeValue("type")), String.valueOf(npcId)));
                    continue;
                }
                if (nodeName.equalsIgnoreCase("client_skills") || nodeName.equalsIgnoreCase("skills")) {
                    Iterator nextIterator2 = secondElement.elementIterator();
                    while (nextIterator2.hasNext()) {
                        Skill skill;
                        org.dom4j.Element nextElement3 = (org.dom4j.Element)nextIterator2.next();
                        int id = Integer.parseInt(nextElement3.attributeValue("id"));
                        int level = Integer.parseInt(nextElement3.attributeValue("level"));
                        if (id == 4416) {
                            template.setRace(level);
                        }
                        if ((skill = SkillHolder.getInstance().getSkill(id, level)) == null) continue;
                        String use_type = nextElement3.attributeValue("use_type");
                        if (use_type != null) {
                            template.setAIParam(use_type, id + "-" + level);
                        }
                        template.addSkill(skill);
                    }
                    continue;
                }
                if (nodeName.equalsIgnoreCase("minions")) {
                    Iterator nextIterator3 = secondElement.elementIterator();
                    while (nextIterator3.hasNext()) {
                        org.dom4j.Element nextElement4 = (org.dom4j.Element)nextIterator3.next();
                        int id = Integer.parseInt(nextElement4.attributeValue("npc_id"));
                        String ai = nextElement4.attributeValue("ai");
                        int count = Integer.parseInt(nextElement4.attributeValue("count"));
                        int respawn = nextElement4.attributeValue("respawn") == null ? -1 : Integer.parseInt(nextElement4.attributeValue("respawn"));
                        template.addMinion(new MinionData(id, ai, count, respawn, null));
                    }
                    continue;
                }
                if (nodeName.equalsIgnoreCase("teleportlist")) {
                    Iterator sublistIterator = secondElement.elementIterator();
                    while (sublistIterator.hasNext()) {
                        org.dom4j.Element subListElement = (org.dom4j.Element)sublistIterator.next();
                        int id = Integer.parseInt(subListElement.attributeValue("id"));
                        boolean prime_hours = subListElement.attributeValue("prime_hours") == null ? true : Boolean.parseBoolean(subListElement.attributeValue("prime_hours"));
                        ArrayList<TeleportLocation> list = new ArrayList<TeleportLocation>();
                        Iterator targetIterator = subListElement.elementIterator();
                        while (targetIterator.hasNext()) {
                            org.dom4j.Element targetElement = (org.dom4j.Element)targetIterator.next();
                            int itemId = Integer.parseInt(targetElement.attributeValue("item_id", "57"));
                            long price = Integer.parseInt(targetElement.attributeValue("price"));
                            int npcStringId = Integer.parseInt(targetElement.attributeValue("name"));
                            int[] castleIds = StringArrayUtils.stringToIntArray((String)targetElement.attributeValue("castle_id", "0"), (String)";");
                            int questZoneId = Integer.parseInt(targetElement.attributeValue("quest_zone_id", "-1"));
                            TeleportLocation loc = new TeleportLocation(itemId, price, npcStringId, castleIds, prime_hours, questZoneId);
                            loc.set(Location.parseLoc(targetElement.attributeValue("loc")));
                            list.add(loc);
                        }
                        template.addTeleportList(id, list);
                    }
                    continue;
                }
                if (nodeName.equalsIgnoreCase("walker_route")) {
                    int id = Integer.parseInt(secondElement.attributeValue("id"));
                    WalkerRouteType type = secondElement.attributeValue("type") == null ? WalkerRouteType.LENGTH : WalkerRouteType.valueOf(secondElement.attributeValue("type").toUpperCase());
                    WalkerRoute walkerRoute = new WalkerRoute(id, type);
                    nextIterator = secondElement.elementIterator();
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement5 = (org.dom4j.Element)nextIterator.next();
                        Location loc = Location.parse(nextElement5);
                        int[] phrasesIds = StringArrayUtils.stringToIntArray((String)(nextElement5.attributeValue("phrase_id") == null ? "" : nextElement5.attributeValue("phrase_id")), (String)";");
                        NpcString[] phrases = new NpcString[phrasesIds.length];
                        for (int i = 0; i < phrasesIds.length; ++i) {
                            phrases[i] = NpcString.valueOf(phrasesIds[i]);
                        }
                        int socialActionId = nextElement5.attributeValue("social_action_id") == null ? -1 : Integer.parseInt(nextElement5.attributeValue("social_action_id"));
                        int delay = nextElement5.attributeValue("delay") == null ? 0 : Integer.parseInt(nextElement5.attributeValue("delay"));
                        boolean running = nextElement5.attributeValue("running") == null ? false : Boolean.parseBoolean(nextElement5.attributeValue("running"));
                        boolean teleport = nextElement5.attributeValue("teleport") == null ? false : Boolean.parseBoolean(nextElement5.attributeValue("teleport"));
                        walkerRoute.addPoint(new WalkerRoutePoint(loc, phrases, socialActionId, delay, running, teleport));
                    }
                    template.addWalkerRoute(walkerRoute);
                    continue;
                }
                if (!nodeName.equalsIgnoreCase("random_actions")) continue;
                boolean random_order = secondElement.attributeValue("random_order") == null ? false : Boolean.parseBoolean(secondElement.attributeValue("random_order"));
                RandomActions randomActions = new RandomActions(random_order);
                Iterator nextIterator4 = secondElement.elementIterator();
                while (nextIterator4.hasNext()) {
                    nextElement = (org.dom4j.Element)nextIterator4.next();
                    int id = Integer.parseInt(nextElement.attributeValue("id"));
                    NpcString phrase = nextElement.attributeValue("phrase_id") == null ? null : NpcString.valueOf(Integer.parseInt(nextElement.attributeValue("phrase_id")));
                    int socialActionId = nextElement.attributeValue("social_action_id") == null ? -1 : Integer.parseInt(nextElement.attributeValue("social_action_id"));
                    int delay = nextElement.attributeValue("delay") == null ? 0 : Integer.parseInt(nextElement.attributeValue("delay"));
                    randomActions.addAction(new RandomActions.Action(id, phrase, socialActionId, delay));
                }
                template.setRandomActions(randomActions);
            }
            secondIterator = npcElement.elementIterator("database_rewardlist");
            while (secondIterator.hasNext()) {
                secondElement = (org.dom4j.Element)secondIterator.next();
                RewardList list = new RewardList(RewardType.RATED_GROUPED, false);
                if (!template.isInstanceOf(RaidBossInstance.class)) {
                    RewardGroup equipAndPiecesGroup = null;
                    RewardGroup etcGroup = null;
                    Iterator nextIterator = secondElement.elementIterator("reward");
                    while (nextIterator.hasNext()) {
                        nextElement = (org.dom4j.Element)nextIterator.next();
                        RewardData data = RewardData.parseReward(nextElement);
                        ItemTemplate itemTemplate = data.getItem();
                        if (itemTemplate.isAdena()) {
                            RewardGroup adenaGroup = new RewardGroup(data.getChance(), null);
                            data.setChance(1000000.0);
                            adenaGroup.addData(data);
                            list.add(adenaGroup);
                            continue;
                        }
                        if (itemTemplate.isArmor() || itemTemplate.isWeapon() || itemTemplate.isAccessory() || itemTemplate.isKeyMatherial()) {
                            if (equipAndPiecesGroup == null) {
                                equipAndPiecesGroup = new RewardGroup(1000000.0, null);
                            }
                            equipAndPiecesGroup.addData(data);
                            continue;
                        }
                        if (etcGroup == null) {
                            etcGroup = new RewardGroup(1000000.0, null);
                        }
                        etcGroup.addData(data);
                    }
                    if (equipAndPiecesGroup != null) {
                        equipAndPiecesGroup.setChance(1000000.0);
                        for (RewardData data : equipAndPiecesGroup.getItems()) {
                            data.setChance(data.getChance());
                        }
                        list.add(equipAndPiecesGroup);
                    }
                    if (etcGroup != null) {
                        etcGroup.setChance(1000000.0);
                        for (RewardData data : etcGroup.getItems()) {
                            data.setChance(data.getChance());
                        }
                        list.add(etcGroup);
                    }
                } else {
                    Iterator nextIterator = secondElement.elementIterator("reward");
                    while (nextIterator.hasNext()) {
                        org.dom4j.Element nextElement6 = (org.dom4j.Element)nextIterator.next();
                        RewardGroup group = new RewardGroup(1000000.0, null);
                        group.addData(RewardData.parseReward(nextElement6));
                        list.add(group);
                    }
                }
                template.addRewardList(list);
            }
            ((NpcHolder)this.getHolder()).addTemplate(template);
        }
    }
}

