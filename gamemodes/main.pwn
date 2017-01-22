#include <a_samp>
#include <a_mysql>
#include <foreach>

#include "module/language/english.pwn" /*english ver*/ //#include "module/language/korea.pwn"/*korea ver*/
#include "module/define.pwn"
#include "module/resource.pwn"
#include "module/directive.pwn"
#include "module/sql.pwn"
#include "module/enum.pwn"

main(){}

forward MyHttpResponse(playerid, response_code, data[]);

forward check(playerid);
forward regist(playerid, pass[]);
forward save(playerid);
forward load(playerid);
forward ServerThread();
forward Float:kdRatio(kill, death);
forward vehicleSpawn(vehicleid);
forward duelTimer(p1, p2);

/* global variable */
new missonTick=0;
new garageTick=0;

/* static */
static mysql;

public OnGameModeExit(){return 1;
}
public OnGameModeInit(){
    #include "module/vehicles.pwn"
    dbcon();
    mode();
    server();
    thread();

    for(new vehicleid=1; vehicleid<=230; vehicleid++)vehicleSpawn(vehicleid);
    return 1;
}

public OnPlayerText(playerid, text[]){
    new send[256];

    if(text[0] == '!'){
        if(USER[playerid][CLANID] == 0)return SendClientMessage(playerid,COL_SYS, YOU_NOT_CLAN_CHAT);
        foreach (new i : Player){
            if(USER[i][CLANID] == USER[playerid][CLANID]){
                strmid(send, text, 1, strlen(text));
                formatMsg(i, 0x7FFF00FF,CLAN_CHAT, USER[playerid][NAME], playerid, send);
                PlayerPlaySound(i, 1137, 0.0, 0.0, 0.0);
            }
        }
        return 0;
    }

    if(text[0] == '@'){
        if(USER[playerid][ADMIN] == 0)return SendClientMessage(playerid,COL_SYS, YOU_NOT_ADMIN);
        foreach (new i : Player){
            if(USER[i][ADMIN] > 0){
                strmid(send, text, 1, strlen(text));
                formatMsg(i, 0x2184DEFF,ADMIN_CHAT, USER[playerid][ADMIN],USER[playerid][NAME], playerid, send);
                PlayerPlaySound(i, 1137, 0.0, 0.0, 0.0);
            }
        }
        return 0;
    }

    if(USER[playerid][CLANID])format(send,sizeof(send),"{%06x}[%s]{E6E6E6} %s(%d) : %s", GetPlayerColor(playerid) >>> 8 , CLAN[USER[playerid][CLANID]-1][NAME], USER[playerid][NAME],playerid, text);
    else format(send,sizeof(send),"{E6E6E6} %s(%d) : %s", USER[playerid][NAME], playerid, text);
    SendClientMessageToAll(-1, send);

    return 0;
}
public OnPlayerRequestClass(playerid, classid){

    SetPlayerPos(playerid, 1934.9633,-1678.8534,24.6377);
    SetPlayerCameraPos(playerid, 1954.9316,-1697.1252,26.3828);
    SetPlayerCameraLookAt(playerid, 1934.9633,-1678.8534,24.6377);

    if(INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,ALREADY_LOGIN);

    join(playerid, check(playerid));
    showZone(playerid);
    showTextDraw(playerid);
    SetPlayerColor(playerid, 0x00000099);
    return 1;
}
public OnPlayerSpawn(playerid){
    if(!INGAME[playerid][LOGIN]) return Kick(playerid);
    if(!INGAME[playerid][SPAWN] && !isHaveWeapon(playerid , 24) && USER[playerid][LEVEL] < 10){
        GivePlayerWeapon(playerid, 24, 500);

        SendClientMessage(playerid,COL_SYS,LEVEL_TEN_BY_DEAGLE);
        INGAME[playerid][SPAWN] = true;
    }
    return 1;
}

public OnVehicleSpawn(vehicleid){
    if(VEHICLE[vehicleid][OWNER_ID] == 0) return 0;
    vehicleSpawn(vehicleid);
    return 1;
}
public OnVehicleDeath(vehicleid, killerid){
    return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
    inCar(playerid,vehicleid);
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid){
    if(INGAME[playerid][NODM] && VEHICLE[vehicleid][OWNER_ID] == 0){

        ClearAnimations(playerid);
        vehicleSpawn(vehicleid);

        SendClientMessage(playerid,COL_SYS, "비전투구역에 주차를 할 시 미입찰 차량은 즉시 스폰됩니다.");
        return 1;
    }

    vehicleSave(vehicleid);
    SetTimerEx("vehicleSpawn", 1500, false, "i", vehicleid);
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid){
    GetPlayerHealth(playerid, USER[playerid][HP]);
    GetPlayerArmour(playerid, USER[playerid][AM]);

    for(new i=0; i<GetMaxPlayers(); i++){
        if(USER[playerid][HP] < 70 && pickupid == INGAME[i][DEATH_PICKUP_HP]){
            USER[playerid][HP] += 30;
            SetPlayerHealth(playerid, USER[playerid][HP]);
            DestroyPickup(INGAME[i][DEATH_PICKUP_HP]);

        }else if(USER[playerid][HP] > 70 && pickupid == INGAME[i][DEATH_PICKUP_HP]){
            USER[playerid][HP] = 100;
            SetPlayerHealth(playerid, USER[playerid][HP]);
            DestroyPickup(INGAME[i][DEATH_PICKUP_HP]);
        }

        if(USER[playerid][AM] < 70 && pickupid == INGAME[i][DEATH_PICKUP_AM]){
            USER[playerid][AM] += 30;
            SetPlayerArmour(playerid, USER[playerid][AM]);
            DestroyPickup(INGAME[i][DEATH_PICKUP_AM]);

        }else if(USER[playerid][AM] > 70 && pickupid == INGAME[i][DEATH_PICKUP_AM]){
            USER[playerid][AM] = 100;
            SetPlayerArmour(playerid, USER[playerid][AM]);
            DestroyPickup(INGAME[i][DEATH_PICKUP_AM]);
        }
    }
    return 1;
}
public OnPlayerClickPlayer(playerid, clickedplayerid, source){
    new result[502], clanName[50];

    if(USER[clickedplayerid][CLANID] == 0) format(clanName,sizeof(clanName), UNCLAN);
    else format(clanName,sizeof(clanName), "%s",CLAN[USER[clickedplayerid][CLANID]-1][NAME]);

    format(result,sizeof(result), infoMessege[1],USER[clickedplayerid][NAME],clanName,USER[clickedplayerid][LEVEL],USER[clickedplayerid][EXP],USER[clickedplayerid][MONEY],USER[clickedplayerid][KILLS],USER[clickedplayerid][DEATHS],kdRatio(USER[clickedplayerid][KILLS],USER[clickedplayerid][DEATHS]),kdTier(USER[clickedplayerid][LEVEL],
    USER[clickedplayerid][KILLS],USER[clickedplayerid][DEATHS]),USER[clickedplayerid][DUEL_WIN],USER[clickedplayerid][DUEL_LOSS],kdRatio(USER[clickedplayerid][DUEL_WIN],USER[clickedplayerid][DUEL_LOSS]));

    ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,result, DIALOG_CLOSE, "");

    return 1;
}
public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid){
    if(!INGAME[playerid][DUEL_JOIN] && !isHaveWeapon(issuerid,weaponid) && weaponid != 24 && weaponid != 0 && weaponid != 47 &&  weaponid != 49 && weaponid != 50 && weaponid != 51 && weaponid != 54 &&  weaponid != 53 && weaponid != 54) return Kick(issuerid);

    if(weaponid == 50)SendClientMessage(playerid,COL_SYS, "    프로펠러 날갈기를 한 상대방은 추방당했습니다."),Kick(issuerid);
    if(weaponid == 49){
        GetPlayerPos(playerid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);
        SetPlayerPos(playerid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);

        formatMsg(issuerid, COL_SYS, "    압사를 지속적으로 할 시 추방됩니다.");
    }

    GetPlayerHealth(playerid, USER[playerid][HP]);
    GetPlayerArmour(playerid, USER[playerid][AM]);

    if(!INGAME[playerid][DUEL_JOIN] && INGAME[playerid][NODM]){
        if(USER[issuerid][HP] > 50 && USER[issuerid][AM] > 50 && !INGAME[playerid][NODM]){
            formatMsg(issuerid, COL_SYS, NO_DM_ZONE_TEXT2);
            SetPlayerPos(issuerid, 1913.1345, -1710.5565, 13.4003);
            SetPlayerFacingAngle(issuerid, 89.3591);
        }
        if(USER[playerid][HP] > 50 && USER[playerid][AM] > 50){
            formatMsg(issuerid, COL_SYS, NO_DM_ZONE_TEXT);

            SetPlayerHealth(playerid, 100);
            SetPlayerArmour(playerid, 100);

            GetPlayerHealth(playerid, USER[playerid][HP]);
            GetPlayerArmour(playerid, USER[playerid][AM]);
            return 0;
        }
    }

    if(weaponid != 18 && weaponid != 37){
        DAMAGE[issuerid][playerid][TAKE] +=amount;
        DAMAGE[playerid][issuerid][GIVE] +=amount;

        new str[120];
        format(str,sizeof(str),"%s~n~-%i (%s)",USER[playerid][NAME],floatround(DAMAGE[issuerid][playerid][TAKE]),wepNameTD(weaponid));
        TextDrawSetString(TDraw[issuerid][TAKE_DAMAGE],str);

        format(str,sizeof(str),"%s~n~-%i (%s)",USER[issuerid][NAME],floatround(DAMAGE[playerid][issuerid][GIVE]),wepNameTD(weaponid));
        TextDrawSetString(TDraw[playerid][GIVE_DAMAGE],str);

        INGAME[issuerid][TAKE_DAMAGE_ALPHA] = 0xFF;
        INGAME[playerid][GIVE_DAMAGE_ALPHA] = 0xFF;

        PlayerPlaySound(issuerid, 17802, 0.0, 0.0, 0.0);
        PlayerPlaySound(playerid, 5205, 0.0, 0.0, 0.0);
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate){
    switch(newstate){
        case PLAYER_STATE_ONFOOT : warpInit(playerid);
        case PLAYER_STATE_DRIVER..PLAYER_STATE_PASSENGER : warp(playerid);
    }

    if(newstate == PLAYER_STATE_DRIVER){
        new vehicleid = GetPlayerVehicleID(playerid);

        if(VEHICLE[vehicleid][OWNER_ID] == 0) SendClientMessage(playerid,COL_SYS,IN_CAR_NOT_OWNER);
        else formatMsg(playerid, COL_SYS, IN_CAR_WHO_OWNER, VEHICLE[vehicleid][OWNER_NAME]);
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
    if(!isBike(GetPlayerVehicleID(playerid)) && PRESSED(KEY_FIRE) && GetPlayerState(playerid)==PLAYER_STATE_DRIVER)AddVehicleComponent(GetPlayerVehicleID(playerid),1010);
    if(RELEASED(KEY_FIRE) && GetPlayerState(playerid)==PLAYER_STATE_DRIVER)RemoveVehicleComponent(GetPlayerVehicleID(playerid),1010);

    if(newkeys == 160 && GetPlayerWeapon(playerid) == 0 && !IsPlayerInAnyVehicle(playerid))sync(playerid);

    if(PRESSED(KEY_YES)){
        if(INGAME[playerid][INVITE_CLANID]){
            clanJoin(playerid, INGAME[playerid][INVITE_CLANID]);
            formatMsg(playerid, COL_SYS, CLAN_INVITE_YES,CLAN[USER[INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID]][CLANID]-1][COLOR] >>> 8 , CLAN[USER[INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID]][CLANID]-1][NAME]);
            formatMsg(INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID], COL_SYS, CLAN_INVITE_YES_CALL,USER[playerid][NAME]);
            INGAME[playerid][INVITE_CLANID] = 0;
            INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID] = 0;
        }
    }

    if(PRESSED(KEY_NO)){
        if(INGAME[playerid][INVITE_CLANID]){
            formatMsg(playerid, COL_SYS, CLAN_INVITE_NOT, CLAN[USER[INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID]][CLANID]-1][NAME]);
            formatMsg(INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID], COL_SYS, CLAN_INVITE_NOT_CALL,USER[playerid][NAME]);
            INGAME[playerid][INVITE_CLANID] = 0;
            INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID] = 0;
        }
    }

    if(PRESSED(KEY_SECONDARY_ATTACK))searchMissonRange(playerid);
    if(PRESSED(KEY_CROUCH) && IsPlayerInAnyVehicle(playerid))searchGarageRange(playerid);

    return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){

    if(!response){
        switch(dialogid){
            case DL_LOGIN, DL_REGIST:return Kick(playerid);
            case DL_MISSON_CLAN, DL_MISSON_SHOP, DL_MISSON_NOTICE, DL_MISSON_GAMBLE, DL_MYWEP, DL_MYCAR, DL_GARAGE :return 0;
            case DL_MISSON_DUEL :return DUEL_CORE[ON]=false;
            case DL_CLAN_INSERT, DL_CLAN_LIST, DL_CLAN_RANK, DL_CLAN_SETUP, DL_CLAN_LEAVE :return showMisson(playerid, 0);
            case DL_CLAN_INSERT_COLOR : return showDialog(playerid, DL_CLAN_INSERT);
            case DL_CLAN_INSERT_COLOR_RANDOM : return clanInsertColorRandom(playerid);
//			case DL_CLAN_INSERT_COLOR_CHOICE :return showDialog(playerid, DL_CLAN_INSERT_COLOR);
            case DL_CLAN_INSERT_SUCCESS : return showDialog(playerid, DL_CLAN_INSERT_COLOR);
            case DL_CLAN_SETUP_INVITE, DL_CLAN_SETUP_MEMBER, DL_CLAN_SETUP_SKIN: return showDialog(playerid, DL_CLAN_SETUP);
            case DL_CLAN_SETUP_MEMBER_SETUP : return showDialog(playerid, DL_CLAN_SETUP_MEMBER);
            case DL_CLAN_SETUP_MEMBER_SETUP_RANK, DL_CLAN_SETUP_MEMBER_SETUP_KICK : return showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
            case DL_CLAN_SETUP_SKIN_SETUP, DL_CLAN_SETUP_SKIN_UPDATE : return showDialog(playerid, DL_CLAN_SETUP_SKIN);
            case DL_SHOP_WEAPON, DL_SHOP_SKIN, DL_SHOP_ACC, DL_SHOP_NAME : return showMisson(playerid, 1);
            case DL_SHOP_WEAPON_BUY : return showDialog(playerid, DL_SHOP_WEAPON);
            case DL_SHOP_SKIN_BUY : return showDialog(playerid, DL_SHOP_SKIN);
            case DL_SHOP_NAME_EDIT : return showDialog(playerid, DL_SHOP_NAME);
            case DL_MYWEP_SETUP : return showDialog(playerid, DL_MYWEP);
            case DL_MYWEP_SETUP_OPTION : return showDialog(playerid, DL_MYWEP_SETUP);
            case DL_MYWEP_SETUP_HOLD, DL_MYWEP_SETUP_PUT: return showDialog(playerid, DL_MYWEP_SETUP_OPTION);
            case DL_MYCAR_SETUP : return showDialog(playerid, DL_MYCAR);
            case DL_MYCAR_SETUP_SPAWN : return showDialog(playerid, DL_MYCAR_SETUP);
            case DL_GARAGE_REPAIR, DL_GARAGE_PAINT, DL_GARAGE_TURNING : return showDialog(playerid, DL_GARAGE);
            case DL_GAMBLE_CHOICE : return ShowPlayerDialog(playerid, DL_MISSON_GAMBLE, DIALOG_STYLE_INPUT,DIALOG_TITLE, MISSON_GAMBLE_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
            case DL_GAMBLE_REGAMBLE, DL_GAMBLE_RESULT : return 0;
            case DL_DUEL_INFO: return 0;
            case DL_DUEL_TYPE:{
                if(INGAME[playerid][DUEL_JOIN])duelLeave(playerid);
                else showMisson(playerid, 3);
                return 1;
            }
            case DL_DUEL_MONEY : return showDialog(playerid, DL_DUEL_TYPE);
            case DL_DUEL_SUCCESS : return showDialog(playerid, DL_DUEL_MONEY);
        }
    }

    switch(dialogid){
        /* CORE */
        case DL_LOGIN  : checked(playerid, inputtext);
        case DL_REGIST : regist(playerid, inputtext);
        case DL_INFO   : info(playerid,listitem);
        case DL_MYWEP  : mywep(playerid,listitem);
        case DL_MYCAR  : mycar(playerid,listitem);
        case DL_GARAGE : garage(playerid,listitem);

        /* MISSON */
        case DL_MISSON_CLAN    : clan(playerid,listitem);
        case DL_MISSON_SHOP    : shop(playerid,listitem);
        case DL_MISSON_NOTICE  : notice(playerid,listitem);
        case DL_MISSON_DUEL    : duel(playerid,listitem);
        case DL_MISSON_GAMBLE  : gamble(playerid, inputtext);

        /* CLAN */
        case DL_CLAN_INSERT : clanInsert(playerid, inputtext);
        case DL_CLAN_LIST   : clanList(playerid);
        case DL_CLAN_RANK   : clanRank(playerid);
        case DL_CLAN_SETUP  : clanSetup(playerid, listitem);
        case DL_CLAN_LEAVE  : clanLeave(playerid);

        /* CLAN INSERT */
        case DL_CLAN_INSERT_COLOR        : clanInsertColor(playerid, listitem);
        case DL_CLAN_INSERT_COLOR_RANDOM : showDialog(playerid, DL_CLAN_INSERT_COLOR);
//        case DL_CLAN_INSERT_COLOR_CHOICE : clanInsertColorChoice(playerid, inputtext);
        case DL_CLAN_INSERT_SUCCESS      : clanInsertSuccess(playerid);

        /* CLAN SETUP */
        case DL_CLAN_SETUP_INVITE : clanInvite(playerid, inputtext);
        case DL_CLAN_SETUP_MEMBER : clanMember(playerid, listitem);
        case DL_CLAN_SETUP_SKIN : clanSkin(playerid,listitem);

        /* CLAN MEMBER SETUP */
        case DL_CLAN_SETUP_MEMBER_SETUP      : clanMemberSetup(playerid,listitem);
        case DL_CLAN_SETUP_MEMBER_SETUP_RANK : clanMemberRank(playerid,listitem);
        case DL_CLAN_SETUP_MEMBER_SETUP_KICK : clanMemberKick(playerid);

        /* CLAN SKIN */
        case DL_CLAN_SETUP_SKIN_SETUP        : clanSkinSetup(playerid, inputtext);
        case DL_CLAN_SETUP_SKIN_UPDATE       : clanSkinUpdate(playerid);

        /* SHOP */
        case DL_SHOP_WEAPON : shopWeapon(playerid, listitem);
        case DL_SHOP_SKIN   : shopSkin(playerid, inputtext);
        case DL_SHOP_ACC    : shopAcc(playerid, listitem);
        case DL_SHOP_NAME   : shopName(playerid, inputtext);

        /* SHOP WEAPON BUY */
        case DL_SHOP_WEAPON_BUY : shopWeaponBuy(playerid);

        /* SHOP SKIN BUY */
        case DL_SHOP_SKIN_BUY : shopSkinBuy(playerid);

        /* SHOP NAME EDIT */
        case DL_SHOP_NAME_EDIT : shopNameEdit(playerid);

        /* NOTICE */
        case DL_NOTICE_SEASON : noticeSeason(playerid);

        /* MYWEP SETUP */
        case DL_MYWEP_SETUP        : setWep(playerid,listitem);
        case DL_MYWEP_SETUP_OPTION : setWepOption(playerid,listitem);
        case DL_MYWEP_SETUP_HOLD   : holdWep(playerid);
        case DL_MYWEP_SETUP_PUT    : putWep(playerid);

        /* MYCAR SETUP */
        case DL_MYCAR_SETUP        : setCar(playerid,listitem);
        case DL_MYCAR_SETUP_SPAWN  : spawnCar(playerid);

        /* GARAGE */
        case DL_GARAGE_REPAIR      : repairCar(playerid);
        case DL_GARAGE_PAINT       : paintCar(playerid, inputtext);
        case DL_GARAGE_TURNING     : turnCar(playerid);

        /* DUEL */
        case DL_DUEL_TYPE          : duelType(playerid, listitem);
        case DL_DUEL_MONEY         : duelMoney(playerid, inputtext);
        case DL_DUEL_SUCCESS       : duelSuccess(playerid);

        /* GAMBLE */
        case DL_GAMBLE_CHOICE      : gambleChoice(playerid, listitem);
        case DL_GAMBLE_REGAMBLE    : gambleRegamble(playerid);
        case DL_GAMBLE_RESULT      : gambleResult(playerid);

    }
    return 1;
}
/* OnDialogResponse stock
   @ info()                          : Help topic                [/ help command related]
   @ clan(playerid,listitem)         : Korean War Association [clan pickup related]
   @ shop(playerid,listitem)         : Cappuccino shop [shop pickup related]
   @ notice(playerid,listitem)       : Meeting place [notice board pickup related]
   @ duel(playerid,listitem)         : Dual [dual-chapter sign-up related]
   @ gamble(playerid,inputtext[])    : Slot Machine [Related to slot machine pickup]
   @ mywep(playerid,listitem)        : My weapon settings        [/wep command related]
   @ mycar(playerid,listitem)        : My car settings           [/car command related]
   @ garage(playerid,listitem)       : Garage related            [Caps Look within the workshop]
*/
stock info(playerid, listitem){
    new result[502], clanName[50];

    switch(listitem){
        case 3 : ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,tierInfo(), DIALOG_CLOSE, "");
        case 4 : ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,adminInfo(), DIALOG_CLOSE, "");
    }

    if(USER[playerid][CLANID] == 0) format(clanName,sizeof(clanName), UNCLAN);
    else format(clanName,sizeof(clanName), "%s",CLAN[USER[playerid][CLANID]-1][NAME]);

    if(listitem ==1) format(result,sizeof(result), infoMessege[listitem],USER[playerid][NAME],clanName,USER[playerid][LEVEL],USER[playerid][EXP],USER[playerid][MONEY],USER[playerid][KILLS],USER[playerid][DEATHS],kdRatio(USER[playerid][KILLS],USER[playerid][DEATHS]),kdTier(USER[playerid][LEVEL],USER[playerid][KILLS],USER[playerid][DEATHS]),USER[playerid][DUEL_WIN],USER[playerid][DUEL_LOSS],kdRatio(USER[playerid][DUEL_WIN],USER[playerid][DUEL_LOSS]));
    else format(result,sizeof(result), infoMessege[listitem]);

    ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,result, DIALOG_CLOSE, "");
    return 0;
}

