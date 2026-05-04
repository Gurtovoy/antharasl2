/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates;

import l2s.gameserver.network.l2.components.SystemMsg;

public class BotPunishment {
    private final int _needReportPoints;
    private final int _skillId;
    private final int _skillLevel;
    private final SystemMsg _message;

    public BotPunishment(int needReportPoints, int skillId, int skillLevel, SystemMsg message) {
        this._needReportPoints = needReportPoints;
        this._skillId = skillId;
        this._skillLevel = skillLevel;
        this._message = message;
    }

    public int getNeedReportPoints() {
        return this._needReportPoints;
    }

    public int getSkillId() {
        return this._skillId;
    }

    public int getSkillLevel() {
        return this._skillLevel;
    }

    public SystemMsg getMessage() {
        return this._message;
    }
}

