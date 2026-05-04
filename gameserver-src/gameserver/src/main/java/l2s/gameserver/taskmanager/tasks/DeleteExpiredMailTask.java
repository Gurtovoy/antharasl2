package l2s.gameserver.taskmanager.tasks;

import java.util.List;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExNoticePostArrived;
import l2s.gameserver.network.l2.s2c.ExUnReadMailCount;
import l2s.gameserver.taskmanager.tasks.AutomaticTask;

public class DeleteExpiredMailTask
extends AutomaticTask {
    @Override
    public void doTask() throws Exception {
        int expireTime = (int)(System.currentTimeMillis() / 1000L);
        List<Mail> mails = MailDAO.getInstance().getExpiredMail(expireTime);
        for (Mail mail : mails) {
            if (!mail.getAttachments().isEmpty()) {
                if (mail.getType() == Mail.SenderType.NORMAL) {
                    Player player = World.getPlayer(mail.getSenderId());
                    Mail reject = mail.reject();
                    mail.delete();
                    reject.setExpireTime(expireTime + 1296000);
                    reject.save();
                    if (player == null) continue;
                    player.sendPacket((IBroadcastPacket)ExNoticePostArrived.STATIC_TRUE);
                    player.sendPacket((IBroadcastPacket)new ExUnReadMailCount(player));
                    player.sendPacket((IBroadcastPacket)SystemMsg.THE_MAIL_HAS_ARRIVED);
                    continue;
                }
                mail.setExpireTime(expireTime + 86400);
                mail.setJdbcState(JdbcEntityState.UPDATED);
                mail.update();
                continue;
            }
            mail.delete();
        }
    }

    @Override
    public long reCalcTime(boolean start) {
        return System.currentTimeMillis() + 600000L;
    }
}

