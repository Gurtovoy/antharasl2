/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.olympiad;

import l2s.gameserver.data.string.StringsHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.utils.TimeUtils;

public class OlympiadHistory {
    private final int _objectId1;
    private final int _objectId2;
    private final int _classId1;
    private final int _classId2;
    private final String _name1;
    private final String _name2;
    private final long _gameStartTime;
    private final int _gameTime;
    private final int _gameStatus;
    private final int _gameType;

    public OlympiadHistory(int objectId1, int objectId2, int classId1, int classId2, String name1, String name2, long gameStartTime, int gameTime, int gameStatus, int gameType) {
        this._objectId1 = objectId1;
        this._objectId2 = objectId2;
        this._classId1 = classId1;
        this._classId2 = classId2;
        this._name1 = name1;
        this._name2 = name2;
        this._gameStartTime = gameStartTime;
        this._gameTime = gameTime;
        this._gameStatus = gameStatus;
        this._gameType = gameType;
    }

    public int getGameTime() {
        return this._gameTime;
    }

    public int getGameStatus() {
        return this._gameStatus;
    }

    public int getGameType() {
        return this._gameType;
    }

    public long getGameStartTime() {
        return this._gameStartTime;
    }

    public String toString(Player player, int target, int wins, int loss, int tie) {
        int team = this._objectId1 == target ? 1 : 2;
        String main = null;
        main = this._gameStatus == 0 ? StringsHolder.getInstance().getString(player, "hero.history.tie") : (team == this._gameStatus ? StringsHolder.getInstance().getString(player, "hero.history.win") : StringsHolder.getInstance().getString(player, "hero.history.loss"));
        main = main.replace("%classId%", String.valueOf(team == 1 ? this._classId2 : this._classId1));
        main = main.replace("%name%", team == 1 ? this._name2 : this._name1);
        main = main.replace("%date%", TimeUtils.toSimpleFormat(this._gameStartTime));
        int m = this._gameTime / 60;
        int s = this._gameTime % 60;
        main = main.replace("%time%", (m <= 9 ? "0" : "") + m + ":" + (s <= 9 ? "0" : "") + s);
        main = main.replace("%victory_count%", String.valueOf(wins));
        main = main.replace("%tie_count%", String.valueOf(tie));
        main = main.replace("%loss_count%", String.valueOf(loss));
        return main;
    }

    public int getObjectId1() {
        return this._objectId1;
    }

    public int getObjectId2() {
        return this._objectId2;
    }

    public int getClassId1() {
        return this._classId1;
    }

    public int getClassId2() {
        return this._classId2;
    }

    public String getName1() {
        return this._name1;
    }

    public String getName2() {
        return this._name2;
    }
}

