package l2s.gameserver.model.actor.instances.player;

import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.templates.agathion.AgathionTemplate;

public class Agathion
extends Cubic {
    public Agathion(Player owner, AgathionTemplate template, Skill skill) {
        super(owner, template, skill);
    }

    public int getNpcId() {
        return this.getTemplate().getNpcId();
    }

    @Override
    public AgathionTemplate getTemplate() {
        return (AgathionTemplate)this._template;
    }

    @Override
    public void init() {
        this._owner.setAgathion(this);
        if (this._task == null) {
            this._task = ThreadPoolManager.getInstance().scheduleAtFixedRate(this, 1000L, 1000L);
        }
    }

    @Override
    public void delete() {
        if (this._task != null) {
            this._task.cancel(true);
            this._task = null;
        }
        if (this._castTask != null) {
            this._castTask.cancel(true);
            this._castTask = null;
        }
        this._owner.setAgathion(null);
    }

    @Override
    public boolean isCubic() {
        return false;
    }

    @Override
    public boolean isAgathion() {
        return true;
    }
}