stock clan(playerid,listitem){
    switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_INSERT);
        case 1 : showDialog(playerid, DL_CLAN_LIST);
        case 2 : showDialog(playerid, DL_CLAN_RANK);
        case 3 : showDialog(playerid, DL_CLAN_SETUP);
        case 4 : showDialog(playerid, DL_CLAN_LEAVE);
    }
}
stock shop(playerid,listitem){
    switch(listitem){
        case 0 : showDialog(playerid, DL_SHOP_WEAPON);
        case 1 : showDialog(playerid, DL_SHOP_SKIN);
        case 2 : showDialog(playerid, DL_SHOP_ACC);
        case 3 : showDialog(playerid, DL_SHOP_NAME);
    }
}
stock notice(playerid,listitem){
    switch(listitem){
        case 0 : showDialog(playerid, DL_NOTICE_SEASON);
    }
}

stock duel(playerid,listitem){
    if(DUEL_CORE[ON]) return SendClientMessage(playerid,COL_SYS, DUEL_ALREADY_SETUP);

    switch(listitem){
        case 0 :{
            switch(DUEL_CORE[LENGTH]){
                case 0: DUEL_CORE[ON]=true, showDialog(playerid, DL_DUEL_TYPE);
                case 1: showDialog(playerid, DL_DUEL_SUCCESS);
                case 2: return SendClientMessage(playerid,COL_SYS, DUEL_ALREADY_PROGRESS);
            }
        }
        case 1:showDialog(playerid, DL_DUEL_INFO);
    }
    return 0;
}

stock gamble(playerid,inputtext[]){
    new money = strval(inputtext);

    if(money < 0)return ShowPlayerDialog(playerid, DL_MISSON_GAMBLE, DIALOG_STYLE_INPUT,DIALOG_TITLE, MISSON_GAMBLE_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
    if(USER[playerid][MONEY] < money) return SendClientMessage(playerid,COL_SYS, GAMBLE_NOT_MONEY);
    if(money > 0 && money < 500){
        SendClientMessage(playerid, COL_SYS, GAMBLE_MIN_MONEY);
        ShowPlayerDialog(playerid, DL_MISSON_GAMBLE, DIALOG_STYLE_INPUT,DIALOG_TITLE, MISSON_GAMBLE_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
        return 0;
    }

    if(money == 0)INGAME[playerid][GAMBLE] = 500;
    else INGAME[playerid][GAMBLE] = money;

    showDialog(playerid, DL_GAMBLE_CHOICE);
    return 0;
}

stock mywep(playerid,listitem){
    if(!WEPBAG[playerid][listitem][MODEL])return showDialog(playerid, DL_MYWEP);

    INGAME[playerid][HOLD_WEPID] = WEPBAG[playerid][listitem][MODEL];
    showDialog(playerid, DL_MYWEP_SETUP);
    return 0;
}
stock mycar(playerid,listitem){
    if(!CARBAG[playerid][listitem][ID])return showDialog(playerid, DL_MYCAR);
    INGAME[playerid][HOLD_CARID] = CARBAG[playerid][listitem][ID];
    showDialog(playerid, DL_MYCAR_SETUP);
    return 0;
}
stock garage(playerid,listitem){
    switch(listitem){
        case 0 : showDialog(playerid, DL_GARAGE_REPAIR);
        case 1 :{
            if(VEHICLE[GetPlayerVehicleID(playerid)][OWNER_ID] != USER[playerid][ID])return SendClientMessage(playerid,COL_SYS, YOU_NOT_MYCAR);
            showDialog(playerid, DL_GARAGE_PAINT);
        }
        case 2 :{
            if(VEHICLE[GetPlayerVehicleID(playerid)][OWNER_ID] != USER[playerid][ID])return SendClientMessage(playerid,COL_SYS, YOU_NOT_MYCAR);
            showDialog(playerid, DL_GARAGE_TURNING);
        }
    }
    return 0;
}
/* CLAN
   @ clanInsert(playerid, inputtext) : Clan Creation         [clanInsert - clanInsertColor - clanInsertColorRandom - clanInsertSuccess]
   @ clanList(playerid);             : Clan List
   @ clanRank(playerid);             : Clan Ranking
   @ clanSetup(playerid, listitem);  : Clan Management
   @ clanLeave(playerid);            : Clan Leave

   @ clanJoin(playerid, clanid)      : Clan joining
*/
stock clanInsert(playerid, inputtext[]){
    if(!strlen(inputtext))return showDialog(playerid, DL_CLAN_INSERT);
    if(strlen(inputtext) < 3)return SendClientMessage(playerid,COL_SYS, CLAN_NAME_MIN_LENTH), showDialog(playerid, DL_CLAN_INSERT);
    if(strlen(inputtext) > 20)return SendClientMessage(playerid,COL_SYS, CLAN_NAME_MAX_LENTH), showDialog(playerid, DL_CLAN_INSERT);

    format(CLAN_SETUP[playerid][NAME], 50, "%s", inputtext);
    if(isHangul(playerid, CLAN_SETUP[playerid][NAME])) return showDialog(playerid, DL_CLAN_INSERT);

    new query[400],row;
    mysql_format(mysql, query, sizeof(query), SQL_CLAN_NAME_CHECK, escape(CLAN_SETUP[playerid][NAME]));
    mysql_query(mysql, query);

    row = cache_num_rows();
    if(row){
        formatMsg(playerid, COL_SYS, ALREADY_CLAN_NAME, CLAN_SETUP[playerid][NAME]);
        showDialog(playerid, DL_CLAN_INSERT);
    }else showDialog(playerid, DL_CLAN_INSERT_COLOR);

    return 0;
}
stock clanList(playerid){
    formatMsg(playerid, COL_SYS, "Clan List %d",playerid);
}

stock clanRank(playerid){
    formatMsg(playerid, COL_SYS, "Clan Ranking %d",playerid);
}
stock clanSetup(playerid, listitem){
    switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_INVITE);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER);
        case 2 : showDialog(playerid, DL_CLAN_SETUP_SKIN);
    }
    return 0;
}
stock clanLeave(playerid){
    formatMsg(playerid, COL_SYS, YOU_CLAN_LEAVE, CLAN[USER[playerid][CLANID]-1][NAME]);
    USER[playerid][CLANID] = 0;

    SetPlayerColor(playerid, 0xE6E6E699);
    SetPlayerTeam(playerid, NO_TEAM);

    save(playerid);

    return 0;
}

stock clanJoin(playerid, clanid){
    USER[playerid][CLANID] = clanid;

    SetPlayerColor(playerid,CLAN[clanid-1][COLOR]);
    SetPlayerTeam(playerid, USER[playerid][CLANID]);

    save(playerid);
}

/* CLAN INSERT
   @ clanInsertColor(playerid, listitem)         : How to assign unique color to a clan [random, direct]
   @ clanInsertColorRandom(playerid)             : Clan unique color random
   @ clanInsertColorChoice(playerid, inputtext)  : Clan Unique Color Direct
   @ clanInsertSuccess(playerid)                 : Check for Clan Generation Complete input
*/
stock clanInsertColor(playerid, listitem){
    switch(listitem){
        case 0 :{
            CLAN_SETUP[playerid][COLOR] = randomColor();

            new query[400],row, field[50];
            mysql_format(mysql, query, sizeof(query), SQL_CLAN_COLOR_CHECK, CLAN_SETUP[playerid][COLOR]);
            mysql_query(mysql, query);

            row = cache_num_rows();
            if(row){
                cache_get_field_content(0, "NAME", field, mysql, 50);
                formatMsg(playerid, COL_SYS, ALREADY_CLAN_COLOR, CLAN_SETUP[playerid][COLOR] , CLAN_SETUP[playerid][COLOR] ,field);
                showDialog(playerid, DL_CLAN_INSERT_COLOR);
            }else showDialog(playerid, DL_CLAN_INSERT_COLOR_RANDOM);
        }
/* HACK : Later, you can select and set color */
//		case 1 : showDialog(playerid, DL_CLAN_INSERT_COLOR_CHOICE);
    }
}

stock clanInsertColorRandom(playerid){
    showDialog(playerid, DL_CLAN_INSERT_SUCCESS);
    return 1;
}
stock clanInsertColorChoice(playerid, inputtext[]){
    CLAN_SETUP[playerid][COLOR] = strval(escape(inputtext));
    showDialog(playerid, DL_CLAN_INSERT_SUCCESS);
}

stock clanInsertSuccess(playerid){
    if(isClan(playerid, IS_CLEN_INSERT_MONEY)) return 0;

    formatMsg(playerid, COL_SYS, YOU_CLAN_INSERT_SUCCESS, CLAN_SETUP[playerid][COLOR] >>> 8, CLAN_SETUP[playerid][NAME]);
    giveMoney(playerid, -8000);

    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_CLAN_INSERT_SUCCESS,
        CLAN_SETUP[playerid][NAME],
        USER[playerid][ID],
        CLAN_SETUP[playerid][COLOR]);

    mysql_query(mysql, query);

    new num = cache_insert_id();
    CLAN[num-1][COLOR] = CLAN_SETUP[playerid][COLOR];

    clan_data();
    clanJoin(playerid, num);

    new temp[CLAN_SETUP_MODEL];
    CLAN_SETUP[playerid] = temp;
    return 0;
}

/* CLAN SETUP
   @ clanInvite(playerid, inputtext)  : Invite a clan
   @ clanMember(playerid, listitem)   : View clan members              [clanMember - clanMemberSetup - clanMemberRank - clanMemberKick]
   @ clanSkin(playerid,listitem)      : Clan Skin Management            [clanSkin - clanSkinSetup - clanSkinUpdate]
*/
stock clanInvite(playerid, inputtext[]){
    new user = getPlayerId(inputtext);

    if(user < 0 || user > GetMaxPlayers()) return SendClientMessage(playerid,COL_SYS,CLAN_INVITE_USER_NAME), showDialog(playerid, DL_CLAN_SETUP_INVITE);
    if(!INGAME[user][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER), showDialog(playerid, DL_CLAN_SETUP_INVITE);
    if(isClan(user, IS_CLEN_HAVE)) return 0;
    if(isClan(playerid, IS_CLEN_LEADER)) return SendClientMessage(playerid, COL_SYS, CLAN_ONLY_LEADER);

    formatMsg(user, COL_SYS, CLAN_INVITE_REQ,USER[playerid][NAME], CLAN[USER[playerid][CLANID]-1][COLOR] >>> 8 , CLAN[USER[playerid][CLANID]-1][NAME]);
    formatMsg(user, COL_SYS, CLAN_INVITE_RES,USER[playerid][NAME], CLAN[USER[playerid][CLANID]-1][COLOR] >>> 8 , CLAN[USER[playerid][CLANID]-1][NAME]);
    INGAME[user][INVITE_CLANID] = USER[playerid][CLANID];
    INGAME[user][INVITE_CLAN_REQUEST_MEMBERID] = playerid;
    return 1;
}

stock clanMember(playerid, listitem){
    showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
    formatMsg(playerid, COL_SYS, "Clan member %d - %d",playerid, listitem);
}

stock clanSkin(playerid, listitem){
    switch(listitem){
        case 0 :{
            if(isClan(playerid, IS_CLEN_LEADER)) return SendClientMessage(playerid, COL_SYS, CLAN_ONLY_LEADER);
            showDialog(playerid, DL_CLAN_SETUP_SKIN_SETUP);
        }
        case 1 : showDialog(playerid, DL_CLAN_SETUP_SKIN_UPDATE);
    }
    return 0;
}
/* CLAN MEMBER SETUP
   @ clanMemberSetup(playerid, listitem);  : Clan member management type [change position, deportation]
   @ clanMemberRank(playerid, listitem);   : Change clan position
   @ clanMemberKick(playerid);             : Clan Exile
*/
stock clanMemberSetup(playerid, listitem){
    switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK);
    }
}

stock clanMemberRank(playerid, listitem){
    formatMsg(playerid, COL_SYS, "클랜원 직위변경 %d - %d",playerid, listitem);
}
stock clanMemberKick(playerid){
    formatMsg(playerid, COL_SYS, "클랜원 강제추방 %d",playerid);
}

/* CLAN SKIN SETUP
   @ clanSkinSetup(playerid, inputtext)   : Set clan representative skin
   @ clanSkinUpdate(playerid)             : Clan wears skins
*/
stock clanSkinSetup(playerid, inputtext[]){
    new skin = strval(inputtext);
    if(skin < 0 || skin > 299) return SendClientMessage(playerid, COL_SYS, SKIN_MAX_299);
    if(skin == 0 || skin == 74) return SendClientMessage(playerid, COL_SYS, SKIN_NOT_CJ);
    CLAN[USER[playerid][CLANID]-1][SKIN] = skin;

    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_CLAN_SKIN_UPDATE, skin, USER[playerid][CLANID]);
    mysql_query(mysql, query);

    formatMsg(playerid, COL_SYS, CLAN_SKIN_EDIT_SUCCESS,CLAN[USER[playerid][CLANID]-1][SKIN]);
    return 0;
}
stock clanSkinUpdate(playerid){
    if(CLAN[USER[playerid][CLANID]-1][SKIN] == 0) return SendClientMessage(playerid, COL_SYS, YOU_CLAN_NOT_SKIN);
    formatMsg(playerid, COL_SYS, CLAN_SKIN_GET_SUCCESS, CLAN[USER[playerid][CLANID]-1][SKIN]);

    USER[playerid][SKIN] = CLAN[USER[playerid][CLANID]-1][SKIN];

    GetPlayerPos(playerid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);
    GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

    new ammo = 9999;
    SetSpawnInfo(playerid, USER[playerid][CLANID], USER[playerid][SKIN], USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z], USER[playerid][ANGLE], USER[playerid][WEP1], ammo, USER[playerid][WEP2], ammo, USER[playerid][WEP3], ammo);
    sync(playerid);

    save(playerid);
    return 0;
}
/* SHOP
    @ shopWeapon(playerid, listitem)   :  Buy Weapon     [shopWeapon - shopWeaponBuy]
    @ shopSkin(playerid, inputtext)    :  Buy Skins      [shopSkin   - shopSkinBuy  ]
    @ shopAcc(playerid, listitem)      :  Buy Acc
    @ shopName(playerid, inputtext)    :  Rename         [shopName   - shopNameEdit ]
*/

stock shopWeapon(playerid, listitem){

    switch(listitem){
        case 0 : INGAME[playerid][BUY_WEAPONID] = 24;
        case 1 : INGAME[playerid][BUY_WEAPONID] = 25;
        case 2 : INGAME[playerid][BUY_WEAPONID] = 42;
        case 3 : INGAME[playerid][BUY_WEAPONID] = 27;
        case 4 : INGAME[playerid][BUY_WEAPONID] = 28;
        case 5 : INGAME[playerid][BUY_WEAPONID] = 29;
        case 6 : INGAME[playerid][BUY_WEAPONID] = 30;
        case 7 : INGAME[playerid][BUY_WEAPONID] = 31;
        case 8 : INGAME[playerid][BUY_WEAPONID] = 32;
        case 9 : INGAME[playerid][BUY_WEAPONID] = 33;
        case 10 : INGAME[playerid][BUY_WEAPONID] = 34;
    }

    new query[400],row;
    mysql_format(mysql, query, sizeof(query), SQL_WEAPON_BUY_CHECK, USER[playerid][ID], INGAME[playerid][BUY_WEAPONID]);
    mysql_query(mysql, query);

    row = cache_num_rows();
    if(row){
        formatMsg(playerid, COL_SYS, ALREADY_HAVE_WEAPON, wepModel[listitem]);
        showDialog(playerid, DL_SHOP_WEAPON);
    }
    else showDialog(playerid, DL_SHOP_WEAPON_BUY);
}
stock shopSkin(playerid, inputtext[]){
    new skin = strval(inputtext);
    if(skin < 0 || skin > 299) return SendClientMessage(playerid, COL_SYS, SKIN_MAX_299);
    if(skin == 0 || skin == 74) return SendClientMessage(playerid, COL_SYS, SKIN_NOT_CJ);
    if(USER[playerid][MONEY] < 2000) return SendClientMessage(playerid,COL_SYS,SKIN_BUY_NOT_MONEY);

    INGAME[playerid][BUY_SKINID] = skin;
    showDialog(playerid, DL_SHOP_SKIN_BUY);
    return 0;
}
stock shopAcc(playerid, listitem){
    formatMsg(playerid, COL_SYS, "Cappuccino shop accessories %d - %d",playerid, listitem);
}

