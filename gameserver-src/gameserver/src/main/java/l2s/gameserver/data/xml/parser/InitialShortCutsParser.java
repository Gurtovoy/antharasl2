/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.InitialShortCutsHolder;
import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Race;
import org.apache.commons.lang3.StringUtils;
import org.dom4j.Element;

public final class InitialShortCutsParser
extends AbstractParser<InitialShortCutsHolder> {
    private static InitialShortCutsParser _instance = new InitialShortCutsParser();

    public static InitialShortCutsParser getInstance() {
        return _instance;
    }

    protected InitialShortCutsParser() {
        super(InitialShortCutsHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/pc_parameters/initial_shortcuts.xml");
    }

    public String getDTDFileName() {
        return "initial_shortcuts.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Element element;
        Iterator iterator = rootElement.elementIterator("shortcuts");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            String raceStr = this.parseString(element, "race", null);
            String typeStr = this.parseString(element, "type", null);
            Race race = StringUtils.isEmpty((CharSequence)raceStr) ? null : Race.valueOf(raceStr.toUpperCase());
            ClassType type = StringUtils.isEmpty((CharSequence)raceStr) ? null : ClassType.valueOf(typeStr.toUpperCase());
            Iterator iterator2 = element.elementIterator("page");
            while (iterator2.hasNext()) {
                Element element2 = (Element)iterator2.next();
                int pageId = this.parseInt(element2, "id");
                Iterator iterator3 = element2.elementIterator("shortcut");
                while (iterator3.hasNext()) {
                    Element element3 = (Element)iterator3.next();
                    int shortCutSlot = this.parseInt(element3, "slot");
                    ShortCut.ShortCutType shortCutType = ShortCut.ShortCutType.valueOf(this.parseString(element3, "type").toUpperCase());
                    int shortCutId = this.parseInt(element3, "id");
                    int shortCutLevel = this.parseInt(element3, "level", 0);
                    ShortCut shortCut = new ShortCut(shortCutSlot, pageId, shortCutType, shortCutId, shortCutLevel, 1);
                    ((InitialShortCutsHolder)this.getHolder()).addInitialShortCut(race, type, shortCut);
                }
            }
        }
        iterator = rootElement.elementIterator("macroses");
        while (iterator.hasNext()) {
            element = (Element)iterator.next();
            Iterator iterator2 = element.elementIterator("macro");
            while (iterator2.hasNext()) {
                Element element2 = (Element)iterator2.next();
                int id = this.parseInt(element2, "id");
                int icon = this.parseInt(element2, "icon");
                String name = this.parseString(element2, "name");
                if (StringUtils.isEmpty((CharSequence)name)) {
                    this.warn("Macro ID[" + id + "] dont have name!");
                    continue;
                }
                String description = this.parseString(element2, "description", "");
                if (description.length() > 32) {
                    this.warn("Macro ID[" + id + "] description cannot contain more than 32 characters!");
                    continue;
                }
                String acronym = this.parseString(element2, "acronym", "");
                boolean enabled = this.parseBoolean(element2, "enabled", true);
                ArrayList<Macro.L2MacroCmd> commands = new ArrayList<Macro.L2MacroCmd>();
                Iterator iterator3 = element2.elementIterator("command");
                while (iterator3.hasNext()) {
                    Element element3 = (Element)iterator3.next();
                    Macro.MacroCmdType cmdType = Macro.MacroCmdType.valueOf(this.parseString(element3, "type").toUpperCase());
                    int param1 = 0;
                    int param2 = 0;
                    String cmd = "";
                    if (cmdType == Macro.MacroCmdType.SKILL) {
                        param1 = this.parseInt(element3, "id");
                        param2 = this.parseInt(element3, "level");
                    } else if (cmdType == Macro.MacroCmdType.DELAY) {
                        param1 = this.parseInt(element3, "delay");
                    } else if (cmdType == Macro.MacroCmdType.TEXT) {
                        cmd = element3.getTextTrim();
                    } else if (cmdType == Macro.MacroCmdType.SHORTCUT) {
                        param1 = this.parseInt(element3, "page");
                        param2 = this.parseInt(element3, "slot");
                    }
                    commands.add(new Macro.L2MacroCmd(commands.size(), cmdType.ordinal(), param1, param2, cmd));
                }
                ((InitialShortCutsHolder)this.getHolder()).addInitialMacro(new Macro(id, icon, name, description, acronym, commands.toArray(new Macro.L2MacroCmd[commands.size()]), enabled));
            }
        }
    }
}

