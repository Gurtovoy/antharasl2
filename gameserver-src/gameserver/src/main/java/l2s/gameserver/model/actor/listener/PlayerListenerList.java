package l2s.gameserver.model.actor.listener;

import l2s.commons.listener.Listener;
import l2s.gameserver.listener.actor.player.OnClassChangeListener;
import l2s.gameserver.listener.actor.player.OnEnchantItemListener;
import l2s.gameserver.listener.actor.player.OnExpReceiveListener;
import l2s.gameserver.listener.actor.player.OnFishingListener;
import l2s.gameserver.listener.actor.player.OnLearnCustomSkillListener;
import l2s.gameserver.listener.actor.player.OnLevelChangeListener;
import l2s.gameserver.listener.actor.player.OnOlympiadFinishBattleListener;
import l2s.gameserver.listener.actor.player.OnParticipateInCastleSiegeListener;
import l2s.gameserver.listener.actor.player.OnPickupItemListener;
import l2s.gameserver.listener.actor.player.OnPlayerChatMessageReceive;
import l2s.gameserver.listener.actor.player.OnPlayerClanInviteListener;
import l2s.gameserver.listener.actor.player.OnPlayerClanLeaveListener;
import l2s.gameserver.listener.actor.player.OnPlayerEnterListener;
import l2s.gameserver.listener.actor.player.OnPlayerExitListener;
import l2s.gameserver.listener.actor.player.OnPlayerPartyInviteListener;
import l2s.gameserver.listener.actor.player.OnPlayerPartyLeaveListener;
import l2s.gameserver.listener.actor.player.OnPlayerSummonServitorListener;
import l2s.gameserver.listener.actor.player.OnQuestFinishListener;
import l2s.gameserver.listener.actor.player.OnSocialActionListener;
import l2s.gameserver.listener.actor.player.OnTeleportListener;
import l2s.gameserver.listener.actor.player.OnTeleportedListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.actor.listener.CharListenerList;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.c2s.RequestActionUse;
import l2s.gameserver.network.l2.components.ChatType;