stock shopName(playerid, inputtext[]){
    if(!strlen(inputtext))return showDialog(playerid, DL_SHOP_NAME);
    if(USER[playerid][MONEY] < 20000) return SendClientMessage(playerid,COL_SYS,NAME_EDIT_NOT_MONEY);
    if(strlen(inputtext) < 3)return SendClientMessage(playerid,COL_SYS, YOU_NAME_MIN_LENTH), showDialog(playerid, DL_SHOP_NAME);
    if(strlen(inputtext) > 24)return SendClientMessage(playerid,COL_SYS, YOU_NAME_MAX_LENTH), showDialog(playerid, DL_SHOP_NAME);

    if(isHangul(playerid, inputtext)) return showDialog(playerid, DL_SHOP_NAME);

    new query[400],row;
    mysql_format(mysql, query, sizeof(query),SQL_NAME_EDIT_CHECK, escape(inputtext));
    mysql_query(mysql, query);

    row = cache_num_rows();
    if(row){
        SendClientMessage(playerid,COL_SYS,ALREADY_NAME);
        showDialog(playerid, DL_SHOP_NAME);
        return 0;
    }

    format(INGAME[playerid][EDIT_NAME], 24,"%s", inputtext);
    showDialog(playerid, DL_SHOP_NAME_EDIT);
    return 0;
}

/* SHOP WEAPON BUY
   @ shopWeaponBuy(playerid)   : Weapon Buy confirmation message
*/
stock shopWeaponBuy(playerid){
    if(isBuyWepMoney(INGAME[playerid][BUY_WEAPONID], USER[playerid][MONEY]))return SendClientMessage(playerid,COL_SYS,WEAPON_BUY_NOT_MONEY);

    formatMsg(playerid, COL_SYS, WEAPON_BUY_SUCCESS,wepName(INGAME[playerid][BUY_WEAPONID]));
    formatMsg(playerid, COL_SYS, WEAPON_BUY_HELP_TEXT);

    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_WEAPON_BUY_SUCCESS,
        USER[playerid][ID],
        INGAME[playerid][BUY_WEAPONID]
    );
    mysql_query(mysql, query);

    INGAME[playerid][WEPBAG_INDEX] +=1;
    WEPBAG[playerid][INGAME[playerid][WEPBAG_INDEX]-1][MODEL] = INGAME[playerid][BUY_WEAPONID];

    giveMoney(playerid, -wepPrice(INGAME[playerid][BUY_WEAPONID]));
    INGAME[playerid][BUY_WEAPONID] = 0;
    return 0;
}

/* SHOP SKIN BUY
   @ shopSkinBuy(playerid)   : Skin Buy confirmation message
*/
stock shopSkinBuy(playerid){
    formatMsg(playerid, COL_SYS, SKIN_BUY_SUCCESS,INGAME[playerid][BUY_SKINID]);
    giveMoney(playerid, -2000);

    USER[playerid][SKIN] = INGAME[playerid][BUY_SKINID];
    INGAME[playerid][BUY_SKINID] = 0;

    GetPlayerPos(playerid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);
    GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

    new ammo = 9999;
    SetSpawnInfo(playerid, USER[playerid][CLANID], USER[playerid][SKIN], USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z], USER[playerid][ANGLE], USER[playerid][WEP1], ammo, USER[playerid][WEP2], ammo, USER[playerid][WEP3], ammo);
    sync(playerid);

    save(playerid);
}

/* SHOP NAME EDIT
   @ shopNameEdit(playerid)  : Rename confirmation message
*/
stock shopNameEdit(playerid){
    formatMsg(playerid, COL_SYS, NAME_EDIT_SUCCESS,INGAME[playerid][EDIT_NAME]);
    giveMoney(playerid, -20000);

    new query[400];

    mysql_format(mysql, query, sizeof(query), SQL_NAME_CLAN_EDIT, escape(INGAME[playerid][EDIT_NAME]), USER[playerid][ID]);
    mysql_query(mysql, query);

    format(USER[playerid][NAME], 24,"%s",INGAME[playerid][EDIT_NAME]);
    SetPlayerName(playerid, USER[playerid][NAME]);

    mysql_format(mysql, query, sizeof(query), SQL_MYCAR_SELECT, USER[playerid][ID]);
    mysql_query(mysql, query);

    new rows, fields;
    cache_get_data(rows, fields);
    for(new i=0; i < rows; i++){
        new vehicleid = cache_get_field_content_int(i, "ID");
        format(VEHICLE[vehicleid][OWNER_NAME], 24, USER[playerid][NAME]);
    }

    format(INGAME[playerid][EDIT_NAME], 24,"");
}

/* NOTICE
    @ noticeSeason(playerid)   : Meeting square season rank
*/
stock noticeSeason(playerid){
    if(INGAME[playerid][SEASON] == 2) return INGAME[playerid][SEASON] = 0;
    showDialog(playerid, DL_NOTICE_SEASON);
    return 0;
}

/* MYWEP SETUP
   @ setWep(playerid, listitem)          : See my weapons  [setWep - setWepOption]
   @ setWepOption(playerid, listitem)    : Setting up the main weapon
   @ holdWep(playerid)                   : Equipped with main weapon
   @ putWep(playerid)                    : Removing the main weapon
*/
stock setWep(playerid, listitem){
    INGAME[playerid][HOLD_WEPLIST] = listitem;
    showDialog(playerid, DL_MYWEP_SETUP_OPTION);
}
stock setWepOption(playerid, listitem){
    switch(listitem){
        case 0 :{
            if(isHoldWep(playerid, INGAME[playerid][HOLD_WEPID])) return showDialog(playerid, DL_MYWEP_SETUP);
            showDialog(playerid, DL_MYWEP_SETUP_HOLD);
        }
        case 1 :{
            if(isEmptyWep(playerid, INGAME[playerid][HOLD_WEPLIST])) return showDialog(playerid, DL_MYWEP_SETUP), SendClientMessage(playerid,COL_SYS,"    비어있는 슬롯입니다.");
            showDialog(playerid, DL_MYWEP_SETUP_PUT);
        }
    }
    return 0;
}
stock holdWep(playerid){
    switch(INGAME[playerid][HOLD_WEPLIST]){
        case 0 : USER[playerid][WEP1] = INGAME[playerid][HOLD_WEPID];
        case 1 : USER[playerid][WEP2] = INGAME[playerid][HOLD_WEPID];
        case 2 : USER[playerid][WEP3] = INGAME[playerid][HOLD_WEPID];
    }

    sync(playerid);
    formatMsg(playerid, COL_SYS, WEAPON_HOLD_SUCCESS,INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));
    save(playerid);
    showDialog(playerid, DL_MYWEP_SETUP);
    return 0;
}
stock putWep(playerid){
    formatMsg(playerid, COL_SYS, WEAPON_PUT_SUCCESS,INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));

    switch(INGAME[playerid][HOLD_WEPLIST]){
        case 0 : USER[playerid][WEP1] = 0;
        case 1 : USER[playerid][WEP2] = 0;
        case 2 : USER[playerid][WEP3] = 0;
    }

    sync(playerid);
    save(playerid);
    showDialog(playerid, DL_MYWEP_SETUP);
    return 0;
}

/* MYCAR SETUP
   @ setCar(playerid, listitem)   : My vehicle            [setCar - spawnCar]
   @ spawnCar(playerid)           : My Vehicle Summon
*/
stock setCar(playerid, listitem){
    switch(listitem){
        case 0 :{
            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,COL_SYS,IN_CAR_NOT_CAR_SPAWN);
            if(USER[playerid][MONEY] < 2000) return SendClientMessage(playerid,COL_SYS, CAR_SPAWN_NOT_MONEY);
            showDialog(playerid, DL_MYCAR_SETUP_SPAWN);
        }
    }
    return 0;
}
stock spawnCar(playerid){
    new vehicleid = INGAME[playerid][HOLD_CARID];
    new model = GetVehicleModel(vehicleid);
    RemovePlayerFromVehicle(playerid);

    GetPlayerPos(playerid,USER[playerid][POS_X],USER[playerid][POS_Y],USER[playerid][POS_Z]);
    GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

    SetVehiclePos(vehicleid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);
    SetVehicleZAngle(vehicleid, USER[playerid][ANGLE]);
    inCar(playerid,vehicleid);
    PutPlayerInVehicle(playerid, vehicleid, 0);

    vehicleSave(vehicleid);
    formatMsg(playerid, COL_SYS, CAR_SPAWN_SUCCESS, vehicleName[model - 400]);
    giveMoney(playerid,-500);
}
/* GARAGE
   @ repairCar(playerid)              : Vehicle repair
   @ paintCar(playerid, inputtext)    : Vehicle paint      [two binding / switch return function ]
   @ turnCar(playerid)                : Vehicle tuning
*/
stock repairCar(playerid){
    if(USER[playerid][MONEY] < 100) return SendClientMessage(playerid,COL_SYS,CAR_REPAIR_NOT_MONEY);
    new vehicleid = GetPlayerVehicleID(playerid);
    new model = GetVehicleModel(vehicleid);

    formatMsg(playerid, COL_SYS, CAR_REPAIR_SUCCESS, vehicleName[model - 400]);
    RepairVehicle(vehicleid);

    giveMoney(playerid,-100);
    return 0;
}
stock paintCar(playerid, inputtext[]){
    if(USER[playerid][MONEY] < 500) return SendClientMessage(playerid,COL_SYS,CAR_PAINT_NOT_MONEY);

    switch(INGAME[playerid][PAINT_TYPE]){
        case 0:{ /* first paint color */
            INGAME[playerid][CAR_PAINT1] = strval(inputtext);
            showDialog(playerid, DL_GARAGE_PAINT);
            INGAME[playerid][PAINT_TYPE] =1;
            SendClientMessage(playerid,COL_SYS, CAR_PAINT1_TEXT);
        }
        case 1:{ /* last paint color */
            new vehicleid = GetPlayerVehicleID(playerid);

            INGAME[playerid][CAR_PAINT2] = strval(inputtext);
            INGAME[playerid][PAINT_TYPE] =0;
            SendClientMessage(playerid,COL_SYS, CAR_PAINT2_TEXT);

            VEHICLE[vehicleid][COLOR1] = INGAME[playerid][CAR_PAINT1];
            VEHICLE[vehicleid][COLOR2] = INGAME[playerid][CAR_PAINT2];

            ChangeVehicleColor(GetPlayerVehicleID(playerid), VEHICLE[vehicleid][COLOR1], VEHICLE[vehicleid][COLOR2]);

            new query[400];
            mysql_format(mysql, query, sizeof(query), SQL_VEHICLE_COLOR_UPDATE,
            VEHICLE[vehicleid][COLOR1],
            VEHICLE[vehicleid][COLOR2],
            vehicleid);

            mysql_query(mysql, query);
        }
    }
    return 0;
}
stock turnCar(playerid){
    formatMsg(playerid, COL_SYS, "Service station tuning %d",playerid);
}

/* DUEL
    @ duelType(playerid, listitem)        : Dual weapon type designation
    @ duelMoney(playerid, inputtext[])    : Specify Dual Betting Amount
    @ duelSuccess(playerid)               : Dual entry
    @ duelSpawn(playerid, order)          : Dual chapter spawning  @order : 0스폰자리/1스폰자리
    @ duelTimer(p1, p2)                   : Dual start timer       [ tick timer 1500, four binding]
    @ duelResult(playerid)                : Dual Results
    @ duelMatchID(playerid)               : Get a matched relative ID return
    @ duelLeave(playerid)                 : Dual exiting
*/
stock duelType(playerid, listitem){
    DUEL_CORE[TYPE] = listitem;

    showDialog(playerid, DL_DUEL_MONEY);
}
stock duelMoney(playerid, inputtext[]){
    new money = strval(inputtext);
    if(money < 0)return showDialog(playerid, DL_DUEL_MONEY);
    if(USER[playerid][MONEY] < money)return showDialog(playerid, DL_DUEL_MONEY);

    DUEL_CORE[MONEY] = money;
    showDialog(playerid, DL_DUEL_SUCCESS);
    return 0;
}
stock duelSuccess(playerid){
    switch(DUEL_CORE[LENGTH]){
        case 0:{
            DUEL_CORE[INDEX]+=1;
            DUEL_CORE[PID1]=playerid;

            formatMsgAll(COL_SYS, DUEL_OPEN1_TEXT,DUEL_CORE[INDEX],USER[DUEL_CORE[PID1]][NAME],DUEL_CORE[MONEY],duelTypeName[DUEL_CORE[TYPE]]);
            SendClientMessageToAll(COL_SYS, DUEL_OPEN2_TEXT);
            SendClientMessage(playerid, COL_SYS, DUEL_OPEN3_TEXT);
            DUEL_CORE[ON]=false;
        }
        case 1:{
            if(USER[playerid][MONEY] < DUEL_CORE[MONEY])return SendClientMessage(playerid,COL_SYS,DUEL_NOT_MONEY);

            DUEL_CORE[PID2]=playerid;
            SetTimerEx("duelTimer", 1500, false, "ii", DUEL_CORE[PID1], DUEL_CORE[PID2]);

            TogglePlayerControllable(DUEL_CORE[PID1],0);
            SetCameraBehindPlayer(DUEL_CORE[PID1]);
            SetPlayerArmedWeapon(DUEL_CORE[PID1], 0);

            TogglePlayerControllable(DUEL_CORE[PID2],0);
            SetCameraBehindPlayer(DUEL_CORE[PID2]);
            SetPlayerArmedWeapon(DUEL_CORE[PID2], 0);

            duelSpawn(DUEL_CORE[PID2], 1);
            formatMsgAll(COL_SYS, DUEL_START_TEXT,DUEL_CORE[INDEX],USER[DUEL_CORE[PID1]][NAME],USER[DUEL_CORE[PID2]][NAME],DUEL_CORE[MONEY],duelTypeName[DUEL_CORE[TYPE]]);
        }
    }
    duelSpawn(DUEL_CORE[PID1], 0);
    DUEL_CORE[LENGTH]+=1;
    return 0;
}

stock duelSpawn(playerid, order){
    SetPlayerTeam(playerid, NO_TEAM);
    SetPlayerPos(playerid, DUEL_POS[order][0],DUEL_POS[order][1],DUEL_POS[order][2]);
    SetPlayerFacingAngle(playerid, DUEL_POS[order][3]);
    ResetPlayerWeapons(playerid);
    switch(DUEL_CORE[TYPE]){
        case 0: GivePlayerWeapon(playerid, 0, 0);
        case 1: GivePlayerWeapon(playerid, 24, 9999);
        case 2: GivePlayerWeapon(playerid, 24, 9999),GivePlayerWeapon(playerid, 25, 9999);
        case 3: GivePlayerWeapon(playerid, 34, 9999),GivePlayerWeapon(playerid, 25, 9999);
        case 4: GivePlayerWeapon(playerid, 27, 9999),GivePlayerWeapon(playerid, 33, 9999);
        case 5: GivePlayerWeapon(playerid, 31, 9999),GivePlayerWeapon(playerid, 25, 9999);
    }
    SetPlayerHealth(playerid, 100);
    SetPlayerArmour(playerid, 100);

    INGAME[playerid][DUEL_JOIN] = true;
}

public duelTimer(p1, p2){
    new str[32];
    DUEL_CORE[TICK]+=1;

    if(DUEL_CORE[TICK] == 4){
        PlayerPlaySound(p1, 3200, 0.0, 0.0, 0.0);
        PlayerPlaySound(p2, 3200, 0.0, 0.0, 0.0);

        TogglePlayerControllable(p1,1);
        TogglePlayerControllable(p2,1);

        format(str,sizeof(str), "~b~~h~START DUEL!");
        GameTextForPlayer(p1, str,1400,1);
        GameTextForPlayer(p2, str,1400,1);

        DUEL_CORE[TICK] = 0;
    }else{
        PlayerPlaySound(p1, 5201, 0.0, 0.0, 0.0);
        PlayerPlaySound(p2, 5201, 0.0, 0.0, 0.0);

        format(str,sizeof(str), "~b~~h~%d!",DUEL_CORE[TICK]);
        GameTextForPlayer(p1, str,1400,6);
        GameTextForPlayer(p2, str,1400,6);

        SetTimerEx("duelTimer", 1500, false, "ii", p1,p2);
    }
}

stock duelResult(playerid){
    new killerid = duelMatchID(playerid);

    GetPlayerHealth(killerid, USER[killerid][HP]);
    GetPlayerArmour(killerid, USER[killerid][AM]);

    DUEL_CORE[ON]=true;
    DUEL_CORE[LENGTH]=0;

    formatMsgAll(COL_SYS, DUEL_RESULT_TEXT, DUEL_CORE[INDEX], USER[killerid][NAME], USER[playerid][NAME], DUEL_CORE[MONEY], duelTypeName[DUEL_CORE[TYPE]], USER[killerid][HP], USER[killerid][AM]);

    USER[playerid][DUEL_LOSS]+=1;
    giveMoney(playerid, -DUEL_CORE[MONEY]);
    INGAME[playerid][DUEL_JOIN] = false;

    USER[killerid][DUEL_WIN]+=1;
    giveMoney(killerid, DUEL_CORE[MONEY]);
    showDialog(killerid, DL_DUEL_TYPE);

    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DUEL_INSERT, killerid, playerid, DUEL_CORE[TYPE], DUEL_CORE[MONEY], USER[killerid][HP], USER[killerid][AM]);
    mysql_query(mysql, query);
}

stock duelMatchID(playerid){
    if(DUEL_CORE[PID1] == playerid) return DUEL_CORE[PID2];
    return DUEL_CORE[PID1];
}
stock duelLeave(playerid){
    DUEL_CORE[LENGTH]=0;
    SetPlayerPos(playerid, 1913.1345, -1710.5565, 13.4003);
    SetPlayerFacingAngle(playerid, 89.3591);

    INGAME[playerid][DUEL_JOIN]=false;
    DUEL_CORE[INDEX]-=1;
    DUEL_CORE[ON]=false;

    ResetPlayerWeapons(playerid);

    GivePlayerWeapon(playerid, USER[playerid][WEP1], 9999);
    GivePlayerWeapon(playerid, USER[playerid][WEP2], 9999);
    GivePlayerWeapon(playerid, USER[playerid][WEP3], 9999);

    if(!isHaveWeapon(playerid , 24) && USER[playerid][LEVEL] < 10)GivePlayerWeapon(playerid, 24, INGAME[playerid][AMMO]);
    SetPlayerArmedWeapon(playerid, 0);
}

