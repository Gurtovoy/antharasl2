/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.PremiumAccountTemplate;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public class PremiumAccountHolder
extends AbstractHolder {
    private static final PremiumAccountHolder _instance = new PremiumAccountHolder();
    private final IntObjectMap<PremiumAccountTemplate> _premiumAccounts = new TreeIntObjectMap();

    public static PremiumAccountHolder getInstance() {
        return _instance;
    }

    public void addPremiumAccount(PremiumAccountTemplate premiumAccount) {
        this._premiumAccounts.put(premiumAccount.getType(), premiumAccount);
    }

    public PremiumAccountTemplate getPremiumAccount(int type) {
        if (type == 0 && !this._premiumAccounts.containsKey(type)) {
            return PremiumAccountTemplate.DEFAULT_ACCOUNT_TEMPLATE;
        }
        return (PremiumAccountTemplate)this._premiumAccounts.get(type);
    }

    public Collection<PremiumAccountTemplate> getPremiumAccounts() {
        return this._premiumAccounts.valueCollection();
    }

    public int size() {
        return this._premiumAccounts.size();
    }

    public void clear() {
        this._premiumAccounts.clear();
    }
}

