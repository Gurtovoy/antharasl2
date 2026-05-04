/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.listener.actor.player.impl.ReviveAnswerListener;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.TeleportPoint;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.entity.residence.ResidenceFunction;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.DiePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.TeleportUtils;
import org.napile.primitive.pair.IntObjectPair;

public class RequestRestartPoint
extends L2GameClientPacket {
    private RestartType _restartType;

    @Override
    protected boolean readImpl() {
        this._restartType = (RestartType)((Object)ArrayUtils.valid((Object[])RestartType.VALUES, (int)this.readD()));
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (this._restartType == null || activeChar == null) {
            return;
        }
        if (activeChar.isFakeDeath()) {
            activeChar.breakFakeDeath();
            return;
        }
        if (!activeChar.isDead() && !activeChar.isGM()) {
            activeChar.sendActionFailed();
            return;
        }
        RequestRestartPoint.requestRestart(activeChar, this._restartType);
    }

    public static void requestRestart(Player activeChar, RestartType restartType) {
        switch (restartType) {
            case ADVENTURES_SONG: {
                if (activeChar.getAbnormalList().contains(22410) || activeChar.getAbnormalList().contains(22411)) {
                    activeChar.getAbnormalList().stop(22410);
                    activeChar.getAbnormalList().stop(22411);
                    activeChar.doRevive(100.0);
                    break;
                }
                activeChar.sendPacket(ActionFailPacket.STATIC, new DiePacket(activeChar));
                break;
            }
            case AGATHION: {
                if (activeChar.isAgathionResAvailable()) {
                    activeChar.doRevive(100.0);
                    break;
                }
                activeChar.sendPacket(ActionFailPacket.STATIC, new DiePacket(activeChar));
                break;
            }
            case FIXED: {
                if (activeChar.getPlayerAccess().ResurectFixed) {
                    activeChar.doRevive(100.0);
                    break;
                }
                if (!RequestRestartPoint.checkFeatherOfBlessingAvailable(activeChar)) break;
                if (ItemFunctions.deleteItem((Playable)activeChar, 10649, 1L, true) || ItemFunctions.deleteItem((Playable)activeChar, 29148, 1L, true)) {
                    SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 7008, 1);
                    if (skillEntry == null) break;
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_USED_THE_FEATHER_OF_BLESSING_TO_RESURRECT);
                    activeChar.doRevive(100.0);
                    skillEntry.getEffects(activeChar, activeChar);
                    break;
                }
                activeChar.sendPacket(ActionFailPacket.STATIC, new DiePacket(activeChar));
                break;
            }
            default: {
                TeleportPoint teleportPoint = null;
                Reflection ref = activeChar.getReflection();
                if (ref.isMain()) {
                    for (Event e : activeChar.getEvents()) {
                        Location loc = e.getRestartLoc(activeChar, restartType);
                        if (loc == null) continue;
                        teleportPoint = new TeleportPoint(loc, ref);
                    }
                }
                if (teleportPoint == null) {
                    teleportPoint = RequestRestartPoint.defaultPoint(restartType, activeChar);
                }
                if (teleportPoint != null) {
                    IntObjectPair<OnAnswerListener> ask = activeChar.getAskListener(false);
                    if (ask != null && ask.getValue() instanceof ReviveAnswerListener && !((ReviveAnswerListener)ask.getValue()).isForPet()) {
                        activeChar.getAskListener(true);
                    }
                    activeChar.setPendingRevive(true);
                    activeChar.teleToLocation((ILocation)teleportPoint.getLoc(), teleportPoint.getReflection());
                    break;
                }
                activeChar.sendPacket(ActionFailPacket.STATIC, new DiePacket(activeChar));
            }
        }
    }

    private static boolean checkFeatherOfBlessingAvailable(Player player) {
        if (player.getAbnormalList().contains(7008)) {
            return false;
        }
        if (ItemFunctions.haveItem(player, 10649, 1L)) {
            return true;
        }
        return ItemFunctions.haveItem(player, 29148, 1L);
    }

    public static TeleportPoint defaultPoint(RestartType restartType, Player activeChar) {
        TeleportPoint teleportPoint = null;
        Clan clan = activeChar.getClan();
        switch (restartType) {
            case TO_CLANHALL: {
                if (clan == null || clan.getHasHideout() == 0) break;
                ClanHall clanHall = activeChar.getClanHall();
                teleportPoint = TeleportUtils.getRestartPoint(activeChar, RestartType.TO_CLANHALL);
                ResidenceFunction function = clanHall.getActiveFunction(ResidenceFunctionType.RESTORE_EXP);
                if (function == null) break;
                activeChar.restoreExp(function.getTemplate().getExpRestore() * 100.0);
                break;
            }
            case TO_CASTLE: {
                if (clan == null || clan.getCastle() == 0) break;
                Castle castle = activeChar.getCastle();
                teleportPoint = TeleportUtils.getRestartPoint(activeChar, RestartType.TO_CASTLE);
                ResidenceFunction function = castle.getActiveFunction(ResidenceFunctionType.RESTORE_EXP);
                if (function == null) break;
                activeChar.restoreExp(function.getTemplate().getExpRestore() * 100.0);
                break;
            }
            default: {
                teleportPoint = TeleportUtils.getRestartPoint(activeChar, RestartType.TO_VILLAGE);
            }
        }
        return teleportPoint;
    }
}

