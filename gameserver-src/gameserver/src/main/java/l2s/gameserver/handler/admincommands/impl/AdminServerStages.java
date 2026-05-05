package l2s.gameserver.handler.admincommands.impl;

import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.instancemanager.ServerStagesManager;
import l2s.gameserver.model.Player;

/**
 * GM: сброс и смена стадий сервера (см. {@link ServerStagesManager}).
 */
public class AdminServerStages implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands) comm;
        if (!activeChar.getPlayerAccess().Menu) {
            return false;
        }
        ServerStagesManager mgr = ServerStagesManager.getInstance();
        switch (command) {
            case admin_stage_reset: {
                if (!mgr.isEnabled()) {
                    activeChar.sendMessage("Server stages: выключено в config/server_stages.properties");
                    return false;
                }
                mgr.resetCurrentStageProgress();
                activeChar.sendMessage(
                        "Стадии: сброшен прогресс стадии "
                                + mgr.getCurrentStageNumber()
                                + " (снимок PK/PvP, рейды, флаги почты/рестарта). Номер стадии без изменений.");
                break;
            }
            case admin_stage_set: {
                if (wordList.length < 2) {
                    activeChar.sendMessage("Использование: //admin_stage_set <1-4>");
                    return false;
                }
                int stage;
                try {
                    stage = Integer.parseInt(wordList[1]);
                } catch (NumberFormatException e) {
                    activeChar.sendMessage("Неверный номер стадии.");
                    return false;
                }
                if (!mgr.isEnabled()) {
                    activeChar.sendMessage("Server stages: выключено в config/server_stages.properties");
                    return false;
                }
                mgr.setCurrentStage(stage);
                activeChar.sendMessage(
                        "Стадии: активная стадия "
                                + mgr.getCurrentStageNumber()
                                + ", прогресс этой стадии обнулён.");
                break;
            }
        }
        return true;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private enum Commands {
        admin_stage_reset,
        admin_stage_set
    }
}
