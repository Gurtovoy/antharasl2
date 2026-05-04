/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Race;

public final class InitialShortCutsHolder
extends AbstractHolder {
    private static final InitialShortCutsHolder INSTANCE = new InitialShortCutsHolder();
    private final Map<Integer, List<ShortCut>> initialShortCuts = new HashMap<Integer, List<ShortCut>>();
    private final Map<Integer, Macro> initialMacroses = new HashMap<Integer, Macro>();

    public static InitialShortCutsHolder getInstance() {
        return INSTANCE;
    }

    private static int makeHashCode(Race race, ClassType type) {
        return race.ordinal() * 100 + type.ordinal();
    }

    public void addInitialShortCut(Race race, ClassType classType, ShortCut shortCut) {
        if (race == null) {
            for (Race r : Race.VALUES) {
                if (classType == null) {
                    for (ClassType ct : ClassType.VALUES) {
                        this.addInitialShortCut0(r, ct, shortCut);
                    }
                    continue;
                }
                this.addInitialShortCut0(r, classType, shortCut);
            }
        } else {
            this.addInitialShortCut0(race, classType, shortCut);
        }
    }

    private void addInitialShortCut0(Race race, ClassType classType, ShortCut shortCut) {
        List shortCuts = this.initialShortCuts.computeIfAbsent(InitialShortCutsHolder.makeHashCode(race, classType), m -> new ArrayList());
        shortCuts.add(shortCut);
    }

    public List<ShortCut> getInitialShortCuts(Race race, ClassType classType) {
        List<ShortCut> shortCuts = this.initialShortCuts.get(InitialShortCutsHolder.makeHashCode(race, classType));
        if (shortCuts == null) {
            return Collections.emptyList();
        }
        return shortCuts;
    }

    public void addInitialMacro(Macro macro) {
        this.initialMacroses.put(macro.getId(), macro);
    }

    public Collection<Macro> getInitialMacroses() {
        return this.initialMacroses.values();
    }

    public void log() {
        HashSet shortCuts = new HashSet();
        for (Collection collection : this.initialShortCuts.values()) {
            shortCuts.addAll(collection);
        }
        this.info(String.format("loaded %d initial short cut(s) count.", shortCuts.size()));
        this.info(String.format("loaded %d initial macro(s) count.", this.initialMacroses.size()));
    }

    public int size() {
        return this.initialShortCuts.size() + this.initialMacroses.size();
    }

    public void clear() {
        this.initialShortCuts.clear();
        this.initialMacroses.clear();
    }
}

