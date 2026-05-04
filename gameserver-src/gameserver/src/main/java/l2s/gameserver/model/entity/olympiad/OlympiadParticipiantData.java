/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.olympiad;

import l2s.gameserver.model.entity.olympiad.OlympiadPlayerData;

public class OlympiadParticipiantData
extends OlympiadPlayerData {
    private int _points = 0;
    private int _pointsPast = 0;
    private int _pointsPastStatic = 0;
    private int _compDone = 0;
    private int _compWin = 0;
    private int _compLoose = 0;
    private int _classedGamesCount = 0;
    private int _nonClassedGamesCount = 0;

    public OlympiadParticipiantData(int objectId, String name, int classId) {
        super(objectId, name, classId);
    }

    public int getPoints() {
        return this._points;
    }

    public void setPoints(int value) {
        this._points = value;
    }

    public int getPointsPast() {
        return this._pointsPast;
    }

    public void setPointsPast(int value) {
        this._pointsPast = value;
    }

    public int getPointsPastStatic() {
        return this._pointsPastStatic;
    }

    public void setPointsPastStatic(int value) {
        this._pointsPastStatic = value;
    }

    public int getCompDone() {
        return this._compDone;
    }

    public void setCompDone(int value) {
        this._compDone = value;
    }

    public int getCompWin() {
        return this._compWin;
    }

    public void setCompWin(int value) {
        this._compWin = value;
    }

    public int getCompLoose() {
        return this._compLoose;
    }

    public void setCompLoose(int value) {
        this._compLoose = value;
    }

    public int getClassedGamesCount() {
        return this._classedGamesCount;
    }

    public void setClassedGamesCount(int value) {
        this._classedGamesCount = value;
    }

    public int getNonClassedGamesCount() {
        return this._nonClassedGamesCount;
    }

    public void setNonClassedGamesCount(int value) {
        this._nonClassedGamesCount = value;
    }
}

