/*
 * This file was originally decompiled from L2S rev.[31495].
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

