package l2s.gameserver.model.instances;

import java.util.concurrent.Future;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.dao.SummonsDAO;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SetSummonRemainTimePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.npc.NpcTemplate;

public class SummonInstance
extends Servitor {
    public static final int CYCLE = 5000;
    private final int _summonSkillId;
    private final int _itemConsumeIdInTime;
    private final int _itemConsumeCountInTime;
    private final int _itemConsumeDelay;
    private final int _maxLifetime;
    private final int _skillId;
    private final int _skillLvl;
    private final boolean _saveable;
    private final int _soulshots;
    private final int _spiritshots;
    private int _consumeCountdown;
    private int _lifetimeCountdown;
    private Future<?> _disappearTask;
    private double _expPenalty = 0.0;
    private boolean _isSiegeSummon;
    private Servitor.AttackMode _attackMode = Servitor.AttackMode.PASSIVE;

    public SummonInstance(int objectId, NpcTemplate template, Player owner, int lifetime, int consumeid, int consumecount, int consumedelay, Skill skill, boolean saveable) {
        super(objectId, template, owner);
        this.setName(template.name);
        this._lifetimeCountdown = this._maxLifetime = lifetime;
        this._itemConsumeIdInTime = consumeid;
        this._itemConsumeCountInTime = consumecount;
        this._consumeCountdown = this._itemConsumeDelay = consumedelay;
        this._summonSkillId = skill.getDisplayId();
        this._disappearTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new Lifetime(), 5000L, 5000L);
        this._skillId = skill.getId();
        this._skillLvl = skill.getLevel();
        this._saveable = saveable;
        this._soulshots = template.getAIParams().getInteger("soulshot_count", 1);
        this._spiritshots = template.getAIParams().getInteger("spiritshot_count", 1);
    }

    @SuppressWarnings("unchecked")
    public HardReference<SummonInstance> getRef() {
        return (HardReference<SummonInstance>)(HardReference<?>)super.getRef();
    }

    @Override
    public final int getLevel() {
        return this.getTemplate() != null ? this.getTemplate().level : 0;
    }

    @Override
    public int getServitorType() {
        return 1;
    }

    @Override
    public int getCurrentFed() {
        return this._lifetimeCountdown;
    }

    @Override
    public int getMaxFed() {
        return this._maxLifetime;
    }

    public void setExpPenalty(double expPenalty) {
        this._expPenalty = expPenalty;
    }

    @Override
    public double getExpPenalty() {
        return this._expPenalty;
    }

    @Override
    protected void onDeath(Creature killer) {
        super.onDeath(killer);
        this.stopDisappear();
    }

    public int getItemConsumeIdInTime() {
        return this._itemConsumeIdInTime;
    }

    public int getItemConsumeCountInTime() {
        return this._itemConsumeCountInTime;
    }

    public int getItemConsumeDelay() {
        return this._itemConsumeDelay;
    }

    protected synchronized void stopDisappear() {
        if (this._disappearTask != null) {
            this._disappearTask.cancel(false);
            this._disappearTask = null;
        }
    }

    @Override
    public void unSummon(boolean logout) {
        if (logout) {
            SummonsDAO.getInstance().insert(this);
        } else if (this.isSiegeSummon()) {
            for (SiegeEvent siegeEvent : this.getEvents(SiegeEvent.class)) {
                siegeEvent.removeSiegeSummon(this.getPlayer(), this);
            }
        }
        this.stopDisappear();
        super.unSummon(logout);
    }

    @Override
    public int getEffectIdentifier() {
        return this._summonSkillId;
    }

    @Override
    public boolean isSummon() {
        return true;
    }

    @Override
    public void onAction(Player player, boolean shift) {
        super.onAction(player, shift);
        if (shift) {
            if (!player.getPlayerAccess().CanViewChar) {
                return;
            }
            String dialog = HtmCache.getInstance().getHtml("scripts/actions/admin.L2SummonInstance.onActionShift.htm", player);
            dialog = dialog.replaceFirst("%name%", String.valueOf(this.getName()));
            dialog = dialog.replaceFirst("%level%", String.valueOf(this.getLevel()));
            dialog = dialog.replaceFirst("%class%", String.valueOf(this.getClass().getSimpleName().replaceFirst("L2", "").replaceFirst("Instance", "")));
            dialog = dialog.replaceFirst("%xyz%", this.getLoc().x + " " + this.getLoc().y + " " + this.getLoc().z);
            dialog = dialog.replaceFirst("%heading%", String.valueOf(this.getLoc().h));
            dialog = dialog.replaceFirst("%owner%", String.valueOf(this.getPlayer().getName()));
            dialog = dialog.replaceFirst("%ownerId%", String.valueOf(this.getPlayer().getObjectId()));
            dialog = dialog.replaceFirst("%npcId%", String.valueOf(this.getNpcId()));
            dialog = dialog.replaceFirst("%expPenalty%", String.valueOf(this.getExpPenalty()));
            dialog = dialog.replaceFirst("%maxHp%", String.valueOf(this.getMaxHp()));
            dialog = dialog.replaceFirst("%maxMp%", String.valueOf(this.getMaxMp()));
            dialog = dialog.replaceFirst("%currHp%", String.valueOf((int)this.getCurrentHp()));
            dialog = dialog.replaceFirst("%currMp%", String.valueOf((int)this.getCurrentMp()));
            dialog = dialog.replaceFirst("%pDef%", String.valueOf(this.getPDef(null)));
            dialog = dialog.replaceFirst("%mDef%", String.valueOf(this.getMDef(null, null)));
            dialog = dialog.replaceFirst("%pAtk%", String.valueOf(this.getPAtk(null)));
            dialog = dialog.replaceFirst("%mAtk%", String.valueOf(this.getMAtk(null, null)));
            dialog = dialog.replaceFirst("%accuracy%", String.valueOf(this.getPAccuracy()));
            dialog = dialog.replaceFirst("%evasionRate%", String.valueOf(this.getPEvasionRate(null)));
            dialog = dialog.replaceFirst("%crt%", String.valueOf(this.getPCriticalHit(null)));
            dialog = dialog.replaceFirst("%runSpeed%", String.valueOf(this.getRunSpeed()));
            dialog = dialog.replaceFirst("%walkSpeed%", String.valueOf(this.getWalkSpeed()));
            dialog = dialog.replaceFirst("%pAtkSpd%", String.valueOf(this.getPAtkSpd()));
            dialog = dialog.replaceFirst("%mAtkSpd%", String.valueOf(this.getMAtkSpd()));
            dialog = dialog.replaceFirst("%dist%", String.valueOf(this.getRealDistance(player)));
            dialog = dialog.replaceFirst("%STR%", String.valueOf(this.getSTR()));
            dialog = dialog.replaceFirst("%DEX%", String.valueOf(this.getDEX()));
            dialog = dialog.replaceFirst("%CON%", String.valueOf(this.getCON()));
            dialog = dialog.replaceFirst("%INT%", String.valueOf(this.getINT()));
            dialog = dialog.replaceFirst("%WIT%", String.valueOf(this.getWIT()));
            dialog = dialog.replaceFirst("%MEN%", String.valueOf(this.getMEN()));
            dialog = dialog.replace("<?object_id?>", String.valueOf(this.getObjectId()));
            HtmlMessage msg = new HtmlMessage(5);
            msg.setHtml(dialog);
            player.sendPacket((IBroadcastPacket)msg);
        }
    }

    @Override
    public long getWearedMask() {
        return WeaponTemplate.WeaponType.SWORD.mask();
    }

    public int getSkillId() {
        return this._skillId;
    }

    public int getSkillLvl() {
        return this._skillLvl;
    }

    public int getConsumeCountdown() {
        return this._consumeCountdown;
    }

    public void setConsumeCountdown(int val) {
        this._consumeCountdown = val;
    }

    public boolean isSaveable() {
        return this._saveable && !this.isDead();
    }

    @Override
    public int getSoulshotConsumeCount() {
        return this._soulshots;
    }

    @Override
    public int getSpiritshotConsumeCount() {
        return this._spiritshots;
    }

    public boolean isSiegeSummon() {
        return this._isSiegeSummon;
    }

    public void setSiegeSummon(boolean siegeSummon) {
        this._isSiegeSummon = siegeSummon;
    }

    @Override
    public void onAttacked(Creature attacker) {
        if (this.isAttackingNow()) {
            return;
        }
        if (attacker == null || this.getPlayer() == null) {
            return;
        }
        if (this.getAttackMode() == Servitor.AttackMode.DEFENCE) {
            this.setTarget(attacker);
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_ATTACK, attacker);
        } else {
            if (this.getMovement().isMoving() || this.isMovementDisabled() || this.getAI().getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
                return;
            }
            Player player = this.getPlayer();
            if (player == null) {
                return;
            }
            this.getMovement().moveToLocation(Location.findPointToStay(this.getPlayer().getLoc(), Config.FOLLOW_RANGE, Config.FOLLOW_RANGE, this.getGeoIndex()), 0, true);
        }
    }

    @Override
    public void onOwnerOfAttacks(Creature target) {
        if (this.isAttackingNow()) {
            return;
        }
        if (target == null) {
            return;
        }
        if (this.getAttackMode() == Servitor.AttackMode.DEFENCE) {
            this.setTarget(target);
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_ATTACK, target);
        } else {
            if (this.getMovement().isMoving() || this.isMovementDisabled() || this.getAI().getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
                return;
            }
            Player player = this.getPlayer();
            if (player == null) {
                return;
            }
            this.getMovement().moveToLocation(Location.findPointToStay(this.getPlayer().getLoc(), Config.FOLLOW_RANGE, Config.FOLLOW_RANGE, this.getGeoIndex()), 0, true);
        }
    }

    @Override
    public void setAttackMode(Servitor.AttackMode mode) {
        this._attackMode = mode;
    }

    @Override
    public Servitor.AttackMode getAttackMode() {
        return this._attackMode;
    }

    class Lifetime
    implements Runnable {
        Lifetime() {
        }

        @Override
        public void run() {
            Player owner = SummonInstance.this.getPlayer();
            if (owner == null) {
                SummonInstance.this.unSummon(false);
                return;
            }
            int usedtime = 5000;
            SummonInstance.this._lifetimeCountdown = SummonInstance.this._lifetimeCountdown - usedtime;
            if (SummonInstance.this._lifetimeCountdown <= 0) {
                owner.sendPacket((IBroadcastPacket)SystemMsg.YOUR_SERVITOR_HAS_VANISHED_YOULL_NEED_TO_SUMMON_A_NEW_ONE);
                SummonInstance.this.unSummon(false);
                return;
            }
            SummonInstance.this._consumeCountdown = SummonInstance.this._consumeCountdown - usedtime;
            if (SummonInstance.this.getItemConsumeIdInTime() > 0 && SummonInstance.this.getItemConsumeCountInTime() > 0 && SummonInstance.this._consumeCountdown <= 0) {
                if (owner.getInventory().destroyItemByItemId(SummonInstance.this.getItemConsumeIdInTime(), SummonInstance.this.getItemConsumeCountInTime())) {
                    SummonInstance.this._consumeCountdown = SummonInstance.this._itemConsumeDelay;
                    owner.sendPacket((IBroadcastPacket)new SystemMessage(1029).addItemName(SummonInstance.this.getItemConsumeIdInTime()));
                } else {
                    owner.sendPacket((IBroadcastPacket)SystemMsg.SINCE_YOU_DO_NOT_HAVE_ENOUGH_ITEMS_TO_MAINTAIN_THE_SERVITORS_STAY_THE_SERVITOR_HAS_DISAPPEARED);
                    SummonInstance.this.unSummon(false);
                    return;
                }
            }
            owner.sendPacket((IBroadcastPacket)new SetSummonRemainTimePacket(SummonInstance.this));
        }
    }

    public static class RestoredSummon {
        public final int skillId;
        public final int skillLvl;
        public final int curHp;
        public final int curMp;
        public final int time;

        public RestoredSummon(int skillId, int skillLvl, int curHp, int curMp, int time) {
            this.skillId = skillId;
            this.skillLvl = skillLvl;
            this.curHp = curHp;
            this.curMp = curMp;
            this.time = time;
        }
    }
}

