/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  l2s.commons.data.xml.AbstractParser
 *  org.dom4j.Attribute
 *  org.dom4j.Element
 */
package l2s.gameserver.data.xml.parser;

import java.util.Iterator;
import java.util.List;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.model.base.PledgeRank;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.conditions.ConditionGameTime;
import l2s.gameserver.stats.conditions.ConditionHasSkill;
import l2s.gameserver.stats.conditions.ConditionLogicAnd;
import l2s.gameserver.stats.conditions.ConditionLogicNot;
import l2s.gameserver.stats.conditions.ConditionLogicOr;
import l2s.gameserver.stats.conditions.ConditionPlayerAgathion;
import l2s.gameserver.stats.conditions.ConditionPlayerCanLearnSkill;
import l2s.gameserver.stats.conditions.ConditionPlayerCanTransform;
import l2s.gameserver.stats.conditions.ConditionPlayerCanUntransform;
import l2s.gameserver.stats.conditions.ConditionPlayerCastleType;
import l2s.gameserver.stats.conditions.ConditionPlayerClanLeaderOnline;
import l2s.gameserver.stats.conditions.ConditionPlayerClassId;
import l2s.gameserver.stats.conditions.ConditionPlayerClassType;
import l2s.gameserver.stats.conditions.ConditionPlayerFlagged;
import l2s.gameserver.stats.conditions.ConditionPlayerHasBuff;
import l2s.gameserver.stats.conditions.ConditionPlayerHasBuffId;
import l2s.gameserver.stats.conditions.ConditionPlayerHasSummonId;
import l2s.gameserver.stats.conditions.ConditionPlayerInstanceZone;
import l2s.gameserver.stats.conditions.ConditionPlayerIsChaotic;
import l2s.gameserver.stats.conditions.ConditionPlayerIsClanLeader;
import l2s.gameserver.stats.conditions.ConditionPlayerIsHero;
import l2s.gameserver.stats.conditions.ConditionPlayerMaxLevel;
import l2s.gameserver.stats.conditions.ConditionPlayerMaxPK;
import l2s.gameserver.stats.conditions.ConditionPlayerMaxSP;
import l2s.gameserver.stats.conditions.ConditionPlayerMinClanLevel;
import l2s.gameserver.stats.conditions.ConditionPlayerMinLevel;
import l2s.gameserver.stats.conditions.ConditionPlayerMinMaxDamage;
import l2s.gameserver.stats.conditions.ConditionPlayerMinPledgeRank;
import l2s.gameserver.stats.conditions.ConditionPlayerOlympiad;
import l2s.gameserver.stats.conditions.ConditionPlayerPercentCp;
import l2s.gameserver.stats.conditions.ConditionPlayerPercentHp;
import l2s.gameserver.stats.conditions.ConditionPlayerPercentMp;
import l2s.gameserver.stats.conditions.ConditionPlayerQuestState;
import l2s.gameserver.stats.conditions.ConditionPlayerRace;
import l2s.gameserver.stats.conditions.ConditionPlayerResidence;
import l2s.gameserver.stats.conditions.ConditionPlayerRiding;
import l2s.gameserver.stats.conditions.ConditionPlayerSex;
import l2s.gameserver.stats.conditions.ConditionPlayerState;
import l2s.gameserver.stats.conditions.ConditionPlayerSummonSiegeGolem;
import l2s.gameserver.stats.conditions.ConditionSlotItemId;
import l2s.gameserver.stats.conditions.ConditionTargetAggro;
import l2s.gameserver.stats.conditions.ConditionTargetCastleDoor;
import l2s.gameserver.stats.conditions.ConditionTargetClan;
import l2s.gameserver.stats.conditions.ConditionTargetDirection;
import l2s.gameserver.stats.conditions.ConditionTargetForbiddenClassId;
import l2s.gameserver.stats.conditions.ConditionTargetHasBuff;
import l2s.gameserver.stats.conditions.ConditionTargetHasBuffId;
import l2s.gameserver.stats.conditions.ConditionTargetHasForbiddenSkill;
import l2s.gameserver.stats.conditions.ConditionTargetMinDistance;
import l2s.gameserver.stats.conditions.ConditionTargetMobId;
import l2s.gameserver.stats.conditions.ConditionTargetNpcClass;
import l2s.gameserver.stats.conditions.ConditionTargetPercentCp;
import l2s.gameserver.stats.conditions.ConditionTargetPercentHp;
import l2s.gameserver.stats.conditions.ConditionTargetPercentMp;
import l2s.gameserver.stats.conditions.ConditionTargetPetFeed;
import l2s.gameserver.stats.conditions.ConditionTargetPlayerRace;
import l2s.gameserver.stats.conditions.ConditionTargetRace;
import l2s.gameserver.stats.conditions.ConditionTargetType;
import l2s.gameserver.stats.conditions.ConditionUsingArmor;
import l2s.gameserver.stats.conditions.ConditionUsingItemType;
import l2s.gameserver.stats.conditions.ConditionUsingSkill;
import l2s.gameserver.stats.conditions.ConditionZoneName;
import l2s.gameserver.stats.conditions.ConditionZoneType;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.stats.triggers.TriggerInfo;
import l2s.gameserver.stats.triggers.TriggerType;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.ArmorTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.utils.PositionUtils;
import org.dom4j.Attribute;
import org.dom4j.Element;

