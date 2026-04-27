/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.dom4j.Element
 */
package l2s.gameserver.templates.fakeplayer.actions;

import java.util.List;
import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import l2s.gameserver.utils.PositionUtils;
import org.dom4j.Element;

public class SpeakWithNpcAction
extends AbstractAction {
    private final int _npcId;
    private final String _bypass;

    public SpeakWithNpcAction(int npcId, String bypass, double chance) {
        super(chance);
        this._npcId = npcId;
        this._bypass = bypass;
    }

    @Override
    public boolean performAction(FakeAI ai) {
        Player player = ai.getActor();
        NpcInstance npc = null;
        List<NpcInstance> npcs = GameObjectsStorage.getNpcs(true, this._npcId);
        for (NpcInstance n : npcs) {
            if (npc != null && n.getDistance(player) >= npc.getDistance(player)) continue;
            npc = n;
        }
        if (npc == null) {
            return false;
        }
        player.setHeading(PositionUtils.calculateHeadingFrom(player, npc), true);
        if (!npc.isPeaceNpc() || !npc.checkInteractionDistance(player)) {
            return false;
        }
        npc.onAction(player, false);
        if (this._bypass != null) {
            npc.onBypassFeedback(player, this._bypass);
        }
        return true;
    }

    public static SpeakWithNpcAction parse(Element element) {
        int npcId = Integer.parseInt(element.attributeValue("id"));
        String bypass = element.attributeValue("bypass");
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new SpeakWithNpcAction(npcId, bypass, chance);
    }
}