/* GAMBLE
	@ gambleChoice(playerid, listitem)            : Specify slot machine bet amount
	@ gambling(playerid, dice, listitem, result)  : Slot machine game progress
	@ gambleRegamble(playerid)                    : Go back to the slot machine [5-value rule re-rolls]
	@ gambleResult(playerid)                      : Output slot machine result
*/

stock gambleChoice(playerid,listitem){
    new dice = random(5)+1, result;

    switch(dice){
        case 1,3:{
            if(listitem == 0) result =1;
            else result =0;
        }
        case 2,4:{
            if(listitem == 1) result =1;
            else result =0;
        }
    }

    gambling(playerid, dice, listitem, result);
    return 0;
}

stock gambling(playerid, dice, choice, result){
    new str[289], diceText[256], choiceText[2][20] = {{"add number"},{"even"}};
    format(diceText, sizeof(diceText), GAMBLE_RESULT_TEXT ,INGAME[playerid][GAMBLE], dice, choiceText[choice]);

    if(result){
        giveMoney(playerid, INGAME[playerid][GAMBLE]);
        format(str, sizeof(str), GAMBLE_DL_WIN, diceText);
        ShowPlayerDialog(playerid, DL_GAMBLE_RESULT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,str, DIALOG_STRAT, DIALOG_CLOSE);
    }else{
        switch(dice){
            case 5:{
                format(str, sizeof(str), GAMBLE_DL_REGAMBLE, diceText);
                ShowPlayerDialog(playerid, DL_GAMBLE_REGAMBLE, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,str, DIALOG_STRAT, DIALOG_CLOSE);
            }
            case 6:{
                giveMoney(playerid, -INGAME[playerid][GAMBLE]);
                format(str, sizeof(str), GAMBLE_DL_FAIL, diceText);
                ShowPlayerDialog(playerid, DL_GAMBLE_RESULT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,str, DIALOG_STRAT, DIALOG_CLOSE);
            }
            default:{
                giveMoney(playerid, -INGAME[playerid][GAMBLE]);
                format(str, sizeof(str), GAMBLE_DL_LOSE, diceText);
                ShowPlayerDialog(playerid, DL_GAMBLE_RESULT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,str, DIALOG_STRAT, DIALOG_CLOSE);
            }
		}
    }
}

stock gambleRegamble(playerid){
    showDialog(playerid, DL_GAMBLE_CHOICE);
}

stock gambleResult(playerid){
    showMisson(playerid, 4);
}

public OnPlayerCommandText(playerid, cmdtext[]){
    new cmd[256], tmp[256], idx, str[256];
    cmd = strtok(cmdtext, idx);

    new giveid;

    if(!strcmp("/sav", cmdtext)){

        if(!INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS, ONLY_LOGIN_CMD);

        save(playerid);
        if(IsPlayerInAnyVehicle(playerid)) vehicleSave(GetPlayerVehicleID(playerid));

        SendClientMessage(playerid,COL_SYS, LOG_SAVE);
        return 1;
    }
    if(!strcmp("/lobby", cmdtext)){
        if(INGAME[playerid][DUEL_JOIN])return SendClientMessage(playerid,COL_SYS, DUEL_NOT_CMD);
        if(USER[playerid][MONEY] < 2000) return SendClientMessage(playerid,COL_SYS,LOBBY_TEL_NOT_MONEY);
        if(USER[playerid][HP] < 90 && USER[playerid][AM] < 90) return SendClientMessage(playerid,COL_SYS, "    비전투구역은 피 90 아머90 이상일때만 이동이 가능합니다.");

        SetPlayerPos(playerid, 1913.1345, -1710.5565, 13.4003);
        SetPlayerFacingAngle(playerid, 89.3591);

        SendClientMessage(playerid,COL_SYS, LOBBY_GO_TEXT);
        giveMoney(playerid, -2000);
        return 1;
    }
    if(!strcmp("/re", cmdtext)){
        if(!INGAME[playerid][DUEL_JOIN])return 1;
        if(DUEL_CORE[LENGTH] != 1)return 1;

        duelLeave(playerid);
        return 1;
    }
    if(!strcmp("/help", cmdtext)){
        showDialog(playerid, DL_INFO);
        return 1;
    }
    if(!strcmp("/wep", cmdtext)){
        if(INGAME[playerid][DUEL_JOIN])return SendClientMessage(playerid,COL_SYS, DUEL_NOT_CMD);

        showDialog(playerid, DL_MYWEP);
        return 1;
    }
    if(!strcmp("/car", cmdtext)){
        if(INGAME[playerid][DUEL_JOIN])return SendClientMessage(playerid,COL_SYS, DUEL_NOT_CMD);

        showDialog(playerid, DL_MYCAR);
        return 1;
    }
    if(!strcmp("/kill", cmdtext)){
        if(INGAME[playerid][DUEL_JOIN] && DUEL_CORE[LENGTH] == 1) return SendClientMessage(playerid,COL_SYS, DUEL_KILL_NOT_CMD);

        SetPlayerHealth(playerid, 0);
        return 1;
    }
    if(!strcmp("/carbuy", cmdtext)){
        if(isMaxHaveCar(playerid)) return SendClientMessage(playerid, COL_SYS, CAR_HAVE_MAX_LENTH);
        if(!IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,COL_SYS,CAR_NOT_IN);
        if(USER[playerid][MONEY] < 30000) return SendClientMessage(playerid,COL_SYS,CAR_BUY_NOT_MONEY);
        if(VEHICLE[GetPlayerVehicleID(playerid)][OWNER_ID] != 0)return SendClientMessage(playerid,COL_SYS,CAR_ALREADY_SELL);

        vehicleBuy(playerid, GetPlayerVehicleID(playerid));
        return 1;
    }
    if(!strcmp("/pm", cmd) || !strcmp("/spm", cmd) || !strcmp("/ow", cmd) || !strcmp("/op", cmd)){
        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_PM_TEXT);
        giveid = strval(tmp);

        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);
        if(giveid == playerid) return SendClientMessage(playerid,COL_SYS,HELP_PM_NOT_SELF);

        str = strtok2(cmdtext, idx);
        if(!strlen(str))return SendClientMessage(playerid, COL_SYS,HELP_PM_TEXT);

        formatMsg(playerid, 0xFFFF00AA, PM_SEND_TEXT,USER[giveid][NAME],giveid, str);
        formatMsg(giveid, 0xFFFF00AA, PM_GET_TEXT,USER[playerid][NAME],playerid, str);
        return 1;
    }
    if(!strcmp("/money", cmd)){
        if(INGAME[playerid][DUEL_JOIN])return SendClientMessage(playerid,COL_SYS, DUEL_NOT_CMD);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_MONEY_TEXT);

        giveid = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        str = strtok(cmdtext, idx);
        if(!strlen(str))return SendClientMessage(playerid, COL_SYS,HELP_MONEY_TEXT);

        new money = strval(str);
        if(money < 0)return 1;
        if(USER[playerid][MONEY] < money) return SendClientMessage(playerid,COL_SYS,GIVE_NOT_MONEY_LENGTH);

        giveMoney(playerid, -money);
        giveMoney(giveid, money);

        formatMsg(giveid, COL_SYS, GIVE_MONEY_GET, USER[playerid][NAME],playerid, money);
        formatMsg(playerid, COL_SYS, GIVE_MONEY_SEND, money,USER[giveid][NAME],giveid );
        return 1;
    }
    if(!strcmp("/servermoney", cmd)){
        if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_GIVEMONEY_TEXT);

        giveid = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        str = strtok(cmdtext, idx);
        if(!strlen(str))return SendClientMessage(playerid, COL_SYS,HELP_GIVEMONEY_TEXT);
        new money = strval(str);
        if(money < 0)return 0;

        giveMoney(giveid, money);
        formatMsg(giveid, COL_SYS, ADMIN_GIVEMONEY_GET,money);
        formatMsg(playerid, COL_SYS, ADMIN_GIVEMONEY_SEND,USER[giveid][NAME], money);
        return 1;
    }
    if(!strcmp("/time", cmd)){
        if(USER[playerid][ADMIN] < 1) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_TIME_TEXT);

        new time = strval(tmp);
        SetWorldTime(time);
        formatMsgAll(COL_SYS, ADMIN_SETTIME_NOTICE, time);
        return 1;
    }
    if(!strcmp("/kick", cmd)){
        if(USER[playerid][ADMIN] < 1) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_KICK_TEXT);

        giveid  = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);
        formatMsg(giveid, COL_SYS, ADMIN_KICK_GET);

        formatMsg(playerid, COL_SYS, ADMIN_KICK_SEND,USER[giveid][NAME]);
        Kick(giveid);
        return 1;
    }
    if(!strcmp("/bomb", cmd)){
        if(USER[playerid][ADMIN] < 2) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_BOMB_TEXT);

        giveid  = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        formatMsg(giveid, COL_SYS, ADMIN_BOMB_GET);
        formatMsg(playerid, COL_SYS, ADMIN_BOMB_SEND,USER[giveid][NAME]);

        GetPlayerPos(giveid, USER[giveid][POS_X], USER[giveid][POS_Y],USER[giveid][POS_Z]);
        CreateExplosion(USER[giveid][POS_X], USER[giveid][POS_Y],USER[giveid][POS_Z], 16, 32.0);
        return 1;
    }
    if(!strcmp("/ip", cmd)){
        if(USER[playerid][ADMIN] < 2) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_IP_TEXT);

        giveid  = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        GetPlayerIp(giveid, USER[giveid][USERIP], 16);
        formatMsg(playerid, COL_SYS, ADMIN_IP_SEND,USER[giveid][NAME], USER[giveid][USERIP]);
        return 1;
    }
    if(!strcmp("/ban", cmd)){
        if(USER[playerid][ADMIN] < 3) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_BAN_TEXT);

        giveid  = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        formatMsg(giveid, COL_SYS, ADMIN_BAN_GET);
        formatMsg(playerid, COL_SYS, ADMIN_BAN_SEND,USER[giveid][NAME]);

        Ban(giveid);
        return 1;
    }
    if(!strcmp("/call", cmd)){
        if(USER[playerid][ADMIN] < 3) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_CALL_TEXT);

        giveid  = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);
        formatMsg(giveid, COL_SYS, ADMIN_CALL_GET);
        formatMsg(playerid, COL_SYS, ADMIN_CALL_SEND,USER[giveid][NAME]);

        GetPlayerPos(playerid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);
        GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

        new inter = GetPlayerInterior(playerid);
        new world = GetPlayerVirtualWorld(playerid);

        SetPlayerPos(giveid, USER[playerid][POS_X], USER[playerid][POS_Y]+1, USER[playerid][POS_Z]);
        SetPlayerFacingAngle(giveid, USER[playerid][ANGLE]);

        SetPlayerInterior(giveid, inter);
        SetPlayerVirtualWorld(giveid, world);

        return 1;
    }
    if(!strcmp("/go", cmd)){
        if(USER[playerid][ADMIN] < 3) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_GO_TEXT);

        giveid  = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        formatMsg(giveid, COL_SYS, ADMIN_GO_GET);
        formatMsg(playerid, COL_SYS, ADMIN_GO_SEND,USER[giveid][NAME]);

        GetPlayerPos(giveid, USER[giveid][POS_X], USER[giveid][POS_Y], USER[giveid][POS_Z]);
        GetPlayerFacingAngle(giveid, USER[giveid][ANGLE]);

        new inter = GetPlayerInterior(giveid);
        new world = GetPlayerVirtualWorld(giveid);

        SetPlayerPos(playerid, USER[giveid][POS_X], USER[giveid][POS_Y]+1, USER[giveid][POS_Z]);
        SetPlayerFacingAngle(playerid, USER[giveid][ANGLE]);

        SetPlayerInterior(playerid, inter);
        SetPlayerVirtualWorld(playerid, world);

        return 1;
    }
    if(!strcmp("/admin", cmd)){
        if(USER[playerid][ADMIN] < 4) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp))return SendClientMessage(playerid, COL_SYS,HELP_ADMIN_TEXT);

        giveid = strval(tmp);
        if(!INGAME[giveid][LOGIN]) return SendClientMessage(playerid,COL_SYS,NOT_JOIN_USER);

        str = strtok(cmdtext, idx);
        if(!strlen(str))return SendClientMessage(playerid, COL_SYS,HELP_GIVEMONEY_TEXT);

        new admin = strval(str);
        if(admin > 4) return SendClientMessage(playerid,COL_SYS,ADMIN_NOT_MAX_LENGTH);

        USER[giveid][ADMIN] = admin;
        save(giveid);

        formatMsg(giveid, COL_SYS, ADMIN_ADMIN_GET,admin);
        formatMsg(playerid, COL_SYS, ADMIN_ADMIN_SEND,USER[giveid][NAME], admin);
        return 1;
    }
    if(!strcmp("/restart", cmdtext)){
        if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,COL_SYS,YOU_NOT_ADMIN);

        SendClientMessageToAll(COL_SYS, SERVER_RESTART_TEXT);

        for(new i=0; i<GetMaxPlayers(); i++)out(i),INGAME[i][RESTART] = true;
        SendRconCommand("gmx");
        return 1;
    }
    return 0;
}

public OnPlayerDisconnect(playerid, reason){
    if(INGAME[playerid][RESTART]) return 0;
    if(INGAME[playerid][DUEL_JOIN])duelResult(playerid);

    out(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
    if(INGAME[playerid][SYNC]) return 0;
    if(INGAME[playerid][DUEL_JOIN])duelResult(playerid);

    death(playerid, killerid, reason);
    return 1;
}

/* REG/LOG
   @checked(playerid, password[])       : Get input password
   @join(playerid, type)                : Sign up / login by user type
*/
stock checked(playerid, password[]){

    if(strlen(password) == 0) return join(playerid, 1), SendClientMessage(playerid,COL_SYS, TYPE_NOT_PASSWORD);
    if(strcmp(password, USER[playerid][PASS])) return join(playerid, 1), SendClientMessage(playerid,COL_SYS, YOU_NOT_PASSWORD);

    SendClientMessage(playerid,COL_SYS,JOIN_LOGIN);
    INGAME[playerid][LOGIN] = true;

    load(playerid);
    return 1;
}
stock join(playerid, type){
    switch(playerid, type){
        case 0 : showDialog(playerid, DL_REGIST);
        case 1 : showDialog(playerid, DL_LOGIN);
    }
    return 1;
}

/* SQL
   @ check(playerid)          : Entered password verification [Type: login date]]
   @ regist(playerid, pass)   : Sign Up
   @ save(playerid)           : Save
   @ load(playerid)           : User data loaded
   @ escape(str[])            : mysql real escape     [ SQL Injection process ]
*/
public check(playerid){
    new query[128], result;
    GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);

    mysql_format(mysql, query, sizeof(query), SQL_USER_PASS_CHECK, escape(USER[playerid][NAME]));
    mysql_query(mysql, query);

    result = cache_num_rows();
    if(result){
        USER[playerid][ID]      = cache_get_field_content_int(0, "ID");
        cache_get_field_content(0, "PASS", USER[playerid][PASS], mysql, 24);
    }
    return result;
}
public regist(playerid, pass[]){
    GetPlayerIp(playerid, USER[playerid][USERIP], 16);
    format(USER[playerid][PASS],24, "%s",pass);
    new query[400];

    mysql_format(mysql, query, sizeof(query), SQL_USER_INSERT,
    USER[playerid][NAME], USER[playerid][PASS], USER[playerid][USERIP],
    USER[playerid][ADMIN] = 0,
    USER[playerid][CLANID] = 0,
    USER[playerid][MONEY] = 1000,
    USER[playerid][LEVEL] = 1,
    USER[playerid][EXP] = 0,
    USER[playerid][KILLS] = 0,
    USER[playerid][DEATHS] = 0,
    USER[playerid][SKIN] = 250,
    USER[playerid][WEP1] = 0,
    USER[playerid][WEP2] = 0,
    USER[playerid][WEP3] = 0,
    USER[playerid][INTERIOR] = 0,
    USER[playerid][WORLD] = 0,
    USER[playerid][POS_X] = 1913.1345,
    USER[playerid][POS_Y] = -1710.5565,
    USER[playerid][POS_Z] = 13.4003,
    USER[playerid][ANGLE] = 89.3591,
    USER[playerid][HP] = 100.0,
    USER[playerid][AM] = 100.0);

    mysql_query(mysql, query);
    GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);

    USER[playerid][ID] = cache_insert_id();

    SendClientMessage(playerid,COL_SYS, JOIN_REGIST);
    INGAME[playerid][LOGIN] = true;
    spawn(playerid);
}
public save(playerid){

    if(INGAME[playerid][DUEL_JOIN]){
        USER[playerid][POS_X] = 1913.1345;
        USER[playerid][POS_Y] = -1710.5565;
        USER[playerid][POS_Z] = 13.4003;
        USER[playerid][ANGLE] = 89.3591;
    }else{
        GetPlayerPos(playerid,USER[playerid][POS_X],USER[playerid][POS_Y],USER[playerid][POS_Z]);
        GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);
    }

    new sql[400];
    strcat(sql, "UPDATE `user_info` SET");
    strcat(sql, " ADMIN=%d");
    strcat(sql, ",CLANID=%d");
    strcat(sql, ",MONEY=%d");
    strcat(sql, ",LEVEL=%d");
    strcat(sql, ",EXP=%d");
    strcat(sql, ",KILLS=%d");
    strcat(sql, ",DEATHS=%d");
    strcat(sql, ",SKIN=%d");
    strcat(sql, ",WEP1=%d");
    strcat(sql, ",WEP2=%d");
    strcat(sql, ",WEP3=%d");
    strcat(sql, ",INTERIOR=%d");
    strcat(sql, ",WORLD=%d");
    strcat(sql, ",POS_X=%f");
    strcat(sql, ",POS_Y=%f");
    strcat(sql, ",POS_Z=%f");
    strcat(sql, ",ANGLE=%f");
    strcat(sql, ",HP=%f");
    strcat(sql, ",AM=%f");
    strcat(sql, " WHERE `ID`=%d");

    new query[400];
    mysql_format(mysql, query, sizeof(query), sql,
    USER[playerid][ADMIN],
    USER[playerid][CLANID],
    USER[playerid][MONEY],
    USER[playerid][LEVEL],
    USER[playerid][EXP],
    USER[playerid][KILLS],
    USER[playerid][DEATHS],
    USER[playerid][SKIN],
    USER[playerid][WEP1],
    USER[playerid][WEP2],
    USER[playerid][WEP3],
    USER[playerid][INTERIOR],
    USER[playerid][WORLD],
    USER[playerid][POS_X],
    USER[playerid][POS_Y],
    USER[playerid][POS_Z],
    USER[playerid][ANGLE],
    USER[playerid][HP],
    USER[playerid][AM],
    USER[playerid][ID]);

    mysql_query(mysql, query);

    new clanName[50];
    if(USER[playerid][CLANID])format(clanName,sizeof(clanName),"%s",CLAN[USER[playerid][CLANID]-1][NAME]);
    else format(clanName,sizeof(clanName),"NONE");

    new str[256];
    format(str,sizeof(str),"~b~~h~N~w~AME : %s   ~b~~h~C~w~LAN : %s   ~b~~h~L~w~EVEL : %d   ~b~~h~E~w~XP : %d/50   ~b~~h~M~w~ONEY : %d   ~b~~h~K~w~ILLS : %d   ~b~~h~D~w~EATHS : %d   ~b~~h~K~w~/D~w~ : %.01f%",
    USER[playerid][NAME],
    clanName,
    USER[playerid][LEVEL],
    USER[playerid][EXP],
    USER[playerid][MONEY],
    USER[playerid][KILLS],
    USER[playerid][DEATHS],
    kdRatio(USER[playerid][KILLS],USER[playerid][DEATHS]));

    TextDrawSetString(TDraw[playerid][ZONETEXT],str);
}
public load(playerid){
    new query[400];
    new id = USER[playerid][ID];
    mysql_format(mysql, query, sizeof(query), SQL_USER_SELECT, id,id,id);
    mysql_query(mysql, query);

    USER[playerid][USERIP]    = cache_get_field_content_int(0, "USERIP");
    USER[playerid][ADMIN]     = cache_get_field_content_int(0, "ADMIN");
    USER[playerid][CLANID]    = cache_get_field_content_int(0, "CLANID");
    USER[playerid][MONEY]     = cache_get_field_content_int(0, "MONEY");
    USER[playerid][LEVEL]     = cache_get_field_content_int(0, "LEVEL");
    USER[playerid][EXP]       = cache_get_field_content_int(0, "EXP");
    USER[playerid][KILLS]     = cache_get_field_content_int(0, "KILLS");
    USER[playerid][DEATHS]    = cache_get_field_content_int(0, "DEATHS");
    USER[playerid][SKIN]      = cache_get_field_content_int(0, "SKIN");
    USER[playerid][WEP1]      = cache_get_field_content_int(0, "WEP1");
    USER[playerid][WEP2]      = cache_get_field_content_int(0, "WEP2");
    USER[playerid][WEP3]      = cache_get_field_content_int(0, "WEP3");
    USER[playerid][INTERIOR]  = cache_get_field_content_int(0, "INTERIOR");
    USER[playerid][WORLD]     = cache_get_field_content_int(0, "WORLD");
    USER[playerid][DUEL_WIN]  = cache_get_field_content_int(0, "DUEL_WIN");
    USER[playerid][DUEL_LOSS] = cache_get_field_content_int(0, "DUEL_LOSS");
    USER[playerid][POS_X]     = cache_get_field_content_float(0, "POS_X");
    USER[playerid][POS_Y]     = cache_get_field_content_float(0, "POS_Y");
    USER[playerid][POS_Z]     = cache_get_field_content_float(0, "POS_Z");
    USER[playerid][ANGLE]     = cache_get_field_content_float(0, "ANGLE");
    USER[playerid][HP]        = cache_get_field_content_float(0, "HP");
    USER[playerid][AM]        = cache_get_field_content_float(0, "AM");

    mysql_format(mysql, query, sizeof(query), SQL_USER_WEAPON_JOIN, id);
    mysql_query(mysql, query);

    new rows, fields;
    cache_get_data(rows, fields);

    INGAME[playerid][WEPBAG_INDEX] = rows;
    for(new i=0; i < rows; i++)WEPBAG[playerid][i][MODEL] = cache_get_field_content_int(i, "MODEL");

    spawn(playerid);
}
stock escape(str[]){
    new result[24];
    mysql_real_escape_string(str, result);
    return result;
}
/* INGAME FUNCTION
   @ spawn(playerid)     : User spawn
*/
stock spawn(playerid){

    new ammo = 9999;
    SetSpawnInfo(playerid, USER[playerid][CLANID], USER[playerid][SKIN], USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z], USER[playerid][ANGLE], USER[playerid][WEP1], ammo, USER[playerid][WEP2], ammo, USER[playerid][WEP3], ammo);

    SpawnPlayer(playerid);

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, USER[playerid][MONEY]);

    USER[playerid][HP] = 100.0;
    USER[playerid][AM] = 100.0;

    SetPlayerHealth(playerid, USER[playerid][HP]);
    SetPlayerArmour(playerid, USER[playerid][AM]);

    if(USER[playerid][CLANID] == 0){
        SetPlayerTeam(playerid, NO_TEAM);
        SetPlayerColor(playerid, 0xE6E6E699);
    }else{
        SetPlayerTeam(playerid, USER[playerid][CLANID]);
        SetPlayerColor(playerid, CLAN[USER[playerid][CLANID]-1][COLOR]);
    }

    save(playerid);
}

