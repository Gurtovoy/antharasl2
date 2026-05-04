/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.player;

import l2s.gameserver.templates.HennaTemplate;

public class Henna
implements Comparable<Henna> {
    private final HennaTemplate _template;
    private final int _drawTime;
    private final boolean _isPremium;

    public Henna(HennaTemplate template, int drawTime, boolean isPremium) {
        this._template = template;
        this._drawTime = drawTime;
        this._isPremium = isPremium;
    }

    public HennaTemplate getTemplate() {
        return this._template;
    }

    public int getDrawTime() {
        return this._drawTime;
    }

    public boolean isPremium() {
        return this._isPremium;
    }

    public int getLeftTime() {
        return this._template.getPeriod() > 0 ? (int)((long)(this.getDrawTime() + this._template.getPeriod() * 60 * 60) - System.currentTimeMillis() / 1000L) : Integer.MAX_VALUE;
    }

    public static String toString(int symbolId, int drawTime, boolean premium) {
        return "Henna[symbolId=" + symbolId + ", drawTime=" + drawTime + ", isPremium=" + premium + "]";
    }

    public String toString() {
        return Henna.toString(this._template.getSymbolId(), this._drawTime, this._isPremium);
    }

    @Override
    public int compareTo(Henna o) {
        return this.getDrawTime() - o.getDrawTime();
    }
}

