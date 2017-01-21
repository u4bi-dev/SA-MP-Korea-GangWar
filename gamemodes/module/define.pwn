    #define DL_LOGIN                          100
    #define DL_REGIST                         101
    #define DL_INFO                           102
    #define DL_MENU                           103
    #define DL_MISSON_CLAN                    104
    #define DL_MISSON_SHOP                    105
    #define DL_MISSON_NOTICE                  106
    #define DL_MYWEP                          107
    #define DL_MYCAR                          108
    #define DL_GARAGE                         109
    #define DL_MISSON_DUEL                    110
    #define DL_MISSON_GAMBLE                  111

    #define DL_CLAN_INSERT                    1040
    #define DL_CLAN_INSERT_COLOR              10400
    #define DL_CLAN_INSERT_COLOR_RANDOM       10401
    //#define DL_CLAN_INSERT_COLOR_CHOICE       10402
    #define DL_CLAN_INSERT_SUCCESS            10403

    #define DL_CLAN_LIST                      1041
    #define DL_CLAN_RANK                      1042
    #define DL_CLAN_SETUP                     1043
    #define DL_CLAN_LEAVE                     1044

    #define DL_CLAN_SETUP_INVITE              10430
    #define DL_CLAN_SETUP_MEMBER              10431
    #define DL_CLAN_SETUP_MEMBER_SETUP        10433
    #define DL_CLAN_SETUP_MEMBER_SETUP_RANK   10434
    #define DL_CLAN_SETUP_MEMBER_SETUP_KICK   10435

    #define DL_CLAN_SETUP_SKIN                10436
    #define DL_CLAN_SETUP_SKIN_SETUP          10437
    #define DL_CLAN_SETUP_SKIN_UPDATE         10438

    #define DL_SHOP_WEAPON                    1050
    #define DL_SHOP_SKIN                      1051
    #define DL_SHOP_ACC                       1052
    #define DL_SHOP_NAME                      1053

    #define DL_SHOP_WEAPON_BUY                10500
    #define DL_SHOP_SKIN_BUY                  10510
    #define DL_SHOP_NAME_EDIT                 10540

    #define DL_NOTICE_SEASON                  1060

    #define DL_MYWEP_SETUP                    1070
    #define DL_MYWEP_SETUP_OPTION             1071
    #define DL_MYWEP_SETUP_HOLD               1072
    #define DL_MYWEP_SETUP_PUT                1073

    #define DL_MYCAR_SETUP                    1080
    #define DL_MYCAR_SETUP_SPAWN              1081

    #define DL_GARAGE_REPAIR                  1090
    #define DL_GARAGE_PAINT                   1091
    #define DL_GARAGE_TURNING                 1092

    #define DL_DUEL_TYPE                      1100
    #define DL_DUEL_MONEY                     1101
    #define DL_DUEL_SUCCESS                   1102
    #define DL_DUEL_INFO                      1103

    #define DL_GAMBLE_CHOICE                  1110
    #define DL_GAMBLE_REGAMBLE                1111
    #define DL_GAMBLE_RESULT                  1112

    #define COL_SYS  0xAFAFAF99

    /* IS CHECK */
    #define IS_CLEN_HAVE          500
    #define IS_CLEN_NOT           501
    #define IS_CLEN_LEADER        502
    #define IS_CLEN_INSERT_MONEY  503

    /*ZONE BASE */
    #define USED_PLAYER    51
    #define USED_ZONE      932
    #define USED_TEXTDRAW  200
    #define USED_WEAPON    11
    #define USED_VEHICLE   230
    #define USED_HOUSE     500
    #define USED_CLAN      100
    #define USED_MISSON    5
    #define USED_GARAGE    5
    #define USED_DUEL      2
    #define USED_DUEL_LIST 20

    #define PRESSED(%0) \
        (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
    #define RELEASED(%0) \
        (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

    new FALSE = false;
    #define formatMsg(%0,%1,%2)\
        do{\
            new _str[256];\
            format(_str,256,%2);\
            SendClientMessage(%0,%1,_str);\
        }\
        while(FALSE)

    #define formatMsgAll(%0,%1,%2)\
        do{\
            new _str[256];\
            format(_str,256,%1,%2);\
            SendClientMessageToAll(%0,_str);\
        }\
        while(FALSE)

    #define rgbToHex(%0,%1,%2,%3) %0 << 24 | %1 << 16 | %2 << 8 | %3