strtok(const string[], &index){
    new length = strlen(string);
    while ((index < length) && (string[index] <= ' ')){
        index++;
    }
    new offset = index;
    new result[20];
    while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1))){
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}
strtok2(const string[], &index)
{
    new length = strlen(string);
    while ((index < length) && (string[index] <= ' '))
    {
        index++;
    }
    new offset = index;
    new result[256];
    while ((index < length) &&((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}
/* INIT
   @ out(playerid)         : Connection termination
   @ dbcon()               : DB pool
   @ data()                : DB Load data
   @ mode()                : Mode stage preference
   @ thread()              : Server thread management
   @ server()              : Server-Side Preferences
   @ cleaning(playerid)    : enum Initialize data
   @ hide(playerid)        : Text Draw, Gangzone Hide
*/
stock out(playerid){
    if(INGAME[playerid][LOGIN]) save(playerid);
    if(IsPlayerInAnyVehicle(playerid)) vehicleSave(GetPlayerVehicleID(playerid));

    ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN] -=1;
    CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX]-=1;
    GangZoneStopFlashForAll(ZONE[INGAME[playerid][ENTER_ZONE]][ID]);

    cleaning(playerid);
    hide(playerid);

    DestroyPickup(INGAME[playerid][DEATH_PICKUP_HP]);
    DestroyPickup(INGAME[playerid][DEATH_PICKUP_AM]);
}

stock mode(){
    zoneSetup();
    loadMisson();
    loadGarage();
    textLabel_init();
    textDraw_init();
    object_init();
}

stock thread(){ SetTimer("ServerThread", 500, true); }
stock server(){
    SetGameModeText("samp.war.korea.v0.12");
    SendRconCommand("mapname Korea War Gamer Group");
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    DisableNameTagLOS();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    AddPlayerClass(0,0,0,0,0,0,0,0,0,0,0);
}
/* TODO : README.MD*/
stock dbcon(){
    new db_key[4][128] = {"hostname", "username", "database", "password"}, db_value[4][128];
    new File:cfg=fopen("database.cfg", io_read), temp[64], tick =0;

    while(fread(cfg, temp)){
        if(strcmp(temp, db_key[tick])){
            new pos = strfind(temp, "=");
            strdel(temp, 0, pos+1);
            new len = strlen(temp);
            if(tick != 3)strdel(temp, len-2, len);
            db_value[tick] = temp;
        }
        tick++;
    }

    mysql = mysql_connect(db_value[0], db_value[1], db_value[2], db_value[3]);
    mysql_set_charset("euckr");

    if(!mysql_errno(mysql))print("DB Load"),data();
    else printf("DB Connection Error");
}
stock data(){
    user_data();
    house_data();
    vehicle_data();
    zone_data();
    clan_data();
    weapon_data();
    duel_data();
}
stock cleaning(playerid){
    new
    temp1[USER_MODEL],
    temp2[INGAME_MODEL],
    temp3[CLAN_SETUP_MODEL],
    temp4[WEPBAG_MODEL];

    USER[playerid] = temp1;
    INGAME[playerid] = temp2;
    CLAN_SETUP[playerid] = temp3;
    for(new i=0; i < USED_WEAPON; i++){
        WEPBAG[playerid][i] = temp4;
    }
    warpInit(playerid);
}
stock hide(playerid){
    TextDrawHideForPlayer(playerid, TDrawG[0][ID]);
    TextDrawHideForPlayer(playerid, TDrawG[1][ID]);
    TextDrawHideForPlayer(playerid, TDrawG[2][ID]);

    TextDrawHideForPlayer(playerid, TDraw[playerid][ZONETEXT]);
    TextDrawHideForPlayer(playerid, TDraw[playerid][CP]);

    TextDrawHideForPlayer(playerid, TDraw[playerid][FPS]);
    TextDrawHideForPlayer(playerid, TDraw[playerid][PING]);
    TextDrawHideForPlayer(playerid, TDraw[playerid][PACKET]);

    TextDrawHideForPlayer(playerid, TDraw[playerid][TAKE_DAMAGE]);
    TextDrawHideForPlayer(playerid, TDraw[playerid][GIVE_DAMAGE]);

    for(new i=0; i < 10; i++){
        TextDrawHideForPlayer(playerid, TDrawG[i][COMBO]);
    }

    for(new i = 0; i < USED_ZONE; i++){
      GangZoneHideForPlayer(playerid, ZONE[i][ID]);
    }
}

/* DB DATA
   @ user_data()        : Check user data connection
   @ house_data()       : House data
   @ vehicle_data()     : Vehicle data
   @ clan_data()        : Vehicle data
   @ zone_data()        : Gangzone data
   @ weapon_data()      : Check weapon data connection
   @ duel_data()        : Check Dual Data Connections    [ Returns the current number of games @ DUEL[LENGTH]
*/
stock user_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_USER);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("USER DB: Connection");
    else{
      print("User DB Error! Create Table Reload");
      mysql_format(mysql, query, sizeof(query), SQL_USER_TABLE_1);
      mysql_query(mysql, query);
      mysql_format(mysql, query, sizeof(query), SQL_USER_TABLE_2);
      mysql_query(mysql, query);
      mysql_format(mysql, query, sizeof(query), SQL_USER_TABLE_3);
      mysql_query(mysql, query);
      user_data();
    }
}
stock house_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_HOUSE);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("House DB: Connection");
    else{
        print("House DB Error! Create Table Reload");
        mysql_format(mysql, query, sizeof(query), SQL_HOUSE_TABLE);
        mysql_query(mysql, query);
        house_data();
        return 0;
    }

    new rows, fields;
    cache_get_data(rows, fields);

    for(new i=0; i < rows; i++){
        HOUSE[i][ID]            = cache_get_field_content_int(i, "ID");
        HOUSE[i][OPEN]          = cache_get_field_content_int(i, "OPEM");
        HOUSE[i][OWNER_ID]      = cache_get_field_content_int(i, "OWNER_ID");
        HOUSE[i][ENTER_POS_X]   = cache_get_field_content_float(i, "ENTER_POS_X");
        HOUSE[i][ENTER_POS_Y]   = cache_get_field_content_float(i, "ENTER_POS_Y");
        HOUSE[i][ENTER_POS_Z]   = cache_get_field_content_float(i, "ENTER_POS_Z");
        HOUSE[i][LEAVE_POS_X]   = cache_get_field_content_float(i, "LEAVE_POS_X");
        HOUSE[i][LEAVE_POS_Y]   = cache_get_field_content_float(i, "LEAVE_POS_Y");
        HOUSE[i][LEAVE_POS_Z]   = cache_get_field_content_float(i, "LEAVE_POS_Z");
    }
    return 0;
}
stock vehicle_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_VEHICLE);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("Vehicle DB: Connection");
    else{
        print("Vehicle DB Error! Create Table Reload");
        mysql_format(mysql, query, sizeof(query), SQL_VEHICLE_TABLE);
        mysql_query(mysql, query);
        vehicleInit();
        vehicle_data();
        return 0;
    }
    new rows, fields;
    cache_get_data(rows, fields);

    for(new i=0; i < rows; i++){
        VEHICLE[i+1][ID]           = cache_get_field_content_int(i, "ID");
        VEHICLE[i+1][OWNER_ID]     = cache_get_field_content_int(i, "OWNER_ID");
        cache_get_field_content(i, "OWNER_NAME", VEHICLE[i+1][OWNER_NAME], mysql, 24);
        VEHICLE[i+1][POS_X]        = cache_get_field_content_float(i, "POS_X");
        VEHICLE[i+1][POS_Y]        = cache_get_field_content_float(i, "POS_Y");
        VEHICLE[i+1][POS_Z]        = cache_get_field_content_float(i, "POS_Z");
        VEHICLE[i+1][ANGLE]        = cache_get_field_content_float(i, "ANGLE");
        VEHICLE[i+1][COLOR1]       = cache_get_field_content_int(i, "COLOR1");
        VEHICLE[i+1][COLOR2]       = cache_get_field_content_int(i, "COLOR2");
    }
    return 0;
}

stock clan_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_CALN);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("Clan DB: Connection");
    else{
        print("Clan DB Error! Create Table Reload");
        mysql_format(mysql, query, sizeof(query), SQL_CLAN_TABLE);
        mysql_query(mysql, query);
        clan_data();
        return 0;
    }
    new rows, fields;
    cache_get_data(rows, fields);

    for(new i=0; i < rows; i++){
        CLAN[i][ID]             = cache_get_field_content_int(i, "ID");
        cache_get_field_content(i, "NAME", CLAN[i][NAME], mysql, 50);
        CLAN[i][LEADER_ID]      = cache_get_field_content_int(i, "LEADER_ID");
        cache_get_field_content(i, "LEADER_NAME", CLAN[i][LEADER_NAME], mysql, 24);
        CLAN[i][KILLS]          = cache_get_field_content_int(i, "KILLS");
        CLAN[i][DEATHS]         = cache_get_field_content_int(i, "DEATHS");
        CLAN[i][COLOR]          = cache_get_field_content_int(i, "COLOR");
        CLAN[i][ZONE_LENGTH]    = cache_get_field_content_int(i, "ZONE_LENGTH");
    }
    return 0;
}
stock zone_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_ZONE);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("Gangzone DB: Connection");
    else{
        print("Gangzone DB Error! Create Table Reload");
        mysql_format(mysql, query, sizeof(query), SQL_ZONE_TABLE);
        mysql_query(mysql, query);
        zone_data();
        zoneInit();
        return 0;
    }
    new rows, fields;
    cache_get_data(rows, fields);

    for(new i=0; i < rows; i++){
        ZONE[i][OWNER_CLAN] = cache_get_field_content_int(i, "OWNER_CLAN");
    }
    return 0;
}

stock weapon_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_WEAPON);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("Weapon DB: Connection");
    else{
      print("Weapon DB Error! Create Table Reload");
      mysql_format(mysql, query, sizeof(query), SQL_WEAPON_TABLE);
      mysql_query(mysql, query);
      weapon_data();
    }
}

stock duel_data(){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_DATA_LOAD_DUEL);
    mysql_query(mysql, query);
    if(!mysql_errno(mysql))print("Duel DB: Connection");
    else{
        print("Duel DB Error! Create Table Reload");
        mysql_format(mysql, query, sizeof(query), SQL_DUEL_TABLE);
        mysql_query(mysql, query);
        duel_data();
        return 0;
    }
    new rows, fields;
    cache_get_data(rows, fields);
    DUEL_CORE[INDEX] = rows;
    return 0;
}

/* SERVER THREAD*/
public ServerThread(){
    foreach (new i : Player){
        if(INGAME[i][LOGIN]){
            fps(i);
            event(i);
            checkZone(i);
            checkWarp(i);
            damage(i);
        }
    }
}

/* stock
   @ zoneInit()                          : Initialize all (init)
   @ zoneSave(id, owner_clan)            : Save up to date
   @ vehicleInit()                       : Vehicle initialization (init)
   @ vehicleSave(vehicleid)              : Vehicle storage
   @ vehicleSpawn(vehicleid)             : Vehicle responder
   @ zoneSetup()                         : Setting up the remainder (create modeling min xy, max xy)
   @ showZone(playerid)                  : Show up
   @ vehicleBuy(playerid, carid)         : Buying a vehicle
   @ showEnvi(playerid)                  : FPS, PING, Packet Loss Print     [ ServerThread - event (tick switch 5, 10 ,15) ]
   @ showRank(playerid)                  : User tier (rank) overhead output [ ServerThread - event (tick switch 20) ]
   @ showTextDraw(playerid)              : Text draw output
   @ fixPos(playerid)                    : Random spawn position random assignment
   @ event(playerid)                     : Thread handler                   [ ServerTherad - event - showEnvi - showRank ]
   @ checkWarp(playerid)                 : Vehicle warp detection check     [ ServerThread - checkWarp ]
   @ inCar(playerid, vehicleid)          : Specifying the vehicle's normal boarding certification
   @ warp(playerid)                      : Vehicle warp detection
   @ warpInit(playerid)                  : Toggle vehicle off (init )
   @ giveMoney(playerid,money)           : Money cycle
   @ death(playerid, killerid, reason)   : death
   @ killCombo(playerid)                 : Specify a kill combo
   @ deathPickup(killerid, playerid, Float:pickup_x, Float:pickup_y, Float:pickup_z)      : Death Pickup Generation [Armor, Heart value greater than 0]
   @ loadMisson()                        : Loading Mission Data [Clan, Store, Ranking, Dual, Slot Machine]
   @ missonInit(name[24],Float:pos_x,Float:pos_y,Float:pos_z)                             : Mission model initialization (init)
   @ object_init()                       : Object initialization (init)
   @ textLabel_init()                    : 3D Label Reset   (init)
   @ textDraw_init();                    : 2D texture initialization (init)
   @ searchMissonRange(playerid)         : Surrounding radius Mission event check
   @ searchGarageRange(playerid)         : Check the existence of the surrounding radius gas station event
   @ showMisson(playerid, type)          : Open Mission Event
   @ showGarage(playerid)                : Open the gas station event
   @ showDialog(playerid, type)          : Dialog Handler
   @ isPlayerZone(playerid, zoneid)      : Check whether there is a certain existence
   @ checkZone(playerid)                 : A rehearsal event              [ ServerThread - checkZone ]
   @ holdZone(playerid)                  : Acquisition of survival
   @ isHaveWeapon(playerid , weaponid)   : Check whether a specific weapon is purchased
   @ isEmptyWep(playerid, listitem)      : Check whether or not to buy a store weapon       [ shopWeapon (Dialog) ]
   @ isBuyWepMoney(weponid, money)       : Check specific weapons purchase conditions       [ shopWeapon ( money ) ]
   @ isHoldWep(playerid, model)          : Check with worn suit
   @ isClan(playerid, type)              : Check user clan related status        @ type : IS_CLEN_HAVE, IS_CLEN_NOT, IS_CLEN_LEADER, IS_CLEN_INSERT_MONEY
   @ isHangul(playerid, str[])           : Input Hangul check
   @ isMaxHaveCar(playerid)              : Limited number of cars checked
   @ randomColor()                       : Random hex value return
   @ packet(playerid)                    : User packet loss update
   @ fps(playerid)                       : User FPS update
   @ setAlpha(color, a)                  : Damage text draw alpha value specified      [TakeDamage Callback - damage - setalpha]
   @ damage(playerid)                    : Shooting hitting information
   @ getPlayerId(name[]                  : Return ID by user name
   @ wepID(model)                        : Returns an array of weapons as a weapon model name
   @ wepName(model)                      : Return weapon name to weapon model name (Korean for)
   @ wepNameTD(model)                    : Return weapon name to weapon model name (English for Text Draw)
   @ sync(playerid)                      : Disink
   @ kdRatio(kill, death)                : Returns the user fee rate
   @ kdTier(level, kill, death)          : Return user tier name
*/

