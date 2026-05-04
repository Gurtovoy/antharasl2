package l2s.gameserver.model.actor.instances.player;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.concurrent.Future;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.PetDataHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.RidePacket;
import l2s.gameserver.network.l2.s2c.SetupGaugePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.pet.PetData;
import l2s.gameserver.templates.pet.PetLevelData;
import org.apache.commons.lang3.ArrayUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Mount {
    private static final Logger _log = LoggerFactory.getLogger(Mount.class);
    private final Player _rider;
    private final int _controlItemObjId;
    private final int _npcId;
    private final int _level;
    private final int _formId;
    private final PetLevelData _data;
    private final MountType _type;
    private int _currentFeed;
    private Future<?> _feedTask;

    public Mount(Player rider, int controlItemObjId, int npcId, int level, int currentFeed, int formId, PetLevelData data, MountType type) {
        this._rider = rider;
        this._controlItemObjId = controlItemObjId;
        this._npcId = npcId;
        this._level = level;
        this._currentFeed = currentFeed;
        this._formId = formId;
        this._data = data;
        this._type = type;
    }

    public int getControlItemObjId() {
        return this._controlItemObjId;
    }

    public int getNpcId() {
        return this._npcId;
    }

    public int getLevel() {
        return this._level;
    }

    public void setCurrentFeed(int val) {
        this._currentFeed = Math.min(this._data.getMaxMeal(), Math.max(0, val));
    }

    public int getCurrentFeed() {
        return this._currentFeed;
    }

    public int getFormId() {
        return this._formId;
    }

    public int getBattleMealConsumeOnRide() {
        return this._data.getBattleMealConsumeOnRide();
    }

    public int getWalkSpdOnRide() {
        return this._data.getWalkSpdOnRide();
    }

    public int getRunSpdOnRide() {
        return this._data.getRunSpdOnRide();
    }

    public int getWaterWalkSpdOnRide() {
        return this._data.getWaterWalkSpdOnRide();
    }

    public int getWaterRunSpdOnRide() {
        return this._data.getWaterRunSpdOnRide();
    }

    public int getFlyWalkSpdOnRide() {
        return this._data.getFlyWalkSpdOnRide();
    }

    public int getFlyRunSpdOnRide() {
        return this._data.getFlyRunSpdOnRide();
    }

    public int getAtkSpdOnRide() {
        return this._data.getAtkSpdOnRide();
    }

    public double getPAtkOnRide() {
        return this._data.getPAtkOnRide();
    }

    public double getMAtkOnRide() {
        return this._data.getMAtkOnRide();
    }

    public int getMaxHpOnRide() {
        return this._data.getMaxHpOnRide();
    }

    public int getMaxMpOnRide() {
        return this._data.getMaxMpOnRide();
    }

    public boolean isMyFeed(int itemId) {
        return ArrayUtils.contains((int[])this._data.getFood(), (int)itemId);
    }

    public MountType getType() {
        return this._type;
    }

    public boolean isOfType(MountType type) {
        return this._type == type;
    }

    public void onRide() {
        switch (this.getType()) {
            case WYVERN: {
                this._rider.setFlying(true);
                this._rider.setLoc(this._rider.getLoc().changeZ(32));
                this._rider.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 4289, 1), false);
                this._rider.sendSkillList();
            }
        }
        this._rider.unEquipWeapon();
        this._rider.broadcastUserInfo(true);
        this._rider.broadcastPacket(new RidePacket(this._rider));
        this._rider.broadcastUserInfo(true);
        this.updateStatus();
        this.startFeedTask();
    }

    public void onUnride() {
        this.onLogout();
        this._rider.setFlying(false);
        boolean sendSkillList = false;
        if (this._rider.removeSkillById(325) != null) {
            sendSkillList = true;
        }
        if (this._rider.removeSkillById(4289) != null) {
            sendSkillList = true;
        }
        if (sendSkillList) {
            this._rider.sendSkillList();
        }
        this._rider.getAbnormalList().stop(4258);
        this._rider.broadcastUserInfo(true);
        this._rider.broadcastPacket(new RidePacket(this._rider));
        this._rider.broadcastUserInfo(true);
        this._rider.sendPacket((IBroadcastPacket)new SetupGaugePacket(this._rider, SetupGaugePacket.Colors.GREEN, 0));
    }

    public void onLogout() {
        this.stopFeedTask();
        this.store();
    }

    public void onDeath() {
        this.stopFeedTask();
    }

    public void onRevive() {
        this.startFeedTask();
    }

    public void onControlItemDelete() {
        this._rider.setMount(null);
    }

    private void startFeedTask() {
        if (this._currentFeed == -1) {
            return;
        }
        if (this._feedTask != null) {
            return;
        }
        this._feedTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new FeedTask(), 10000L, 10000L);
    }

    private void stopFeedTask() {
        if (this._feedTask != null) {
            this._feedTask.cancel(false);
            this._feedTask = null;
        }
    }

    private void consumeMeal() {
        this._currentFeed -= this._rider.isInCombat() ? this._data.getBattleMealConsumeOnRide() : this._data.getNormalMealConsumeOnRide();
        if (this._currentFeed < 0) {
            this._currentFeed = 0;
        }
        this.updateStatus();
    }

    public void updateStatus() {
        int mealConsume = this._rider.isInCombat() ? this._data.getBattleMealConsumeOnRide() : this._data.getNormalMealConsumeOnRide();
        int time = this._data.getMaxMeal() / mealConsume * 60000;
        int timeLost = this._currentFeed / mealConsume * 60000;
        this._rider.sendPacket((IBroadcastPacket)new SetupGaugePacket(this._rider, SetupGaugePacket.Colors.GREEN, time, timeLost));
        this._rider.sendUserInfo(false);
    }

    public boolean isHungry() {
        if (this._controlItemObjId == 0) {
            return false;
        }
        return this._currentFeed < (int)((double)this._data.getMaxMeal() * 0.01 * (double)this._data.getHungryLimit());
    }

    private void tryFeed() {
        ItemInstance food = null;
        for (int foodId : this._data.getFood()) {
            food = this._rider.getInventory().getItemByItemId(foodId);
            if (food == null) continue;
            if (food.getTemplate().useItem(this._rider, food, false, false)) break;
            food = null;
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void store() {
        if (this._controlItemObjId == 0) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            String req = "UPDATE pets SET fed=? WHERE item_obj_id = ?";
            statement = con.prepareStatement(req);
            statement.setInt(1, this._currentFeed);
            statement.setInt(2, this._controlItemObjId);
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("Could not store mount current feed!", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public static Mount create(Player rider, int controlItemObjId, int npcId, int level, int currentFeed) {
        if (rider == null) {
            return null;
        }
        PetData template = PetDataHolder.getInstance().getTemplateByNpcId(npcId);
        if (template == null) {
            return null;
        }
        PetLevelData data = template.getLvlData(level);
        if (data == null) {
            return null;
        }
        return new Mount(rider, controlItemObjId, npcId, level, currentFeed, template.getFormId(level), data, template.getMountType());
    }

    private class FeedTask
    implements Runnable {
        private FeedTask() {
        }

        @Override
        public void run() {
            if (Mount.this.isHungry()) {
                Mount.this.tryFeed();
            }
            if (Mount.this._currentFeed <= 0) {
                Mount.this._rider.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_OUT_OF_FEED);
                Mount.this._rider.setMount(null);
                return;
            }
            Mount.this.consumeMeal();
        }
    }
}

