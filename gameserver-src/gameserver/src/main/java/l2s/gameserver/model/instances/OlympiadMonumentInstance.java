/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 */
package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.RequestBypassToServer;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExHeroListPacket;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.utils.ItemFunctions;

public class OlympiadMonumentInstance
extends NpcInstance {
    public OlympiadMonumentInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public void onMenuSelect(Player player, int ask, long reply, int state) {
        if (ask == -50) {
            if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                this.showChatWindow(player, "olympiad/obelisk001.htm", false, new Object[0]);
            } else {
                this.showChatWindow(player, "olympiad/obelisk001a.htm", false, new Object[0]);
            }
        }
        if (ask == -51) {
            if (reply == 1L) {
                if (Hero.getInstance().isInactiveHero(player.getObjectId())) {
                    if (Olympiad.isValidationPeriod()) {
                        this.showChatWindow(player, "olympiad/obelisk010c.htm", false, new Object[0]);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk010.htm", false, new Object[0]);
                    }
                } else if (player.isHero()) {
                    this.showChatWindow(player, "olympiad/obelisk010b.htm", false, new Object[0]);
                } else {
                    this.showChatWindow(player, "olympiad/obelisk010a.htm", false, new Object[0]);
                }
            } else if (reply == 2L) {
                if (player.isHero()) {
                    if (!player.isQuestContinuationPossible(true)) {
                        return;
                    }
                    if (ItemFunctions.getItemCount(player, 6611) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6612) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6613) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6614) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6616) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6617) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6618) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6619) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6620) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else if (ItemFunctions.getItemCount(player, 6621) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020.htm", false, new Object[0]);
                    }
                } else {
                    this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                }
            } else if (reply != 3L && reply == 4L) {
                if (player.isHero()) {
                    if (ItemFunctions.getItemCount(player, 6842) >= 1L) {
                        this.showChatWindow(player, "olympiad/obelisk020c.htm", false, new Object[0]);
                    } else if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6842, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020c.htm", false, new Object[0]);
                    }
                } else {
                    this.showChatWindow(player, "olympiad/obelisk020d.htm", false, new Object[0]);
                }
            }
        } else if (ask == -52) {
            if (reply == 1L) {
                if (Hero.getInstance().isInactiveHero(player.getObjectId())) {
                    if (player.isBaseClassActive()) {
                        if (player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                            Hero.getInstance().activateHero(player);
                        } else {
                            this.showChatWindow(player, "olympiad/obelisk010d.htm", false, new Object[0]);
                        }
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk010e.htm", false, new Object[0]);
                    }
                } else {
                    this.showChatWindow(player, "olympiad/obelisk010a.htm", false, new Object[0]);
                }
            }
        } else if (ask != -53) {
            if (ask == -54) {
                if (reply == 1L) {
                    int rank = Olympiad.getRank(player);
                    if (rank == 1) {
                        if (ItemFunctions.getItemCount(player, 30372) < 1L && ItemFunctions.getItemCount(player, 30373) < 1L) {
                            if (!player.isQuestContinuationPossible(true)) {
                                return;
                            }
                            ItemFunctions.addItem(player, 30372, 1L);
                        } else {
                            this.showChatWindow(player, "olympiad/obelisk040c.htm", false, new Object[0]);
                        }
                    } else if (rank == 0 || rank > 1) {
                        this.showChatWindow(player, "olympiad/obelisk040d.htm", false, new Object[0]);
                    }
                }
            } else if (ask == -60) {
                if (ItemFunctions.getItemCount(player, 6611) >= 1L || ItemFunctions.getItemCount(player, 6612) >= 1L || ItemFunctions.getItemCount(player, 6613) >= 1L || ItemFunctions.getItemCount(player, 6614) >= 1L || ItemFunctions.getItemCount(player, 6616) >= 1L) {
                    this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    return;
                }
                if (ItemFunctions.getItemCount(player, 6617) >= 1L || ItemFunctions.getItemCount(player, 6618) >= 1L || ItemFunctions.getItemCount(player, 6619) >= 1L || ItemFunctions.getItemCount(player, 6620) >= 1L || ItemFunctions.getItemCount(player, 6621) >= 1L) {
                    this.showChatWindow(player, "olympiad/obelisk020b.htm", false, new Object[0]);
                    return;
                }
                if (reply == 1L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6611, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 2L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6612, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 3L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6613, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 4L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6614, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 5L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6616, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 6L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6617, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 7L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6618, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 8L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6619, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 9L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6620, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 10L) {
                    if (player.isHero()) {
                        if (!player.isQuestContinuationPossible(true)) {
                            return;
                        }
                        ItemFunctions.addItem(player, 6621, 1L);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk020a.htm", false, new Object[0]);
                    }
                }
                if (reply == 0L) {
                    if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                        this.showChatWindow(player, "olympiad/obelisk001.htm", false, new Object[0]);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk001a.htm", false, new Object[0]);
                    }
                }
            } else if (ask == -61) {
                if (reply == 0L) {
                    if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                        this.showChatWindow(player, "olympiad/obelisk001.htm", false, new Object[0]);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk001a.htm", false, new Object[0]);
                    }
                }
            } else if (ask == -62) {
                if (reply == 0L) {
                    if (player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL) {
                        this.showChatWindow(player, "olympiad/obelisk001.htm", false, new Object[0]);
                    } else {
                        this.showChatWindow(player, "olympiad/obelisk001a.htm", false, new Object[0]);
                    }
                }
            } else if (ask != -70) {
                super.onMenuSelect(player, ask, reply, state);
            }
        }
    }

    @Override
    public void onBypassFeedback(Player player, String command) {
        if (command.equalsIgnoreCase("_heroes")) {
            player.sendPacket((IBroadcastPacket)new ExHeroListPacket());
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
            fileName = player.getClassLevel().ordinal() >= ClassLevel.SECOND.ordinal() && player.getLevel() >= Config.OLYMPIAD_MIN_LEVEL ? fileName + "obelisk001.htm" : fileName + "obelisk001a.htm";
            this.showChatWindow(player, fileName, firstTalk, new Object[0]);
        } else {
            super.showChatWindow(player, val, firstTalk, arg);
        }
    }

    @Override
    public boolean canPassPacket(Player player, Class<? extends L2GameClientPacket> packet, Object ... arg) {
        return packet == RequestBypassToServer.class && arg.length == 1 && arg[0].equals("_heroes");
    }
}

