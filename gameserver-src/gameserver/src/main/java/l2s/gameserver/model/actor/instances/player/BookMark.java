package l2s.gameserver.model.actor.instances.player;

import l2s.gameserver.geometry.Location;

public class BookMark {
    public final int x;
    public final int y;
    public final int z;
    private int icon;
    private String name;
    private String acronym;

    public BookMark(Location loc, int aicon, String aname, String aacronym) {
        this(loc.x, loc.y, loc.z, aicon, aname, aacronym);
    }

    public BookMark(int _x, int _y, int _z, int aicon, String aname, String aacronym) {
        this.x = _x;
        this.y = _y;
        this.z = _z;
        this.setIcon(aicon);
        this.setName(aname);
        this.setAcronym(aacronym);
    }

    public BookMark setIcon(int val) {
        this.icon = val;
        return this;
    }

    public int getIcon() {
        return this.icon;
    }

    public BookMark setName(String val) {
        this.name = val.length() > 32 ? val.substring(0, 32) : val;
        return this;
    }

    public String getName() {
        return this.name;
    }

    public BookMark setAcronym(String val) {
        this.acronym = val.length() > 4 ? val.substring(0, 4) : val;
        return this;
    }

    public String getAcronym() {
        return this.acronym;
    }
}