public abstract class StatParser<H extends AbstractHolder>
extends AbstractParser<H> {
    private static final Pattern TABLE_PATTERN = Pattern.compile("((?!;|:| |-).*?)((;|:| |-)|$)", 32);

    protected StatParser(H holder) {
        super(holder);
    }

    protected Condition parseFirstCond(Element sub, int ... arg) {
        List e = sub.elements();
        if (e.isEmpty()) {
            return null;
        }
        Element element = (Element)e.get(0);
        return this.parseCond(element, arg);
    }

    protected Condition parseCond(Element element, int ... arg) {
        String name = element.getName();
        if (name.equalsIgnoreCase("and")) {
            return this.parseLogicAnd(element, arg);
        }
        if (name.equalsIgnoreCase("or")) {
            return this.parseLogicOr(element, arg);
        }
        if (name.equalsIgnoreCase("not")) {
            return this.parseLogicNot(element, arg);
        }
        if (name.equalsIgnoreCase("target")) {
            return this.parseTargetCondition(element, arg);
        }
        if (name.equalsIgnoreCase("player")) {
            return this.parsePlayerCondition(element, arg);
        }
        if (name.equalsIgnoreCase("using")) {
            return this.parseUsingCondition(element, arg);
        }
        if (name.equalsIgnoreCase("zone")) {
            return this.parseZoneCondition(element, arg);
        }
        if (name.equalsIgnoreCase("has")) {
            return this.parseHasCondition(element, arg);
        }
        if (name.equalsIgnoreCase("game")) {
            return this.parseGameCondition(element, arg);
        }
        return null;
    }

    protected Condition parseLogicAnd(Element n, int ... arg) {
        ConditionLogicAnd cond = new ConditionLogicAnd();
        Iterator iterator = n.elementIterator();
        while (iterator.hasNext()) {
            Element condElement = (Element)iterator.next();
            cond.add(this.parseCond(condElement, arg));
        }
        if (cond._conditions == null || cond._conditions.length == 0) {
            this.error("Empty <and> condition in " + this.getCurrentFileName());
        }
        return cond;
    }

    protected Condition parseLogicOr(Element n, int ... arg) {
        ConditionLogicOr cond = new ConditionLogicOr();
        Iterator iterator = n.elementIterator();
        while (iterator.hasNext()) {
            Element condElement = (Element)iterator.next();
            cond.add(this.parseCond(condElement, arg));
        }
        if (cond._conditions == null || cond._conditions.length == 0) {
            this.error("Empty <or> condition in " + this.getCurrentFileName());
        }
        return cond;
    }

    protected Condition parseLogicNot(Element n, int ... arg) {
        Iterator iterator = n.elements().iterator();
        if (iterator.hasNext()) {
            Object element = iterator.next();
            return new ConditionLogicNot(this.parseCond((Element)element, arg));
        }
        this.error("Empty <not> condition in " + this.getCurrentFileName());
        return null;
    }

    protected Condition parseTargetCondition(Element element, int ... arg) {
        Condition cond = null;
        Iterator iterator = element.attributeIterator();
        while (iterator.hasNext()) {
            int level;
            StringTokenizer st;
            Attribute attribute = (Attribute)iterator.next();
            String name = attribute.getName();
            String value = this.parseTableString(attribute.getValue(), arg);
            if (name.equalsIgnoreCase("is_pet_feed")) {
                cond = this.joinAnd(cond, new ConditionTargetPetFeed(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("type")) {
                cond = this.joinAnd(cond, new ConditionTargetType(value));
                continue;
            }
            if (name.equalsIgnoreCase("aggro")) {
                cond = this.joinAnd(cond, new ConditionTargetAggro(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("mobId")) {
                cond = this.joinAnd(cond, new ConditionTargetMobId(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("race")) {
                cond = this.joinAnd(cond, new ConditionTargetRace(value));
                continue;
            }
            if (name.equalsIgnoreCase("npc_class")) {
                cond = this.joinAnd(cond, new ConditionTargetNpcClass(value));
                continue;
            }
            if (name.equalsIgnoreCase("playerRace")) {
                cond = this.joinAnd(cond, new ConditionTargetPlayerRace(value));
                continue;
            }
            if (name.equalsIgnoreCase("forbiddenClassIds")) {
                cond = this.joinAnd(cond, new ConditionTargetForbiddenClassId(value.split(";")));
                continue;
            }
            if (name.equalsIgnoreCase("playerSameClan")) {
                cond = this.joinAnd(cond, new ConditionTargetClan(value));
                continue;
            }
            if (name.equalsIgnoreCase("castledoor")) {
                cond = this.joinAnd(cond, new ConditionTargetCastleDoor(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("direction")) {
                cond = this.joinAnd(cond, new ConditionTargetDirection(PositionUtils.TargetDirection.valueOf(value.toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("percentHP")) {
                cond = this.joinAnd(cond, new ConditionTargetPercentHp(Double.parseDouble(value)));
                continue;
            }
            if (name.equalsIgnoreCase("percentMP")) {
                cond = this.joinAnd(cond, new ConditionTargetPercentMp(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("percentCP")) {
                cond = this.joinAnd(cond, new ConditionTargetPercentCp(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("hasBuffId")) {
                st = new StringTokenizer(value, ";");
                int id = Integer.parseInt(st.nextToken().trim());
                level = -1;
                if (st.hasMoreTokens()) {
                    level = this.parseTableNumber(st.nextToken().trim(), arg).intValue();
                }
                cond = this.joinAnd(cond, new ConditionTargetHasBuffId(id, level));
                continue;
            }
            if (name.equalsIgnoreCase("has_abnormal_type")) {
                st = new StringTokenizer(value, ";");
                AbnormalType at = Enum.valueOf(AbnormalType.class, st.nextToken().trim().toUpperCase());
                level = -1;
                if (st.hasMoreTokens()) {
                    level = this.parseTableNumber(st.nextToken().trim(), arg).intValue();
                }
                cond = this.joinAnd(cond, new ConditionTargetHasBuff(at, level));
                continue;
            }
            if (name.equalsIgnoreCase("hasForbiddenSkill")) {
                cond = this.joinAnd(cond, new ConditionTargetHasForbiddenSkill(Integer.parseInt(value)));
                continue;
            }
            if (!name.equalsIgnoreCase("min_distance")) continue;
            cond = this.joinAnd(cond, new ConditionTargetMinDistance(Integer.parseInt(value)));
        }
        return cond;
    }

    protected Condition parseZoneCondition(Element element, int ... arg) {
        Condition cond = null;
        Iterator iterator = element.attributeIterator();
        while (iterator.hasNext()) {
            Attribute attribute = (Attribute)iterator.next();
            String name = attribute.getName();
            String value = this.parseTableString(attribute.getValue(), arg);
            if (name.equalsIgnoreCase("type")) {
                cond = this.joinAnd(cond, new ConditionZoneType(value));
                continue;
            }
            if (!name.equalsIgnoreCase("name")) continue;
            cond = this.joinAnd(cond, new ConditionZoneName(value));
        }
        return cond;
    }

    protected Condition parseHasCondition(Element element, int ... arg) {
        Condition cond = null;
        Iterator iterator = element.attributeIterator();
        while (iterator.hasNext()) {
            Attribute attribute = (Attribute)iterator.next();
            String name = attribute.getName();
            String value = this.parseTableString(attribute.getValue(), arg);
            if (!name.equalsIgnoreCase("skill")) continue;
            StringTokenizer st = new StringTokenizer(value, ";");
            int id = Integer.parseInt(st.nextToken().trim());
            int level = this.parseTableNumber(st.nextToken().trim(), arg).intValue();
            cond = this.joinAnd(cond, new ConditionHasSkill(id, level));
        }
        return cond;
    }

    protected Condition parseGameCondition(Element element, int ... arg) {
        Condition cond = null;
        Iterator iterator = element.attributeIterator();
        while (iterator.hasNext()) {
            Attribute attribute = (Attribute)iterator.next();
            String name = attribute.getName();
            String value = this.parseTableString(attribute.getValue(), arg);
            if (!name.equalsIgnoreCase("night")) continue;
            cond = this.joinAnd(cond, new ConditionGameTime(ConditionGameTime.CheckGameTime.NIGHT, Boolean.valueOf(value)));
        }
        return cond;
    }

    protected Condition parsePlayerCondition(Element element, int ... arg) {
        Condition cond = null;
        Iterator iterator = element.attributeIterator();
        while (iterator.hasNext()) {
            int level;
            Object st;
            Attribute attribute = (Attribute)iterator.next();
            String name = attribute.getName();
            String value = this.parseTableString(attribute.getValue(), arg);
            if (name.equalsIgnoreCase("residence")) {
                st = value.split(";");
                cond = this.joinAnd(cond, new ConditionPlayerResidence(Integer.parseInt(((String[])st)[1]), ResidenceType.valueOf(((String[])st)[0].toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("classId")) {
                cond = this.joinAnd(cond, new ConditionPlayerClassId(value.split(",")));
                continue;
            }
            if (name.equalsIgnoreCase("olympiad")) {
                cond = this.joinAnd(cond, new ConditionPlayerOlympiad(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("instance_zone")) {
                cond = this.joinAnd(cond, new ConditionPlayerInstanceZone(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("is_clan_leader")) {
                cond = this.joinAnd(cond, new ConditionPlayerIsClanLeader(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("is_hero")) {
                cond = this.joinAnd(cond, new ConditionPlayerIsHero(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("is_chaotic")) {
                cond = this.joinAnd(cond, new ConditionPlayerIsChaotic(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("race")) {
                cond = this.joinAnd(cond, new ConditionPlayerRace(value));
                continue;
            }
            if (name.equalsIgnoreCase("sex")) {
                cond = this.joinAnd(cond, new ConditionPlayerSex(Sex.valueOf(value.toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("castle_type")) {
                cond = this.joinAnd(cond, new ConditionPlayerCastleType(ResidenceSide.valueOf(value.toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("max_level")) {
                cond = this.joinAnd(cond, new ConditionPlayerMaxLevel(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("min_clan_level")) {
                cond = this.joinAnd(cond, new ConditionPlayerMinClanLevel(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("avail_max_sp")) {
                cond = this.joinAnd(cond, new ConditionPlayerMaxSP(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("minLevel")) {
                cond = this.joinAnd(cond, new ConditionPlayerMinLevel(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("class_type")) {
                cond = this.joinAnd(cond, new ConditionPlayerClassType(SubClassType.valueOf(value.toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("isFlagged")) {
                cond = this.joinAnd(cond, new ConditionPlayerFlagged(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("damage")) {
                st = new StringTokenizer(value, ";");
                double min = Double.parseDouble(((StringTokenizer)st).nextToken().trim());
                double max = 2.147483647E9;
                if (((StringTokenizer)st).hasMoreTokens()) {
                    max = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).doubleValue();
                }
                cond = this.joinAnd(cond, new ConditionPlayerMinMaxDamage(min, max));
                continue;
            }
            if (name.equalsIgnoreCase("quest_state")) {
                st = new StringTokenizer(value, ";");
                int questId = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).intValue();
                int condId = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).intValue();
                cond = this.joinAnd(cond, new ConditionPlayerQuestState(questId, condId));
                continue;
            }
            if (name.equalsIgnoreCase("min_pledge_rank")) {
                cond = this.joinAnd(cond, new ConditionPlayerMinPledgeRank(PledgeRank.valueOf(value.toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("summon_siege_golem")) {
                cond = this.joinAnd(cond, new ConditionPlayerSummonSiegeGolem());
                continue;
            }
            if (name.equalsIgnoreCase("maxPK")) {
                cond = this.joinAnd(cond, new ConditionPlayerMaxPK(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("resting")) {
                cond = this.joinAnd(cond, new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.RESTING, Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("moving")) {
                cond = this.joinAnd(cond, new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.MOVING, Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("running")) {
                cond = this.joinAnd(cond, new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.RUNNING, Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("standing")) {
                cond = this.joinAnd(cond, new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.STANDING, Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("flying")) {
                cond = this.joinAnd(cond, new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.FLYING, Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("flyingTransform")) {
                cond = this.joinAnd(cond, new ConditionPlayerState(ConditionPlayerState.CheckPlayerState.FLYING_TRANSFORM, Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("percentHP")) {
                cond = this.joinAnd(cond, new ConditionPlayerPercentHp(Double.parseDouble(value)));
                continue;
            }
            if (name.equalsIgnoreCase("percentMP")) {
                cond = this.joinAnd(cond, new ConditionPlayerPercentMp(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("percentCP")) {
                cond = this.joinAnd(cond, new ConditionPlayerPercentCp(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("clan_leader_online")) {
                cond = this.joinAnd(cond, new ConditionPlayerClanLeaderOnline(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("riding")) {
                cond = this.joinAnd(cond, new ConditionPlayerRiding(ConditionPlayerRiding.CheckPlayerRiding.valueOf(value.toUpperCase())));
                continue;
            }
            if (name.equalsIgnoreCase("hasBuffId")) {
                st = new StringTokenizer(value, ";");
                int id = Integer.parseInt(((StringTokenizer)st).nextToken().trim());
                level = -1;
                if (((StringTokenizer)st).hasMoreTokens()) {
                    level = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).intValue();
                }
                cond = this.joinAnd(cond, new ConditionPlayerHasBuffId(id, level));
                continue;
            }
            if (name.equalsIgnoreCase("has_abnormal_type")) {
                st = new StringTokenizer(value, ";");
                AbnormalType at = Enum.valueOf(AbnormalType.class, ((StringTokenizer)st).nextToken().trim().toUpperCase());
                level = -1;
                if (((StringTokenizer)st).hasMoreTokens()) {
                    level = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).intValue();
                }
                cond = this.joinAnd(cond, new ConditionPlayerHasBuff(at, level));
                continue;
            }
            if (name.equalsIgnoreCase("has_summon_id")) {
                cond = this.joinAnd(cond, new ConditionPlayerHasSummonId(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("can_transform")) {
                cond = this.joinAnd(cond, new ConditionPlayerCanTransform(Integer.parseInt(value)));
                continue;
            }
            if (name.equalsIgnoreCase("can_untransform")) {
                cond = this.joinAnd(cond, new ConditionPlayerCanUntransform(Boolean.valueOf(value)));
                continue;
            }
            if (name.equalsIgnoreCase("agathion")) {
                cond = this.joinAnd(cond, new ConditionPlayerAgathion(Integer.parseInt(value)));
                continue;
            }
            if (!name.equalsIgnoreCase("can_learn_skill")) continue;
            st = new StringTokenizer(value, "-");
            int id = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).intValue();
            level = 1;
            if (((StringTokenizer)st).hasMoreTokens()) {
                level = this.parseTableNumber(((StringTokenizer)st).nextToken().trim(), arg).intValue();
            }
            cond = this.joinAnd(cond, new ConditionPlayerCanLearnSkill(id, level));
        }
        return cond;
    }

    protected Condition parseUsingCondition(Element element, int ... arg) {
        Condition cond = null;
        Iterator iterator = element.attributeIterator();
        while (iterator.hasNext()) {
            Attribute attribute = (Attribute)iterator.next();
            String name = attribute.getName();
            String value = this.parseTableString(attribute.getValue(), arg);
            if (name.equalsIgnoreCase("slotitem")) {
                StringTokenizer st = new StringTokenizer(value, ";");
                int id = Integer.parseInt(st.nextToken().trim());
                int slot = Integer.parseInt(st.nextToken().trim());
                int enchant = 0;
                if (st.hasMoreTokens()) {
                    enchant = this.parseTableNumber(st.nextToken().trim(), arg).intValue();
                }
                cond = this.joinAnd(cond, new ConditionSlotItemId(slot, id, enchant));
                continue;
            }
            if (name.equalsIgnoreCase("kind") || name.equalsIgnoreCase("weapon")) {
                long mask = 0L;
                StringTokenizer st = new StringTokenizer(value, ",");
                block1: while (st.hasMoreTokens()) {
                    String item = st.nextToken().trim();
                    for (WeaponTemplate.WeaponType weaponType : WeaponTemplate.WeaponType.VALUES) {
                        if (!weaponType.toString().equalsIgnoreCase(item)) continue;
                        mask |= weaponType.mask();
                        continue block1;
                    }
                    for (Enum enum_ : ArmorTemplate.ArmorType.VALUES) {
                        if (!((ArmorTemplate.ArmorType)enum_).toString().equalsIgnoreCase(item)) continue;
                        mask |= ((ArmorTemplate.ArmorType)enum_).mask();
                        continue block1;
                    }
                    this.error("Invalid item kind: \"" + item + "\" in " + this.getCurrentFileName());
                }
                if (mask == 0L) continue;
                cond = this.joinAnd(cond, new ConditionUsingItemType(mask));
                continue;
            }
            if (name.equalsIgnoreCase("skill")) {
                cond = this.joinAnd(cond, new ConditionUsingSkill(Integer.parseInt(value)));
                continue;
            }
            if (!name.equalsIgnoreCase("armor")) continue;
            cond = this.joinAnd(cond, new ConditionUsingArmor(ArmorTemplate.ArmorType.valueOf(value.toUpperCase())));
        }
        return cond;
    }

    protected Condition joinAnd(Condition cond, Condition c) {
        if (cond == null) {
            return c;
        }
        if (cond instanceof ConditionLogicAnd) {
            ((ConditionLogicAnd)cond).add(c);
            return cond;
        }
        ConditionLogicAnd and = new ConditionLogicAnd();
        and.add(cond);
        and.add(c);
        return and;
    }

    protected void parseFor(Element forElement, StatTemplate template, int ... arg) {
        Iterator iterator = forElement.elementIterator();
        while (iterator.hasNext()) {
            StatsSet params;
            Stats stat;
            Element element = (Element)iterator.next();
            String elementName = element.getName().toLowerCase();
            if (elementName.equals("add")) {
                this.attachFunc(element, 64, template, "Add", arg);
                continue;
            }
            if (elementName.equals("set")) {
                this.attachFunc(element, 128, template, "Set", arg);
                continue;
            }
            if (elementName.equals("sub")) {
                this.attachFunc(element, 64, template, "Sub", arg);
                continue;
            }
            if (elementName.equals("mul")) {
                this.attachFunc(element, 48, template, "Mul", arg);
                continue;
            }
            if (elementName.equals("div")) {
                this.attachFunc(element, 48, template, "Div", arg);
                continue;
            }
            if (elementName.equalsIgnoreCase("stat_effect")) {
                stat = Stats.valueOfXml(this.parseTableString(element.attributeValue("name"), new int[0]));
                params = new StatsSet();
                params.set("mode", StatModifierType.valueOfXml(this.parseTableString(this.parseString(element, "type", StatModifierType.DIFF.toString()), arg)));
                params.set("value", this.parseTableNumber(this.parseString(element, "value", "0"), arg).doubleValue());
                for (Element setElement : element.elements("set")) {
                    params.set(setElement.attributeValue("name"), this.parseTableString(setElement.attributeValue("value"), arg));
                }
                this.attachFunc(element, stat, template, "New", params, arg);
                continue;
            }
            if (!elementName.startsWith("p_")) continue;
            if (elementName.equals("p_attack_trait")) {
                stat = Stats.valueOfXml("attack_trait_" + this.parseTableString(element.attributeValue("name"), new int[0]));
                this.attachFunc(element, stat, template, "Add", new StatsSet(), arg);
                continue;
            }
            if (elementName.equals("p_defence_trait")) {
                stat = Stats.valueOfXml("defence_trait_" + this.parseTableString(element.attributeValue("name"), new int[0]));
                this.attachFunc(element, stat, template, "AddTraitDefence", new StatsSet(), arg);
                continue;
            }
            if (elementName.equals("p_vampiric_attack") || elementName.equals("p_mp_vampiric_attack")) {
                stat = elementName.equals("p_vampiric_attack") ? Stats.VAMPIRIC_ATTACK : Stats.MP_VAMPIRIC_ATTACK;
                params = StatsSet.simpleStatsSet("chance", this.parseTableNumber(element.attributeValue("chance"), arg).doubleValue());
                this.attachFunc(element, stat, template, "Absorb", params, arg);
                continue;
            }
            StatsSet params2 = new StatsSet();
            Stats stat2 = Stats.valueOfXml(elementName.replaceFirst("^p_", ""));
            StatModifierType type = StatModifierType.valueOfXml(this.parseTableString(element.attributeValue("type"), arg));
            params2.set("mode", type);
            this.attachFunc(element, stat2, template, "New", params2, arg);
        }
    }

    protected void parseTriggers(Element f, StatTemplate triggerable, int ... arg) {
        Iterator iterator = f.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int id = this.parseTableNumber(element.attributeValue("id"), arg).intValue();
            int level = this.parseTableNumber(element.attributeValue("level"), arg).intValue();
            if (id <= 0 || level <= 0) continue;
            TriggerType t = TriggerType.valueOf(this.parseTableString(element.attributeValue("type"), arg));
            double chance = element.attributeValue("chance") == null ? 100.0 : this.parseTableNumber(element.attributeValue("chance"), arg).doubleValue();
            boolean increasing = element.attributeValue("increasing") != null && this.parseTableBoolean(element.attributeValue("increasing"), new int[0]);
            int delay = element.attributeValue("delay") != null ? this.parseTableNumber(element.attributeValue("delay"), arg).intValue() * 1000 : 0;
            boolean cancel = element.attributeValue("cancel_effects_on_remove") != null && this.parseTableBoolean(element.attributeValue("cancel_effects_on_remove"), new int[0]);
            String args = element.attributeValue("args") != null ? element.attributeValue("args") : "";
            TriggerInfo trigger = new TriggerInfo(id, level, t, chance, increasing, delay, cancel, args);
            Condition condition = this.parseFirstCond(element, arg);
            if (condition != null) {
                trigger.addCondition(condition);
            }
            triggerable.addTrigger(trigger);
        }
    }

    protected void attachFunc(Element n, Stats stat, StatTemplate template, String name, StatsSet params, int ... arg) {
        params.set("stat", stat);
        params.set("function", name);
        params.set("condition", this.parseFirstCond(n, arg));
        String valueStr = n.attributeValue("value");
        if (valueStr != null) {
            params.set("value", this.parseTableNumber(valueStr, arg).doubleValue());
        }
        template.attachFunc(FuncTemplate.makeTemplate(params));
    }

    protected void attachFunc(Element n, int defaultOrder, StatTemplate template, String name, int ... arg) {
        StatsSet params = new StatsSet();
        Stats stat = Stats.valueOfXml(n.attributeValue("stat"));
        String order = n.attributeValue("order");
        params.set("order", order == null ? defaultOrder : this.parseTableNumber(order, arg).intValue());
        this.attachFunc(n, stat, template, name, params, arg);
    }

    protected final Object parseTableValue(Object object, int ... arg) {
        if (object == null) {
            return null;
        }
        String value = String.valueOf(object);
        if (value.isEmpty()) {
            return object;
        }
        if (value.contains("#")) {
            StringBuilder sb = new StringBuilder();
            Matcher m = TABLE_PATTERN.matcher(value);
            while (m.find()) {
                String temp = m.group(1);
                if (temp == null || temp.isEmpty()) continue;
                if (temp.charAt(0) == '#') {
                    sb.append(this.getTableValue(temp, arg));
                } else {
                    sb.append(temp);
                }
                if ((temp = m.group(2)) == null || temp.isEmpty()) continue;
                sb.append(temp);
            }
            return sb.toString();
        }
        return object;
    }

    protected final String parseTableString(Object object, int ... arg) {
        object = this.parseTableValue(object, arg);
        return String.valueOf(object);
    }

    protected final boolean parseTableBoolean(Object object, int ... arg) {
        return Boolean.parseBoolean(this.parseTableString(object, arg));
    }

    protected final Number parseTableNumber(String value, int ... arg) {
        value = this.parseTableString(value, arg);
        try {
            if (value.equalsIgnoreCase("max")) {
                return Double.POSITIVE_INFINITY;
            }
            if (value.equalsIgnoreCase("min")) {
                return Double.NEGATIVE_INFINITY;
            }
            if (value.indexOf(46) == -1) {
                int radix = 10;
                if (value.length() > 2 && value.substring(0, 2).equalsIgnoreCase("0x")) {
                    value = value.substring(2);
                    radix = 16;
                }
                return Integer.valueOf(value, radix);
            }
            return Double.valueOf(value);
        }
        catch (NumberFormatException e) {
            this.warn("Error while parsing number: " + value, e);
            return null;
        }
    }

    protected abstract Object getTableValue(String var1, int ... var2);
}