stock vehicleInit(){
    printf("vehicle DB data init load");
    for(new vehicleid=1; vehicleid<USED_VEHICLE; vehicleid++){
        GetVehiclePos(vehicleid, VEHICLE[vehicleid][POS_X], VEHICLE[vehicleid][POS_Y], VEHICLE[vehicleid][POS_Z]);
        GetVehicleZAngle(vehicleid, VEHICLE[vehicleid][ANGLE]);
        new query[400];
        mysql_format(mysql, query, sizeof(query), SQL_VEHICLE_INIT_INSERT,
        VEHICLE[vehicleid][POS_X],
        VEHICLE[vehicleid][POS_Y],
        VEHICLE[vehicleid][POS_Z],
        VEHICLE[vehicleid][ANGLE]
        );
        mysql_query(mysql, query);
        printf("%d/%d",vehicleid,USED_VEHICLE);
    }
}
stock zoneInit(){
    new query[400];
    printf("gangzone DB data init load");
    for(new i = 0; i < USED_ZONE; i++){
        mysql_format(mysql, query, sizeof(query), SQL_ZONE_INIT_INSERT,-1);
        mysql_query(mysql, query);
        printf("%d/%d",i,USED_ZONE);
    }
}

stock zoneSave(id, owner_clan){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_ZONE_DATA_UPDATE,owner_clan, id);
    mysql_query(mysql, query);
}
stock vehicleSave(vehicleid){
    GetVehiclePos(vehicleid, VEHICLE[vehicleid][POS_X], VEHICLE[vehicleid][POS_Y], VEHICLE[vehicleid][POS_Z]);
    GetVehicleZAngle(vehicleid, VEHICLE[vehicleid][ANGLE]);

    if(VEHICLE[vehicleid][OWNER_ID] == 0)return 0;
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_VEHICLE_DATA_UPDATE,
    VEHICLE[vehicleid][POS_X],
    VEHICLE[vehicleid][POS_Y],
    VEHICLE[vehicleid][POS_Z],
    VEHICLE[vehicleid][ANGLE],
    vehicleid
    );
    mysql_query(mysql, query);
    return 0;
}
public vehicleSpawn(vehicleid){
    SetVehiclePos(vehicleid, VEHICLE[vehicleid][POS_X], VEHICLE[vehicleid][POS_Y], VEHICLE[vehicleid][POS_Z]);
    SetVehicleZAngle(vehicleid, VEHICLE[vehicleid][ANGLE]);
    ChangeVehicleColor(vehicleid, VEHICLE[vehicleid][COLOR1], VEHICLE[vehicleid][COLOR2]);
    SetVehicleHealth(vehicleid, 5000);
}
stock zoneSetup(){
    new pos[4] = { -3000, 2800, -2800, 3000 };
    new fix = 200, tick = 0;

    for(new i = 0; i < USED_ZONE; i++){
        tick++;
        if(tick == 31){
            tick = 1;
            pos[0] = -3000;
            pos[1] = pos[1] - fix;
            pos[2] = -2800;
            pos[3] = pos[3] - fix;
        }

        ZONE[i][ID] = GangZoneCreate(pos[0], pos[1], pos[2], pos[3]);
        ZONE[i][MIN_X] = pos[0];
        ZONE[i][MIN_Y] = pos[1];
        ZONE[i][MAX_X] = pos[2];
        ZONE[i][MAX_Y] = pos[3];
        pos[0] = fix + pos[0];
        pos[2] = fix + pos[2];
    }
    NODMZONE[MIN_X] = 1904.296875;
    NODMZONE[MIN_Y] = -1750;
    NODMZONE[MAX_X] = 1933.59375;
    NODMZONE[MAX_Y] = -1623.046875;
    NODMZONE[ID] = GangZoneCreate(NODMZONE[MIN_X],NODMZONE[MIN_Y],NODMZONE[MAX_X],NODMZONE[MAX_Y]);
}

stock showZone(playerid){
    new zoneCol[2] = { 0xFFFFFF99, 0xAFAFAF99};
    new flag = 0, flag2 = 0, tick = 0;

    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_ZONE_DATA_SELECT);
    mysql_query(mysql, query);

    for(new i = 0; i < USED_ZONE; i++){
        tick++;
        if(tick == 31){
            tick = 1;
            flag2 = !flag2;
        }
        flag = !flag;
        if(flag == 1){
            if(flag2 == 1)GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[0]);
            else GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[1]);
        }
        else if(!flag2)GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[0]);
        else GangZoneShowForPlayer(playerid, ZONE[i][ID], zoneCol[1]);
        if(ZONE[i][OWNER_CLAN] != -1){
            ZONE[i][OWNER_CLAN] = cache_get_field_content_int(i, "OWNER_CLAN");
            GangZoneShowForPlayer(playerid, ZONE[i][ID], CLAN[ZONE[i][OWNER_CLAN]-1][COLOR]);
        }
    }
    GangZoneShowForPlayer(playerid, NODMZONE[ID], 0xFFFFFFFF);
    return 0;
}

stock vehicleBuy(playerid, vehicleid){
    new query[400];
    new model = GetVehicleModel(vehicleid);

    format(VEHICLE[vehicleid][OWNER_NAME], 24, "%s",USER[playerid][NAME]);
    VEHICLE[vehicleid][OWNER_ID] = USER[playerid][ID];

    formatMsg(playerid, COL_SYS, CAR_BUY_SUCCESS, vehicleName[model - 400]);

    mysql_format(mysql, query, sizeof(query), SQL_VEHICLE_BUY_UPDATE,
    USER[playerid][ID],
    vehicleid);

    mysql_query(mysql, query);

    giveMoney(playerid, -30000);
}

stock showEnvi(playerid){
    new str[30];
    format(str,sizeof(str),"~r~~h~F~w~PS : %d",INGAME[playerid][FPS]);
    TextDrawSetString(TDraw[playerid][FPS],str);

    format(str,sizeof(str),"~r~~h~P~w~ING : %d",GetPlayerPing(playerid));
    TextDrawSetString(TDraw[playerid][PING],str);

    packet(playerid);
    format(str,sizeof(str),"~r~~h~P~w~ket loss: %.01f%",INGAME[playerid][PACKET]);
    TextDrawSetString(TDraw[playerid][PACKET],str);
}

stock showRank(playerid){
    new str[50];
    if(INGAME[playerid][DUEL_JOIN]) format(str, sizeof(str),"{CC0033}FPS : %d PING : %d",INGAME[playerid][FPS], GetPlayerPing(playerid));
    else if(INGAME[playerid][NODM] && USER[playerid][HP] > 90 && USER[playerid][AM] > 90) format(str, sizeof(str),"[LV.%d 비전투상태{7FFF00}]",USER[playerid][LEVEL]);
    else format(str, sizeof(str),"[LV.%d %s{7FFF00}]",USER[playerid][LEVEL], kdTier(USER[playerid][LEVEL], USER[playerid][KILLS],USER[playerid][DEATHS]));
    SetPlayerChatBubble(playerid, str, 0x7FFF00FF, 14.0, 10000);
    return 0;
}

stock showTextDraw(playerid){
    TextDrawShowForPlayer(playerid, TDrawG[0][ID]);
    TextDrawShowForPlayer(playerid, TDrawG[1][ID]);
    TextDrawShowForPlayer(playerid, TDrawG[2][ID]);

    TextDrawShowForPlayer(playerid, TDraw[playerid][ZONETEXT]);
    TextDrawShowForPlayer(playerid, TDraw[playerid][CP]);

    TextDrawShowForPlayer(playerid, TDraw[playerid][FPS]);
    TextDrawShowForPlayer(playerid, TDraw[playerid][PING]);
    TextDrawShowForPlayer(playerid, TDraw[playerid][PACKET]);
}
stock isPlayerZone(playerid, zoneid){
    new	Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(x > ZONE[zoneid][MIN_X] && x < ZONE[zoneid][MAX_X] && y > ZONE[zoneid][MIN_Y] && y < ZONE[zoneid][MAX_Y])return 1;

    return 0;
}
/* ZONE LIFE CYCLE

   @ checkZone(playerid)
       @ enterZone(playerid)
           @ notDmZone(playerid)
           @ ownerZone(playerid)
           @ stayClanCheck(playerid)
           @ tickZone(playerid)

       @ exitZone(playerid)
       @ joinZone(playerid, z)
*/
stock checkZone(playerid){

    for(new i = 0; i < USED_ZONE; i++){
        if(isPlayerZone(playerid, i)){
            if(isNotDmZone(playerid))notDmZone(playerid);
            else if(INGAME[playerid][NODM]){
                threadZone(playerid, i);
                INGAME[playerid][NODM] =false;
                return 0;
            }
            if(!INGAME[playerid][NODM]){
                if(INGAME[playerid][ENTER_ZONE] == i)return enterZone(playerid);
                leaveZone(playerid);
                threadZone(playerid, i);
            }
        }
    }
    return 0;
}
stock threadZone(playerid, zoneid){
    INGAME[playerid][ENTER_ZONE] = zoneid;

    if(!isNotClanUser(playerid))CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX]+=1;
    ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN]+=1;
    INGAME[playerid][ZONE_TICK] = 0;
}
stock isNotDmZone(playerid){
    new	Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(x > NODMZONE[MIN_X] && x < NODMZONE[MAX_X] && y > NODMZONE[MIN_Y] && y < NODMZONE[MAX_Y]){
        if(!INGAME[playerid][NODM]){
            leaveZone(playerid);
            INGAME[playerid][NODM] =true;
        }
        return 1;
    }
    return 0;
}
stock notDmZone(playerid){
    TextDrawSetString(TDraw[playerid][CP], "~g~~h~NOT DEATH MATCH ZONE");
    return 0;
}

stock enterZone(playerid){
    if(isNotClanUser(playerid)) return notClanUser(playerid);
    if(isBattleZone(playerid)) return battleZone(playerid);
    if(isHavedZone(playerid)) return havedZone(playerid);

    tickZone(playerid);
    return 0;
}
stock leaveZone(playerid){
    ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN] -=1;

    if(!isNotClanUser(playerid)){
        CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX]-=1;

        if(isNotStayClan(playerid)){
            CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] = 0;
            GangZoneStopFlashForAll(ZONE[INGAME[playerid][ENTER_ZONE]][ID]);
        }
    }
    return 0;
}
stock isNotStayClan(playerid){
    if(CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX] == 0) return 1;
    return 0;
}

stock isNotClanUser(playerid){
    if(USER[playerid][CLANID] == 0)return 1;
    return 0;
}
stock notClanUser(playerid){
    new str[120];
    format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN]);
    TextDrawSetString(TDraw[playerid][CP],str);
    return 0;
}
stock isBattleZone(playerid){
    ZONE[INGAME[playerid][ENTER_ZONE]][STAY_CLAN] = 0;

    for(new i=0; i < USED_CLAN; i++){
        if(CLAN_CP[INGAME[playerid][ENTER_ZONE]][i][INDEX]){
            ZONE[INGAME[playerid][ENTER_ZONE]][STAY_CLAN] +=1;
        }
    }
    if(ZONE[INGAME[playerid][ENTER_ZONE]][STAY_CLAN] > 1)return 1;
    return 0;
}
stock battleZone(playerid){
    new str[120];
    format(str,sizeof(str),"~r~~h~%d ZONE IN - ~w~BATTLE ~r~~h~IN CLAN LENGTH : ~w~%d",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_CLAN]);
    TextDrawSetString(TDraw[playerid][CP],str);
    return 0;
}
stock isHavedZone(playerid){
    if(ZONE[INGAME[playerid][ENTER_ZONE]][OWNER_CLAN] == USER[playerid][CLANID])return 1;
    return 0;
}
stock havedZone(playerid){
    new str[120];
    format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d ~r~~h~- CP : ~w~CLAN HAVED",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN]);
    TextDrawSetString(TDraw[playerid][CP],str);
    return 0;
}

stock tickZone(playerid){

    INGAME[playerid][ZONE_TICK] +=1;

    if(INGAME[playerid][ZONE_TICK] == 2){
        INGAME[playerid][ZONE_TICK] = 0;
        CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] +=1;
        if(CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] > 80)PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);

        switch(CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP]){
            case 80:{
                formatMsgAll(COL_SYS, ZONE_CLAN_HOLD_TEXT ,INGAME[playerid][ENTER_ZONE], GetPlayerColor(playerid) >>> 8, CLAN[USER[playerid][CLANID]-1][NAME]);
                GangZoneFlashForAll(ZONE[INGAME[playerid][ENTER_ZONE]][ID], GetPlayerColor(playerid));
            }
            case 100:holdZone(playerid);
        }
    }

    new str[120];
    format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d ~r~~h~- CP : ~w~%d%",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN], CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP]);
    TextDrawSetString(TDraw[playerid][CP],str);
}
stock holdZone(playerid){
    new zoneid = INGAME[playerid][ENTER_ZONE];
    new zoneOwner;
    new query[400];


    formatMsgAll(COL_SYS, ZONE_CLAN_HAVED_TEXT ,GetPlayerColor(playerid) >>> 8, CLAN[USER[playerid][CLANID]-1][NAME], zoneid, USER[playerid][NAME]);
    for(new i=0; i<GetMaxPlayers(); i++){
        if(zoneid == INGAME[i][ENTER_ZONE] && USER[playerid][CLANID] == USER[i][CLANID]){
            giveMoney(i, 2000);
            giveExp(i, 2);
        }
    }
    CLAN_CP[zoneid][USER[playerid][CLANID]][CP] = 0;
    GangZoneStopFlashForAll(ZONE[zoneid][ID]);

    if(ZONE[zoneid][OWNER_CLAN] == -1)zoneOwner = ZONE[zoneid][OWNER_CLAN]+1;
    else zoneOwner = ZONE[zoneid][OWNER_CLAN]-1;

    if(ZONE[zoneid][OWNER_CLAN] != -1){
        CLAN[zoneOwner][ZONE_LENGTH] -=1;
        mysql_format(mysql, query, sizeof(query), SQL_CLAN_ZONE_LENGTH, CLAN[zoneOwner][ZONE_LENGTH], zoneOwner);
        mysql_query(mysql, query);
    }

    CLAN[USER[playerid][CLANID]-1][ZONE_LENGTH] +=1;
    mysql_format(mysql, query, sizeof(query), SQL_CLAN_ZONE_LENGTH, CLAN[USER[playerid][CLANID]-1][ZONE_LENGTH], USER[playerid][CLANID]);
    mysql_query(mysql, query);

    ZONE[zoneid][OWNER_CLAN] = USER[playerid][CLANID];
    GangZoneShowForAll(ZONE[zoneid][ID], CLAN[USER[playerid][CLANID]-1][COLOR]);

    zoneSave(zoneid, ZONE[zoneid][OWNER_CLAN]);
    return 0;
}

stock fixPos(playerid){
    new ran = random(sizeof(SPAWN_MODEL));
    INGAME[playerid][SPAWN_POS_X] = SPAWN_MODEL[ran][0];
    INGAME[playerid][SPAWN_POS_Y] = SPAWN_MODEL[ran][1];
    INGAME[playerid][SPAWN_POS_Z] = SPAWN_MODEL[ran][2];
    INGAME[playerid][SPAWN_ANGLE] = 89.3591;
}

stock event(playerid){
    INGAME[playerid][EVENT_TICK] +=1;

    switch(INGAME[playerid][EVENT_TICK]){
        case 5,10,15:showEnvi(playerid);
        case 20:{
            showRank(playerid);
            INGAME[playerid][EVENT_TICK] = 0;
        }
    }
}
stock checkWarp(playerid){
    if(!WARP[playerid][INCAR]) return 0;
    new vehicleid = GetPlayerVehicleID(playerid);
    if(WARP[playerid][CARID] != vehicleid && vehicleid != 0)printf("워프핵 : %s",USER[playerid][NAME]),Kick(playerid);
    return 0;
}
stock inCar(playerid, vehicleid){
   WARP[playerid][CARID]=vehicleid;
   WARP[playerid][CHECK]=true;
}
stock warp(playerid){
   WARP[playerid][INCAR]=true;
   if(!WARP[playerid][CHECK])checkWarp(playerid);
   SetPlayerArmedWeapon(playerid, 0);
}
stock warpInit(playerid){
   new temp[WARP_MODEL];
   WARP[playerid] = temp;
}

stock giveMoney(playerid,money){
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, USER[playerid][MONEY]+=money);
    formatMsg(playerid, COL_SYS,GIVE_CASH,money);
}

stock giveExp(playerid,exp){
    USER[playerid][EXP]+=exp;
    formatMsg(playerid, COL_SYS,GIVE_EXP,exp);
    if(USER[playerid][EXP] >= 50){
        USER[playerid][LEVEL] +=1;
        USER[playerid][EXP] = USER[playerid][EXP]-50;
        new str[50];
        format(str,sizeof(str), "~y~Level UP!~w~%d!",USER[playerid][LEVEL]);
        GameTextForPlayer(playerid, str,3000,1);
        save(playerid);
    }
}

stock death(playerid, killerid, reason){

    new Float:death_pos[3];
    GetPlayerPos(playerid, death_pos[0], death_pos[1], death_pos[2]);
    CreateExplosion(death_pos[0], death_pos[1], death_pos[2], 16, 32.0);
    CreateExplosion(death_pos[0], death_pos[1], death_pos[2]+10, 0, 0.1);

    fixPos(playerid);
    USER[playerid][POS_X]   = INGAME[playerid][SPAWN_POS_X];
    USER[playerid][POS_Y]   = INGAME[playerid][SPAWN_POS_Y];
    USER[playerid][POS_Z]   = INGAME[playerid][SPAWN_POS_Y];
    USER[playerid][ANGLE]   = INGAME[playerid][SPAWN_ANGLE];
    USER[playerid][DEATHS] += 1;

    for(new i=0; i < INGAME[playerid][COMBO]; i++){
        TextDrawHideForPlayer(playerid, TDrawG[i][COMBO]);
    }
    INGAME[playerid][COMBO] = 0;
    INGAME[playerid][SPAWN] = false;

    spawn(playerid);
    if(reason == 255 || reason == 47 || reason == 49 || reason == 50 || reason == 51 || reason == 54 || reason == 53 || reason == 54 ) return 1;

    SendDeathMessage(killerid, playerid, reason);
    deathPickup(killerid, playerid, death_pos[0],death_pos[1],death_pos[2]);

    new str[128];
    format(str, sizeof(str), "~y~You got killed by ~r~%s", USER[killerid][NAME]);
    GameTextForPlayer( playerid, str, 3000, 1 );

    if(!INGAME[playerid][DUEL_JOIN]){
        USER[killerid][KILLS] += 1;
        giveMoney(killerid, 1000);
        giveExp(killerid, 1);
    }

    if(INGAME[killerid][COMBO] < 10){
        TextDrawShowForPlayer(killerid, TDrawG[INGAME[killerid][COMBO]][COMBO]);
    }
    killCombo(killerid);
    INGAME[killerid][COMBO]+=1;

    save(killerid);
    return 1;
}

stock killCombo(playerid){
    new str[50];
    format(str, sizeof(str), "~r~~>~~y~%s~r~~<~",comboText[INGAME[playerid][COMBO]]);
    GameTextForPlayer(playerid, str, 2500, 6);
    switch(INGAME[playerid][COMBO]){
        case 2 : giveExp(playerid, 1);
        case 3 : giveExp(playerid, 2);
        case 5 : giveExp(playerid, 3);
        case 7 : giveExp(playerid, 4);
        case 8 : giveExp(playerid, 5);
        case 10: giveExp(playerid, 6);
    }
}

