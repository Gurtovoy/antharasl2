package l2s.gameserver.model.actor.instances.player;

import java.util.Collection;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.AccountVariablesDAO;
import l2s.gameserver.data.xml.holder.AttendanceRewardHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExConfirmVipAttendanceCheck;
import l2s.gameserver.network.l2.s2c.ExVipAttendanceItemList;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.data.AttendanceRewardData;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.TimeUtils;

public class AttendanceRewards {
    private static final SchedulingPattern VIP_ATTENDANCE_DATE_PATTERN = TimeUtils.DAILY_DATE_PATTERN;
    private static final String VIP_ATTENDANCE_REWARD_INDEX_VAR = "@vip_attendance_reward_index";
    private static final String VIP_ATTENDANCE_REWARD_DATE_VAR = "@vip_attendance_date_index";
    private static final int AFTER_LOGIN_RECEIVE_REWARD_DELAY = 30;
    protected final ReadWriteLock lock = new ReentrantReadWriteLock();
    protected final Lock readLock = this.lock.readLock();
    protected final Lock writeLock = this.lock.writeLock();
    private final Player _owner;
    private int _receivedRewardIndex = 0;
    private int _nextRewardIndex = 0;
    private ScheduledFuture<?> _loginDelayTask = null;
    private ScheduledFuture<?> _getNextRewardIndexTask = null;

