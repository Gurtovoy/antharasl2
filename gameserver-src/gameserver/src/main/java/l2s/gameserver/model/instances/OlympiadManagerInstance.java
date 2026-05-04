package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.MultiSellHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.olympiad.CompType;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.RequestBypassToServer;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExReceiveOlympiadPacket;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.ItemFunctions;

public class OlympiadManagerInstance
extends NpcInstance {
    public OlympiadManagerInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
        Olympiad.addOlympiadNpc(this);
    }

    @Override
    public void onMenuSelect(Player player, int ask, long reply, int state) {
        if (ask == -50) {
            if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                this.showChatWindow(player, "olympiad/olympiad_operator001.htm", false, new Object[0]);
            } else {
                this.showChatWindow(player, "olympiad/olympiad_operator002.htm", false, new Object[0]);
            }
        } else if (ask == -51) {
            if (!Olympiad.isRegistered(player, false)) {
                if (!Olympiad.isRegistrationActive()) {
                    this.showChatWindow(player, "olympiad/olympiad_operator010p.htm", false, new Object[0]);
                } else if (Olympiad.isClassedBattlesAllowed()) {
                    this.showChatWindow(player, "olympiad/olympiad_operator010a.htm", false, "<?olympiad_round?>", Olympiad.getCurrentCycle(), "<?olympiad_week?>", Olympiad.getCompWeek(), "<?olympiad_participant?>", Olympiad.getParticipantsCount());
                } else {
                    this.showChatWindow(player, "olympiad/olympiad_operator010b.htm", false, "<?olympiad_round?>", Olympiad.getCurrentCycle(), "<?olympiad_week?>", Olympiad.getCompWeek(), "<?olympiad_participant?>", Olympiad.getParticipantsCount());
                }
            } else {
                this.showChatWindow(player, "olympiad/olympiad_operator010n.htm", false, new Object[0]);
            }
        } else if (ask == -52) {
            switch ((int)reply) {
                case 0: {
                    this.showChatWindow(player, "olympiad/olympiad_operator001.htm", false, new Object[0]);
                    break;
                }
                case 1: {
                    this.showChatWindow(player, "olympiad/olympiad_operator010a.htm", false, new Object[0]);
                    break;
                }
                case 2: {
                    this.showChatWindow(player, "olympiad/olympiad_operator010b.htm", false, new Object[0]);
                    break;
                }
                case 3: {
                    int[] waitingCounts = Olympiad.getWaitingList();
                    int classedWaitingCount = waitingCounts[0];
                    int teamWaitingCount = 0;
                    int nonClassedWaitingCount = waitingCounts[0];
                    String WaitingCount = classedWaitingCount < 100 ? HtmlUtils.htmlNpcString(1000504, 100) : HtmlUtils.htmlNpcString(1000505, 100);
                    String TeamWaitingCount = teamWaitingCount < 100 ? HtmlUtils.htmlNpcString(1000504, 100) : HtmlUtils.htmlNpcString(1000505, 100);
                    String ClassFreeWaitingCount = nonClassedWaitingCount < 100 ? HtmlUtils.htmlNpcString(1000504, 100) : HtmlUtils.htmlNpcString(1000505, 100);
                    this.showChatWindow(player, "olympiad/olympiad_operator010f.htm", false, "<?WaitingCount?>", WaitingCount, "<?TeamWaitingCount?>", TeamWaitingCount, "<?ClassFreeWaitingCount?>", ClassFreeWaitingCount);
                    break;
                }
                case 4: {
                    this.showChatWindow(player, "olympiad/olympiad_operator010g.htm", false, new Object[0]);
                    break;
                }
                case 5: {
                    this.showChatWindow(player, "olympiad/olympiad_operator010h.htm", false, "<?WaitingCount?>", Olympiad.getParticipantPoints(player.getObjectId()));
                    break;
                }
                case 6: 
                case 7: {
                    this.showChatWindow(player, "olympiad/olympiad_operator010m.htm", false, new Object[0]);
                }
            }
        } else if (ask == -53) {
            if (reply == 0L) {
                this.showChatWindow(player, "olympiad/olympiad_operator001.htm", false, new Object[0]);
            } else if (reply == 1L) {
                if (player.isBaseClassActive()) {
                    if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                        Olympiad.addParticipant(player);
                        if (Olympiad.getParticipantPoints(player.getObjectId()) > 0) {
                            if (!player.isQuestContinuationPossible(true)) {
                                return;
                            }
                            if (Olympiad.registerParticipant(player, CompType.NON_CLASSED)) {
                                this.showChatWindow(player, "olympiad/olympiad_operator010d.htm", false, new Object[0]);
                            }
                        } else {
                            this.showChatWindow(player, "olympiad/olympiad_operator010i.htm", false, new Object[0]);
                        }
                    } else {
                        this.showChatWindow(player, "olympiad/olympiad_operator010j.htm", false, new Object[0]);
                    }
                } else {
                    this.showChatWindow(player, "olympiad/olympiad_operator010c.htm", false, new Object[0]);
                }
            }
        } else if (ask == -54) {
            if (reply == 0L) {
                this.showChatWindow(player, "olympiad/olympiad_operator001.htm", false, new Object[0]);
            } else if (reply == 1L) {
                if (player.isBaseClassActive()) {
                    if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                        Olympiad.addParticipant(player);
                        if (Olympiad.getParticipantPoints(player.getObjectId()) > 0) {
                            if (!player.isQuestContinuationPossible(true)) {
                                return;
                            }
                            if (Olympiad.registerParticipant(player, CompType.CLASSED)) {
                                this.showChatWindow(player, "olympiad/olympiad_operator010e.htm", false, new Object[0]);
                            }
                        } else {
                            this.showChatWindow(player, "olympiad/olympiad_operator010i.htm", false, new Object[0]);
                        }
                    } else {
                        this.showChatWindow(player, "olympiad/olympiad_operator010j.htm", false, new Object[0]);
                    }
                } else {
                    this.showChatWindow(player, "olympiad/olympiad_operator010c.htm", false, new Object[0]);
                }
            }
        } else if (ask == -55) {
            this.showChatWindow(player, "olympiad/olympiad_operator030.htm", false, new Object[0]);
        } else if (ask != -56 && ask != -57) {
            if (ask == -58) {
                Olympiad.unregisterParticipant(player);
            } else if (ask == -60) {
                if (reply == 0L) {
                    if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                        this.showChatWindow(player, "olympiad/olympiad_operator001.htm", false, new Object[0]);
                    } else {
                        this.showChatWindow(player, "olympiad/olympiad_operator002.htm", false, new Object[0]);
                    }
                }
            } else if (ask == -61) {
                this.showChatWindow(player, "olympiad/olympiad_operator020.htm", false, new Object[0]);
            } else if (ask == -70) {
                if (reply == 0L) {
                    this.showChatWindow(player, "olympiad/olympiad_operator001.htm", false, new Object[0]);
                } else if (reply == 1L) {
                    int passes = Olympiad.getParticipantRewardCount(player, false);
                    if (passes == 0) {
                        this.showChatWindow(player, "olympiad/olympiad_operator031a.htm", false, new Object[0]);
                    } else if (passes < 20) {
                        if (player.isHero() || Hero.getInstance().isInactiveHero(player.getObjectId())) {
                            this.showChatWindow(player, "olympiad/olympiad_operator031b.htm", false, new Object[0]);
                        } else {
                            this.showChatWindow(player, "olympiad/olympiad_operator031a.htm", false, new Object[0]);
                        }
                    } else {
                        this.showChatWindow(player, "olympiad/olympiad_operator031.htm", false, new Object[0]);
                    }
                } else if (reply == 2L) {
                    this.showChatWindow(player, "olympiad/olympiad_operator010l.htm", false, "<?WaitingCount?>", Olympiad.getParticipantPointsPast(player.getObjectId()));
                } else if (reply == 603L) {
                    MultiSellHolder.getInstance().SeparateAndSend((int)reply, player, 0.0);
                }
            } else if (ask == -71) {
                if (reply == 0L) {
                    this.showChatWindow(player, "olympiad/olympiad_operator030.htm", false, new Object[0]);
                } else if (reply == 1L) {
                    if (!player.isQuestContinuationPossible(true)) {
                        return;
                    }
                    int passes = Olympiad.getParticipantRewardCount(player, true);
                    if (passes > 0) {
                        ItemFunctions.addItem(player, Config.ALT_OLY_COMP_RITEM, passes);
                    }
                }
            } else if (ask != -80) {
                if (ask == -130) {
                    if (!Config.ENABLE_OLYMPIAD_SPECTATING) {
                        return;
                    }
                    Olympiad.addObserver((int)reply, player);
                } else {
                    super.onMenuSelect(player, ask, reply, state);
                }
            }
        }
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
        if (command.startsWith("_olympiad?")) {
            if (command.startsWith("_olympiad?command=op_field_list")) {
                if (!Olympiad.inCompPeriod() || Olympiad.isOlympiadEnd()) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THE_GRAND_OLYMPIAD_GAMES_ARE_NOT_CURRENTLY_IN_PROGRESS);
                    return;
                }
                player.sendPacket((IBroadcastPacket)new ExReceiveOlympiadPacket.MatchList());
            } else if (command.startsWith("_olympiad?command=move_op_field")) {
                String[] ar = command.split("&");
                if (ar.length < 2) {
                    return;
                }
                if (!Config.ENABLE_OLYMPIAD_SPECTATING) {
                    return;
                }
                String[] command2 = ar[1].split("=");
                if (command2.length < 2) {
                    return;
                }
                Olympiad.addObserver(Integer.parseInt(command2[1]) - 1, player);
            }
            return;
        }
        super.onBypassFeedback(player, command);
    }

    @Override
    public String getHtmlDir(String filename, Player player) {
        return "olympiad/";
    }

    @Override
    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... arg) {
        if (val == 0) {
            String fileName = "olympiad/";
            fileName = player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL ? fileName + "olympiad_operator001.htm" : fileName + "olympiad_operator002.htm";
            this.showChatWindow(player, fileName, firstTalk, new Object[0]);
        } else {
            super.showChatWindow(player, val, firstTalk, arg);
        }
    }

    @Override
    public boolean canPassPacket(Player player, Class<? extends L2GameClientPacket> packet, Object ... arg) {
        return packet == RequestBypassToServer.class && arg.length == 1 && (arg[0].equals("_olympiad?command=op_field_list") || arg[0].equals("_olympiad?command=move_op_field"));
    }
}

