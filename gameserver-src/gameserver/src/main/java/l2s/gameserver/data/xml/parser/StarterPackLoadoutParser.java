package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.StarterPackLoadoutHolder;
import org.dom4j.Element;

public final class StarterPackLoadoutParser extends AbstractParser<StarterPackLoadoutHolder> {
    private static final StarterPackLoadoutParser _instance = new StarterPackLoadoutParser();

    public static StarterPackLoadoutParser getInstance() {
        return _instance;
    }

    private StarterPackLoadoutParser() {
        super(StarterPackLoadoutHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/starter_pack_loadout.xml");
    }

    public String getDTDFileName() {
        return "starter_pack_loadout.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        StarterPackLoadoutHolder holder = (StarterPackLoadoutHolder)this.getHolder();
        Element settingsElement = rootElement.element("settings");
        if (settingsElement != null) {
            holder.setLevel(this.parseInt(settingsElement, "level", 10));
        }
        Iterator loadoutIt = rootElement.elementIterator("loadout");
        while (loadoutIt.hasNext()) {
            Element loadoutElement = (Element)loadoutIt.next();
            String role = this.parseString(loadoutElement, "role", "WARRIOR").toUpperCase();
            Element weaponsElement = loadoutElement.element("weapons");
            if (weaponsElement != null) {
                Iterator weaponIt = weaponsElement.elementIterator("item");
                while (weaponIt.hasNext()) {
                    Element itemElement = (Element)weaponIt.next();
                    int itemId = this.parseInt(itemElement, "id");
                    if ("MAGE".equals(role)) {
                        holder.addMageWeapon(itemId);
                        continue;
                    }
                    holder.addWarriorWeapon(itemId);
                }
            }
            Element armorsElement = loadoutElement.element("armors");
            if (armorsElement != null) {
                Iterator packIt = armorsElement.elementIterator("pack");
                while (packIt.hasNext()) {
                    Element packElement = (Element)packIt.next();
                    String type = this.parseString(packElement, "type", "LIGHT").toUpperCase();
                    Iterator itemIt = packElement.elementIterator("item");
                    while (itemIt.hasNext()) {
                        Element itemElement = (Element)itemIt.next();
                        int itemId = this.parseInt(itemElement, "id");
                        if ("MAGIC".equals(type)) {
                            holder.addMagicArmor(itemId);
                            continue;
                        }
                        holder.addLightArmor(itemId);
                    }
                }
            }
            Element accessorysElement = loadoutElement.element("accessorys");
            if (accessorysElement != null) {
                Iterator itemIt = accessorysElement.elementIterator("item");
                while (itemIt.hasNext()) {
                    Element itemElement = (Element)itemIt.next();
                    holder.addAccessory(this.parseInt(itemElement, "id"));
                }
            }
            Element consumableElement = loadoutElement.element("consumable");
            if (consumableElement != null) {
                Element warrior = consumableElement.element("warrior_hit");
                if (warrior != null) {
                    holder.setWarriorConsumable(this.parseInt(warrior, "id", 5789), this.parseLong(warrior, "count", 10000L));
                }
                Element mage = consumableElement.element("mage_hit");
                if (mage != null) {
                    holder.setMageConsumable(this.parseInt(mage, "id", 5790), this.parseLong(mage, "count", 3000L));
                }
                Element scroll = consumableElement.element("rebuff_scroll");
                if (scroll != null) {
                    holder.setScroll(this.parseInt(scroll, "id", 29011), this.parseLong(scroll, "count", 20L), this.parseLong(scroll, "cooldown_ms", 10000L));
                }
            }
        }
    }
}