stock deathPickup(killerid, playerid, Float:pickup_x, Float:pickup_y, Float:pickup_z){

    DestroyPickup(INGAME[playerid][DEATH_PICKUP_HP]);
    DestroyPickup(INGAME[playerid][DEATH_PICKUP_AM]);

    if(!INGAME[playerid][DUEL_JOIN]){
        GetPlayerHealth(killerid, USER[killerid][HP]);
        GetPlayerArmour(killerid, USER[killerid][AM]);
        if(USER[killerid][HP] >= 1.00)INGAME[playerid][DEATH_PICKUP_HP] = CreatePickup(1240,8, pickup_x, pickup_y, pickup_z, 0);
        if(USER[killerid][AM] >= 1.00)INGAME[playerid][DEATH_PICKUP_AM] = CreatePickup(1242,8, pickup_x, pickup_y+1.0, pickup_z, 0);
    }
    return 0;
}
stock loadGarage(){
    garageInit(GARAGE1_TEXT,1936.2174,-1774.7317,13.0537);
    garageInit(GARAGE2_TEXT,1941.7302,-1772.3066,19.5250);
    garageInit(GARAGE3_TEXT,2454.6113,-1461.0303,23.7785);
    garageInit(GARAGE4_TEXT,1002.5181,-941.1222,41.8907);
    garageInit(GARAGE5_TEXT,-91.1692,-1169.8002,2.1782);
}
stock loadMisson(){
    missonInit(MISSON1_TEXT,1910.2273,-1714.3197,13.3307);
    missonInit(MISSON2_TEXT,1909.9907,-1707.3611,13.3251);
    missonInit(MISSON3_TEXT,1909.9747,-1700.0070,13.3236);
    missonInit(MISSON4_TEXT,1926.5613,-1702.1071,13.5469);
    missonInit(MISSON5_TEXT,1910.2163,-1728.9521,13.3305);
}
stock missonInit(name[],Float:pos_x,Float:pos_y,Float:pos_z){
    new num = missonTick++;
    format(MISSON[num][NAME], 50,"%s",name);
    MISSON[num][POS_X]=pos_x;
    MISSON[num][POS_Y]=pos_y;
    MISSON[num][POS_Z]=pos_z;
}

stock garageInit(name[],Float:pos_x,Float:pos_y,Float:pos_z){
    new num = garageTick++;
    format(GARAGE[num][NAME], 50,"%s",name);
    GARAGE[num][POS_X]=pos_x;
    GARAGE[num][POS_Y]=pos_y;
    GARAGE[num][POS_Z]=pos_z;
}

stock object_init(){
    #include "module/objects.pwn"
}

stock textLabel_init(){

    for(new i = 0;i<USED_GARAGE;i++){
        new str[60];
        format(str, sizeof(str),GARAGE_TEXT_LABEL,GARAGE[i][NAME]);
        Create3DTextLabel(str, 0x8D8DFFFF, GARAGE[i][POS_X], GARAGE[i][POS_Y], GARAGE[i][POS_Z], 25.0, 0, 1);
    }

    for(new i = 0;i<USED_MISSON;i++){
        new str[40];
        format(str, sizeof(str),MISSON_TEXT_LABEL,MISSON[i][NAME]);
        Create3DTextLabel(str, 0x8D8DFFFF, MISSON[i][POS_X], MISSON[i][POS_Y], MISSON[i][POS_Z], 7.0, 0, 1);
    }
}

stock textDraw_init(){
    TDrawG[0][ID] = TextDrawCreate(20.000000,424.000000,"SA:MP KOREA ~b~~h~WAR~w~ Server");
    TextDrawAlignment(TDrawG[0][ID],0);
    TextDrawBackgroundColor(TDrawG[0][ID],0x000000ff);
    TextDrawFont(TDrawG[0][ID],2);
    TextDrawLetterSize(TDrawG[0][ID],0.199999,0.899999);
    TextDrawColor(TDrawG[0][ID],0xffffffff);
    TextDrawSetOutline(TDrawG[0][ID],1);
    TextDrawSetProportional(TDrawG[0][ID],1);
    TextDrawSetShadow(TDrawG[0][ID],1);

    TDrawG[1][ID] = TextDrawCreate(-0.500, 436.000, "_______________________");
    TextDrawUseBox(TDrawG[1][ID], 1);
    TextDrawBoxColor(TDrawG[1][ID], 0x00000099);
    TextDrawTextSize(TDrawG[1][ID], 641.500, 13.000);

    TDrawG[2][ID] = TextDrawCreate(520,437.000,"~b~~h~S~w~HOT:");
    TextDrawLetterSize(TDrawG[2][ID], 0.219999,1.099999);
    TextDrawFont(TDrawG[2][ID], 1);
    TextDrawSetShadow(TDrawG[2][ID], 0);

    for(new i = 0; i <= GetMaxPlayers(); i++){
        TDraw[i][ZONETEXT] = TextDrawCreate(1,437.000,"SOUTH KOREA SAMP GANG WAR SERVER");
        TextDrawLetterSize(TDraw[i][ZONETEXT], 0.219999,1.099999);
        TextDrawFont(TDraw[i][ZONETEXT], 1);
        TextDrawSetShadow(TDraw[i][ZONETEXT], 0);

        TDraw[i][CP] = TextDrawCreate(302.500, 2.500,"~r~~h~NEAR ZONE IN ~w~HUMAN 6 ~r~~h~- CP : ~w~00%");
        TextDrawLetterSize(TDraw[i][CP], 0.219999,1.099999);
        TextDrawFont(TDraw[i][CP], 1);
        TextDrawSetShadow(TDraw[i][CP], 0);
        TextDrawUseBox(TDraw[i][CP], 1);
        TextDrawBoxColor(TDraw[i][CP], 0x00000099);
        TextDrawTextSize(TDraw[i][CP], 641.500, 13.000);

        TDraw[i][FPS] = TextDrawCreate(499, 2,"~r~~h~F~w~PS : 000");
        TextDrawLetterSize(TDraw[i][FPS], 0.219999,1.099999);
        TextDrawFont(TDraw[i][FPS], 1);
        TextDrawSetShadow(TDraw[i][FPS], 0);

        TDraw[i][PING] = TextDrawCreate(536, 2,"~r~~h~P~w~ING : 000");
        TextDrawLetterSize(TDraw[i][PING], 0.219999,1.099999);
        TextDrawFont(TDraw[i][PING], 1);
        TextDrawSetShadow(TDraw[i][PING], 0);

        TDraw[i][PACKET] = TextDrawCreate(577, 2,"~r~~h~P~w~ket loss: 0.0%");
        TextDrawLetterSize(TDraw[i][PACKET], 0.219999,1.099999);
        TextDrawFont(TDraw[i][PACKET], 1);
        TextDrawSetShadow(TDraw[i][PACKET], 0);

        TDraw[i][TAKE_DAMAGE] = TextDrawCreate(440.0, 370.0, "HI0000000000~n~-23 (Deagle Eagle)");
        TextDrawLetterSize(TDraw[i][TAKE_DAMAGE], 0.219999,1.099999);
        TextDrawFont(TDraw[i][TAKE_DAMAGE], 1);
        TextDrawSetShadow(TDraw[i][TAKE_DAMAGE], 0);
        TextDrawColor(TDraw[i][TAKE_DAMAGE], 0x8D8DFFFF);

        TDraw[i][GIVE_DAMAGE] = TextDrawCreate(200.0, 370.0, "HI0000000000~n~-23 (Deagle Eagle)");
        TextDrawLetterSize(TDraw[i][GIVE_DAMAGE], 0.219999,1.099999);
        TextDrawFont(TDraw[i][GIVE_DAMAGE], 1);
        TextDrawSetShadow(TDraw[i][GIVE_DAMAGE], 0);
        TextDrawColor(TDraw[i][GIVE_DAMAGE], 0xB00000FF);

    }

    new comboWidth = 542;
    for(new i = 0; i < 10; i++){
        TDrawG[i][COMBO] = TextDrawCreate(comboWidth+(i*10), 437.500, "ld_shtr:ex3");
        TextDrawFont(TDrawG[i][COMBO], 4);
        TextDrawTextSize(TDrawG[i][COMBO], 10, 8.5);
        TextDrawColor(TDrawG[i][COMBO], -1);
    }

}

