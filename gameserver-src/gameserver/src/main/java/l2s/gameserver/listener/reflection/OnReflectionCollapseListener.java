/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.listener.reflection;

import l2s.commons.listener.Listener;
import l2s.gameserver.model.entity.Reflection;

public interface OnReflectionCollapseListener
extends Listener<Reflection> {
    public void onReflectionCollapse(Reflection var1);
}

