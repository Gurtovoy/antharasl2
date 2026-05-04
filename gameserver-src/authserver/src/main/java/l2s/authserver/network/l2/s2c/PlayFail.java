package l2s.authserver.network.l2.s2c;

import l2s.authserver.network.l2.s2c.L2LoginServerPacket;

public final class PlayFail
extends L2LoginServerPacket {
    public static final PlayFail REASON_NO_MESSAGE = new PlayFail(0);
    public static final PlayFail REASON_SYSTEM_ERROR_LOGIN_LATER = new PlayFail(1);
    public static final PlayFail REASON_USER_OR_PASS_WRONG = new PlayFail(2);
    public static final PlayFail REASON_ACCESS_FAILED_TRY_AGAIN_LATER = new PlayFail(4);
    public static final PlayFail REASON_ACCOUNT_INFO_INCORRECT_CONTACT_SUPPORT = new PlayFail(5);
    public static final PlayFail REASON_ACCOUNT_IN_USE = new PlayFail(7);
    public static final PlayFail REASON_UNDER_18_YEARS_KR = new PlayFail(12);
    public static final PlayFail REASON_SERVER_OVERLOADED = new PlayFail(15);
    public static final PlayFail REASON_SERVER_MAINTENANCE = new PlayFail(16);
    public static final PlayFail REASON_TEMP_PASS_EXPIRED = new PlayFail(17);
    public static final PlayFail REASON_GAME_TIME_EXPIRED = new PlayFail(18);
    public static final PlayFail REASON_NO_TIME_LEFT = new PlayFail(19);
    public static final PlayFail REASON_SYSTEM_ERROR = new PlayFail(20);
    public static final PlayFail REASON_ACCESS_FAILED = new PlayFail(21);
    public static final PlayFail REASON_RESTRICTED_IP = new PlayFail(22);
    public static final PlayFail REASON_WEEK_USAGE_FINISHED = new PlayFail(30);
    public static final PlayFail REASON_SECURITY_CARD_NUMBER_INVALID = new PlayFail(31);
    public static final PlayFail REASON_AGE_NOT_VERIFIED_CANT_LOG_BEETWEEN_10PM_6AM = new PlayFail(32);
    public static final PlayFail REASON_SERVER_CANNOT_BE_ACCESSED_BY_YOUR_COUPON = new PlayFail(33);
    public static final PlayFail REASON_DUAL_BOX = new PlayFail(35);
    public static final PlayFail REASON_INACTIVE = new PlayFail(36);
    public static final PlayFail REASON_USER_AGREEMENT_REJECTED_ON_WEBSITE = new PlayFail(37);
    public static final PlayFail REASON_GUARDIAN_CONSENT_REQUIRED = new PlayFail(38);
    public static final PlayFail REASON_USER_AGREEMENT_DECLINED_OR_WITHDRAWL_REQUEST = new PlayFail(39);
    public static final PlayFail REASON_ACCOUNT_SUSPENDED_CALL = new PlayFail(40);
    public static final PlayFail REASON_CHANGE_PASSWORD_AND_QUIZ_ON_WEBSITE = new PlayFail(41);
    public static final PlayFail REASON_ALREADY_LOGGED_INTO_10_ACCOUNTS = new PlayFail(42);
    public static final PlayFail REASON_MASTER_ACCOUNT_RESTRICTED = new PlayFail(43);
    public static final PlayFail REASON_CERTIFICATION_FAILED = new PlayFail(46);
    public static final PlayFail REASON_TELEPHONE_CERTIFICATION_UNAVAILABLE = new PlayFail(47);
    public static final PlayFail REASON_TELEPHONE_SIGNALS_DELAYED = new PlayFail(48);
    public static final PlayFail REASON_CERTIFICATION_FAILED_LINE_BUSY = new PlayFail(49);
    public static final PlayFail REASON_CERTIFICATION_SERVICE_NUMBER_EXPIRED_OR_INCORRECT = new PlayFail(50);
    public static final PlayFail REASON_CERTIFICATION_SERVICE_CURRENTLY_BEING_CHECKED = new PlayFail(51);
    public static final PlayFail REASON_CERTIFICATION_SERVICE_CANT_BE_USED_HEAVY_VOLUME = new PlayFail(52);
    public static final PlayFail REASON_CERTIFICATION_SERVICE_EXPIRED_GAMEPLAY_BLOCKED = new PlayFail(53);
    public static final PlayFail REASON_CERTIFICATION_FAILED_3_TIMES_GAMEPLAY_BLOCKED_30_MIN = new PlayFail(54);
    public static final PlayFail REASON_CERTIFICATION_DAILY_USE_EXCEEDED = new PlayFail(55);
    public static final PlayFail REASON_CERTIFICATION_UNDERWAY_TRY_AGAIN_LATER = new PlayFail(56);
    private int reason;

    private PlayFail(int reason) {
        this.reason = reason;
    }

    @Override
    protected void writeImpl() {
        this.writeC(6);
        this.writeC(this.reason);
    }
}

