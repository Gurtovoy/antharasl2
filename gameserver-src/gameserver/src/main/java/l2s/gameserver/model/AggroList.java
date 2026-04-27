/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntObjectIterator
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.collections.LazyArrayList
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.model;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.util.Rnd;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectTasks;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.instances.NpcInstance;

public class AggroList {
    private final NpcInstance _npc;
    private final TIntObjectHashMap<AggroInfo> _hateList = new TIntObjectHashMap();
    private final Map<Party, PartyDamage> _partyDamageMap = new HashMap<Party, PartyDamage>();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();
    private AggroInfo _mostHated = null;

    public AggroList(NpcInstance npc) {
        this._npc = npc;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void addDamageHate(Creature attacker, int damage, int aggro) {
        if ((damage = Math.max(damage, 0)) == 0 && aggro == 0) {
            return;
        }
        if (attacker.isConfused()) {
            return;
        }
        this.writeLock.lock();
        try {
            Party party;
            AggroInfo ai = (AggroInfo)this._hateList.get(attacker.getObjectId());
            if (ai == null) {
                ai = new AggroInfo(attacker);
                this._hateList.put(attacker.getObjectId(), ai);
            }
            if (attacker.getPlayer() != null && (party = attacker.getPlayer().getParty()) != null) {
                PartyDamage pd = this._partyDamageMap.get(party);
                if (pd == null) {
                    pd = new PartyDamage(party);
                    this._partyDamageMap.put(party, pd);
                }
                pd.damage += damage;
            }
            ai.damage += damage;
            ai.hate += aggro;
            ai.damage = Math.max(ai.damage, 0);
            ai.hate = Math.max(ai.hate, 0);
            if (aggro > 0 && (this._mostHated == null || this._mostHated != ai && ai.hate > this._mostHated.hate)) {
                this._mostHated = ai;
                ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this._npc, CtrlEvent.EVT_MOST_HATED_CHANGED));
            }
        }
        finally {
            this.writeLock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void reduceHate(Creature target, int hate) {
        this.writeLock.lock();
        try {
            AggroInfo ai = (AggroInfo)this._hateList.get(target.getObjectId());
            if (ai != null) {
                ai.hate -= hate;
                ai.hate = Math.max(ai.hate, 0);
                if (ai == this._mostHated) {
                    AggroInfo mostHatedInfo;
                    Creature mostHated = this.getMostHated(-1);
                    if (mostHated != null && (mostHatedInfo = this.get(mostHated)) != null && mostHatedInfo != ai && mostHatedInfo.hate > ai.hate) {
                        this._mostHated = mostHatedInfo;
                        ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this._npc, CtrlEvent.EVT_MOST_HATED_CHANGED));
                        return;
                    }
                    if (ai.hate <= 0) {
                        ThreadPoolManager.getInstance().execute(new GameObjectTasks.NotifyAITask(this._npc, CtrlEvent.EVT_MOST_HATED_CHANGED));
                    }
                }
            }
        }
        finally {
            this.writeLock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public int getHate(Creature target) {
        int hate = 0;
        this.writeLock.lock();
        try {
            AggroInfo ai = (AggroInfo)this._hateList.get(target.getObjectId());
            if (ai != null) {
                hate = ai.hate;
            }
        }
        finally {
            this.writeLock.unlock();
        }
        return hate;
    }

    public AggroInfo get(Creature attacker) {
        this.readLock.lock();
        try {
            AggroInfo aggroInfo = (AggroInfo)this._hateList.get(attacker.getObjectId());
            return aggroInfo;
        }
        finally {
            this.readLock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void remove(int objectId, boolean onlyHate) {
        this.writeLock.lock();
        try {
            if (!onlyHate) {
                this._hateList.remove(objectId);
                return;
            }
            AggroInfo ai = (AggroInfo)this._hateList.get(objectId);
            if (ai != null) {
                if (ai.damage == 0) {
                    this._hateList.remove(objectId);
                } else {
                    ai.hate = 0;
                }
            }
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public void remove(Creature attacker, boolean onlyHate) {
        this.remove(attacker.getObjectId(), onlyHate);
    }

    public void clear() {
        this.clear(false);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void clear(boolean onlyHate) {
        this.writeLock.lock();
        try {
            if (this._hateList.isEmpty()) {
                return;
            }
            if (!onlyHate) {
                this._hateList.clear();
                return;
            }
            TIntObjectIterator itr = this._hateList.iterator();
            while (itr.hasNext()) {
                itr.advance();
                AggroInfo ai = (AggroInfo)itr.value();
                ai.hate = 0;
                if (ai.damage != 0) continue;
                itr.remove();
            }
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public boolean isEmpty() {
        this.readLock.lock();
        try {
            boolean bl = this._hateList.isEmpty();
            return bl;
        }
        finally {
            this.readLock.unlock();
        }
    }

    private Creature getOrRemoveHated(int objectId) {
        GameObject object = GameObjectsStorage.findObject(objectId);
        if (object == null || !object.isCreature()) {
            this.remove(objectId, true);
            return null;
        }
        Creature cha = (Creature)object;
        if (cha.isPlayable() && ((Playable)cha).isInNonAggroTime()) {
            this.remove(objectId, true);
            return null;
        }
        if (cha.isPlayer() && !((Player)cha).isOnline()) {
            this.remove(objectId, true);
            return null;
        }
        return cha;
    }

    public List<Creature> getHateList(int radius) {
        AggroInfo[] hated;
        this.readLock.lock();
        try {
            hated = (AggroInfo[])this._hateList.values(new AggroInfo[this._hateList.size()]);
        }
        finally {
            this.readLock.unlock();
        }
        if (hated.length == 0) {
            return Collections.emptyList();
        }
        try {
            Arrays.sort(hated, HateComparator.getInstance());
        }
        catch (Exception e) {
            // empty catch block
        }
        if (hated[0].hate == 0) {
            return Collections.emptyList();
        }
        LazyArrayList tempList = new LazyArrayList();
        for (AggroInfo ai : hated) {
            Creature cha;
            if (ai.hate == 0 || (cha = this.getOrRemoveHated(ai.attackerId)) == null || radius != -1 && !cha.isInRangeZ(this._npc.getLoc(), radius)) continue;
            tempList.add(cha);
            break;
        }
        return tempList;
    }

    public Creature getMostHated(int radius) {
        AggroInfo[] hated;
        this.readLock.lock();
        try {
            hated = (AggroInfo[])this._hateList.values(new AggroInfo[this._hateList.size()]);
        }
        finally {
            this.readLock.unlock();
        }
        if (hated.length == 0) {
            return null;
        }
        try {
            Arrays.sort(hated, HateComparator.getInstance());
        }
        catch (Exception exception) {
            // empty catch block
        }
        if (hated[0].hate == 0) {
            return null;
        }
        for (AggroInfo ai : hated) {
            Creature cha;
            if (ai.hate == 0 || (cha = this.getOrRemoveHated(ai.attackerId)) == null || radius != -1 && !cha.isInRangeZ(this._npc.getLoc(), radius) || cha.isDead()) continue;
            return cha;
        }
        return null;
    }

    public Creature getRandomHated(int radius) {
        AggroInfo[] hated;
        this.readLock.lock();
        try {
            hated = (AggroInfo[])this._hateList.values(new AggroInfo[this._hateList.size()]);
        }
        finally {
            this.readLock.unlock();
        }
        if (hated.length == 0) {
            return null;
        }
        try {
            Arrays.sort(hated, HateComparator.getInstance());
        }
        catch (Exception e) {
            // empty catch block
        }
        if (hated[0].hate == 0) {
            return null;
        }
        LazyArrayList randomHated = LazyArrayList.newInstance();
        for (AggroInfo ai : hated) {
            Creature cha;
            if (ai.hate == 0 || (cha = this.getOrRemoveHated(ai.attackerId)) == null || radius != -1 && !cha.isInRangeZ(this._npc.getLoc(), radius) || cha.isDead()) continue;
            randomHated.add(cha);
            break;
        }
        Creature mostHated = randomHated.isEmpty() ? null : (Creature)randomHated.get(Rnd.get((int)randomHated.size()));
        LazyArrayList.recycle((LazyArrayList)randomHated);
        return mostHated;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Creature getTopDamager(Creature defaultDamager) {
        PartyDamage[] partyDmg;
        AggroInfo[] hated;
        this.readLock.lock();
        try {
            hated = (AggroInfo[])this._hateList.values(new AggroInfo[this._hateList.size()]);
        }
        finally {
            this.readLock.unlock();
        }
        if (hated.length == 0) {
            return defaultDamager;
        }
        try {
            Arrays.sort(hated, DamageComparator.getInstance());
        }
        catch (Exception e) {
            // empty catch block
        }
        if (hated[0].damage == 0) {
            return defaultDamager;
        }
        Creature topDamager = defaultDamager;
        int topDamage = 0;
        List<Creature> chars = World.getAroundCharacters(this._npc);
        block11: for (AggroInfo ai : hated) {
            for (Creature cha : chars) {
                if (cha.getObjectId() != ai.attackerId) continue;
                topDamager = cha;
                topDamage = ai.damage;
                break block11;
            }
        }
        this.readLock.lock();
        try {
            if (this._partyDamageMap.isEmpty()) {
                Creature creature = topDamager;
                return creature;
            }
            partyDmg = this._partyDamageMap.values().toArray(new PartyDamage[this._partyDamageMap.size()]);
        }
        finally {
            this.readLock.unlock();
        }
        try {
            Arrays.sort(partyDmg, DamageComparator.getInstance());
        }
        catch (Exception e) {
            // empty catch block
        }
        for (PartyDamage pd : partyDmg) {
            if (pd.damage <= topDamage) continue;
            for (AggroInfo ai : hated) {
                for (Player player : pd.party.getPartyMembers()) {
                    if (player.getObjectId() != ai.attackerId || !chars.contains(player)) continue;
                    return player;
                }
            }
        }
        return topDamager;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Map<Creature, HateInfo> getCharMap() {
        if (this.isEmpty()) {
            return Collections.emptyMap();
        }
        HashMap<Creature, HateInfo> aggroMap = new HashMap<Creature, HateInfo>();
        List<Creature> chars = World.getAroundCharacters(this._npc);
        this.readLock.lock();
        try {
            TIntObjectIterator itr = this._hateList.iterator();
            block3: while (itr.hasNext()) {
                itr.advance();
                AggroInfo ai = (AggroInfo)itr.value();
                if (ai.damage == 0 && ai.hate == 0) continue;
                for (Creature attacker : chars) {
                    if (attacker.getObjectId() != ai.attackerId) continue;
                    aggroMap.put(attacker, new HateInfo(attacker, ai));
                    continue block3;
                }
            }
        }
        finally {
            this.readLock.unlock();
        }
        return aggroMap;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Map<Playable, HateInfo> getPlayableMap() {
        if (this.isEmpty()) {
            return Collections.emptyMap();
        }
        HashMap<Playable, HateInfo> aggroMap = new HashMap<Playable, HateInfo>();
        List<Playable> chars = World.getAroundPlayables(this._npc);
        this.readLock.lock();
        try {
            TIntObjectIterator itr = this._hateList.iterator();
            block3: while (itr.hasNext()) {
                itr.advance();
                AggroInfo ai = (AggroInfo)itr.value();
                if (ai.damage == 0 && ai.hate == 0) continue;
                for (Playable attacker : chars) {
                    if (attacker.getObjectId() != ai.attackerId) continue;
                    aggroMap.put(attacker, new HateInfo(attacker, ai));
                    continue block3;
                }
            }
        }
        finally {
            this.readLock.unlock();
        }
        return aggroMap;
    }

    public Collection<AggroInfo> getAggroInfos() {
        Collection infos;
        this.readLock.lock();
        try {
            infos = this._hateList.valueCollection();
        }
        finally {
            this.readLock.unlock();
        }
        return infos;
    }

    public Collection<PartyDamage> getPartyDamages() {
        Collection<PartyDamage> damages;
        this.readLock.lock();
        try {
            damages = this._partyDamageMap.values();
        }
        finally {
            this.readLock.unlock();
        }
        return damages;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void copy(AggroList aggroList) {
        this.writeLock.lock();
        try {
            Collection<AggroInfo> aggroInfos = aggroList.getAggroInfos();
            for (AggroInfo aggroInfo : aggroInfos) {
                this._hateList.put(aggroInfo.attackerId, aggroInfo);
            }
            Collection<PartyDamage> partyDamages = aggroList.getPartyDamages();
            for (PartyDamage partyDamage : partyDamages) {
                this._partyDamageMap.put(partyDamage.party, partyDamage);
            }
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public static class HateComparator
    implements Comparator<DamageHate> {
        private static Comparator<DamageHate> instance = new HateComparator();

        public static Comparator<DamageHate> getInstance() {
            return instance;
        }

        @Override
        public int compare(DamageHate o1, DamageHate o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            if (o1 == o2) {
                return 0;
            }
            if (o1.hate == o2.hate) {
                return Integer.compare(o2.damage, o1.damage);
            }
            return Integer.compare(o2.hate, o1.hate);
        }
    }

    public static class DamageComparator
    implements Comparator<DamageHate> {
        private static Comparator<DamageHate> instance = new DamageComparator();

        public static Comparator<DamageHate> getInstance() {
            return instance;
        }

        @Override
        public int compare(DamageHate o1, DamageHate o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            if (o1 == o2) {
                return 0;
            }
            return Integer.compare(o2.damage, o1.damage);
        }
    }

    public static class PartyDamage
    extends DamageHate {
        public final Party party;

        PartyDamage(Party party) {
            this.party = party;
        }
    }

    public static class AggroInfo
    extends DamageHate {
        public final int attackerId;

        AggroInfo(Creature attacker) {
            this.attackerId = attacker.getObjectId();
        }
    }

    public static class HateInfo
    extends DamageHate {
        public final Creature attacker;

        HateInfo(Creature attacker, AggroInfo ai) {
            this.attacker = attacker;
            this.hate = ai.hate;
            this.damage = ai.damage;
        }
    }

    private static abstract class DamageHate {
        public int hate;
        public int damage;

        private DamageHate() {
        }
    }
}

