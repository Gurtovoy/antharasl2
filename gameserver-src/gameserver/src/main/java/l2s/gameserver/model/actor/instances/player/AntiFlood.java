/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntLongIterator
 *  gnu.trove.map.TIntLongMap
 *  gnu.trove.map.hash.TIntLongHashMap
 *  gnu.trove.set.TIntSet
 *  gnu.trove.set.hash.TIntHashSet
 */
package l2s.gameserver.model.actor.instances.player;

import gnu.trove.iterator.TIntLongIterator;
import gnu.trove.map.TIntLongMap;
import gnu.trove.map.hash.TIntLongHashMap;
import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class AntiFlood {
    private final TIntSet _interlocutors = new TIntHashSet();
    private final TIntLongMap _recentReceivers = new TIntLongHashMap();
    private final Player _owner;
    private long _lastSent = 0L;
    private String _lastText = "";
    private long _allChatUseTime;
    private long _shoutChatUseTime;
    private long _tradeChatUseTime;
    private long _heroChatUseTime;
    private long _privateChatUseTime;
    private long _mailUseTime;

    public AntiFlood(Player owner) {
        this._owner = owner;
    }

    public boolean canAll(String text) {
        if (this._owner.isGM()) {
            return true;
        }
        if (this._owner.hasPremiumAccount()) {
            if (Config.ALL_CHAT_USE_MIN_LEVEL > this._owner.getLevel()) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.all.level").addNumber(Config.ALL_CHAT_USE_MIN_LEVEL));
                return false;
            }
        } else if (Config.ALL_CHAT_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
            this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.PLAYERS_CAN_USE_GENERAL_CHAT_AFTER_LV_S1).addInteger(Config.ALL_CHAT_USE_MIN_LEVEL_WITHOUT_PA - 1));
            return false;
        }
        if (Config.ALL_CHAT_USE_DELAY > 0) {
            long currentMillis = System.currentTimeMillis();
            int delay = (int)((this._allChatUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.all.delay").addNumber(delay));
                return false;
            }
            this._allChatUseTime = currentMillis + (long)Config.ALL_CHAT_USE_DELAY * 1000L;
        }
        return true;
    }

    public boolean canShout(String text) {
        if (this._owner.isGM()) {
            return true;
        }
        if (this._owner.hasPremiumAccount()) {
            if (Config.SHOUT_CHAT_USE_MIN_LEVEL > this._owner.getLevel()) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.shout.level").addNumber(Config.ALL_CHAT_USE_MIN_LEVEL));
                return false;
            }
        } else if (Config.SHOUT_CHAT_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
            this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.PLAYERS_CAN_SHOUT_AFTER_LV_S1).addInteger(Config.SHOUT_CHAT_USE_MIN_LEVEL_WITHOUT_PA - 1));
            return false;
        }
        if (Config.SHOUT_CHAT_USE_DELAY > 0) {
            long currentMillis = System.currentTimeMillis();
            int delay = (int)((this._shoutChatUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.shout.delay").addNumber(delay));
                return false;
            }
            this._shoutChatUseTime = currentMillis + (long)Config.SHOUT_CHAT_USE_DELAY * 1000L;
        }
        return true;
    }

    public boolean canWorld(String text) {
        if (this._owner.isGM()) {
            return true;
        }
        if (this._owner.getWorldChatPoints() <= 0) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.TODAY_YOU_REACHED_THE_LIMIT_OF_USE_OF_THE_WORLD_CHAT__RESET_OF_THE_WORLD_USE_CHAT_IS_DONE_DAILY_AT_6_30_AM);
            return false;
        }
        if (this._owner.hasPremiumAccount() || this._owner.hasVIPAccount()) {
            int vipMinLevel;
            int minLevel = Config.WORLD_CHAT_USE_MIN_LEVEL;
            int paMinLevel = this._owner.getPremiumAccount().getWorldChatMinLevel();
            if (paMinLevel != -1) {
                minLevel = Math.min(minLevel, paMinLevel);
            }
            if ((vipMinLevel = this._owner.getVIP().getTemplate().getWorldChatMinLevel()) != -1) {
                minLevel = Math.min(minLevel, vipMinLevel);
            }
            if (minLevel > this._owner.getLevel()) {
                this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_CAN_USE_THE_WORLD_CHAT_WITH_S1_LEVEL).addInteger(minLevel));
                return false;
            }
        } else if (Config.WORLD_CHAT_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
            this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_CAN_USE_THE_WORLD_CHAT_WITH_S1_LEVEL).addInteger(Config.WORLD_CHAT_USE_MIN_LEVEL_WITHOUT_PA));
            return false;
        }
        if (Config.WORLD_CHAT_USE_DELAY > 0) {
            long currentMillis = System.currentTimeMillis();
            int delay = (int)((this._shoutChatUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.world.delay").addNumber(delay));
                return false;
            }
            this._shoutChatUseTime = currentMillis + (long)Config.WORLD_CHAT_USE_DELAY * 1000L;
        }
        return true;
    }

    public boolean canTrade(String text) {
        if (this._owner.isGM()) {
            return true;
        }
        if (this._owner.hasPremiumAccount()) {
            if (Config.TRADE_CHAT_USE_MIN_LEVEL > this._owner.getLevel()) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.trade.level").addNumber(Config.TRADE_CHAT_USE_MIN_LEVEL));
                return false;
            }
        } else if (Config.TRADE_CHAT_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
            this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.PLAYERS_CAN_USE_TRADE_CHAT_AFTER_LV_S1).addInteger(Config.SHOUT_CHAT_USE_MIN_LEVEL_WITHOUT_PA - 1));
            return false;
        }
        if (Config.TRADE_CHAT_USE_DELAY > 0) {
            long currentMillis = System.currentTimeMillis();
            int delay = (int)((this._tradeChatUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.trade.delay").addNumber(delay));
                return false;
            }
            this._tradeChatUseTime = currentMillis + (long)Config.TRADE_CHAT_USE_DELAY * 1000L;
        }
        return true;
    }

    public boolean canHero(String text) {
        if (this._owner.isGM()) {
            return true;
        }
        if (this._owner.hasPremiumAccount()) {
            if (Config.HERO_CHAT_USE_MIN_LEVEL > this._owner.getLevel()) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.hero.level").addNumber(Config.HERO_CHAT_USE_MIN_LEVEL));
                return false;
            }
        } else if (Config.HERO_CHAT_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
            this._owner.sendMessage(new CustomMessage("antispam.no_chat.hero.level").addNumber(Config.HERO_CHAT_USE_MIN_LEVEL_WITHOUT_PA));
            return false;
        }
        if (Config.HERO_CHAT_USE_DELAY > 0) {
            long currentMillis = System.currentTimeMillis();
            int delay = (int)((this._heroChatUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.hero.delay").addNumber(delay));
                return false;
            }
            this._heroChatUseTime = currentMillis + (long)Config.HERO_CHAT_USE_DELAY * 1000L;
        }
        return true;
    }

    public boolean canMail() {
        if (this._owner.isGM()) {
            return true;
        }
        if (this._owner.hasPremiumAccount()) {
            if (Config.MAIL_USE_MIN_LEVEL > this._owner.getLevel()) {
                this._owner.sendMessage(new CustomMessage("antispam.no_mail.level").addNumber(Config.MAIL_USE_MIN_LEVEL));
                return false;
            }
        } else if (Config.MAIL_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
            this._owner.sendMessage(new CustomMessage("antispam.no_mail.level").addNumber(Config.MAIL_USE_MIN_LEVEL_WITHOUT_PA));
            return false;
        }
        if (Config.MAIL_USE_DELAY > 0) {
            long currentMillis = System.currentTimeMillis();
            int delay = (int)((this._mailUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_mail.delay").addNumber(delay));
                return false;
            }
            this._mailUseTime = currentMillis + (long)Config.MAIL_USE_DELAY * 1000L;
        }
        return true;
    }

    public boolean canTell(int receiverId, String text) {
        long currentMillis;
        if (this._owner.isGM()) {
            return true;
        }
        if (!this._interlocutors.contains(receiverId)) {
            if (this._owner.hasPremiumAccount()) {
                if (Config.PRIVATE_CHAT_USE_MIN_LEVEL > this._owner.getLevel()) {
                    this._owner.sendMessage(new CustomMessage("antispam.no_chat.private.level").addNumber(Config.PRIVATE_CHAT_USE_MIN_LEVEL));
                    return false;
                }
            } else if (Config.PRIVATE_CHAT_USE_MIN_LEVEL_WITHOUT_PA > this._owner.getLevel()) {
                this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.PLAYERS_CAN_RESPOND_TO_A_WHISPER_BUT_CANNOT_INITIATE_A_WHISPER_UNTIL_LV_S1).addInteger(Config.SHOUT_CHAT_USE_MIN_LEVEL_WITHOUT_PA - 1));
                return false;
            }
        }
        if (Config.PRIVATE_CHAT_USE_DELAY > 0) {
            currentMillis = System.currentTimeMillis();
            int delay = (int)((this._privateChatUseTime - currentMillis) / 1000L);
            if (delay > 0) {
                this._owner.sendMessage(new CustomMessage("antispam.no_chat.private.delay").addNumber(delay));
                return false;
            }
            this._privateChatUseTime = currentMillis + (long)Config.PRIVATE_CHAT_USE_DELAY * 1000L;
        }
        currentMillis = System.currentTimeMillis();
        TIntLongIterator itr = this._recentReceivers.iterator();
        int recent = 0;
        while (itr.hasNext()) {
            itr.advance();
            long lastSent = itr.value();
            if (currentMillis - lastSent < (text.equalsIgnoreCase(this._lastText) ? 600000L : 60000L)) {
                ++recent;
                continue;
            }
            itr.remove();
        }
        long lastSent = this._recentReceivers.put(receiverId, currentMillis);
        long delay = 333L;
        if (recent > 3) {
            lastSent = this._lastSent;
            delay = (long)(recent - 3) * 3333L;
        }
        this._lastText = text;
        this._lastSent = currentMillis;
        int remainingDelay = (int)((delay - (currentMillis - lastSent)) / 1000L);
        if (remainingDelay > 0) {
            this._owner.sendMessage(new CustomMessage("antispam.no_chat.private.delay").addNumber(remainingDelay));
            return false;
        }
        return true;
    }

    public void addInterlocutorId(int id) {
        this._interlocutors.add(id);
    }
}