stock searchMissonRange(playerid){
    new Float:x,Float:y,Float:z;

    for(new i=0; i < USED_MISSON; i++){
        x=MISSON[i][POS_X];
        y=MISSON[i][POS_Y];
        z=MISSON[i][POS_Z];
        if(IsPlayerInRangeOfPoint(playerid,3.0,x,y,z)) showMisson(playerid, i);
    }
}
stock searchGarageRange(playerid){
    new Float:x,Float:y,Float:z;

    for(new i=0; i < USED_GARAGE; i++){
        x=GARAGE[i][POS_X];
        y=GARAGE[i][POS_Y];
        z=GARAGE[i][POS_Z];
        if(IsPlayerInRangeOfPoint(playerid,10.0,x,y,z)) showGarage(playerid);
    }
}
stock showMisson(playerid, type){
    switch(type){
        case 0: ShowPlayerDialog(playerid, DL_MISSON_CLAN, DIALOG_STYLE_LIST,DIALOG_TITLE, MISSON_CLAN_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
        case 1: ShowPlayerDialog(playerid, DL_MISSON_SHOP, DIALOG_STYLE_LIST,DIALOG_TITLE, MISSON_SHOP_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
        case 2: ShowPlayerDialog(playerid, DL_MISSON_NOTICE, DIALOG_STYLE_LIST,DIALOG_TITLE, MISSON_NOTICE_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
        case 3: ShowPlayerDialog(playerid, DL_MISSON_DUEL, DIALOG_STYLE_LIST,DIALOG_TITLE, MISSON_DUEL_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
        case 4: ShowPlayerDialog(playerid, DL_MISSON_GAMBLE, DIALOG_STYLE_INPUT,DIALOG_TITLE, MISSON_GAMBLE_TEXT, DIALOG_ENTER, DIALOG_CLOSE);
    }
    ClearAnimations(playerid);
    return 1;
}

stock showGarage(playerid){
    showDialog(playerid, DL_GARAGE);

}

stock showDialog(playerid, type){
    switch(type){
        case DL_LOGIN : ShowPlayerDialog(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, LOGIN_DL_TEXT, DIALOG_ENTER, DIALOG_EXIT);
        case DL_REGIST : ShowPlayerDialog(playerid, DL_REGIST, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, REGIST_DL_TEXT, DIALOG_ENTER, DIALOG_EXIT);

        case DL_INFO  : ShowPlayerDialog(playerid, DL_INFO, DIALOG_STYLE_LIST, DIALOG_TITLE, INFO_DL_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_MYWEP :{
            new str[256];
            strcat(str, "{FFFFFF}");
            if(INGAME[playerid][WEPBAG_INDEX] == 0)formatMsg(playerid, COL_SYS, YOU_WEAPON_NOT_HAVE);
            for(new i=0; i < INGAME[playerid][WEPBAG_INDEX]; i++){
                new temp[20];
                format(temp, sizeof(temp), "%s\n", wepName(WEPBAG[playerid][i][MODEL]));
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_MYWEP, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_MYCAR :{
            new query[400], str[600];

            mysql_format(mysql, query, sizeof(query), SQL_MYCAR_SELECT, USER[playerid][ID]);
            mysql_query(mysql, query);

            new rows, fields;
            cache_get_data(rows, fields);
            strcat(str, "{FFFFFF}");
            if(rows == 0)formatMsg(playerid, COL_SYS, YOU_CAR_NOT_HAVE);

            for(new i=0; i < rows; i++){
                new temp[60];

                new vehicleid = cache_get_field_content_int(i, "ID");
                CARBAG[playerid][i][ID] = vehicleid;

                new model = GetVehicleModel(vehicleid);

                format(temp, sizeof(temp), MYCAR_DL_TEXT, vehicleid, vehicleName[model - 400]);
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_MYCAR, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_GARAGE :ShowPlayerDialog(playerid, DL_GARAGE, DIALOG_STYLE_LIST, DIALOG_TITLE, GARAGE_DL_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_LIST :{
            new query[400], str[1286];

            mysql_format(mysql, query, sizeof(query), SQL_CLAN_LIST);
            mysql_query(mysql, query);

            new rows, fields;
            cache_get_data(rows, fields);
            strcat(str, CLAN_LIST_DL_TITLE);

            for(new i=0; i < rows; i++){
                new temp[128], name[24];

                cache_get_field_content(i, "NAME", name, mysql, 24);

                format(temp, sizeof(temp), CLAN_LIST_DL_CONTENT, CLAN[i][COLOR] >>> 8, name);
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_CLAN_LIST, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_RANK :{
            new query[400], str[1286];

            mysql_format(mysql, query, sizeof(query), SQL_CLAN_RANK);
            mysql_query(mysql, query);

            new rows, fields;
            cache_get_data(rows, fields);
            strcat(str, CLAN_RANK_DL_TITLE);

            for(new i=0; i < rows; i++){
                new temp[128], name[24];

                cache_get_field_content(i, "NAME", name, mysql, 24);

                format(temp, sizeof(temp), CLAN_RANK_DL_CONTENT, i+1, cache_get_field_content_int(i, "ZONE_LENGTH"), CLAN[i][COLOR] >>> 8, name);
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_CLAN_RANK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_SETUP :{
            if(isClan(playerid, IS_CLEN_NOT)) return 0;

            ShowPlayerDialog(playerid, DL_CLAN_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, CLAN_SETUP_DL_TEXT, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_LEAVE :{
            if(isClan(playerid, IS_CLEN_NOT)) return 0;
            ShowPlayerDialog(playerid, DL_CLAN_LEAVE, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, CLAN_LEAVE_DL_TEXT, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_INSERT :{
            if(isClan(playerid, IS_CLEN_HAVE)) return 0;

            ShowPlayerDialog(playerid, DL_CLAN_INSERT, DIALOG_STYLE_INPUT, DIALOG_TITLE, CLAN_INSERT_DL_NAME, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_INSERT_COLOR : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR, DIALOG_STYLE_LIST, DIALOG_TITLE, CLAN_INSERT_DL_COLOR, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT_COLOR_RANDOM :{
            new str[256];
            format(str, sizeof(str),CLAN_RANDOM_COLOR_TEXT, CLAN_SETUP[playerid][COLOR] >>> 8, CLAN_SETUP[playerid][NAME]);
            ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR_RANDOM, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_PREV, DIALOG_ENTER);
        }
//        case DL_CLAN_INSERT_COLOR_CHOICE : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR_CHOICE, DIALOG_STYLE_INPUT, DIALOG_TITLE, CLAN_CHOICE_COLOR_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT_SUCCESS :{
            new str[256];
            format(str, sizeof(str),CLAN_INSERT_DL_SUCCESS, CLAN_SETUP[playerid][NAME],CLAN_SETUP[playerid][COLOR] >>> 8, CLAN_SETUP[playerid][COLOR] >>> 8);
            ShowPlayerDialog(playerid, DL_CLAN_INSERT_SUCCESS, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }

        case DL_CLAN_SETUP_INVITE :{
            if(isClan(playerid, IS_CLEN_LEADER)) return SendClientMessage(playerid, COL_SYS, CLAN_ONLY_LEADER);
            ShowPlayerDialog(playerid, DL_CLAN_SETUP_INVITE, DIALOG_STYLE_INPUT, DIALOG_TITLE, CLAN_INVITE_TEXT, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_SETUP_SKIN : ShowPlayerDialog(playerid, DL_CLAN_SETUP_SKIN, DIALOG_STYLE_LIST, DIALOG_TITLE, CLAN_MEMBER_DL_SKIN, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_SKIN_SETUP   : ShowPlayerDialog(playerid, DL_CLAN_SETUP_SKIN_SETUP, DIALOG_STYLE_INPUT, DIALOG_TITLE, CLAN_MEMBER_SKIN_SETUP, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_SKIN_UPDATE : ShowPlayerDialog(playerid, DL_CLAN_SETUP_SKIN_UPDATE, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, CLAN_MEMBER_SKIN_UPDATE, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER :{
            new query[400], str[256];

            mysql_format(mysql, query, sizeof(query), SQL_CLAN_MEMBER_LIST,USER[playerid][CLANID]);
            mysql_query(mysql, query);

            new rows, fields;
            cache_get_data(rows, fields);
            strcat(str, "{FFFFFF}");

            for(new i=0; i < rows; i++){
                new temp[128], name[24];

                cache_get_field_content(i, "NAME", name, mysql, 24);

                format(temp, sizeof(temp), CLAN_MEMBER_CONTENT,
                    name,
                    cache_get_field_content_int(i, "LEVEL"),
                    cache_get_field_content_int(i, "KILLS"),
                    cache_get_field_content_int(i, "DEATHS"),
                    kdRatio(cache_get_field_content_int(i, "KILLS"), cache_get_field_content_int(i, "DEATHS")),
                    kdTier(cache_get_field_content_int(i, "LEVEL"),cache_get_field_content_int(i, "KILLS"),  cache_get_field_content_int(i, "DEATHS")));
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_SETUP_MEMBER_SETUP :{
            if(isClan(playerid, IS_CLEN_LEADER)) return SendClientMessage(playerid, COL_SYS, CLAN_ONLY_LEADER);
            ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, CLAN_MEMBER_SETUP, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_SETUP_MEMBER_SETUP_RANK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK, DIALOG_STYLE_LIST, DIALOG_TITLE, CLAN_MEMBER_SETUP_RANK, DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP_KICK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, CLAN_MEMBER_SETUP_KICK, DIALOG_ENTER, DIALOG_PREV);
        case DL_SHOP_WEAPON :{
            new str[256];
            strcat(str, "{FFFFFF}");

            for(new i=0; i < sizeof(wepModel); i++){
                new temp[20];
                format(temp, sizeof(temp), "%s\n", wepModel[i]);
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_SHOP_WEAPON, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_SHOP_SKIN : ShowPlayerDialog(playerid, DL_SHOP_SKIN, DIALOG_STYLE_INPUT, DIALOG_TITLE, SHOP_DL_SKIN_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_SHOP_ACC : ShowPlayerDialog(playerid, DL_SHOP_ACC, DIALOG_STYLE_LIST, DIALOG_TITLE, SHOP_DL_ACC_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_SHOP_NAME : ShowPlayerDialog(playerid, DL_SHOP_NAME, DIALOG_STYLE_INPUT, DIALOG_TITLE, SHOP_DL_NAME_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_SHOP_WEAPON_BUY : {
            new str[256];
            format(str, sizeof(str),SHOP_DL_WEAPON_BUY_TEXT, wepName(INGAME[playerid][BUY_WEAPONID]), wepPrice(INGAME[playerid][BUY_WEAPONID]));
            ShowPlayerDialog(playerid, DL_SHOP_WEAPON_BUY, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_SHOP_SKIN_BUY : {
            new str[256];
            format(str, sizeof(str),SHOP_DL_SKIN_BUY_TEXT, INGAME[playerid][BUY_SKINID]);
            ShowPlayerDialog(playerid, DL_SHOP_SKIN_BUY, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_SHOP_NAME_EDIT : {
            new str[256];
            format(str, sizeof(str),SHOP_DL_NAME_EDIT_TEXT, INGAME[playerid][EDIT_NAME]);
            ShowPlayerDialog(playerid, DL_SHOP_NAME_EDIT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_NOTICE_SEASON :{
            new query[400], sql[400], str[1286];

            switch(INGAME[playerid][SEASON]){
                case 0:{
                    strcat(sql, SQL_USER_LEVEL_RANK);
                    strcat(str, SEASON_DL_LEVEL_TITLE);
                }
                case 1:{
                    strcat(sql, SQL_USER_KILL_RANK);
                    strcat(str, SEASON_DL_KILL_TITLE);
                }
            }
            INGAME[playerid][SEASON] +=1;
            mysql_format(mysql, query, sizeof(query), sql);
            mysql_query(mysql, query);

            new rows, fields;
            cache_get_data(rows, fields);

            for(new i=0; i < rows; i++){
                new temp[128], name[24];

                cache_get_field_content(i, "NAME", name, mysql, 24);

                format(temp, sizeof(temp), SEASON_DL_CONTENT_TEXT,
                    cache_get_field_content_int(i, "LEVEL"),
                    cache_get_field_content_int(i, "KILLS"),
                    cache_get_field_content_int(i, "DEATHS"),
                    kdRatio(cache_get_field_content_int(i, "KILLS"), cache_get_field_content_int(i, "DEATHS")),
                    kdTier(cache_get_field_content_int(i, "LEVEL"), cache_get_field_content_int(i, "KILLS"),  cache_get_field_content_int(i, "DEATHS")), i+1,name);
                strcat(str, temp);
            }

            ShowPlayerDialog(playerid, DL_NOTICE_SEASON, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_MYWEP_SETUP :{
            new str[256], temp[50];

            strcat(str, "{FFFFFF}");
            strcat(str, MYWEP_SETUP_SLOT_TITLE);
            if(!USER[playerid][WEP1]) format(temp, sizeof(temp), "1\t\t%s\n", MYWEP_SETUP_SLOT_NONE);
            else format(temp, sizeof(temp), "1\t\t(%s)\n", wepName(USER[playerid][WEP1]));
            strcat(str, temp);

            strcat(str, MYWEP_SETUP_SLOT_TITLE);
            if(!USER[playerid][WEP2]) format(temp, sizeof(temp), "2\t\t%s\n", MYWEP_SETUP_SLOT_NONE);
            else format(temp, sizeof(temp), "2\t\t(%s)\n", wepName(USER[playerid][WEP2]));
            strcat(str, temp);

            strcat(str, MYWEP_SETUP_SLOT_TITLE);
            if(!USER[playerid][WEP3]) format(temp, sizeof(temp), "3\t\t%s\n", MYWEP_SETUP_SLOT_NONE);
            else format(temp, sizeof(temp), "3\t\t(%s)\n", wepName(USER[playerid][WEP3]));
            strcat(str, temp);

            ShowPlayerDialog(playerid, DL_MYWEP_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_MYWEP_SETUP_OPTION : ShowPlayerDialog(playerid, DL_MYWEP_SETUP_OPTION, DIALOG_STYLE_LIST, DIALOG_TITLE, MYWEP_DL_OPTION_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_MYWEP_SETUP_HOLD   :{
            new str[256];
            format(str, sizeof(str),MYWEP_DL_HOLD_TEXT, INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));
            ShowPlayerDialog(playerid, DL_MYWEP_SETUP_HOLD, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_MYWEP_SETUP_PUT    :{
            new str[256];
            format(str, sizeof(str),MYWEP_DL_PUT_TEXT, INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));
            ShowPlayerDialog(playerid, DL_MYWEP_SETUP_PUT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_MYCAR_SETUP : ShowPlayerDialog(playerid, DL_MYCAR_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, MYCAR_SETUP_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_MYCAR_SETUP_SPAWN :{
            new str[256];
            new model = GetVehicleModel(INGAME[playerid][HOLD_CARID]);
            format(str, sizeof(str), MYCAR_DL_SPAWN_TEXT, vehicleName[model - 400]);
            ShowPlayerDialog(playerid, DL_MYCAR_SETUP_SPAWN, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_GARAGE_REPAIR     : ShowPlayerDialog(playerid, DL_GARAGE_REPAIR, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, GARAGE_DL_REPAIR_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_GARAGE_PAINT      : ShowPlayerDialog(playerid, DL_GARAGE_PAINT, DIALOG_STYLE_INPUT, DIALOG_TITLE, GARAGE_DL_PAINT_SETUP, DIALOG_ENTER, DIALOG_PREV);
        case DL_GARAGE_TURNING    : ShowPlayerDialog(playerid, DL_GARAGE_TURNING, DIALOG_STYLE_LIST, DIALOG_TITLE, GARAGE_DL_TURNING_TEXT, DIALOG_ENTER, DIALOG_PREV);

        case DL_DUEL_INFO         :{

            new query[400], str[1286];

            mysql_format(mysql, query, sizeof(query), SQL_DUEL_SELECT);
            mysql_query(mysql, query);

            new rows, fields;
            cache_get_data(rows, fields);
            strcat(str, DUEL_LIST_DL_TITLE);

            for(new i=0; i < rows; i++){
                new temp[128];

                DUEL[i][ID]             = cache_get_field_content_int(i, "ID");
                DUEL[i][WIN_ID]         = cache_get_field_content_int(i, "WIN_ID");
                cache_get_field_content(i, "WIN_NAME", DUEL[i][WIN_NAME], mysql, 24);
                DUEL[i][LOSS_ID]        = cache_get_field_content_int(i, "LOSS_ID");
                cache_get_field_content(i, "LOSS_NAME", DUEL[i][LOSS_NAME], mysql, 24);
                DUEL[i][TYPE]           = cache_get_field_content_int(i, "TYPE");
                DUEL[i][MONEY]          = cache_get_field_content_int(i, "MONEY");
                DUEL[i][WIN_HP]         = cache_get_field_content_float(i, "WIN_HP");
                DUEL[i][WIN_AM]         = cache_get_field_content_float(i, "WIN_AM");
                printf("%s",DUEL[i][LOSS_NAME]);
                format(temp, sizeof(temp), DUEL_LIST_DL_CONTENT, DUEL[i][ID], duelTypeName[DUEL[i][TYPE]], DUEL[i][MONEY], DUEL[i][WIN_HP], DUEL[i][WIN_AM], DUEL[i][WIN_NAME], DUEL[i][LOSS_NAME]);
                strcat(str, temp);
            }
            ShowPlayerDialog(playerid, DL_DUEL_INFO, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER,"");
        }
        case DL_DUEL_TYPE         : ShowPlayerDialog(playerid, DL_DUEL_TYPE, DIALOG_STYLE_LIST, DIALOG_TITLE, DUEL_DL_TYPE_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_DUEL_MONEY        : ShowPlayerDialog(playerid, DL_DUEL_MONEY, DIALOG_STYLE_INPUT, DIALOG_TITLE, DUEL_DL_MONEY_TEXT, DIALOG_ENTER, DIALOG_PREV);
        case DL_DUEL_SUCCESS      :{
            new str[256];
            format(str, sizeof(str), DUEL_DL_SUCCESS_TEXT, duelTypeName[DUEL_CORE[TYPE]],DUEL_CORE[MONEY]);
            ShowPlayerDialog(playerid, DL_DUEL_SUCCESS, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_GAMBLE_CHOICE     : ShowPlayerDialog(playerid, DL_GAMBLE_CHOICE, DIALOG_STYLE_LIST, DIALOG_TITLE, GAMBLE_DL_CHOICE_TEXT, DIALOG_ENTER, DIALOG_PREV);
    }
    return 1;
}
stock isHoldWep(playerid, model){
    if(USER[playerid][WEP1] == model ||
       USER[playerid][WEP2] == model ||
       USER[playerid][WEP3] == model) return SendClientMessage(playerid,COL_SYS,ALREADY_HOLD_WEAPON);
    return 0;
}

stock isHaveWeapon(playerid , weaponid){
    for(new i=0; i < INGAME[playerid][WEPBAG_INDEX]; i++){
        if(WEPBAG[playerid][i][MODEL] == weaponid)return 1;
    }
    return 0;
}
stock isEmptyWep(playerid, listitem){
    switch(listitem){
        case 0: if(USER[playerid][WEP1] == 0) return 1;
        case 1: if(USER[playerid][WEP2] == 0) return 1;
        case 2: if(USER[playerid][WEP3] == 0) return 1;
    }
    return 0;
}
stock isBuyWepMoney(weponid, money){
    if(money < wepPrice(weponid))return 1;
    return 0;
}

stock isClan(playerid, type){
    switch(type){
        case IS_CLEN_HAVE   : if(USER[playerid][CLANID] != 0) return SendClientMessage(playerid,COL_SYS,CLAN_HAVE_TEXT);
        case IS_CLEN_NOT    : if(USER[playerid][CLANID] == 0)return SendClientMessage(playerid,COL_SYS,CLAN_NOT_TEXT);
        case IS_CLEN_LEADER : if(CLAN[USER[playerid][CLANID]-1][LEADER_ID] != USER[playerid][ID])return SendClientMessage(playerid,COL_SYS,CLAN_NOT_LEADER_TEXT);
        case IS_CLEN_INSERT_MONEY   : if(USER[playerid][MONEY] < 8000) return SendClientMessage(playerid,COL_SYS,CLAN_INSERT_NOT_MONEY);
    }
    return 0;
}

stock isHangul(playerid, str[]){
    for (new i=0, j=strlen(str); i<j; i++){
        if((str[i] < 'a' || str[i] > 'z') && (str[i] < 'A' || str[i] > 'Z'))
        if(str[i] > '9' || str[i] < '0')
        if(str[i] != '_' && str[i] != '[' && str[i] != ']' && str[i] != '.' && str[i] != '@')return SendClientMessage(playerid,COL_SYS, INPUT_TEXT_HANGUL);
    }
    return 0;
}

stock isMaxHaveCar(playerid){
    new query[400];
    mysql_format(mysql, query, sizeof(query), SQL_MYCAR_LENGTH, USER[playerid][ID]);
    mysql_query(mysql, query);

    new rows, fields;
    cache_get_data(rows, fields);
    if(rows > 5)return 1;
    return 0;
}

stock isBike(vehicleid){
    new bikeModel[13] ={522,481,441,468,448,446,513,521,510,430,520,476,463};
    for(new i = 0; i < 13; i++)if(GetVehicleModel(vehicleid) == bikeModel[i]) return 1;
    return 0;
}
stock randomColor(){
    new code[3];
    for(new i=0; i < sizeof(code); i++)code[i] = random(256);
    return rgbToHex(code[0], code[1], code[2], 103);
}

stock packet(playerid){
    new nstats[400+1], nstats_loss[20], start, end;
    GetPlayerNetworkStats(playerid, nstats, sizeof(nstats));

    start = strfind(nstats,"packetloss",true);
    end = strfind(nstats,"%",true,start);

    strmid(nstats_loss, nstats, start+12, end, sizeof(nstats_loss));
    INGAME[playerid][PACKET] = floatstr(nstats_loss);
}
stock fps(playerid){
    new drunk = GetPlayerDrunkLevel(playerid);

    if(drunk < 100)SetPlayerDrunkLevel(playerid, 2000);
    else{
        if (INGAME[playerid][DRUNK_LEVEL_LAST] != drunk){
            new value = INGAME[playerid][DRUNK_LEVEL_LAST] - drunk;
            if((value > 0)&&(value < 200))INGAME[playerid][FPS] = value;

            INGAME[playerid][DRUNK_LEVEL_LAST] = drunk;
        }
    }
}

stock setAlpha(color, a){return (((color >> 24) & 0xFF) << 24 | ((color >> 16) & 0xFF) << 16 | ((color >> 8) & 0xFF) << 8 | floatround((float(color & 0xFF) / 255) * a));}
stock damage(playerid){
    if(INGAME[playerid][TAKE_DAMAGE_ALPHA] > 0){
        TextDrawColor(TDraw[playerid][TAKE_DAMAGE], setAlpha(0x8D8DFFFF, INGAME[playerid][TAKE_DAMAGE_ALPHA]));
        TextDrawBackgroundColor(TDraw[playerid][TAKE_DAMAGE], setAlpha(0x000000FF, INGAME[playerid][TAKE_DAMAGE_ALPHA] / 0x6));

        TextDrawShowForPlayer(playerid, TDraw[playerid][TAKE_DAMAGE]);
        INGAME[playerid][TAKE_DAMAGE_ALPHA] -= 0x6;

    }else if(INGAME[playerid][TAKE_DAMAGE_ALPHA] < 0){

        TextDrawHideForPlayer(playerid, TDraw[playerid][TAKE_DAMAGE]);

        INGAME[playerid][TAKE_DAMAGE_ALPHA] = 0;
        for(new i = 0; i < GetMaxPlayers(); i++)DAMAGE[playerid][i][TAKE] = 0.0;
    }
    if(INGAME[playerid][GIVE_DAMAGE_ALPHA] > 0){
        TextDrawColor(TDraw[playerid][GIVE_DAMAGE], setAlpha(0xB00000FF, INGAME[playerid][GIVE_DAMAGE_ALPHA]));
        TextDrawBackgroundColor(TDraw[playerid][GIVE_DAMAGE], setAlpha(0x000000FF, INGAME[playerid][GIVE_DAMAGE_ALPHA] / 0x6));

        TextDrawShowForPlayer(playerid, TDraw[playerid][GIVE_DAMAGE]);
        INGAME[playerid][GIVE_DAMAGE_ALPHA] -= 0x6;

    }else if(INGAME[playerid][GIVE_DAMAGE_ALPHA] < 0){

        TextDrawHideForPlayer(playerid, TDraw[playerid][GIVE_DAMAGE]);

        INGAME[playerid][GIVE_DAMAGE_ALPHA] = 0;
        for(new i = 0; i < GetMaxPlayers(); i++)DAMAGE[playerid][i][GIVE] = 0.0;
    }
}

stock getPlayerId(name[]){
  for(new i = 0; i <= GetMaxPlayers(); i++){
    if(IsPlayerConnected(i)){
      if(!strcmp(USER[i][NAME], name))return i;
    }
  }
  return INVALID_PLAYER_ID;
}

stock wepID(model){
    new wep;
    switch(model){
        case 24 : wep = 0;
        case 25 : wep = 1;
        case 42 : wep = 2;
        case 27 : wep = 3;
        case 28 : wep = 4;
        case 29 : wep = 5;
        case 30 : wep = 6;
        case 31 : wep = 7;
        case 32 : wep = 8;
        case 33 : wep = 9;
        case 34 : wep = 10;
    }
    return wep;
}

stock wepName(model){
    new wep[30];
    switch(model){
        case 24 : format(wep, sizeof(wep), "%s", wepModel[0]);
        case 25 : format(wep, sizeof(wep), "%s", wepModel[1]);
        case 42 : format(wep, sizeof(wep), "%s", wepModel[2]);
        case 27 : format(wep, sizeof(wep), "%s", wepModel[3]);
        case 28 : format(wep, sizeof(wep), "%s", wepModel[4]);
        case 29 : format(wep, sizeof(wep), "%s", wepModel[5]);
        case 30 : format(wep, sizeof(wep), "%s", wepModel[6]);
        case 31 : format(wep, sizeof(wep), "%s", wepModel[7]);
        case 32 : format(wep, sizeof(wep), "%s", wepModel[8]);
        case 33 : format(wep, sizeof(wep), "%s", wepModel[9]);
        case 34 : format(wep, sizeof(wep), "%s", wepModel[10]);
    }
    return wep;
}
stock wepNameTD(model){
    new wep[30];
    switch(model){
        case 24 : format(wep, sizeof(wep), "%s", wepModelTD[0]);
        case 25 : format(wep, sizeof(wep), "%s", wepModelTD[1]);
        case 42 : format(wep, sizeof(wep), "%s", wepModelTD[2]);
        case 27 : format(wep, sizeof(wep), "%s", wepModelTD[3]);
        case 28 : format(wep, sizeof(wep), "%s", wepModelTD[4]);
        case 29 : format(wep, sizeof(wep), "%s", wepModelTD[5]);
        case 30 : format(wep, sizeof(wep), "%s", wepModelTD[6]);
        case 31 : format(wep, sizeof(wep), "%s", wepModelTD[7]);
        case 32 : format(wep, sizeof(wep), "%s", wepModelTD[8]);
        case 33 : format(wep, sizeof(wep), "%s", wepModelTD[9]);
        case 34 : format(wep, sizeof(wep), "%s", wepModelTD[10]);
    }
    return wep;
}

stock wepPrice(model){
    new price;
    switch(model){
        case 24 : price = 8000;
        case 25 : price = 8000;
        case 42 : price = 40000;
        case 27 : price = 80000;
        case 28 : price = 15000;
        case 29 : price = 8000;
        case 30 : price = 17000;
        case 31 : price = 32000;
        case 32 : price = 20000;
        case 33 : price = 20000;
        case 34 : price = 50000;
    }
    return price;
}

stock sync(playerid){
    if(!isHaveWeapon(playerid , 24) && USER[playerid][LEVEL] < 10){
        new wep[2];
        GetPlayerWeaponData(playerid, 2, wep[0], wep[1]);
        if(wep[0] == 24 && wep[1] > 0)INGAME[playerid][AMMO] = wep[1];
    }

    INGAME[playerid][SYNC] = true;
    new Float:pos[4],world, inter;

    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    GetPlayerFacingAngle(playerid, pos[3]);

    inter = GetPlayerInterior(playerid);
    world = GetPlayerVirtualWorld(playerid);

    SpawnPlayer(playerid);

    SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    SetPlayerFacingAngle(playerid, pos[3]);

    SetPlayerInterior(playerid, inter);
    SetPlayerVirtualWorld(playerid, world);

    INGAME[playerid][SYNC] = false;

    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid, USER[playerid][WEP1], 9999);
    GivePlayerWeapon(playerid, USER[playerid][WEP2], 9999);
    GivePlayerWeapon(playerid, USER[playerid][WEP3], 9999);

    if(!isHaveWeapon(playerid , 24) && USER[playerid][LEVEL] < 10)GivePlayerWeapon(playerid, 24, INGAME[playerid][AMMO]);
    SetPlayerArmedWeapon(playerid, 0);
    return 0;
}

public Float:kdRatio(kill, death){
    return float(kill*100) / float(kill+death);
}

stock kdTier(level, kill, death){
    new rank[30];
    if(level < 2)rank = "unrank";
    else{
        new Float:kd = kdRatio(kill, death);

        switch(floatround(kd, floatround_round)){
            case 0..9    : rank = "unrank";
            case 10..49  : rank = "{804040}◎Bronze";
            case 50..54  : rank = "{C0C0C0}▼Sliver";
            case 55..59  : rank = "{FFFF00}▣Gold";
            case 60..69  : rank = "{00FFFF}⊙Platinum";
            case 70..79  : rank = "{1229FA}◈Diamond";
            case 80..100 : rank = "{FF0000}▩Challenger";
        }
    }
    return rank;
}
