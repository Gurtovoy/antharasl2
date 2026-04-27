/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.funcs;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.tables.EnchantHPBonusTable;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.ItemQuality;
import l2s.gameserver.templates.item.ItemType;
import l2s.gameserver.templates.item.WeaponTemplate;

public class FuncEnchant
extends Func {
    public FuncEnchant(Stats stat, int order, Object owner, double value, StatsSet params) {
        super(stat, order, owner);
    }

    @Override
    public void calc(Env env, StatModifierType modifierType) {
        ItemInstance item = (ItemInstance)this.owner;
        int enchant = env.character.isPlayer() ? item.getFixedEnchantLevel(env.character.getPlayer()) : item.getEnchantLevel();
        int overenchant = Math.max(0, enchant - 3);
        int overenchantR1 = Math.max(0, enchant - 6);
        int overenchantR2 = Math.max(0, enchant - 9);
        int overenchantR3 = Math.max(0, enchant - 12);
        boolean isBlessed = item.getTemplate().getQuality() == ItemQuality.BLESSED;
        switch (this.stat) {
            case SHIELD_DEFENCE: 
            case MAGIC_DEFENCE: 
            case POWER_DEFENCE: {
                env.value = env.value + ((double)enchant + (double)(overenchant * 2) * (isBlessed ? 1.6 : 1.0));
                return;
            }
            case MAX_HP: {
                if (env.character.isPlayer()) {
                    env.value = env.value + (double)EnchantHPBonusTable.getInstance().getHPBonus(env.character.getPlayer(), item) * (isBlessed ? 1.6 : 1.0);
                }
                return;
            }
            case MAGIC_ATTACK: {
                switch (item.getTemplate().getGrade().getCrystalId()) {
                    case 17371: {
                        env.value = env.value + (double)(5 * (enchant + overenchant + overenchantR1 + overenchantR2 + overenchantR3)) * (isBlessed ? 1.6 : 1.0);
                        break;
                    }
                    case 1462: {
                        env.value = env.value + (double)(4 * (enchant + overenchant)) * (isBlessed ? 1.6 : 1.0);
                        break;
                    }
                    case 1461: {
                        env.value = env.value + (double)(3 * (enchant + overenchant)) * (isBlessed ? 1.6 : 1.0);
                        break;
                    }
                    case 1460: {
                        env.value = env.value + (double)(3 * (enchant + overenchant)) * (isBlessed ? 1.6 : 1.0);
                        break;
                    }
                    case 1459: {
                        env.value = env.value + (double)(3 * (enchant + overenchant)) * (isBlessed ? 1.6 : 1.0);
                        break;
                    }
                    case 0: 
                    case 1458: {
                        env.value = env.value + (double)(3 * (enchant + overenchant)) * (isBlessed ? 1.6 : 1.0);
                    }
                }
                return;
            }
            case POWER_ATTACK: {
                ItemType itemType = item.getItemType();
                boolean isBow = itemType == WeaponTemplate.WeaponType.BOW;
                boolean isCrossbow = itemType == WeaponTemplate.WeaponType.CROSSBOW || itemType == WeaponTemplate.WeaponType.TWOHANDCROSSBOW;
                boolean isSword = (itemType == WeaponTemplate.WeaponType.DUALFIST || itemType == WeaponTemplate.WeaponType.DUAL || itemType == WeaponTemplate.WeaponType.BIGSWORD || itemType == WeaponTemplate.WeaponType.SWORD || itemType == WeaponTemplate.WeaponType.RAPIER || itemType == WeaponTemplate.WeaponType.ANCIENTSWORD) && item.getTemplate().getBodyPart() == 16384L;
                boolean isDualBlunt = itemType == WeaponTemplate.WeaponType.DUALBLUNT;
                switch (item.getTemplate().getGrade().getCrystalId()) {
                    case 17371: {
                        if (isBow) {
                            env.value = env.value + (double)(12 * (enchant + overenchant + overenchantR1 + overenchantR2 + overenchantR3)) * (isBlessed ? 1.6 : 1.0);
                            break;
                        }
                        if (isSword || isCrossbow) {
                            env.value = env.value + (double)(7 * (enchant + overenchant + overenchantR1 + overenchantR2 + overenchantR3)) * (isBlessed ? 1.6 : 1.0);
                            break;
                        }
                        env.value = env.value + (double)(6 * (enchant + overenchant + overenchantR1 + overenchantR2 + overenchantR3)) * (isBlessed ? 1.6 : 1.0);
                        break;
                    }
                    case 1462: {
                        if (isBow) {
                            env.value += (double)(10 * (enchant + overenchant));
                            break;
                        }
                        if (isCrossbow) {
                            env.value += (double)(7 * (enchant + overenchant));
                            break;
                        }
                        if (isSword) {
                            env.value += (double)(6 * (enchant + overenchant));
                            break;
                        }
                        env.value += (double)(5 * (enchant + overenchant));
                        break;
                    }
                    case 1461: {
                        if (isBow) {
                            env.value += (double)(8 * (enchant + overenchant));
                            break;
                        }
                        if (isSword) {
                            env.value += (double)(5 * (enchant + overenchant));
                            break;
                        }
                        env.value += (double)(4 * (enchant + overenchant));
                        break;
                    }
                    case 1460: {
                        if (isBow) {
                            env.value += (double)(8 * (enchant + overenchant));
                            break;
                        }
                        if (isSword) {
                            env.value += (double)(5 * (enchant + overenchant));
                            break;
                        }
                        env.value += (double)(4 * (enchant + overenchant));
                        break;
                    }
                    case 1459: {
                        if (isBow) {
                            env.value += (double)(8 * (enchant + overenchant));
                            break;
                        }
                        if (isSword) {
                            env.value += (double)(5 * (enchant + overenchant));
                            break;
                        }
                        env.value += (double)(4 * (enchant + overenchant));
                        break;
                    }
                    case 0: 
                    case 1458: {
                        if (isBow) {
                            env.value += (double)(8 * (enchant + overenchant));
                            break;
                        }
                        if (isSword) {
                            env.value += (double)(5 * (enchant + overenchant));
                            break;
                        }
                        env.value += (double)(4 * (enchant + overenchant));
                    }
                }
                return;
            }
            case SOULSHOT_POWER: 
            case SPIRITSHOT_POWER: {
                env.value += (double)Math.min(30, enchant) * 0.7;
                return;
            }
        }
    }
}

