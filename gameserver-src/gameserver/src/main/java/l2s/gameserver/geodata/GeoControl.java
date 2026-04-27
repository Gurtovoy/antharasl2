/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  l2s.commons.geometry.Shape
 *  org.napile.primitive.pair.ByteObjectPair
 */
package l2s.gameserver.geodata;

import gnu.trove.map.TIntObjectMap;
import l2s.commons.geometry.Shape;
import l2s.gameserver.geodata.GeoEngine;
import org.napile.primitive.pair.ByteObjectPair;

public interface GeoControl {
    public Shape getGeoShape();

    public TIntObjectMap<ByteObjectPair<GeoEngine.CeilGeoControlType>> getGeoAround();

    public void setGeoAround(TIntObjectMap<ByteObjectPair<GeoEngine.CeilGeoControlType>> var1);

    public int getGeoControlIndex();

    public boolean isHollowGeo();
}

