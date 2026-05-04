/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items;

import l2s.gameserver.model.base.Element;

public class ItemAttributes {
    private int fire;
    private int water;
    private int wind;
    private int earth;
    private int holy;
    private int unholy;

    public ItemAttributes() {
        this(0, 0, 0, 0, 0, 0);
    }

    public ItemAttributes(int fire, int water, int wind, int earth, int holy, int unholy) {
        this.fire = fire;
        this.water = water;
        this.wind = wind;
        this.earth = earth;
        this.holy = holy;
        this.unholy = unholy;
    }

    public int getFire() {
        return this.fire;
    }

    public void setFire(int fire) {
        this.fire = fire;
    }

    public int getWater() {
        return this.water;
    }

    public void setWater(int water) {
        this.water = water;
    }

    public int getWind() {
        return this.wind;
    }

    public void setWind(int wind) {
        this.wind = wind;
    }

    public int getEarth() {
        return this.earth;
    }

    public void setEarth(int earth) {
        this.earth = earth;
    }

    public int getHoly() {
        return this.holy;
    }

    public void setHoly(int holy) {
        this.holy = holy;
    }

    public int getUnholy() {
        return this.unholy;
    }

    public void setUnholy(int unholy) {
        this.unholy = unholy;
    }

    public Element getElement() {
        if (this.fire > 0) {
            return Element.FIRE;
        }
        if (this.water > 0) {
            return Element.WATER;
        }
        if (this.wind > 0) {
            return Element.WIND;
        }
        if (this.earth > 0) {
            return Element.EARTH;
        }
        if (this.holy > 0) {
            return Element.HOLY;
        }
        if (this.unholy > 0) {
            return Element.UNHOLY;
        }
        return Element.NONE;
    }

    public int getValue() {
        if (this.fire > 0) {
            return this.fire;
        }
        if (this.water > 0) {
            return this.water;
        }
        if (this.wind > 0) {
            return this.wind;
        }
        if (this.earth > 0) {
            return this.earth;
        }
        if (this.holy > 0) {
            return this.holy;
        }
        if (this.unholy > 0) {
            return this.unholy;
        }
        return 0;
    }

    public void setValue(Element element, int value) {
        switch (element) {
            case FIRE: {
                this.fire = value;
                break;
            }
            case WATER: {
                this.water = value;
                break;
            }
            case WIND: {
                this.wind = value;
                break;
            }
            case EARTH: {
                this.earth = value;
                break;
            }
            case HOLY: {
                this.holy = value;
                break;
            }
            case UNHOLY: {
                this.unholy = value;
            }
        }
    }

    public int getValue(Element element) {
        switch (element) {
            case FIRE: {
                return this.fire;
            }
            case WATER: {
                return this.water;
            }
            case WIND: {
                return this.wind;
            }
            case EARTH: {
                return this.earth;
            }
            case HOLY: {
                return this.holy;
            }
            case UNHOLY: {
                return this.unholy;
            }
        }
        return 0;
    }

    public ItemAttributes clone() {
        return new ItemAttributes(this.fire, this.water, this.wind, this.earth, this.holy, this.unholy);
    }
}