    public AttendanceRewards(Player owner) {
        this._owner = owner;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restore() {
        this.writeLock();
        try {
            if (!Config.VIP_ATTENDANCE_REWARDS_ENABLED) {
                return;
            }
            Collection<AttendanceRewardData> rewards = AttendanceRewardHolder.getInstance().getRewards(this._owner.hasPremiumAccount());
            if (rewards.isEmpty()) {
                return;
            }
            int receiveTime = Config.VIP_ATTENDANCE_REWARDS_REWARD_BY_ACCOUNT ? Integer.parseInt(AccountVariablesDAO.getInstance().select(this._owner.getAccountName(), VIP_ATTENDANCE_REWARD_DATE_VAR, "0")) : this._owner.getVarInt(VIP_ATTENDANCE_REWARD_DATE_VAR, 0);
            int index = 0;
            index = Config.VIP_ATTENDANCE_REWARDS_REWARD_BY_ACCOUNT ? Integer.parseInt(AccountVariablesDAO.getInstance().select(this._owner.getAccountName(), VIP_ATTENDANCE_REWARD_INDEX_VAR, "0")) : this._owner.getVarInt(VIP_ATTENDANCE_REWARD_INDEX_VAR, 0);
            this._receivedRewardIndex = index = Math.max(0, Math.min(index, rewards.size()));
            long nextRewardTime = VIP_ATTENDANCE_DATE_PATTERN.next((long)receiveTime * 1000L);
            if (nextRewardTime <= System.currentTimeMillis()) {
                if (index >= rewards.size()) {
                    this._receivedRewardIndex = 0;
                    index = 1;
                } else {
                    ++index;
                }
            }
            this._nextRewardIndex = index;
        }
        finally {
            this.writeUnlock();
        }
    }

    public int getReceivedRewardIndex() {
        this.readLock();
        try {
            int n = this._receivedRewardIndex;
            return n;
        }
        finally {
            this.readUnlock();
        }
    }

    public int getNextRewardIndex() {
        this.readLock();
        try {
            int n = this._nextRewardIndex;
            return n;
        }
        finally {
            this.readUnlock();
        }
    }

    public boolean isAvailable() {
        return this.getNextRewardIndex() > 0;
    }

    public boolean isReceived() {
        return this.getReceivedRewardIndex() == this.getNextRewardIndex();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean receiveReward() {
        this.writeLock();
        try {
            if (!this.isAvailable()) {
                boolean bl = false;
                return bl;
            }
            if (this.isReceived()) {
                boolean bl = false;
                return bl;
            }
            AttendanceRewardData reward = AttendanceRewardHolder.getInstance().getReward(this.getNextRewardIndex(), this._owner.hasPremiumAccount());
            if (reward == null) {
                this._owner.sendPacket((IBroadcastPacket)SystemMsg.DUE_TO_A_SYSTEM_ERROR_THE_ATTENDANCE_REWARD_CANNOT_BE_RECEIVED_PLEASE_TRY_AGAIN_LATER_BY_GOING_TO_MENU__ATTENDANCE_CHECK);
                boolean bl = false;
                return bl;
            }
            if (!this._owner.hasPremiumAccount() && this._loginDelayTask != null && !this._loginDelayTask.isDone()) {
                int receiveDelay = (int)this._loginDelayTask.getDelay(TimeUnit.MINUTES) + 1;
                this._owner.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.YOU_CAN_REDEEM_YOUR_REWARD_S1_MINUTES_AFTER_LOGGING_IN_S2_MINUTES_LEFT).addInteger(30.0)).addInteger(receiveDelay));
                boolean bl = false;
                return bl;
            }
            if (this._owner.isInventoryFull()) {
                this._owner.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTENDANCE_REWARD_CANNOT_BE_RECEIVED_BECAUSE_THE_INVENTORY_WEIGHTQUANTITY_LIMIT_HAS_BEEN_EXCEEDED);
                boolean bl = false;
                return bl;
            }
            this._receivedRewardIndex = this.getNextRewardIndex();
            if (Config.VIP_ATTENDANCE_REWARDS_REWARD_BY_ACCOUNT) {
                AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_ATTENDANCE_REWARD_INDEX_VAR, String.valueOf(this.getReceivedRewardIndex()));
                AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_ATTENDANCE_REWARD_DATE_VAR, String.valueOf((int)(System.currentTimeMillis() / 1000L)));
            } else {
                this._owner.setVar(VIP_ATTENDANCE_REWARD_INDEX_VAR, String.valueOf(this.getReceivedRewardIndex()));
                this._owner.setVar(VIP_ATTENDANCE_REWARD_DATE_VAR, String.valueOf((int)(System.currentTimeMillis() / 1000L)));
            }
            if (!this._owner.hasPremiumAccount()) {
                this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUVE_RECEIVED_YOUR_ATTENDANCE_REWARD_FOR_DAY_S1_).addInteger(this.getReceivedRewardIndex()));
            } else {
                this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUVE_RECEIVED_YOUR_PC_CAF_ATTENDANCE_REWARD_FOR_DAY_S1_).addInteger(this.getReceivedRewardIndex()));
            }
            this._owner.sendPacket((IBroadcastPacket)new ExConfirmVipAttendanceCheck(true, this.getReceivedRewardIndex()));
            ItemFunctions.addItem(this._owner, reward.getId(), reward.getCount(), true);
        }
        finally {
            this.writeUnlock();
        }
        this.startTasks();
        return true;
    }

    public void sendRewardsList(boolean force) {
        if (this.isAvailable()) {
            if (force || !this.isReceived()) {
                this._owner.sendPacket((IBroadcastPacket)new ExVipAttendanceItemList(this._owner));
            }
        } else if (force) {
            this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_NO_LONGER_RECEIVE_ATTENDANCE_CHECK_REWARDS_);
        }
    }

    public void onEnterWorld() {
        if (this.isAvailable() && !this.isReceived()) {
            this._owner.sendPacket((IBroadcastPacket)new ExVipAttendanceItemList(this._owner));
            if (!this._owner.hasPremiumAccount()) {
                this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_DAY_S1_ATTENDANCE_REWARD_IS_READY_CLICK_ON_THE_REWARDS_ICON).addInteger(this.getNextRewardIndex()));
            } else {
                this._owner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_DAY_S1_PC_CAF_ATTENDANCE_REWARD_IS_READY_CLICK_ON_THE_REWARDS_ICON).addInteger(this.getNextRewardIndex()));
            }
        }
    }

    public void startTasks() {
        this.stopTasks();
        if (this.isAvailable()) {
            if (!this.isReceived()) {
                long loginDelay = this._owner.getOnlineBeginTime() + 1800000L - System.currentTimeMillis();
                if (loginDelay > 0L) {
                    this._loginDelayTask = ThreadPoolManager.getInstance().schedule(() -> this._owner.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAN_REDEEM_YOUR_REWARD_NOW), loginDelay);
                }
            } else {
                long nextRewardDelay = VIP_ATTENDANCE_DATE_PATTERN.next(System.currentTimeMillis()) - System.currentTimeMillis();
                this._getNextRewardIndexTask = ThreadPoolManager.getInstance().schedule(() -> {
                    this.restore();
                    this.onEnterWorld();
                }, nextRewardDelay);
            }
        }
    }

    public void stopTasks() {
        if (this._loginDelayTask != null) {
            this._loginDelayTask.cancel(false);
            this._loginDelayTask = null;
        }
        if (this._getNextRewardIndexTask != null) {
            this._getNextRewardIndexTask.cancel(false);
            this._getNextRewardIndexTask = null;
        }
    }

    public void onReceivePremiumAccount() {
        this.restore();
        this.startTasks();
    }

    public void onRemovePremiumAccount() {
        this.restore();
        this.startTasks();
    }

    public final void writeLock() {
        this.writeLock.lock();
    }

    public final void writeUnlock() {
        this.writeLock.unlock();
    }

    public final void readLock() {
        this.readLock.lock();
    }

    public final void readUnlock() {
        this.readLock.unlock();
    }
}

