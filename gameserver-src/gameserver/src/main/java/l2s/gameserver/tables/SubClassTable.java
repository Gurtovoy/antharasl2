/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.TIntCollection
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  gnu.trove.set.TIntSet
 *  gnu.trove.set.hash.TIntHashSet
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.tables;

import gnu.trove.TIntCollection;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.util.Arrays;
import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.SubClass;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.Race;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class SubClassTable {
    private static final Logger _log = LoggerFactory.getLogger(SubClassTable.class);
    private static SubClassTable _instance;
    private TIntObjectMap<TIntSet> _subClasses;

    public SubClassTable() {
        this.init();
    }

    public static SubClassTable getInstance() {
        if (_instance == null) {
            _instance = new SubClassTable();
        }
        return _instance;
    }

    private void init() {
        this._subClasses = new TIntObjectHashMap();
        for (ClassId baseClassId : ClassId.VALUES) {
            if (baseClassId.isDummy() || baseClassId.isOfLevel(ClassLevel.NONE) || baseClassId.isOfLevel(ClassLevel.FIRST)) continue;
            TIntHashSet availSubs = new TIntHashSet();
            for (ClassId subClassId : ClassId.VALUES) {
                if (subClassId.isDummy() || subClassId.isOfLevel(ClassLevel.NONE) || subClassId.isOfLevel(ClassLevel.FIRST) || !SubClassTable.areClassesComportable(baseClassId, subClassId)) continue;
                availSubs.add(subClassId.getId());
            }
            this._subClasses.put(baseClassId.getId(), availSubs);
        }
        _log.info("SubClassTable: Loaded " + this._subClasses.size() + " sub-classes variations.");
    }

    public int[] getAvailableSubClasses(Player player, int classId) {
        TIntSet subClassesList = (TIntSet)this._subClasses.get(classId);
        if (subClassesList == null || subClassesList.isEmpty()) {
            return new int[0];
        }
        TIntHashSet tempSubClassesList = new TIntHashSet(subClassesList.size());
        tempSubClassesList.addAll((TIntCollection)subClassesList);
        block0: for (int clsId : tempSubClassesList.toArray()) {
            ClassId subClassId = ClassId.VALUES[clsId];
            if (subClassId.getClassLevel() != ClassLevel.SECOND) {
                tempSubClassesList.remove(clsId);
                continue;
            }
            if (player.getRace() == Race.ELF && subClassId.isOfRace(Race.DARKELF) || player.getRace() == Race.DARKELF && subClassId.isOfRace(Race.ELF)) {
                tempSubClassesList.remove(clsId);
                continue;
            }
            Collection<SubClass> playerSubClasses = player.getSubClassList().values();
            for (SubClass playerSubClass : playerSubClasses) {
                ClassId playerSubClassId = ClassId.VALUES[playerSubClass.getClassId()];
                if (SubClassTable.areClassesComportable(playerSubClassId, subClassId)) continue;
                tempSubClassesList.remove(clsId);
                continue block0;
            }
        }
        int[] result = tempSubClassesList.toArray();
        Arrays.sort(result);
        return result;
    }

    private static boolean areClassesComportable(ClassId baseClassId, ClassId subClassId) {
        if (baseClassId == subClassId) {
            return false;
        }
        if (ClassId.isKnight(baseClassId.getId()) && ClassId.isKnight(subClassId.getId())) {
            return false;
        }
        if (ClassId.isDagger(baseClassId.getId()) && ClassId.isDagger(subClassId.getId())) {
            return false;
        }
        if (ClassId.isBow(baseClassId.getId()) && ClassId.isBow(subClassId.getId())) {
            return false;
        }
        if (ClassId.isDance(baseClassId.getId()) && ClassId.isDance(subClassId.getId())) {
            return false;
        }
        if (ClassId.isWizard(baseClassId.getId()) && ClassId.isWizard(subClassId.getId())) {
            return false;
        }
        if (ClassId.isSummoner(baseClassId.getId()) && ClassId.isSummoner(subClassId.getId())) {
            return false;
        }
        if (ClassId.isHalfHealer(baseClassId.getId()) && ClassId.isHalfHealer(subClassId.getId())) {
            return false;
        }
        if (subClassId == ClassId.OVERLORD || subClassId == ClassId.WARSMITH) {
            return false;
        }
        return subClassId != ClassId.MAESTRO && subClassId != ClassId.DOMINATOR;
    }
}

