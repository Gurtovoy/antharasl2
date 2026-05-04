package l2s.gameserver.model.actor.instances.player;

import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDailyMissionsDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.dailymissions.DailyMissionStatus;
import l2s.gameserver.templates.dailymissions.DailyMissionTemplate;

public class DailyMission
implements Comparable<DailyMission> {
    private final Player _owner;
    private final DailyMissionTemplate _template;
    private final boolean _finallyCompleted;
    private boolean _completed;
    private int _value;

    public DailyMission(Player owner, DailyMissionTemplate template, boolean completed, int value) {
        this._owner = owner;
        this._template = template;
        this._completed = completed;
        this._value = value;
        this._finallyCompleted = completed && !this._template.getHandler().isReusable();
    }

    public int getId() {
        return this._template.getId();
    }

    public DailyMissionTemplate getTemplate() {
        return this._template;
    }

    public void setCompleted(boolean value) {
        this._completed = value;
    }

    public boolean isCompleted() {
        if (this._completed) {
            if (this._template.getHandler().isReusable()) {
                int value = this.getValue();
                long reuseTime = this._template.getHandler().getReusePattern().next((long)value * 1000L);
                if (reuseTime <= System.currentTimeMillis()) {
                    this.setValue(0);
                    this.setCompleted(false);
                    if (!CharacterDailyMissionsDAO.getInstance().insert(this._owner, this)) {
                        this.setValue(value);
                        this.setCompleted(true);
                        return true;
                    }
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    public boolean isFinallyCompleted() {
        return this._finallyCompleted;
    }

    public void setValue(int value) {
        this._value = value;
    }

    public int getValue() {
        return this._value;
    }

    public DailyMissionStatus getStatus() {
        if (!Config.EX_USE_TO_DO_LIST) {
            return DailyMissionStatus.NOT_AVAILABLE;
        }
        if (this._owner.getLevel() < this._template.getMinLevel() || this._owner.getLevel() > this._template.getMaxLevel()) {
            return DailyMissionStatus.NOT_AVAILABLE;
        }
        return this._template.getHandler().getStatus(this._owner, this);
    }

    public int getRequiredProgress() {
        return this._template.getValue();
    }

    public int getCurrentProgress() {
        if (!Config.EX_USE_TO_DO_LIST) {
            return 0;
        }
        if (this.isCompleted()) {
            return this.getRequiredProgress();
        }
        return this._template.getHandler().getProgress(this._owner, this);
    }

    public String toString() {
        return "DailyMission[id=" + this._template.getId() + ", completed=" + this._completed + ", value=" + this._value + "]";
    }

    @Override
    public int compareTo(DailyMission o) {
        return this.getId() - o.getId();
    }
}

