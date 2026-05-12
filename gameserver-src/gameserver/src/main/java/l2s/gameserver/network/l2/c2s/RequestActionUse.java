package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.instancemanager.BotReportManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.PetType;
import l2s.gameserver.model.instances.ChairInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.PetBabyInstance;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.instances.residences.SiegeFlagInstance;
import l2s.gameserver.model.instances.residences.SiegeToggleNpcInstance;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.ExAskCoupleAction;
import l2s.gameserver.network.l2.s2c.ExInzoneWaitingInfo;
import l2s.gameserver.network.l2.s2c.PrivateStoreBuyManageList;
import l2s.gameserver.network.l2.s2c.PrivateStoreManageList;
import l2s.gameserver.network.l2.s2c.RecipeShopManageListPacket;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.utils.TradeHelper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestActionUse
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestActionUse.class);
    private int _actionId;
    private boolean _ctrlPressed;
    private boolean _shiftPressed;

    @Override
    protected boolean readImpl() {
        this._actionId = this.readD();
        this._ctrlPressed = this.readD() == 1;
        this._shiftPressed = this.readC() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Action action = Action.find(this._actionId);
        if (action == null) {
            _log.warn("unhandled action type " + this._actionId + " by player " + activeChar.getName());
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isTransformed() && !activeChar.getTransform().haveAction(action.id)) {
            activeChar.sendActionFailed();
            return;
        }
        if (action.type == 0) {
            if (!(!activeChar.isOutOfControl() && !activeChar.isActionsDisabled() || activeChar.isFakeDeath() && this._actionId == 0)) {
                activeChar.sendActionFailed();
                return;
            }
            GameObject target = activeChar.getTarget();
            switch (action.id) {
                case 0: {
                    if (activeChar.isMounted()) {
                        activeChar.sendActionFailed();
                        break;
                    }
                    if (activeChar.isFakeDeath()) {
                        activeChar.breakFakeDeath();
                        activeChar.updateAbnormalIcons();
                        break;
                    }
                    if (!activeChar.isSitting()) {
                        if (target != null && target instanceof ChairInstance && ((ChairInstance)target).canSit(activeChar)) {
                            activeChar.sitDown((ChairInstance)target);
                            break;
                        }
                        activeChar.sitDown(null);
                        break;
                    }
                    activeChar.standUp();
                    break;
                }
                case 1: {
                    if (activeChar.isRunning()) {
                        activeChar.setWalking();
                    } else {
                        activeChar.setRunning();
                    }
                    activeChar.sendUserInfo(true);
                    break;
                }
                case 10: 
                case 61: {
                    if (activeChar.getSittingTask()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.isInStoreMode()) {
                        activeChar.setPrivateStoreType(0);
                        activeChar.storePrivateStore();
                        activeChar.standUp();
                        activeChar.broadcastCharInfo();
                    } else if (!TradeHelper.checksIfCanOpenStore(activeChar, this._actionId == 61 ? 8 : 1)) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    activeChar.sendPacket((IBroadcastPacket)new PrivateStoreManageList(1, activeChar, this._actionId == 61));
                    activeChar.sendPacket((IBroadcastPacket)new PrivateStoreManageList(2, activeChar, this._actionId == 61));
                    break;
                }
                case 28: {
                    if (activeChar.getSittingTask()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.isInStoreMode()) {
                        activeChar.setPrivateStoreType(0);
                        activeChar.storePrivateStore();
                        activeChar.standUp();
                        activeChar.broadcastCharInfo();
                    } else if (!TradeHelper.checksIfCanOpenStore(activeChar, 3)) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    activeChar.sendPacket((IBroadcastPacket)new PrivateStoreBuyManageList(1, activeChar));
                    activeChar.sendPacket((IBroadcastPacket)new PrivateStoreBuyManageList(2, activeChar));
                    break;
                }
                case 37: {
                    if (activeChar.getSittingTask()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.getDwarvenRecipeBook().isEmpty()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.isInStoreMode()) {
                        activeChar.setPrivateStoreType(0);
                        activeChar.storePrivateStore();
                        activeChar.standUp();
                        activeChar.broadcastCharInfo();
                    } else if (!TradeHelper.checksIfCanOpenStore(activeChar, 5)) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    activeChar.sendPacket((IBroadcastPacket)new RecipeShopManageListPacket(activeChar, true));
                    break;
                }
                case 51: {
                    if (activeChar.getSittingTask()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.getCommonRecipeBook().isEmpty()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.isInStoreMode()) {
                        activeChar.setPrivateStoreType(0);
                        activeChar.storePrivateStore();
                        activeChar.standUp();
                        activeChar.broadcastCharInfo();
                    } else if (!TradeHelper.checksIfCanOpenStore(activeChar, 5)) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    activeChar.sendPacket((IBroadcastPacket)new RecipeShopManageListPacket(activeChar, false));
                    break;
                }
                case 96: {
                    _log.info("96 Accessed");
                    break;
                }
                case 97: {
                    _log.info("97 Accessed");
                    break;
                }
                case 38: {
                    PetInstance pet = activeChar.getPet();
                    if (activeChar.isTransformed()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (pet == null || !pet.isMountable()) {
                        if (!activeChar.isMounted()) break;
                        if (activeChar.getMount().isHungry()) {
                            return;
                        }
                        if (activeChar.isFlying() && !activeChar.checkLandingState()) {
                            activeChar.sendPacket(SystemMsg.YOU_ARE_NOT_ALLOWED_TO_DISMOUNT_IN_THIS_LOCATION, ActionFailPacket.STATIC);
                            return;
                        }
                        activeChar.setMount(null);
                        break;
                    }
                    if (activeChar.isMounted() || activeChar.isInBoat()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isDead()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (pet.isDead()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_DEAD_STRIDER_CANNOT_BE_RIDDEN);
                        break;
                    }
                    if (activeChar.isInDuel()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isInCombat() || pet.isInCombat()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isInTrainingCamp()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isSitting()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isFishing()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.getActiveWeaponFlagAttachment() != null) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isCastingNow()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (activeChar.isDecontrolled()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_BOARD_BECAUSE_YOU_DO_NOT_MEET_THE_REQUIREMENTS);
                        break;
                    }
                    if (pet.isHungry()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_HUNGRY_STRIDER_CANNOT_BE_MOUNTED_OR_DISMOUNTED);
                        break;
                    }
                    activeChar.getAbnormalList().stop(5239);
                    activeChar.setMount(pet.getControlItemObjId(), pet.getNpcId(), pet.getLevel(), pet.getCurrentFed());
                    pet.unSummon(false);
                    break;
                }
                case 65: {
                    BotReportManager.getInstance().reportBot(activeChar);
                    break;
                }
                case 76: {
                    if (target == null) {
                        return;
                    }
                    IBroadcastPacket msg = activeChar.getFriendList().requestFriendInvite(target);
                    if (msg == null) break;
                    activeChar.sendPacket(msg);
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_FAILED_TO_ADD_A_FRIEND_TO_YOUR_FRIENDS_LIST);
                    break;
                }
                case 78: {
                    this.changeTacticalSign(activeChar, 1, target);
                    break;
                }
                case 79: {
                    this.changeTacticalSign(activeChar, 2, target);
                    break;
                }
                case 80: {
                    this.changeTacticalSign(activeChar, 3, target);
                    break;
                }
                case 81: {
                    this.changeTacticalSign(activeChar, 4, target);
                    break;
                }
                case 82: {
                    this.findTacticalTarget(activeChar, 1);
                    break;
                }
                case 83: {
                    this.findTacticalTarget(activeChar, 2);
                    break;
                }
                case 84: {
                    this.findTacticalTarget(activeChar, 3);
                    break;
                }
                case 85: {
                    this.findTacticalTarget(activeChar, 4);
                    break;
                }
                case 90: {
                    activeChar.sendPacket((IBroadcastPacket)new ExInzoneWaitingInfo(activeChar, true));
                    break;
                }
                default: {
                    _log.warn("unhandled action type " + this._actionId + " by player " + activeChar.getName());
                }
            }
            return;
        }
        if (action.type == 1) {
            if (activeChar.isDead()) {
                activeChar.sendActionFailed();
                return;
            }
            PetInstance pet = activeChar.getPet();
            if (pet == null || pet.isOutOfControl()) {
                activeChar.sendActionFailed();
                return;
            }
            if (action.value > 0) {
                if (!this.servitorUseSkill(activeChar, pet, action.value, action.id)) {
                    activeChar.sendActionFailed();
                }
                return;
            }
            if (pet.isDepressed()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PETSERVITOR_IS_UNRESPONSIVE_AND_WILL_NOT_OBEY_ANY_ORDERS);
                return;
            }
            GameObject target = activeChar.getTarget();
            switch (action.id) {
                case 15: {
                    pet.setFollowMode(!pet.isFollowMode());
                    break;
                }
                case 16: {
                    if (target == null || !target.isCreature() || target == activeChar || pet == target || pet.isDead()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.isInOlympiadMode() && !activeChar.isOlympiadCompStart()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (pet.getData().isOfType(PetType.KARMA)) {
                        return;
                    }
                    if (pet.isNotControlled()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_IS_TOO_HIGH_LEVEL_TO_CONTROL);
                        return;
                    }
                    pet.getAI().Attack(target, this._ctrlPressed, this._shiftPressed);
                    break;
                }
                case 17: {
                    pet.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    break;
                }
                case 19: {
                    if (pet.isDead()) {
                        activeChar.sendPacket(SystemMsg.DEAD_PETS_CANNOT_BE_RETURNED_TO_THEIR_SUMMONING_ITEM, ActionFailPacket.STATIC);
                        return;
                    }
                    if (pet.isInCombat()) {
                        activeChar.sendPacket(SystemMsg.A_PET_CANNOT_BE_UNSUMMONED_DURING_BATTLE, ActionFailPacket.STATIC);
                        break;
                    }
                    if (pet.isHungry()) {
                        activeChar.sendPacket(SystemMsg.YOU_MAY_NOT_RESTORE_A_HUNGRY_PET, ActionFailPacket.STATIC);
                        break;
                    }
                    pet.unSummon(false);
                    break;
                }
                case 54: {
                    if (target == null || pet == target || pet.isMovementDisabled()) break;
                    pet.setFollowMode(false);
                    pet.getMovement().moveToLocation(target.getLoc(), 100, true);
                    break;
                }
                case 1070: {
                    if (!(pet instanceof PetBabyInstance)) break;
                    ((PetBabyInstance)pet).triggerBuff();
                    break;
                }
                default: {
                    _log.warn("unhandled action type " + this._actionId + " by player " + activeChar.getName());
                }
            }
            return;
        }
        if (action.type == 2 || action.type == 5) {
            if (activeChar.isDead()) {
                activeChar.sendActionFailed();
                return;
            }
            SummonInstance summon = activeChar.getSummon();
            if (summon == null || summon.isOutOfControl()) {
                activeChar.sendActionFailed();
                return;
            }
            GameObject target = activeChar.getTarget();
            if (action.value > 0) {
                if (action.id == 1000 && target != null && !target.isDoor() && !(target instanceof SiegeToggleNpcInstance)) {
                    activeChar.sendActionFailed();
                    return;
                }
                if ((action.id == 1039 || action.id == 1040) && (target.isDoor() || target instanceof SiegeFlagInstance)) {
                    activeChar.sendActionFailed();
                    return;
                }
                if (!this.servitorUseSkill(activeChar, summon, action.value, action.id)) {
                    activeChar.sendActionFailed();
                }
                return;
            }
            if (summon.isDepressed()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PETSERVITOR_IS_UNRESPONSIVE_AND_WILL_NOT_OBEY_ANY_ORDERS);
                return;
            }
            switch (action.id) {
                case 21: {
                    summon.setFollowMode(!summon.isFollowMode());
                    break;
                }
                case 22: 
                case 1099: {
                    if (target == null || !target.isCreature() || target == activeChar || summon == target || summon.isDead()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    if (activeChar.isInOlympiadMode() && !activeChar.isOlympiadCompStart()) {
                        activeChar.sendActionFailed();
                        return;
                    }
                    summon.getAI().Attack(target, this._ctrlPressed, this._shiftPressed);
                    break;
                }
                case 23: {
                    summon.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    summon.setFollowMode(true);
                    break;
                }
                case 52: {
                    if (summon.isInCombat()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_PET_CANNOT_BE_UNSUMMONED_DURING_BATTLE);
                        activeChar.sendActionFailed();
                        break;
                    }
                    summon.unSummon(false);
                    break;
                }
                case 53: {
                    if (target == null || summon == target || summon.isMovementDisabled()) break;
                    summon.setFollowMode(false);
                    summon.getMovement().moveToLocation(target.getLoc(), 100, true);
                    break;
                }
                case 1100: {
                    if (target == null || summon == target || summon.isMovementDisabled()) break;
                    summon.setFollowMode(false);
                    summon.getMovement().moveToLocation(target.getLoc(), 100, true);
                    break;
                }
                case 1101: {
                    summon.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    summon.setFollowMode(true);
                    break;
                }
                case 1102: {
                    if (summon.isInCombat()) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_PET_CANNOT_BE_UNSUMMONED_DURING_BATTLE);
                        activeChar.sendActionFailed();
                        break;
                    }
                    summon.unSummon(false);
                    break;
                }
                case 1103: {
                    summon.getAI().notifyAttackModeChange(Servitor.AttackMode.PASSIVE);
                    break;
                }
                case 1104: {
                    summon.getAI().notifyAttackModeChange(Servitor.AttackMode.DEFENCE);
                    break;
                }
                default: {
                    _log.warn("unhandled action type " + this._actionId + " by player " + activeChar.getName());
                }
            }
            return;
        }
        if (action.type == 3) {
            Object npc;
            if (activeChar.isOutOfControl() || activeChar.isTransformed() || activeChar.isActionsDisabled() || activeChar.isSitting() || activeChar.getPrivateStoreType() != 0 || activeChar.isProcessingRequest()) {
                activeChar.sendActionFailed();
                return;
            }
            if (activeChar.isFishing()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING_2);
                return;
            }
            if (activeChar.isInTrainingCamp()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
                return;
            }
            activeChar.broadcastPacket(new SocialActionPacket(activeChar.getObjectId(), action.value));
            if (Config.ALT_SOCIAL_ACTION_REUSE) {
                ThreadPoolManager.getInstance().schedule(new SocialTask(activeChar), 2600L);
                activeChar.getFlags().getParalyzed().start();
            }
            activeChar.getListeners().onSocialAction(action);
            GameObject target = activeChar.getTarget();
            if (target != null && target.isNpc() && activeChar.checkInteractionDistance((GameObject)(npc = (NpcInstance)target))) {
                ((NpcInstance)npc).onSeeSocialAction(activeChar, action.value);
            }
            for (QuestState state : activeChar.getAllQuestsStates()) {
                state.getQuest().notifySocialActionUse(state, action.value);
            }
            return;
        }
        if (action.type == 4) {
            if (activeChar.isOutOfControl() || activeChar.isActionsDisabled() || activeChar.isSitting()) {
                activeChar.sendActionFailed();
                return;
            }
            GameObject target = activeChar.getTarget();
            if (target == null || !target.isPlayer()) {
                activeChar.sendActionFailed();
                return;
            }
            Player pcTarget = target.getPlayer();
            if (pcTarget.isProcessingRequest() && pcTarget.getRequest().isTypeOf(Request.L2RequestType.COUPLE_ACTION)) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ALREADY_PARTICIPATING_IN_A_COUPLE_ACTION_AND_CANNOT_BE_REQUESTED_FOR_ANOTHER_COUPLE_ACTION).addName(pcTarget));
                return;
            }
            if (pcTarget.isProcessingRequest()) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addName(pcTarget));
                return;
            }
            if (!activeChar.isInRange(pcTarget, 300) || activeChar.isInRange(pcTarget, 25) || activeChar.getTargetId() == activeChar.getObjectId() || !GeoEngine.canSeeTarget(activeChar, pcTarget)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_REQUEST_CANNOT_BE_COMPLETED_BECAUSE_THE_TARGET_DOES_NOT_MEET_LOCATION_REQUIREMENTS);
                return;
            }
            if (!activeChar.checkCoupleAction(pcTarget)) {
                return;
            }
            new Request(Request.L2RequestType.COUPLE_ACTION, activeChar, pcTarget).setTimeout(10000L);
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_REQUESTED_A_COUPLE_ACTION_WITH_C1).addName(pcTarget));
            pcTarget.sendPacket((IBroadcastPacket)new ExAskCoupleAction(activeChar.getObjectId(), action.value));
            if (Config.ALT_SOCIAL_ACTION_REUSE) {
                ThreadPoolManager.getInstance().schedule(new SocialTask(activeChar), 2600L);
                activeChar.getFlags().getParalyzed().start();
            }
            return;
        }
        activeChar.sendActionFailed();
    }

    private void summonsUseSkill(Player player, int skillId, int actionId) {
        if (player.hasSummon()) {
            SummonInstance s = player.getSummon();
            if (s == null || s.isOutOfControl()) {
                return;
            }
            if (s.isDepressed()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PETSERVITOR_IS_UNRESPONSIVE_AND_WILL_NOT_OBEY_ANY_ORDERS);
                return;
            }
            this.servitorUseSkill(player, s, skillId, actionId);
        } else {
            player.sendActionFailed();
        }
    }

    private boolean servitorUseSkill(Player player, Servitor servitor, int skillId, int actionId) {
        int npcId;
        if (servitor == null) {
            return false;
        }
        int skillLevel = servitor.getActiveSkillLevel(skillId);
        if (skillLevel == 0) {
            return false;
        }
        Skill skill = SkillHolder.getInstance().getSkill(skillId, skillLevel);
        if (skill == null) {
            return false;
        }
        if (servitor.isDepressed()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PETSERVITOR_IS_UNRESPONSIVE_AND_WILL_NOT_OBEY_ANY_ORDERS);
            return false;
        }
        if (servitor.isNotControlled()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_IS_TOO_HIGH_LEVEL_TO_CONTROL);
            return false;
        }
        if (!(skill.getId() == 6054 || (npcId = servitor.getNpcId()) != 16051 && npcId != 16052 && npcId != 16053 && npcId != 1601 && npcId != 1602 && npcId != 1603 && npcId != 1562 && npcId != 1563 && npcId != 1564 && npcId != 1565 && npcId != 1566 && npcId != 1567 && npcId != 1568 && npcId != 1569 && npcId != 1570 && npcId != 1571 && npcId != 1572 && npcId != 1573 || servitor.getAbnormalList().contains(6054))) {
            player.sendPacket((IBroadcastPacket)SystemMsg.A_PET_ON_AUXILIARY_MODE_CANNOT_USE_SKILLS);
            return false;
        }
        if (skill.isToggle() && servitor.getAbnormalList().contains(skill)) {
            if (skill.isNecessaryToggle()) {
                servitor.getAbnormalList().stop(skill.getId());
            }
            return true;
        }
        SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.SERVITOR, skill);
        if (skillEntry == null) {
            return false;
        }
        Creature aimingTarget = skill.getAimingTarget(servitor, player.getTarget());
        if (!skill.checkCondition(skillEntry, servitor, aimingTarget, this._ctrlPressed, this._shiftPressed, true)) {
            return false;
        }
        servitor.setUsedSkill(skill, actionId);
        servitor.getAI().Cast(skillEntry, aimingTarget, this._ctrlPressed, this._shiftPressed);
        return true;
    }

    private void changeTacticalSign(Player player, int sign, GameObject target) {
        if (!player.isInParty()) {
            return;
        }
        if (target == null || !target.isCreature() || !target.isTargetable(player)) {
            return;
        }
        player.getParty().changeTacticalSign(player, sign, (Creature)target);
    }

    private void findTacticalTarget(Player player, int sign) {
        if (!player.isInParty()) {
            return;
        }
        Creature target = player.getParty().findTacticalTarget(player, sign);
        if (target == null || target.isAlikeDead() || !target.isTargetable(player)) {
            return;
        }
        player.setTarget(target);
    }

    static class SocialTask
    implements Runnable {
        Player _player;

        SocialTask(Player player) {
            this._player = player;
        }

        @Override
        public void run() {
            this._player.getFlags().getParalyzed().stop();
        }
    }

    public static enum Action {
        ACTION0(0, 0, 0),
        ACTION1(1, 0, 0),
        ACTION7(7, 0, 0),
        ACTION10(10, 0, 0),
        ACTION28(28, 0, 0),
        ACTION37(37, 0, 0),
        ACTION38(38, 0, 0),
        ACTION51(51, 0, 0),
        ACTION61(61, 0, 0),
        ACTION96(96, 0, 0),
        ACTION97(97, 0, 0),
        ACTION65(65, 0, 0),
        ACTION76(76, 0, 0),
        ACTION78(78, 0, 0),
        ACTION79(79, 0, 0),
        ACTION80(80, 0, 0),
        ACTION81(81, 0, 0),
        ACTION82(82, 0, 0),
        ACTION83(83, 0, 0),
        ACTION84(84, 0, 0),
        ACTION85(85, 0, 0),
        ACTION86(86, 0, 0),
        ACTION90(90, 0, 0),
        ACTION15(15, 1, 0),
        ACTION16(16, 1, 0),
        ACTION17(17, 1, 0),
        ACTION19(19, 1, 0),
        ACTION53(54, 1, 0),
        ACTION1001(1001, 1, 0),
        ACTION1003(1003, 1, 4710),
        ACTION1004(1004, 1, 4711),
        ACTION1005(1005, 1, 4712),
        ACTION1006(1006, 1, 4713),
        ACTION1041(1041, 1, 5442),
        ACTION1042(1042, 1, 5444),
        ACTION1043(1043, 1, 5443),
        ACTION1044(1044, 1, 5445),
        ACTION1045(1045, 1, 5584),
        ACTION1046(1046, 1, 5585),
        ACTION1061(1061, 1, 5745),
        ACTION1062(1062, 1, 5746),
        ACTION1063(1063, 1, 5747),
        ACTION1064(1064, 1, 5748),
        ACTION1065(1065, 1, 5753),
        ACTION1066(1066, 1, 5749),
        ACTION1067(1067, 1, 5750),
        ACTION1068(1068, 1, 5751),
        ACTION1069(1069, 1, 5752),
        ACTION1070(1070, 1, 5771),
        ACTION1071(1071, 1, 5761),
        ACTION1072(1072, 1, 6046),
        ACTION1073(1073, 1, 6047),
        ACTION1074(1074, 1, 6048),
        ACTION1075(1075, 1, 6049),
        ACTION1076(1076, 1, 6050),
        ACTION1077(1077, 1, 6051),
        ACTION1078(1078, 1, 6052),
        ACTION1079(1079, 1, 6053),
        ACTION1084(1084, 1, 6054),
        ACTION1089(1089, 1, 6199),
        ACTION1090(1090, 1, 6205),
        ACTION1091(1091, 1, 6206),
        ACTION1092(1092, 1, 6207),
        ACTION1093(1093, 1, 6618),
        ACTION1094(1094, 1, 6681),
        ACTION1095(1095, 1, 6619),
        ACTION1096(1096, 1, 6682),
        ACTION1097(1097, 1, 6683),
        ACTION1098(1098, 1, 6684),
        ACTION5000(5000, 1, 23155),
        ACTION5001(5001, 1, 23167),
        ACTION5002(5002, 1, 23168),
        ACTION5003(5003, 1, 5749),
        ACTION5004(5004, 1, 5750),
        ACTION5005(5005, 1, 5751),
        ACTION5006(5006, 1, 5771),
        ACTION5007(5007, 1, 6046),
        ACTION5008(5008, 1, 6047),
        ACTION5009(5009, 1, 6048),
        ACTION5010(5010, 1, 6049),
        ACTION5011(5011, 1, 6050),
        ACTION5012(5012, 1, 6051),
        ACTION5013(5013, 1, 6052),
        ACTION5014(5014, 1, 6053),
        ACTION5015(5015, 1, 6054),
        ACTION5016(5016, 1, 6054),
        ACTION21(21, 2, 0),
        ACTION22(22, 2, 0),
        ACTION23(23, 2, 0),
        ACTION52(52, 2, 0),
        ACTION54(53, 2, 0),
        ACTION32(32, 2, 4230),
        ACTION36(36, 2, 4259),
        ACTION39(39, 2, 4138),
        ACTION41(41, 2, 4230),
        ACTION42(42, 2, 4378),
        ACTION43(43, 2, 4137),
        ACTION44(44, 2, 4139),
        ACTION45(45, 2, 4025),
        ACTION46(46, 2, 4261),
        ACTION47(47, 2, 4260),
        ACTION48(48, 2, 4068),
        ACTION1000(1000, 2, 4079),
        ACTION1002(1002, 2, 0),
        ACTION1007(1007, 2, 4699),
        ACTION1008(1008, 2, 4700),
        ACTION1009(1009, 2, 4701),
        ACTION1010(1010, 2, 4702),
        ACTION1011(1011, 2, 4703),
        ACTION1012(1012, 2, 4704),
        ACTION1013(1013, 2, 4705),
        ACTION1014(1014, 2, 4706),
        ACTION1015(1015, 2, 4707),
        ACTION1016(1016, 2, 4709),
        ACTION1017(1017, 2, 4708),
        ACTION1018(1018, 2, 0),
        ACTION1019(1019, 2, 0),
        ACTION1020(1020, 2, 0),
        ACTION1021(1021, 2, 0),
        ACTION1022(1022, 2, 0),
        ACTION1023(1023, 2, 0),
        ACTION1024(1024, 2, 0),
        ACTION1025(1025, 2, 0),
        ACTION1026(1026, 2, 0),
        ACTION1027(1027, 2, 0),
        ACTION1028(1028, 2, 0),
        ACTION1029(1029, 2, 0),
        ACTION1030(1030, 2, 0),
        ACTION1031(1031, 2, 5135),
        ACTION1032(1032, 2, 5136),
        ACTION1033(1033, 2, 5137),
        ACTION1034(1034, 2, 5138),
        ACTION1035(1035, 2, 5139),
        ACTION1036(1036, 2, 5142),
        ACTION1037(1037, 2, 5141),
        ACTION1038(1038, 2, 5140),
        ACTION1039(1039, 2, 5110),
        ACTION1040(1040, 2, 5111),
        ACTION1047(1047, 2, 5580),
        ACTION1048(1048, 2, 5581),
        ACTION1049(1049, 2, 5582),
        ACTION1050(1050, 2, 5583),
        ACTION1051(1051, 2, 5638),
        ACTION1052(1052, 2, 5639),
        ACTION1053(1053, 2, 5640),
        ACTION1054(1054, 2, 5643),
        ACTION1055(1055, 2, 5647),
        ACTION1056(1056, 2, 5648),
        ACTION1057(1057, 2, 5646),
        ACTION1058(1058, 2, 5652),
        ACTION1059(1059, 2, 5653),
        ACTION1060(1060, 2, 5654),
        ACTION1080(1080, 2, 6041),
        ACTION1081(1081, 2, 6042),
        ACTION1082(1082, 2, 6043),
        ACTION1083(1083, 2, 6044),
        ACTION1086(1086, 2, 6094),
        ACTION1087(1087, 2, 6095),
        ACTION1088(1088, 2, 6096),
        ACTION1113(1113, 2, 10051),
        ACTION1114(1114, 2, 10052),
        ACTION1115(1115, 2, 10053),
        ACTION1116(1116, 2, 10054),
        ACTION1117(1117, 2, 10794),
        ACTION1118(1118, 2, 10795),
        ACTION1120(1120, 2, 10797),
        ACTION1121(1121, 2, 10798),
        ACTION1122(1122, 2, 11806),
        ACTION1123(1123, 2, 14767),
        ACTION1142(1142, 2, 10087),
        ACTION1143(1143, 2, 10088),
        ACTION1099(1099, 5, 0),
        ACTION1100(1100, 5, 0),
        ACTION1101(1101, 5, 0),
        ACTION1102(1102, 5, 0),
        ACTION1103(1103, 5, 0),
        ACTION1104(1104, 5, 0),
        ACTION1106(1106, 5, 11278),
        ACTION1107(1107, 5, 11279),
        ACTION1108(1108, 5, 11280),
        ACTION1109(1109, 5, 11281),
        ACTION1110(1110, 5, 11282),
        ACTION1111(1111, 5, 11283),
        ACTION1124(1124, 5, 11323),
        ACTION1125(1125, 5, 11324),
        ACTION1126(1126, 5, 11325),
        ACTION1127(1127, 5, 11326),
        ACTION1128(1128, 5, 11327),
        ACTION1129(1129, 5, 11328),
        ACTION1130(1130, 5, 11332),
        ACTION1131(1131, 5, 11333),
        ACTION1132(1132, 5, 11334),
        ACTION1133(1133, 5, 11335),
        ACTION1134(1134, 5, 11336),
        ACTION1135(1135, 5, 11337),
        ACTION1136(1136, 5, 11341),
        ACTION1137(1137, 5, 11342),
        ACTION1138(1138, 5, 11343),
        ACTION1139(1139, 5, 11344),
        ACTION1140(1140, 5, 11345),
        ACTION1141(1141, 5, 11346),
        ACTION12(12, 3, 2),
        ACTION13(13, 3, 3),
        ACTION14(14, 3, 4),
        ACTION24(24, 3, 6),
        ACTION25(25, 3, 5),
        ACTION26(26, 3, 7),
        ACTION29(29, 3, 8),
        ACTION30(30, 3, 9),
        ACTION31(31, 3, 10),
        ACTION33(33, 3, 11),
        ACTION34(34, 3, 12),
        ACTION35(35, 3, 13),
        ACTION62(62, 3, 14),
        ACTION66(66, 3, 15),
        ACTION87(87, 3, 28),
        ACTION88(88, 3, 29),
        ACTION89(89, 3, 30),
        ACTION71(71, 4, 16),
        ACTION72(72, 4, 17),
        ACTION73(73, 4, 18);

        public int id;
        public int type;
        public int value;

        private Action(int id, int type, int value) {
            this.id = id;
            this.type = type;
            this.value = value;
        }

        public static Action find(int id) {
            for (Action action : Action.values()) {
                if (action.id != id) continue;
                return action;
            }
            return null;
        }
    }
}

