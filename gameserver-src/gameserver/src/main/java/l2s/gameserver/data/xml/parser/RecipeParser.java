package l2s.gameserver.data.xml.parser;

import java.io.File;
import java.util.Iterator;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.data.xml.AbstractParser;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.RecipeHolder;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.RecipeTemplate;
import l2s.gameserver.templates.item.data.ChancedItemData;
import l2s.gameserver.templates.item.data.ItemData;
import org.dom4j.Element;

public final class RecipeParser
extends AbstractParser<RecipeHolder> {
    private static final RecipeParser _instance = new RecipeParser();

    public static RecipeParser getInstance() {
        return _instance;
    }

    private RecipeParser() {
        super(RecipeHolder.getInstance());
    }

    public File getXMLPath() {
        return new File(Config.DATAPACK_ROOT, "data/recipes.xml");
    }

    public String getDTDFileName() {
        return "recipes.dtd";
    }

    protected void readData(Element rootElement) throws Exception {
        Iterator iterator = rootElement.elementIterator();
        while (iterator.hasNext()) {
            Element element = (Element)iterator.next();
            int id = Integer.parseInt(element.attributeValue("id"));
            int level = Integer.parseInt(element.attributeValue("level"));
            int mpConsume = element.attributeValue("mp_consume") == null ? 0 : Integer.parseInt(element.attributeValue("mp_consume"));
            int successRate = Integer.parseInt(element.attributeValue("success_rate"));
            int itemId = Integer.parseInt(element.attributeValue("item_id"));
            boolean isCommon = element.attributeValue("is_common") == null ? false : Boolean.parseBoolean(element.attributeValue("is_common"));
            RecipeTemplate recipe = new RecipeTemplate(id, level, mpConsume, successRate, itemId, isCommon);
            Iterator subIterator = element.elementIterator();
            while (subIterator.hasNext()) {
                long count;
                int item_id;
                Element subElement = (Element)subIterator.next();
                if ("materials".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : subElement.elements()) {
                        if (!"item".equalsIgnoreCase(e.getName())) continue;
                        item_id = Integer.parseInt(e.attributeValue("id"));
                        count = Long.parseLong(e.attributeValue("count"));
                        if (Config.ALT_EASY_RECIPES && !RecipeParser.checkComponent(item_id)) continue;
                        recipe.addMaterial(new ItemData(item_id, count));
                    }
                    continue;
                }
                if ("products".equalsIgnoreCase(subElement.getName())) {
                    for (Element e : subElement.elements()) {
                        int book_id;
                        if (!"item".equalsIgnoreCase(e.getName())) continue;
                        item_id = Integer.parseInt(e.attributeValue("id"));
                        count = Long.parseLong(e.attributeValue("count"));
                        int chance = Integer.parseInt(e.attributeValue("chance"));
                        recipe.addProduct(new ChancedItemData(item_id, count, chance));
                        if (!Config.ALT_EASY_RECIPES || (book_id = RecipeParser.checkAndAddBook(item_id)) == 0) continue;
                        recipe.addMaterial(new ItemData(item_id, 1L));
                    }
                    continue;
                }
                if (!"npc_fee".equalsIgnoreCase(subElement.getName())) continue;
                for (Element e : subElement.elements()) {
                    if (!"item".equalsIgnoreCase(e.getName()) || Config.ALT_EASY_RECIPES) continue;
                    item_id = Integer.parseInt(e.attributeValue("id"));
                    count = Long.parseLong(e.attributeValue("count"));
                    recipe.addNpcFee(new ItemData(item_id, count));
                }
            }
            ((RecipeHolder)this.getHolder()).addRecipe(recipe);
        }
    }

    public static boolean checkComponent(int itemId) {
        ItemTemplate template = ItemHolder.getInstance().getTemplate(itemId);
        if (template.isRecipe()) {
            return true;
        }
        return template.isCrystall();
    }

    public static int checkAndAddBook(int itemId) {
        ItemTemplate template = ItemHolder.getInstance().getTemplate(itemId);
        if (template == null) {
            return 0;
        }
        if (template.getGrade() == ItemGrade.NONE) {
            return 0;
        }
        if (!template.isEquipable()) {
            return 0;
        }
        return RecipeParser.getBookId(template.getGrade(), template.isWeapon());
    }

    public static int getBookId(ItemGrade grade, boolean isWpn) {
        switch (grade) {
            case D: {
                if (isWpn) {
                    return 40000;
                }
                return 40001;
            }
            case C: {
                if (isWpn) {
                    return 40002;
                }
                return 40003;
            }
            case B: {
                if (isWpn) {
                    return 40004;
                }
                return 40005;
            }
            case A: {
                if (isWpn) {
                    return 40006;
                }
                return 40007;
            }
            case S: {
                if (isWpn) {
                    return 40008;
                }
                return 40009;
            }
            case S80: {
                if (isWpn) {
                    return 40010;
                }
                return 40011;
            }
            case R: {
                if (isWpn) {
                    return 40012;
                }
                return 40013;
            }
            case R95: {
                if (isWpn) {
                    return 40014;
                }
                return 40015;
            }
            case R99: {
                if (isWpn) {
                    return 40016;
                }
                return 40017;
            }
        }
        return 40000;
    }
}

