package l2s.gameserver.model.actor.instances.player;

import gnu.trove.iterator.TIntIntIterator;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.Future;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.CharacterHennaDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Henna;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPeriodicHenna;
import l2s.gameserver.network.l2.s2c.HennaInfoPacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.HennaTemplate;
import l2s.gameserver.utils.ItemFunctions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HennaList {
    public static final int MAX_SIZE = 3;
    private static final Logger _log = LoggerFactory.getLogger(HennaList.class);
    private static final int MAX_STAT_VALUE = 15;
    private List<Henna> _hennaList = Collections.emptyList();
    private Henna _premiumHenna = null;
    private int _str;
    private int _int;
    private int _dex;
    private int _men;
    private int _wit;
    private int _con;
    private Future<?> _removeTask;
    private final Player _owner;
    private final TIntObjectMap<SkillEntry> _skills = new TIntObjectHashMap();

    public HennaList(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        this._hennaList = new ArrayList<Henna>();
        this._premiumHenna = null;
        List<Henna> hennas = CharacterHennaDAO.getInstance().select(this._owner);
        for (Henna henna : hennas) {
            if (henna.isPremium()) {
                if (this._premiumHenna != null) {
                    _log.warn(this + ": Contains more than one premium henna!");
                }
                if (henna.getTemplate().getPeriod() == 0) {
                    _log.warn(this + ": Contains no premium henna in premium slot!");
                }
                this._premiumHenna = henna;
                continue;
            }
            this._hennaList.add(henna);
        }
        Collections.sort(this._hennaList);
        if (this._hennaList.size() > 3) {
            _log.warn(this + ": Contains more than three henna's!");
            for (int i = 3; i < this._hennaList.size(); ++i) {
                this._hennaList.remove(i);
            }
        }
        this.refreshStats(false);
        this._owner.sendPacket((IBroadcastPacket)new HennaInfoPacket(this._owner));
        this.stopHennaRemoveTask();
        this.startHennaRemoveTask();
    }

    public Henna get(int symbolId) {
        for (Henna henna : this.values(true)) {
            if (henna.getTemplate().getSymbolId() != symbolId) continue;
            return henna;
        }
        return null;
    }

    public int size() {
        return this._hennaList.size();
    }

    public int getFreeSize() {
        return Math.max(0, 3 - this.size());
    }

    public Henna[] values(boolean withPremium) {
        if (!withPremium) {
            return this._hennaList.toArray(new Henna[this._hennaList.size()]);
        }
        ArrayList<Henna> hennas = new ArrayList<Henna>(this._hennaList);
        if (this._premiumHenna != null) {
            hennas.add(this._premiumHenna);
        }
        return hennas.toArray(new Henna[hennas.size()]);
    }

    public Henna getPremiumHenna() {
        return this._premiumHenna;
    }

    public boolean isFull() {
        return this.getFreeSize() == 0;
    }

    public boolean canAdd(Henna henna) {
        if (!henna.isPremium() && this.isFull()) {
            return false;
        }
        return !henna.isPremium() || Config.EX_USE_PREMIUM_HENNA_SLOT && this._premiumHenna == null;
    }

    public boolean add(Henna henna) {
        if (!this.canAdd(henna)) {
            return false;
        }
        if (CharacterHennaDAO.getInstance().insert(this._owner, henna)) {
            if (!henna.isPremium()) {
                this._hennaList.add(henna);
                Collections.sort(this._hennaList);
            } else {
                this._premiumHenna = henna;
            }
            if (this.refreshStats(true)) {
                this._owner.sendSkillList();
            }
            return true;
        }
        return false;
    }

    public boolean remove(Henna henna) {
        long removeCount;
        if (!this.remove0(henna)) {
            return false;
        }
        if (this.refreshStats(true)) {
            this._owner.sendSkillList();
        }
        if (!henna.isPremium() && (removeCount = henna.getTemplate().getRemoveCount()) > 0L) {
            ItemFunctions.addItem(this._owner, henna.getTemplate().getDyeId(), henna.getTemplate().getRemoveCount(), true);
        }
        return true;
    }

    private boolean remove0(Henna henna) {
        if (!this._hennaList.remove(henna)) {
            if (this._premiumHenna != henna) {
                return false;
            }
            this.stopHennaRemoveTask();
            this._premiumHenna = null;
        }
        Collections.sort(this._hennaList);
        return CharacterHennaDAO.getInstance().delete(this._owner, henna);
    }

    public boolean isActive(Henna henna) {
        if (!henna.getTemplate().isForThisClass(this._owner)) {
            return false;
        }
        return !henna.isPremium() || Config.EX_USE_PREMIUM_HENNA_SLOT;
    }

    public boolean refreshStats(boolean send) {
        this._int = 0;
        this._str = 0;
        this._con = 0;
        this._men = 0;
        this._wit = 0;
        this._dex = 0;
        boolean updateSkillList = false;
        for (int skillId : this._skills.keys()) {
            if (this._owner.removeSkill(skillId, false) == null) continue;
            updateSkillList = true;
        }
        this._skills.clear();
        for (Henna henna : this.values(true)) {
            if (!this.isActive(henna)) continue;
            HennaTemplate template = henna.getTemplate();
            this._int += template.getStatINT();
            this._str += template.getStatSTR();
            this._men += template.getStatMEN();
            this._con += template.getStatCON();
            this._wit += template.getStatWIT();
            this._dex += template.getStatDEX();
            TIntIntIterator iterator = template.getSkills().iterator();
            while (iterator.hasNext()) {
                SkillEntry tempSkillEntry;
                iterator.advance();
                SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, iterator.key(), iterator.value());
                if (skillEntry == null || (tempSkillEntry = (SkillEntry)this._skills.get(skillEntry.getId())) != null && tempSkillEntry.getLevel() >= skillEntry.getLevel()) continue;
                this._skills.put(skillEntry.getId(), skillEntry);
            }
        }
        Iterator<SkillEntry> object = this._skills.valueCollection().iterator();
        while (object.hasNext()) {
            SkillEntry skillEntry = object.next();
            this._owner.addSkill(skillEntry, false);
        }
        if (!this._skills.isEmpty()) {
            updateSkillList = true;
        }
        this._int = Math.min(this._int, 15);
        this._str = Math.min(this._str, 15);
        this._con = Math.min(this._con, 15);
        this._men = Math.min(this._men, 15);
        this._wit = Math.min(this._wit, 15);
        this._dex = Math.min(this._dex, 15);
        if (send) {
            this._owner.sendPacket((IBroadcastPacket)new HennaInfoPacket(this._owner));
            this._owner.sendUserInfo(true);
        }
        return updateSkillList;
    }

    public void stopHennaRemoveTask() {
        if (this._removeTask != null) {
            this._removeTask.cancel(false);
            this._removeTask = null;
        }
    }

    private void startHennaRemoveTask() {
        if (this._premiumHenna == null) {
            return;
        }
        if (this._removeTask != null) {
            return;
        }
        this._removeTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> {
            if (this._premiumHenna.getLeftTime() <= 0) {
                if (this.remove0(this._premiumHenna) && this.refreshStats(true)) {
                    this._owner.sendSkillList();
                }
            } else {
                this._owner.sendPacket((IBroadcastPacket)new ExPeriodicHenna(this._owner));
            }
        }, 0L, 60000L);
    }

    public int getINT() {
        return this._int;
    }

    public int getSTR() {
        return this._str;
    }

    public int getCON() {
        return this._con;
    }

    public int getMEN() {
        return this._men;
    }

    public int getWIT() {
        return this._wit;
    }

    public int getDEX() {
        return this._dex;
    }

    public String toString() {
        return "HennaList[owner=" + this._owner.getName() + "]";
    }
}

