package l2s.gameserver.instancemanager;

import java.io.File;
import java.util.concurrent.CopyOnWriteArrayList;
import javax.xml.parsers.DocumentBuilderFactory;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class BotCheckManager {
    private static final Logger _log = LoggerFactory.getLogger(BotCheckManager.class);
    public static CopyOnWriteArrayList<BotCheckQuestion> questionInfo = new CopyOnWriteArrayList();

    public static void loadBotQuestions() {
        if (!Config.ENABLE_ANTI_BOT_SYSTEM) {
            return;
        }
        Document doc = null;
        File file = new File(Config.DATAPACK_ROOT, "data/bot_questions.xml");
        if (!file.exists()) {
            _log.warn("BotManager: bot_questions.xml file is missing.");
            return;
        }
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            factory.setValidating(false);
            factory.setIgnoringComments(true);
            doc = factory.newDocumentBuilder().parse(file);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
            BotCheckManager.parseBotQuestions(doc);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected static void parseBotQuestions(Document doc) {
        for (Node n = doc.getFirstChild(); n != null; n = n.getNextSibling()) {
            if (!"list".equalsIgnoreCase(n.getNodeName())) continue;
            for (Node d = n.getFirstChild(); d != null; d = d.getNextSibling()) {
                if (!"question".equalsIgnoreCase(d.getNodeName())) continue;
                int id = Integer.parseInt(d.getAttributes().getNamedItem("id").getNodeValue());
                String question_ru = d.getAttributes().getNamedItem("question_ru").getNodeValue();
                String question_en = d.getAttributes().getNamedItem("question_en").getNodeValue();
                boolean answer = Integer.parseInt(d.getAttributes().getNamedItem("answer").getNodeValue()) == 0;
                BotCheckQuestion question_info = new BotCheckQuestion(id, question_ru, question_en, answer);
                questionInfo.add(question_info);
            }
        }
        _log.info("BotManager System: Loaded " + questionInfo.size() + " questions total");
        BotCheckManager.ScheduleNextQuestion();
    }

    public static CopyOnWriteArrayList<BotCheckQuestion> getAllAquisions() {
        if (questionInfo == null) {
            return null;
        }
        return questionInfo;
    }

    public static boolean checkAnswer(int qId, boolean answer) {
        for (BotCheckQuestion info : questionInfo) {
            if (info._id != qId) continue;
            return info.getAnswer() == answer;
        }
        return true;
    }

    public static BotCheckQuestion generateRandomQuestion() {
        return questionInfo.get(Rnd.get((int)0, (int)(questionInfo.size() - 1)));
    }

    private static void ScheduleNextQuestion() {
        ThreadPoolManager.getInstance().schedule(new BotQuestionAsked(), Rnd.get((int)(Config.MINIMUM_TIME_QUESTION_ASK * 60000), (int)(Config.MAXIMUM_TIME_QUESTION_ASK * 60000)));
    }

    static class BotQuestionAsked
    implements Runnable {
        BotQuestionAsked() {
        }

        @Override
        public void run() {
            block0: for (Player player : GameObjectsStorage.getPlayers(false, false)) {
                if (player == null || player.isGM() || player.getPvpFlag() != 0 || player.isInOlympiadMode() || player.isInOfflineMode() || player.isInStoreMode() || player.isInDuel() || player.isInSiegeZone() || player.isInAwayingMode() || player.getBotRating() > Rnd.get((int)Config.MINIMUM_BOT_POINTS_TO_STOP_ASKING, (int)Config.MAXIMUM_BOT_POINTS_TO_STOP_ASKING)) continue;
                for (Creature creature : World.getAroundNpc(player, 1000, 1000)) {
                    if (!creature.isMonster()) continue;
                    player.requestCheckBot();
                    continue block0;
                }
            }
            BotCheckManager.ScheduleNextQuestion();
        }
    }

    public static class BotCheckQuestion {
        public final int _id;
        public final String _questionRus;
        public final String _questionEn;
        public final boolean _answer;

        public BotCheckQuestion(int id, String questionRus, String questionEn, boolean answer) {
            this._id = id;
            this._questionRus = questionRus;
            this._questionEn = questionEn;
            this._answer = answer;
        }

        public int getId() {
            return this._id;
        }

        public String getDescr(boolean rus) {
            if (rus) {
                return this._questionRus;
            }
            return this._questionEn;
        }

        public boolean getAnswer() {
            return this._answer;
        }
    }
}

