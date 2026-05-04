package l2s.gameserver.templates.fakeplayer.actions;

import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.handler.bbs.BbsHandlerHolder;
import l2s.gameserver.handler.bbs.IBbsHandler;
import l2s.gameserver.templates.fakeplayer.actions.AbstractAction;
import org.dom4j.Element;

public class UseCommunityAction
extends AbstractAction {
    private final String _bypass;

    public UseCommunityAction(String bypass, double chance) {
        super(chance);
        this._bypass = bypass;
    }

    @Override
    public boolean performAction(FakeAI ai) {
        IBbsHandler handler = BbsHandlerHolder.getInstance().getCommunityHandler(this._bypass);
        if (handler != null) {
            handler.onBypassCommand(ai.getActor(), this._bypass);
            return true;
        }
        return false;
    }

    public static UseCommunityAction parse(Element element) {
        String bypass = element.attributeValue("bypass");
        double chance = element.attributeValue("chance") == null ? 100.0 : Double.parseDouble(element.attributeValue("chance"));
        return new UseCommunityAction(bypass, chance);
    }
}

