package l2s.gameserver.model.instances;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.concurrent.Future;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.data.xml.holder.PetDataHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.actor.basestats.PetBaseStats;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.base.PetType;
import l2s.gameserver.model.instances.PetBabyInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PetInventory;
import l2s.gameserver.model.items.attachment.FlagItemAttachment;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExChangeNPCState;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.item.data.RewardItemData;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.pet.PetData;
import l2s.gameserver.templates.pet.PetSkillData;
import l2s.gameserver.utils.ItemFunctions;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PetInstance
extends Servitor {
    private static final Logger _log = LoggerFactory.getLogger(PetInstance.class);
    private static final int BASE_CORPSE_TIME = 86400;
    private final int _controlItemObjId;
    private int _currentFeed;
    private Future<?> _feedTask;
    protected PetInventory _inventory;
    private int _level;
    private boolean _respawned;
    private int lostExp;
    private PetData _data;
    private int _npcState;
    private final int _corpseTime;

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static final PetInstance restore(ItemInstance control, NpcTemplate template, Player owner) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        PetInstance pet;
        pet = null;
        con = null;
        statement = null;
        rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT objId, name, curHp, curMp, exp, sp, fed FROM pets WHERE item_obj_id=?");
            statement.setInt(1, control.getObjectId());
            rset = statement.executeQuery();
            if (!rset.next()) {
                pet = PetDataHolder.isBabyPet(template.getId()) || PetDataHolder.isImprovedBabyPet(template.getId()) || PetDataHolder.isSpecialPet(template.getId()) ? new PetBabyInstance(IdFactory.getInstance().getNextId(), template, owner, control) : new PetInstance(IdFactory.getInstance().getNextId(), template, owner, control);
            } else {
                pet = PetDataHolder.isBabyPet(template.getId()) || PetDataHolder.isImprovedBabyPet(template.getId()) || PetDataHolder.isSpecialPet(template.getId()) ? new PetBabyInstance(rset.getInt("objId"), template, owner, control, rset.getLong("exp")) : new PetInstance(rset.getInt("objId"), template, owner, control, rset.getLong("exp"));
                pet.setRespawned(true);
                String name = rset.getString("name");
                pet.setName(name == null || name.isEmpty() ? "" : name);
                pet.setCurrentHpMp(rset.getDouble("curHp"), rset.getInt("curMp"), true);
                pet.setCurrentCp(pet.getMaxCp());
                pet.setSp(rset.getInt("sp"));
                pet.setCurrentFed(rset.getInt("fed"), false);
            }
        }
        catch (Exception e) {
            _log.error("Could not restore Pet data from item: " + control + "!", (Throwable)e);
            return null;
        }
        finally {
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        return pet;
    }

    public PetInstance(int objectId, NpcTemplate template, Player owner, ItemInstance control) {
        this(objectId, template, owner, control, 0L);
    }

    public PetInstance(int objectId, NpcTemplate template, Player owner, ItemInstance control, long exp) {
        super(objectId, template, owner);
        int minLevel;
        this._data = PetDataHolder.getInstance().getTemplateByNpcId(template.getId());
        this._controlItemObjId = control.getObjectId();
        this._exp = exp;
        this._level = control.getEnchantLevel();
        if (this._level <= 0) {
            this._level = template.level;
            this._exp = this.getExpForThisLevel();
        }
        if (this._level < (minLevel = this._data.getMinLvl())) {
            this._level = minLevel;
        }
        if (this._exp < this.getExpForThisLevel()) {
            this._exp = this.getExpForThisLevel();
        }
        while (this._exp >= this.getExpForNextLevel() && this._level < Experience.getMaxLevel()) {
            ++this._level;
        }
        while (this._exp < this.getExpForThisLevel() && this._level > minLevel) {
            --this._level;
        }
        if (this._data.isOfType(PetType.KARMA) || this._data.isOfType(PetType.SPECIAL)) {
            this._level = owner.getLevel();
            this._exp = this.getExpForNextLevel();
        }
        this._inventory = new PetInventory(this);
        this._corpseTime = template.getAIParams().getInteger("corpse_time", 86400);
        this.refreshPetSkills();
    }

    public PetData getData() {
        return this._data;
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.startFeedTask();
    }

    @Override
    protected void onDespawn() {
        super.onDespawn();
        this.stopFeedTask();
    }

    private void tryFeed() {
        ItemInstance food = null;
        for (int foodId : this.getFoodId()) {
            food = this.getInventory().getItemByItemId(foodId);
            if (food == null) continue;
            if (food.getTemplate().useItem(this, food, false, false)) {
                this.getPlayer().sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_PET_WAS_HUNGRY_SO_IT_ATE_S1).addItemName(food.getItemId()));
                if (!Rnd.chance((int)5)) break;
                this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_ATE_A_LITTLE_BUT_IS_STILL_HUNGRY);
                break;
            }
            food = null;
        }
    }

    @Override
    public void addExpAndSp(long addToExp, long addToSp) {
        Player owner = this.getPlayer();
        if (this.isHungry()) {
            return;
        }
        if (this.getData().isOfType(PetType.SPECIAL)) {
            return;
        }
        this._exp += addToExp;
        this._sp = (int)((long)this._sp + addToSp);
        if (this._exp > this.getMaxExp()) {
            this._exp = this.getMaxExp();
        }
        if (addToExp > 0L || addToSp > 0L) {
            owner.sendPacket((IBroadcastPacket)new SystemMessage(1014).addNumber(addToExp));
        }
        int old_level = this._level;
        while (this._exp >= this.getExpForNextLevel() && this._level < Experience.getMaxLevel()) {
            ++this._level;
        }
        while (this._exp < this.getExpForThisLevel() && this._level > this.getMinLevel()) {
            --this._level;
        }
        if (old_level < this._level) {
            owner.sendMessage(new CustomMessage("l2s.gameserver.model.instances.L2PetInstance.PetLevelUp").addNumber(this._level));
            this.broadcastPacket(new SocialActionPacket(this.getObjectId(), 2122));
            this.setCurrentHpMp(this.getMaxHp(), this.getMaxMp());
        }
        if (old_level != this._level) {
            this.updateControlItem();
            this.refreshPetSkills();
        }
        if (addToExp > 0L || addToSp > 0L) {
            this.sendStatusUpdate();
        }
    }

    @Override
    public boolean consumeItem(int itemConsumeId, long itemCount, boolean sendMessage) {
        return this.getInventory().destroyItemByItemId(itemConsumeId, itemCount);
    }

    private void deathPenalty() {
        if (this.isInZoneBattle()) {
            return;
        }
        int lvl = this.getLevel();
        double percentLost = -0.07 * (double)lvl + 6.5;
        this.lostExp = (int)Math.round((double)(this.getExpForNextLevel() - this.getExpForThisLevel()) * percentLost / 100.0);
        this.addExpAndSp(-this.lostExp, 0L);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void destroyControlItem() {
        if (this.getControlItemObjId() == 0) {
            return;
        }
        if (!this.getPlayer().getInventory().destroyItemByObjectId(this.getControlItemObjId(), 1L)) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM pets WHERE item_obj_id=?");
            statement.setInt(1, this.getControlItemObjId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("could not delete pet:" + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    @Override
    protected void onDeath(Creature killer) {
        super.onDeath(killer);
        this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.THE_PET_HAS_BEEN_KILLED);
        if (this.getData().isOfType(PetType.SPECIAL)) {
            return;
        }
        this.stopFeedTask();
        this.deathPenalty();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public void doPickupItem(GameObject object) {
        ItemInstance item;
        Player owner = this.getPlayer();
        this.getMovement().stopMove();
        if (!object.isItem()) {
            return;
        }
        ItemInstance itemInstance = item = (ItemInstance)object;
        synchronized (itemInstance) {
            FlagItemAttachment attachment;
            if (!item.isVisible()) {
                return;
            }
            if (item.isHerb()) {
                for (SkillEntry skillEntry : item.getTemplate().getAttachedSkills()) {
                    this.altUseSkill(skillEntry, this);
                }
                item.deleteMe();
                return;
            }
            if (!this.getInventory().validateWeight(item)) {
                this.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_CANNOT_CARRY_ANY_MORE_ITEMS_);
                return;
            }
            if (!this.getInventory().validateCapacity(item)) {
                this.sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_CANNOT_CARRY_ANY_MORE_ITEMS);
                return;
            }
            if (!item.getTemplate().getHandler().pickupItem(this, item)) {
                return;
            }
            FlagItemAttachment flagItemAttachment = attachment = item.getAttachment() instanceof FlagItemAttachment ? (FlagItemAttachment)item.getAttachment() : null;
            if (attachment != null) {
                return;
            }
            item.pickupMe();
        }
        if (owner.getParty() == null || owner.getParty().getLootDistribution() == 0) {
            this.getInventory().addItem(item);
            this.sendChanges();
        } else {
            owner.getParty().distributeItem(owner, item, null);
        }
        this.broadcastPickUpMsg(item);
    }

    public void doRevive(double percent) {
        this.restoreExp(percent);
        this.doRevive();
    }

    @Override
    public void doRevive() {
        this.stopDecay();
        super.doRevive();
        this.startFeedTask();
        this.setRunning();
    }

    @Override
    public ItemInstance getActiveWeaponInstance() {
        return null;
    }

    @Override
    public WeaponTemplate getActiveWeaponTemplate() {
        return null;
    }

    public ItemInstance getControlItem() {
        Player owner = this.getPlayer();
        if (owner == null) {
            return null;
        }
        int item_obj_id = this.getControlItemObjId();
        if (item_obj_id == 0) {
            return null;
        }
        return owner.getInventory().getItemByObjectId(item_obj_id);
    }

    @Override
    public int getControlItemObjId() {
        return this._controlItemObjId;
    }

    @Override
    public int getCurrentFed() {
        if (Config.ALT_PETS_NOT_STARVING) {
            return this.getMaxFed();
        }
        return this._currentFeed;
    }

    @Override
    public long getExpForNextLevel() {
        return this._data.getExp(this._level + 1);
    }

    @Override
    public long getExpForThisLevel() {
        return this._data.getExp(this._level);
    }

    public int[] getFoodId() {
        return this._data.getFood(this._level);
    }

    @Override
    public PetInventory getInventory() {
        return this._inventory;
    }

    @Override
    public long getWearedMask() {
        return this._inventory.getWearedMask();
    }

    @Override
    public final int getLevel() {
        return this._level;
    }

    public void setLevel(int level) {
        this._level = level;
    }

    public int getMinLevel() {
        return this._data.getMinLvl();
    }

    public long getMaxExp() {
        return this._data.getExp(this._data.getMaxLvl());
    }

    @Override
    public int getMaxFed() {
        return this._data.getMaxMeal(this._level);
    }

    @Override
    public int getMaxLoad() {
        return (int)this.getStat().calc(Stats.MAX_LOAD, this._data.getMaxLoad(this._level), null, null);
    }

    @Override
    public int getInventoryLimit() {
        return Config.ALT_PET_INVENTORY_LIMIT;
    }

    @Override
    public int getSoulshotConsumeCount() {
        return this._data.getSoulshotCount(this._level);
    }

    @Override
    public int getSpiritshotConsumeCount() {
        return this._data.getSpiritshotCount(this._level);
    }

    @Override
    public ItemInstance getSecondaryWeaponInstance() {
        return null;
    }

    @Override
    public WeaponTemplate getSecondaryWeaponTemplate() {
        return null;
    }

    @Override
    public int getSkillLevel(int skillId) {
        if (this._skills == null || this._skills.get(skillId) == null) {
            return -1;
        }
        int lvl = this.getLevel();
        return lvl > 70 ? 7 + (lvl - 70) / 5 : lvl / 10;
    }

    @Override
    public int getServitorType() {
        return 2;
    }

    @Override
    public boolean isMountable() {
        return this.getData().getMountType() != MountType.NONE;
    }

    public boolean isMyFeed(int itemId) {
        return ArrayUtils.contains((int[])this.getFoodId(), (int)itemId);
    }

    public boolean isRespawned() {
        return this._respawned;
    }

    public void restoreExp(double percent) {
        if (this.lostExp != 0) {
            this.addExpAndSp((long)((double)this.lostExp * percent / 100.0), 0L);
            this.lostExp = 0;
        }
    }

    public void setCurrentFed(int num, boolean send) {
        this._currentFeed = Math.min(this.getMaxFed(), Math.max(0, num));
        this.setNpcState(this.getCurrentFed() <= 0 ? 100 : 101, send);
    }

    public void setRespawned(boolean respawned) {
        this._respawned = respawned;
    }

    @Override
    public void setSp(int sp) {
        this._sp = sp;
    }

    private void startFeedTask() {
        if (this.isDead()) {
            return;
        }
        if (this._feedTask != null) {
            return;
        }
        if (Config.ALT_PETS_NOT_STARVING) {
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
        int mealConsume = this.isInCombat() ? this._data.getBattleMealConsume(this._level) : this._data.getNormalMealConsume(this._level);
        this.setCurrentFed(this.getCurrentFed() - mealConsume, true);
        this.sendStatusUpdate();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void store() {
        if (this.getControlItemObjId() == 0 || this._exp == 0L) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            String req = !this.isRespawned() ? "INSERT INTO pets (name,curHp,curMp,exp,sp,fed,objId,item_obj_id) VALUES (?,?,?,?,?,?,?,?)" : "UPDATE pets SET name=?,curHp=?,curMp=?,exp=?,sp=?,fed=?,objId=? WHERE item_obj_id = ?";
            statement = con.prepareStatement(req);
            statement.setString(1, this.getName().equalsIgnoreCase(this.getTemplate().name) ? "" : this.getName());
            statement.setDouble(2, this.getCurrentHp());
            statement.setDouble(3, this.getCurrentMp());
            statement.setLong(4, this._exp);
            statement.setLong(5, this._sp);
            statement.setInt(6, this.getCurrentFed());
            statement.setInt(7, this.getObjectId());
            statement.setInt(8, this._controlItemObjId);
            statement.executeUpdate();
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        catch (Exception e) {
            _log.error("Could not store pet data!", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, statement);
        }
        this._respawned = true;
    }

    @Override
    protected void onDecay() {
        this.getInventory().store();
        this.destroyControlItem();
        super.onDecay();
    }

    @Override
    public void unSummon(boolean logout) {
        this.stopFeedTask();
        this.getInventory().store();
        this.store();
        super.unSummon(logout);
    }

    public void updateControlItem() {
        ItemInstance controlItem = this.getControlItem();
        if (controlItem == null) {
            return;
        }
        controlItem.setEnchantLevel(this._level);
        controlItem.setCustomType2(this.isDefaultName() ? 0 : 1);
        controlItem.setJdbcState(JdbcEntityState.UPDATED);
        controlItem.update();
        Player player = this.getPlayer();
        player.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(player, controlItem));
    }

    @Override
    public double getExpPenalty() {
        return (100.0 - (double)this._data.getExpType(this._level)) * 0.01;
    }

    @Override
    public int getFormId() {
        return this._data.getFormId(this._level);
    }

    @Override
    public boolean isPet() {
        return true;
    }

    public boolean isDefaultName() {
        return StringUtils.isEmpty((CharSequence)this._name) || this.getName().equalsIgnoreCase(this.getTemplate().name);
    }

    @Override
    public boolean isHungry() {
        return this.getCurrentFed() < (int)((double)this.getMaxFed() * 0.01 * (double)this._data.getHungryLimit(this.getLevel()));
    }

    @Override
    public int getEffectIdentifier() {
        return this.getObjectId();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public boolean useItem(ItemInstance item, boolean ctrl, boolean sendMsg) {
        if (!this._isUsingItem.compareAndSet(false, true)) {
            return false;
        }
        try {
            if (this.isAlikeDead() || this.isDead() || this.isOutOfControl()) {
                boolean bl = false;
                return bl;
            }
            ItemTemplate template = item.getTemplate();
            if (template.useItem(this, item, ctrl, true)) {
                boolean bl = true;
                return bl;
            }
            if (!item.isEquipped() && !template.testCondition(this, item, false)) {
                if (sendMsg) {
                    this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_CANNOT_CARRY_THIS_ITEM);
                }
                boolean bl = false;
                return bl;
            }
            if (this.isSharedGroupDisabled(template.getReuseGroup())) {
                boolean bl = false;
                return bl;
            }
            if (this.getPlayer().getInventory().isLockedItem(item)) {
                boolean bl = false;
                return bl;
            }
            if (template.useItem(this, item, ctrl, false)) {
                long nextTimeUse = template.getReuseType().next(item);
                if (nextTimeUse > System.currentTimeMillis()) {
                    TimeStamp timeStamp = new TimeStamp(item.getItemId(), nextTimeUse, (long)template.getReuseDelay());
                    this.addSharedGroupReuse(template.getReuseGroup(), timeStamp);
                }
                boolean bl = true;
                return bl;
            }
        }
        finally {
            this._isUsingItem.set(false);
        }
        return false;
    }

    @Override
    public boolean isNotControlled() {
        int lvlDiff = this.getLevel() - this.getPlayer().getLevel();
        if (lvlDiff >= 20) {
            return true;
        }
        return this.isHungry() && this.getCurrentFed() < (int)((double)this.getMaxFed() * 0.1);
    }

    @Override
    public int getCurrentLoad() {
        return this.getInventory().getTotalWeight();
    }

    @Override
    public int getWeightPenalty() {
        double weightproc = ((double)this.getCurrentLoad() - this.getStat().calc(Stats.MAX_NO_PENALTY_LOAD, 0.0, this, null)) / (double)this.getMaxLoad();
        if (weightproc >= 50.0) {
            return 1;
        }
        if (weightproc >= 60.0) {
            return 2;
        }
        if (weightproc >= 80.0) {
            return 3;
        }
        return 0;
    }

    public void setNpcState(int val, boolean send) {
        if (this._npcState != val) {
            if (send) {
                ExChangeNPCState packet = new ExChangeNPCState(this.getObjectId(), val);
                this.getPlayer().sendPacket((IBroadcastPacket)packet);
                this.getPlayer().broadcastPacket(packet);
            }
            this._npcState = val;
        }
    }

    @Override
    public int getNpcState() {
        return this._npcState;
    }

    @Override
    public PetBaseStats getBaseStats() {
        if (this._baseStats == null) {
            this._baseStats = new PetBaseStats(this);
        }
        return (PetBaseStats)this._baseStats;
    }

    @Override
    protected int getCorpseTime() {
        return this._corpseTime;
    }

    private void rewardOwner() {
        for (RewardItemData ci : this.getData().getExpirationRewardItems()) {
            long maxCount;
            if (!Rnd.chance((double)ci.getChance())) continue;
            long minCount = ci.getMinCount();
            long count = minCount == (maxCount = ci.getMaxCount()) ? minCount : Rnd.get((long)minCount, (long)maxCount);
            ItemFunctions.addItem(this.getPlayer(), ci.getId(), count, true);
        }
    }

    private void refreshPetSkills() {
        for (PetSkillData skillData : this._data.getSkills()) {
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillData.getId(), skillData.getLevel(this.getLevel()));
            if (skillEntry == null) continue;
            int haveSkillLevel = this.getSkillLevel(skillEntry.getId(), 0);
            if (skillEntry.getLevel() == haveSkillLevel) continue;
            this.removeSkillById(skillEntry.getId());
            this.addSkill(skillEntry);
        }
    }

    @Override
    public void onAttacked(Creature attacker) {
        if (this.isAttackingNow()) {
            return;
        }
        if (attacker == null || this.getPlayer() == null) {
            return;
        }
        if (this.getMovement().isMoving() || this.isMovementDisabled() || this.getAI().getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
            return;
        }
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        this.getMovement().moveToLocation(Location.findPointToStay(this.getPlayer().getLoc(), Config.FOLLOW_RANGE, Config.FOLLOW_RANGE, this.getGeoIndex()), 0, true);
    }

    @Override
    public void onOwnerOfAttacks(Creature target) {
        if (this.isAttackingNow()) {
            return;
        }
        if (target == null || this.getPlayer() == null) {
            return;
        }
        if (this.getMovement().isMoving() || this.isMovementDisabled() || this.getAI().getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
            return;
        }
        Player player = this.getPlayer();
        if (player == null) {
            return;
        }
        this.getMovement().moveToLocation(Location.findPointToStay(this.getPlayer().getLoc(), Config.FOLLOW_RANGE, Config.FOLLOW_RANGE, this.getGeoIndex()), 0, true);
    }

    private class FeedTask
    implements Runnable {
        private FeedTask() {
        }

        @Override
        public void run() {
            if (PetInstance.this.getData().isOfType(PetType.SPECIAL)) {
                if (PetInstance.this.getCurrentFed() <= 0) {
                    PetInstance.this.rewardOwner();
                    PetInstance.this.unSummon(false);
                    PetInstance.this.destroyControlItem();
                }
            } else {
                if (PetInstance.this.isHungry()) {
                    PetInstance.this.tryFeed();
                }
                if (PetInstance.this.getCurrentFed() <= (int)((double)PetInstance.this.getMaxFed() * 0.1)) {
                    PetInstance.this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.WHEN_YOUR_PETS_HUNGER_GAUGE_IS_AT_0_YOU_CANNOT_USE_YOUR_PET);
                } else if (PetInstance.this.getCurrentFed() <= 0) {
                    PetInstance.this.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.YOUR_PET_IS_STARVING_AND_WILL_NOT_OBEY_UNTIL_IT_GETS_ITS_FOOD);
                    return;
                }
            }
            PetInstance.this.consumeMeal();
            ItemInstance item = PetInstance.this.getControlItem();
            if (item != null && !item.getTemplate().testCondition(PetInstance.this.getPlayer(), item, false)) {
                PetInstance.this.unSummon(false);
            }
        }
    }
}