public class PlayerListenerList
extends CharListenerList {
    public PlayerListenerList(Player actor) {
        super(actor);
    }

    @Override
    public Player getActor() {
        return (Player)this.actor;
    }

    public void onEnter() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerEnterListener.class.isInstance(listener)) continue;
                ((OnPlayerEnterListener)listener).onPlayerEnter(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerEnterListener.class.isInstance(listener)) continue;
                ((OnPlayerEnterListener)listener).onPlayerEnter(this.getActor());
            }
        }
    }

    public void onExit() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerExitListener.class.isInstance(listener)) continue;
                ((OnPlayerExitListener)listener).onPlayerExit(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerExitListener.class.isInstance(listener)) continue;
                ((OnPlayerExitListener)listener).onPlayerExit(this.getActor());
            }
        }
    }

    public void onTeleport(int x, int y, int z, Reflection reflection) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnTeleportListener.class.isInstance(listener)) continue;
                ((OnTeleportListener)listener).onTeleport(this.getActor(), x, y, z, reflection);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnTeleportListener.class.isInstance(listener)) continue;
                ((OnTeleportListener)listener).onTeleport(this.getActor(), x, y, z, reflection);
            }
        }
    }

    public void onTeleported() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnTeleportedListener.class.isInstance(listener)) continue;
                ((OnTeleportedListener)listener).onTeleported(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnTeleportedListener.class.isInstance(listener)) continue;
                ((OnTeleportedListener)listener).onTeleported(this.getActor());
            }
        }
    }

    public void onPartyInvite() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerPartyInviteListener.class.isInstance(listener)) continue;
                ((OnPlayerPartyInviteListener)listener).onPartyInvite(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerPartyInviteListener.class.isInstance(listener)) continue;
                ((OnPlayerPartyInviteListener)listener).onPartyInvite(this.getActor());
            }
        }
    }

    public void onPartyLeave() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerPartyLeaveListener.class.isInstance(listener)) continue;
                ((OnPlayerPartyLeaveListener)listener).onPartyLeave(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerPartyLeaveListener.class.isInstance(listener)) continue;
                ((OnPlayerPartyLeaveListener)listener).onPartyLeave(this.getActor());
            }
        }
    }

    public void onClanInvite() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerClanInviteListener.class.isInstance(listener)) continue;
                ((OnPlayerClanInviteListener)listener).onClanInvite(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerClanInviteListener.class.isInstance(listener)) continue;
                ((OnPlayerClanInviteListener)listener).onClanInvite(this.getActor());
            }
        }
    }

    public void onClanLeave() {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerClanLeaveListener.class.isInstance(listener)) continue;
                ((OnPlayerClanLeaveListener)listener).onClanLeave(this.getActor());
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerClanLeaveListener.class.isInstance(listener)) continue;
                ((OnPlayerClanLeaveListener)listener).onClanLeave(this.getActor());
            }
        }
    }

    public void onSummonServitor(Servitor servitor) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerSummonServitorListener.class.isInstance(listener)) continue;
                ((OnPlayerSummonServitorListener)listener).onSummonServitor(this.getActor(), servitor);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerSummonServitorListener.class.isInstance(listener)) continue;
                ((OnPlayerSummonServitorListener)listener).onSummonServitor(this.getActor(), servitor);
            }
        }
    }

    public void onSocialAction(RequestActionUse.Action action) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnSocialActionListener.class.isInstance(listener)) continue;
                ((OnSocialActionListener)listener).onSocialAction(this.getActor(), this.getActor().getTarget(), action);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnSocialActionListener.class.isInstance(listener)) continue;
                ((OnSocialActionListener)listener).onSocialAction(this.getActor(), this.getActor().getTarget(), action);
            }
        }
    }

    public void onLevelChange(int oldLvl, int newLvl) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnLevelChangeListener.class.isInstance(listener)) continue;
                ((OnLevelChangeListener)listener).onLevelChange(this.getActor(), oldLvl, newLvl);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnLevelChangeListener.class.isInstance(listener)) continue;
                ((OnLevelChangeListener)listener).onLevelChange(this.getActor(), oldLvl, newLvl);
            }
        }
    }

    public void onClassChange(ClassId oldClass, ClassId newClass) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnClassChangeListener.class.isInstance(listener)) continue;
                ((OnClassChangeListener)listener).onClassChange(this.getActor(), oldClass, newClass);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnClassChangeListener.class.isInstance(listener)) continue;
                ((OnClassChangeListener)listener).onClassChange(this.getActor(), oldClass, newClass);
            }
        }
    }

    public void onPickupItem(ItemInstance item) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPickupItemListener.class.isInstance(listener)) continue;
                ((OnPickupItemListener)listener).onPickupItem(this.getActor(), item);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPickupItemListener.class.isInstance(listener)) continue;
                ((OnPickupItemListener)listener).onPickupItem(this.getActor(), item);
            }
        }
    }

    public void onEnchantItem(ItemInstance item, boolean success) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnEnchantItemListener.class.isInstance(listener)) continue;
                ((OnEnchantItemListener)listener).onEnchantItem(this.getActor(), item, success);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnEnchantItemListener.class.isInstance(listener)) continue;
                ((OnEnchantItemListener)listener).onEnchantItem(this.getActor(), item, success);
            }
        }
    }

    public void onFishing(boolean success) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnFishingListener.class.isInstance(listener)) continue;
                ((OnFishingListener)listener).onFishing(this.getActor(), success);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnFishingListener.class.isInstance(listener)) continue;
                ((OnFishingListener)listener).onFishing(this.getActor(), success);
            }
        }
    }

    public void onOlympiadFinishBattle(boolean winner) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnOlympiadFinishBattleListener.class.isInstance(listener)) continue;
                ((OnOlympiadFinishBattleListener)listener).onOlympiadFinishBattle(this.getActor(), winner);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnOlympiadFinishBattleListener.class.isInstance(listener)) continue;
                ((OnOlympiadFinishBattleListener)listener).onOlympiadFinishBattle(this.getActor(), winner);
            }
        }
    }

    public void onQuestFinish(int questId) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnQuestFinishListener.class.isInstance(listener)) continue;
                ((OnQuestFinishListener)listener).onQuestFinish(this.getActor(), questId);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnQuestFinishListener.class.isInstance(listener)) continue;
                ((OnQuestFinishListener)listener).onQuestFinish(this.getActor(), questId);
            }
        }
    }

    public void onChatMessageReceive(ChatType type, String charName, String text) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnPlayerChatMessageReceive.class.isInstance(listener)) continue;
                ((OnPlayerChatMessageReceive)listener).onChatMessageReceive(this.getActor(), type, charName, text);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnPlayerChatMessageReceive.class.isInstance(listener)) continue;
                ((OnPlayerChatMessageReceive)listener).onChatMessageReceive(this.getActor(), type, charName, text);
            }
        }
    }

    public void onParticipateInCastleSiege(CastleSiegeEvent siegeEvent) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnParticipateInCastleSiegeListener.class.isInstance(listener)) continue;
                ((OnParticipateInCastleSiegeListener)listener).onParticipateInCastleSiege(this.getActor(), siegeEvent);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnParticipateInCastleSiegeListener.class.isInstance(listener)) continue;
                ((OnParticipateInCastleSiegeListener)listener).onParticipateInCastleSiege(this.getActor(), siegeEvent);
            }
        }
    }

    public void onLearnCustomSkill(SkillLearn skillLearn) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnLearnCustomSkillListener.class.isInstance(listener)) continue;
                ((OnLearnCustomSkillListener)listener).onLearnCustomSkill(this.getActor(), skillLearn);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnLearnCustomSkillListener.class.isInstance(listener)) continue;
                ((OnLearnCustomSkillListener)listener).onLearnCustomSkill(this.getActor(), skillLearn);
            }
        }
    }

    public void onExpReceive(long value, boolean hunting) {
        if (!global.getListeners().isEmpty()) {
            for (Listener listener : global.getListeners()) {
                if (!OnExpReceiveListener.class.isInstance(listener)) continue;
                ((OnExpReceiveListener)listener).onExpReceive(this.getActor(), value, hunting);
            }
        }
        if (!this.getListeners().isEmpty()) {
            for (Listener listener : this.getListeners()) {
                if (!OnExpReceiveListener.class.isInstance(listener)) continue;
                ((OnExpReceiveListener)listener).onExpReceive(this.getActor(), value, hunting);
            }
        }
    }
}

