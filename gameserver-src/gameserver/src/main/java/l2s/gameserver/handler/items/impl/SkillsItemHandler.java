/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.ArrayUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.handler.items.impl;

import l2s.gameserver.Config;
import l2s.gameserver.handler.items.impl.DefaultItemHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.utils.ItemFunctions;
import org.apache.commons.lang3.ArrayUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SkillsItemHandler
extends DefaultItemHandler {
    private static final Logger LOGGER = LoggerFactory.getLogger(SkillsItemHandler.class);

    @Override
    public void attachSkill(ItemTemplate itemTemplate, Skill skill) {
        boolean haveNoAltSkill = false;
        for (SkillEntry skillEntry : itemTemplate.getAttachedSkills()) {
            if (skillEntry.isAltUse()) continue;
            haveNoAltSkill = true;
            break;
        }
        if (!skill.isAltUse(SkillEntryType.CUNSUMABLE_ITEM) && haveNoAltSkill) {
            LOGGER.warn(String.format("Item ID[%d] already has a \"no-alt\" skill: ID[%d] LEVEL[%d] that can lead to malfunction of item!", itemTemplate.getItemId(), skill.getId(), skill.getLevel()));
        }
        itemTemplate.addAttachedSkill(SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, skill));
    }

    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        PetInstance pet;
        if (!playable.isPlayer() && !playable.isPet()) {
            return false;
        }
        if (playable.isPet() && !(pet = (PetInstance)playable).isMyFeed(item.getItemId()) && !ArrayUtils.contains((int[])Config.ALT_ALLOWED_PET_POTIONS, (int)item.getItemId())) {
            if (pet.getPlayer() != null) {
                pet.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_CANNOT_CARRY_THIS_ITEM);
            }
            return false;
        }
        boolean sendMessage = false;
        SkillEntry[] skills = item.getTemplate().getAttachedSkills();
        for (int i = 0; i < skills.length; ++i) {
            SkillEntry skillEntry = skills[i];
            Creature aimingTarget = skillEntry.getTemplate().getAimingTarget(playable, playable.getTarget());
            if (skillEntry.checkCondition(playable, aimingTarget, ctrl, false, true)) {
                if (!playable.getAI().Cast(skillEntry, aimingTarget, ctrl, false)) {
                    return false;
                }
                if (skillEntry.isAltUse()) continue;
                sendMessage = true;
                continue;
            }
            if (i != 0) continue;
            return false;
        }
        if (this.reduceAfterUse()) {
            ItemFunctions.deleteItem(playable, item, 1L, sendMessage);
        }
        return true;
    }

    public boolean reduceAfterUse() {
        return false;
    }
}

