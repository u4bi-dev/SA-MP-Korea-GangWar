#include <a_samp>
#include <a_mysql>
#include <foreach>
	
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

#define DL_CLAN_INSERT                    1040
#define DL_CLAN_INSERT_COLOR              10400
#define DL_CLAN_INSERT_COLOR_RANDOM       10401
//#define DL_CLAN_INSERT_COLOR_CHOICE       10402
#define DL_CLAN_INSERT_SUCCESS            10403

#define DL_CLAN_LIST                      1041
#define DL_CLAN_RANK                      1042
#define DL_CLAN_SETUP                     1043
#define DL_CLAN_LEAVE                    1044

#define DL_CLAN_SETUP_INVITE              10430
#define DL_CLAN_SETUP_MEMBER              10431

#define DL_CLAN_SETUP_MEMBER_SETUP        104310
#define DL_CLAN_SETUP_MEMBER_SETUP_RANK   104311
#define DL_CLAN_SETUP_MEMBER_SETUP_KICK   104312

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

#define COL_SYS  0xAFAFAF99
#define DIALOG_TITLE "{8D8DFF}샘프워코리아"
#define DIALOG_ENTER "확인"
#define DIALOG_PREV "뒤로"

/* IS CHECK */
#define IS_CLEN_HAVE          500
#define IS_CLEN_NOT           501
#define IS_CLEN_LEADER        502
#define IS_CLEN_INSERT_MONEY  503

/*ZONE BASE */
#define USED_ZONE     932
#define USED_TEXTDRAW 200
#define USED_WEAPON   11
#define USED_VEHICLE  230
#define USED_HOUSE    500
#define USED_CLAN     100
#define USED_MISSON   3
#define USED_GARAGE   5

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

#define rgbToHex(%0,%1,%2,%3) %0 << 24 | %1 << 16 | %2 << 8 | %3

main(){}

forward MyHttpResponse(playerid, response_code, data[]);

forward check(playerid);
forward regist(playerid, pass[]);
forward save(playerid);
forward load(playerid);
forward ServerThread();
forward Float:kdRatio(kill, death);
forward vehicleSapwn(vehicleid);


/* global variable */
new missonTick=0;
new garageTick=0;
#include "module/resource.pwn"
#include "module/sql.pwn"

/* static */
static mysql;
	
enum CLAN_CP_MODEL{
   CP,
   INDEX
}
new CLAN_CP[USED_ZONE][USED_CLAN][CLAN_CP_MODEL];

enum ZONE_MODEL{
	ID,
	OWNER_CLAN,
	STAY_HUMAN,
    STAY_CLAN,
	Float:MIN_X,
	Float:MIN_Y,
	Float:MAX_X,
	Float:MAX_Y
}
new ZONE[USED_ZONE][ZONE_MODEL];

enum USER_MODEL{
 	ID,
	NAME[MAX_PLAYER_NAME],
	PASS[24],
	USERIP[16],
	CLANID,
	ADMIN,
	MONEY,
	LEVEL,
	EXP,
	KILLS,
	DEATHS,
	SKIN,
	WEP1,
	WEP2,
	WEP3,
	INTERIOR,
	WORLD,
	Float:POS_X,
	Float:POS_Y,
	Float:POS_Z,
	Float:ANGLE,
 	Float:HP,
 	Float:AM
}
new USER[MAX_PLAYERS][USER_MODEL];

enum WEPBAG_MODEL{
	MODEL
}
new WEPBAG[MAX_PLAYERS][USED_WEAPON][WEPBAG_MODEL];

enum CARBAG_MODEL{
	ID
}
new CARBAG[MAX_PLAYERS][USED_WEAPON][CARBAG_MODEL];

enum VEHICLE_MODEL{
 	ID,
	NAME[MAX_PLAYER_NAME],
 	COLOR1,
 	COLOR2,
	Float:POS_X,
	Float:POS_Y,
	Float:POS_Z,
	Float:ANGLE
}
new VEHICLE[USED_VEHICLE][VEHICLE_MODEL];

enum HOUSE_MODEL{
 	ID,
 	NAME[MAX_PLAYER_NAME],
 	OPEN,
	Float:ENTER_POS_X,
	Float:ENTER_POS_Y,
	Float:ENTER_POS_Z,
	Float:LEAVE_POS_X,
	Float:LEAVE_POS_Y,
	Float:LEAVE_POS_Z
}
new HOUSE[USED_HOUSE][HOUSE_MODEL];

enum CLAN_MODEL{
 	ID,
 	NAME[50],
 	LEADER_NAME[MAX_PLAYER_NAME],
 	KILLS,
 	DEATHS,
    COLOR,
    ZONE_LENGTH,
}
new CLAN[USED_CLAN][CLAN_MODEL];

enum INGAME_MODEL{
	bool:LOGIN,
	Float:SPAWN_POS_X,
	Float:SPAWN_POS_Y,
	Float:SPAWN_POS_Z,
	Float:SPAWN_ANGLE,
	ENTER_ZONE,
	ZONE_TICK,
	INVITE_CLANID,
	INVITE_CLAN_REQUEST_MEMBERID,
	BUY_SKINID,
	BUY_WEAPONID,
	HOLD_WEPID,
	HOLD_WEPLIST,
    WEPBAG_INDEX,
    HOLD_CARID,
    EDIT_NAME,
	COMBO,
    bool:SYNC,
	EVENT_TICK,
	SEASON
}
new INGAME[MAX_PLAYERS][INGAME_MODEL];

enum MISSON_MODEL{
	NAME[24],
	Float:POS_Y,
	Float:POS_X,
	Float:POS_Z
}
new MISSON[USED_MISSON][MISSON_MODEL];

enum GARAGE_MODEL{
	NAME[50],
	Float:POS_Y,
	Float:POS_X,
	Float:POS_Z
}
new GARAGE[USED_GARAGE][GARAGE_MODEL];

enum CLAN_SETUP_MODEL{
	NAME[50],
	MEMBER,
	COLOR,
}
new CLAN_SETUP[MAX_PLAYERS][CLAN_SETUP_MODEL];

enum TDrawG_MODEL{
	Text:ID,
	Text:COMBO
}
new TDrawG[USED_TEXTDRAW][TDrawG_MODEL];

enum TDraw_MODEL{
	Text:ZONETEXT,
	Text:CP
}
new TDraw[MAX_PLAYERS][TDraw_MODEL];

public OnGameModeExit(){return 1;
}
public OnGameModeInit(){
	#include "module/vehicles.pwn"
	dbcon();
	data();
    mode();
	server();
	thread();
    for(new vehicleid=1; vehicleid<=230; vehicleid++){
        vehicleSapwn(vehicleid);
    }
    return 1;
}

public OnPlayerText(playerid, text[]){
    new send[256];
    if(text[0] == '!'){
        foreach (new i : Player){
	        if(USER[i][CLANID] == USER[playerid][CLANID]){
                new str[256];
                strmid(str, text, 1, strlen(text));
	            formatMsg(i, 0x7FFF00FF,"(클랜채팅) %s : %s", USER[playerid][NAME], str);
	        }
        }
        return 0;
    }
	if(USER[playerid][CLANID])format(send,sizeof(send),"{%06x}[%s]{E6E6E6} %s : %s", GetPlayerColor(playerid) >>> 8 , CLAN[USER[playerid][CLANID]-1][NAME], USER[playerid][NAME], text);
	else format(send,sizeof(send),"{E6E6E6} %s : %s", USER[playerid][NAME], text);
    SendClientMessageToAll(-1, send);
    return 0;
}
public OnPlayerRequestClass(playerid, classid){

    if(INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    이미 로그인 하셨습니다.");

    join(playerid, check(playerid));
    showZone(playerid);
    showTextDraw(playerid);
	SetPlayerColor(playerid, 0x00000099);
    return 1;
}
public OnPlayerSpawn(playerid){
    if(!isDeagle(playerid) && USER[playerid][LEVEL] < 10)GivePlayerWeapon(playerid, 24, 500),SendClientMessage(playerid,COL_SYS,"    레벨 10까지 데져트이글이 제공됩니다.");
    
    return 1;
}

public OnVehicleSpawn(vehicleid){
	vehicleSapwn(vehicleid);
    return 1;
}
public OnVehicleDeath(vehicleid, killerid){
    return 1;
}
public OnPlayerExitVehicle(playerid, vehicleid){
	vehicleSave(vehicleid);
    SetTimerEx("vehicleSapwn", 1500, false, "i", vehicleid);
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid){
    PlayerPlaySound(issuerid, 17802, 0.0, 0.0, 0.0);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate){

    if(newstate == PLAYER_STATE_DRIVER){
        new vehicleid = GetPlayerVehicleID(playerid);
	    if(!strcmp("N", VEHICLE[vehicleid][NAME])) SendClientMessage(playerid,COL_SYS,"    소유자가 없는 차량입니다.");
	    else formatMsg(playerid, COL_SYS, "    탑승하신 차량은 [%s] 유저분의 소유입니다.", VEHICLE[vehicleid][NAME]);
	}
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
    if(!isBike(GetPlayerVehicleID(playerid)) && PRESSED(KEY_FIRE) && GetPlayerState(playerid)==PLAYER_STATE_DRIVER)AddVehicleComponent(GetPlayerVehicleID(playerid),1010);
    if(RELEASED(KEY_FIRE) && GetPlayerState(playerid)==PLAYER_STATE_DRIVER)RemoveVehicleComponent(GetPlayerVehicleID(playerid),1010);
    
    if(newkeys == 160 && GetPlayerWeapon(playerid) == 0 && !IsPlayerInAnyVehicle(playerid)){
        sync(playerid);
	}
	if(PRESSED(KEY_YES)){
		if(INGAME[playerid][INVITE_CLANID]){
            clanJoin(playerid, INGAME[playerid][INVITE_CLANID]);
            formatMsg(playerid, COL_SYS, "    당신은  [{%06x}%s{AFAFAF}] 클랜의 멤버가 되었습니다.",CLAN[USER[INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID]][CLANID]-1][COLOR] >>> 8 , CLAN[USER[INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID]][CLANID]-1][NAME]);
            formatMsg(INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID], COL_SYS, "    %s님이 당신의 클랜 가입 권유를 승낙하였습니다.",USER[playerid][NAME]);
            INGAME[playerid][INVITE_CLANID] = 0;
            INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID] = 0;
		}
	}
	if(PRESSED(KEY_NO)){
		if(INGAME[playerid][INVITE_CLANID]){
            formatMsg(playerid, COL_SYS, "    당신은 [%s] 클랜의 가입 권유를 거부하였습니다.", CLAN[USER[INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID]][CLANID]-1][NAME]);
            formatMsg(INGAME[playerid][INVITE_CLAN_REQUEST_MEMBERID], COL_SYS, "    %s님이 당신의 클랜 가입 권유를 거부하였습니다.",USER[playerid][NAME]);
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
			case DL_MISSON_CLAN, DL_MISSON_SHOP, DL_MISSON_NOTICE, DL_MYWEP, DL_MYCAR, DL_GARAGE :return 0;
			case DL_CLAN_INSERT, DL_CLAN_LIST, DL_CLAN_RANK, DL_CLAN_SETUP, DL_CLAN_LEAVE :return showMisson(playerid, 0);
			case DL_CLAN_INSERT_COLOR : return showDialog(playerid, DL_CLAN_INSERT);
			case DL_CLAN_INSERT_COLOR_RANDOM : return clanInsertColorRandom(playerid);
//			case DL_CLAN_INSERT_COLOR_CHOICE :return showDialog(playerid, DL_CLAN_INSERT_COLOR);
			case DL_CLAN_INSERT_SUCCESS : return showDialog(playerid, DL_CLAN_INSERT_COLOR);
			case DL_CLAN_SETUP_INVITE, DL_CLAN_SETUP_MEMBER : return showDialog(playerid, DL_CLAN_SETUP);
			case DL_CLAN_SETUP_MEMBER_SETUP : return showDialog(playerid, DL_CLAN_SETUP_MEMBER);
			case DL_CLAN_SETUP_MEMBER_SETUP_RANK, DL_CLAN_SETUP_MEMBER_SETUP_KICK : return showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
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
        
        /* CLAN MEMBER SETUP */
        case DL_CLAN_SETUP_MEMBER_SETUP      : clanMemberSetup(playerid,listitem);
		case DL_CLAN_SETUP_MEMBER_SETUP_RANK : clanMemberRank(playerid,listitem);
		case DL_CLAN_SETUP_MEMBER_SETUP_KICK : clanMemberKick(playerid);
		
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
		case DL_GARAGE_PAINT       : paintCar(playerid);
		case DL_GARAGE_TURNING     : turnCar(playerid);
    }
    return 1;
}
/* OnDialogResponse stock
   @ info()
   @ clan(playerid,listitem)
   @ shop(playerid,listitem)
   @ notice(playerid,listitem)
   @ mywep(playerid,listitem)
   @ mycar(playerid,listitem)
   @ garage(playerid,listitem)
*/
stock info(playerid, listitem){
	new result[502], clanName[50];
	
	if(USER[playerid][CLANID] == 0) format(clanName,sizeof(clanName), "미소속");
	else format(clanName,sizeof(clanName), "%s",CLAN[USER[playerid][CLANID]-1][NAME]);
	
	if(listitem ==1) format(result,sizeof(result), infoMessege[listitem],USER[playerid][NAME],clanName,USER[playerid][LEVEL],USER[playerid][EXP],USER[playerid][MONEY],USER[playerid][KILLS],USER[playerid][DEATHS],kdRatio(USER[playerid][KILLS],USER[playerid][DEATHS]),kdTier(USER[playerid][KILLS],USER[playerid][DEATHS]));
	else format(result,sizeof(result), infoMessege[listitem]);
	ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, DIALOG_TITLE,result, "닫기", "");
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

stock mywep(playerid,listitem){
	if(!WEPBAG[playerid][listitem][MODEL])return showDialog(playerid, DL_MYWEP);
	
    INGAME[playerid][HOLD_WEPID] = WEPBAG[playerid][listitem][MODEL];
    showDialog(playerid, DL_MYWEP_SETUP);
    return 0;
}
stock mycar(playerid,listitem){
    INGAME[playerid][HOLD_CARID] = CARBAG[playerid][listitem][ID];
    showDialog(playerid, DL_MYCAR_SETUP);
    return 0;
}
stock garage(playerid,listitem){
	switch(listitem){
        case 0 : showDialog(playerid, DL_GARAGE_REPAIR);
        case 1 : showDialog(playerid, DL_GARAGE_PAINT);
        case 2 : showDialog(playerid, DL_GARAGE_TURNING);
	}
}
/* CLAN
   @ clanInsert(playerid, inputtext)
   @ clanList(playerid);
   @ clanRank(playerid);
   @ clanSetup(playerid, listitem);
   @ clanLeave(playerid);
   
   @ clanJoin(playerid, clanid)
*/
stock clanInsert(playerid, inputtext[]){
    if(!strlen(inputtext))return showDialog(playerid, DL_CLAN_INSERT);
    
    format(CLAN_SETUP[playerid][NAME], 50, "%s", escape(inputtext));
    if(isClanHangul(playerid, CLAN_SETUP[playerid][NAME])) return showDialog(playerid, DL_CLAN_INSERT);

	new query[400],row;
    mysql_format(mysql, query, sizeof(query), "SELECT NAME FROM `clan_info` WHERE `NAME` = '%s' LIMIT 1", CLAN_SETUP[playerid][NAME]);
    mysql_query(mysql, query);
    
    row = cache_num_rows();
	if(row){
        formatMsg(playerid, COL_SYS, "    [%s] 클랜은 이미 존재하는 클랜입니다.", CLAN_SETUP[playerid][NAME]);
        showDialog(playerid, DL_CLAN_INSERT);
    }
    else showDialog(playerid, DL_CLAN_INSERT_COLOR);
    
    return 0;
}
stock clanList(playerid){
    formatMsg(playerid, COL_SYS, "클랜 리스트 %d",playerid);
}

stock clanRank(playerid){
    formatMsg(playerid, COL_SYS, "클랜 랭킹 %d",playerid);
}
stock clanSetup(playerid, listitem){
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_INVITE);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER);
	}
	return 0;
}
stock clanLeave(playerid){
    formatMsg(playerid, COL_SYS, "    당신이 소속되어 있던 [%s] 클랜을 탈퇴하였습니다.", CLAN[USER[playerid][CLANID]-1][NAME]);
	USER[playerid][CLANID] = 0;
	SetPlayerColor(playerid, 0xE6E6E699);
    save(playerid);
	return 0;
}

stock clanJoin(playerid, clanid){
	USER[playerid][CLANID] = clanid;
	SetPlayerColor(playerid,CLAN[clanid-1][COLOR]);
    save(playerid);
}

/* CLAN INSERT
   @ clanInsertColor(playerid, listitem)
   @ clanInsertColorRandom(playerid)
   @ clanInsertColorChoice(playerid, inputtext)
   @ clanInsertSuccess(playerid)
*/
stock clanInsertColor(playerid, listitem){
	switch(listitem){
		case 0 :{
            CLAN_SETUP[playerid][COLOR] = randomColor();
            
            new query[400],row, field[50];
            mysql_format(mysql, query, sizeof(query), "SELECT NAME,COLOR FROM `clan_info` WHERE `COLOR` = %d LIMIT 1", CLAN_SETUP[playerid][COLOR]);
            mysql_query(mysql, query);

            row = cache_num_rows();
            if(row){
                cache_get_field_content(0, "NAME", field, mysql, 50);
                formatMsg(playerid, COL_SYS, "    {%06x}%06x{FFFFFF}색상은 [$s] 클랜의 고유 색상으로 지정되어 있습니다.", CLAN_SETUP[playerid][COLOR] , CLAN_SETUP[playerid][COLOR] ,field);
                showDialog(playerid, DL_CLAN_INSERT_COLOR);
            }else showDialog(playerid, DL_CLAN_INSERT_COLOR_RANDOM);
		}
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
    
	formatMsg(playerid, COL_SYS, "    당신은 [{%06x}%s{AFAFAF}]클랜을 창설하였습니다.", CLAN_SETUP[playerid][COLOR] >>> 8, CLAN_SETUP[playerid][NAME]);
    giveMoney(playerid, -20000);
	
	new query[400],sql[400];
	strcat(sql, "INSERT INTO `clan_info`");
	strcat(sql, " (`NAME`,`LEADER_NAME`,`KILLS`,`DEATHS`,`COLOR`,`ZONE_LENGTH`)");
	strcat(sql, " VALUES ('%s','%s',0,0,%d,0)");
	mysql_format(mysql, query, sizeof(query), sql,
        CLAN_SETUP[playerid][NAME],
        USER[playerid][NAME],
        CLAN_SETUP[playerid][COLOR]
	);
	
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
   @ clanInvite(playerid, inputtext)
   @ clanMember(playerid, listitem)
*/
stock clanInvite(playerid, inputtext[]){
    new user = getPlayerId(inputtext);

	if(user < 0 || user > GetMaxPlayers()) return SendClientMessage(playerid,COL_SYS,"    초대하실 유저분의 닉네임을 입력해주세요."), showDialog(playerid, DL_CLAN_SETUP_INVITE);
    if(!INGAME[user][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    현재 서버에 접속하지 않은 유저 번호입니다."), showDialog(playerid, DL_CLAN_SETUP_INVITE);
    if(isClan(user, IS_CLEN_HAVE)) return 0;
    formatMsg(user, COL_SYS, "    %s님이 당신에게 [{%06x}%s{AFAFAF}] 클랜 가입 권유를 보냈습니다.",USER[playerid][NAME], CLAN[USER[playerid][CLANID]-1][COLOR] >>> 8 , CLAN[USER[playerid][CLANID]-1][NAME]);
    formatMsg(user, COL_SYS, "    동의하시면 {8D8DFF}Y키{AFAFAF} 거부하시면 {FF0000}N키{AFAFAF}를 눌러주세요.",USER[playerid][NAME], CLAN[USER[playerid][CLANID]-1][COLOR] >>> 8 , CLAN[USER[playerid][CLANID]-1][NAME]);
    INGAME[user][INVITE_CLANID] = USER[playerid][CLANID];
    INGAME[user][INVITE_CLAN_REQUEST_MEMBERID] = playerid;
	return 1;
}

stock clanMember(playerid, listitem){
	showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
	formatMsg(playerid, COL_SYS, "클랜 정보 %d - %d",playerid, listitem);
}

/* CLAN MEMBER SETUP
   @ clanMemberSetup(playerid, listitem);
   @ clanMemberRank(playerid, listitem);
   @ clanMemberKick(playerid);
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

/* SHOP
	@ shopWeapon(playerid, listitem)
	@ shopSkin(playerid, inputtext)
	@ shopAcc(playerid, listitem)
	@ shopName(playerid, inputtext)
*/

stock shopWeapon(playerid, listitem){

	switch(listitem){
		case 0 : INGAME[playerid][BUY_WEAPONID] = 24;
		case 1 : INGAME[playerid][BUY_WEAPONID] = 25;
		case 2 : INGAME[playerid][BUY_WEAPONID] = 26;
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
    mysql_format(mysql, query, sizeof(query), "SELECT USER_ID FROM `weapon_info` WHERE `USER_ID` = %d AND `MODEL` = %d LIMIT 1", USER[playerid][ID], INGAME[playerid][BUY_WEAPONID]);
    mysql_query(mysql, query);

    row = cache_num_rows();
	if(row){
        formatMsg(playerid, COL_SYS, "    [%s]를 이미 보유하고 있습니다.", wepModel[listitem]);
        showDialog(playerid, DL_SHOP_WEAPON);
    }
    else showDialog(playerid, DL_SHOP_WEAPON_BUY);
}
stock shopSkin(playerid, inputtext[]){
    new skin = strval(inputtext);
    if(skin < 0 || skin > 299) return SendClientMessage(playerid, COL_SYS, "    1번부터 299번까지 스킨이 존재합니다.");
    if(skin == 0 || skin == 74) return SendClientMessage(playerid, COL_SYS, "    CJ 스킨은 규정상 선택하실 수 없습니다.");
    if(USER[playerid][MONEY] < 5000) return SendClientMessage(playerid,COL_SYS,"    스킨을 구매할 자금이 부족합니다.");

    INGAME[playerid][BUY_SKINID] = skin;
	showDialog(playerid, DL_SHOP_SKIN_BUY);
	return 0;
}
stock shopAcc(playerid, listitem){
    formatMsg(playerid, COL_SYS, "카푸치노샵 악세 %d - %d",playerid, listitem);
}

stock shopName(playerid, inputtext[]){
    if(USER[playerid][MONEY] < 20000) return SendClientMessage(playerid,COL_SYS,"    닉네임을 변경할 자금이 부족합니다.");

	new query[400],row;
    mysql_format(mysql, query, sizeof(query), "SELECT NAME FROM `user_info` WHERE `NAME` = '%s' LIMIT 1", inputtext);
    mysql_query(mysql, query);

    row = cache_num_rows();
	if(row){
	    SendClientMessage(playerid,COL_SYS,"    이미 존재하는 닉네임입니다.");
	    showDialog(playerid, DL_SHOP_NAME);
	    return 0;
	}

    format(INGAME[playerid][EDIT_NAME], 24,"%s", escape(inputtext));
    showDialog(playerid, DL_SHOP_NAME_EDIT);
	return 0;
}

/* SHOP WEAPON BUY
   @ shopWeaponBuy(playerid)
*/
stock shopWeaponBuy(playerid){
	if(isBuyWepMoney(INGAME[playerid][BUY_WEAPONID], USER[playerid][MONEY]))return SendClientMessage(playerid,COL_SYS,"    무기를 구매할 자금이 부족합니다.");

    formatMsg(playerid, COL_SYS, "    당신은 [%s] 무기를 구매하였습니다.",wepName(INGAME[playerid][BUY_WEAPONID]));

	new query[400];
	mysql_format(mysql, query, sizeof(query), "INSERT INTO `weapon_info` (`USER_ID`,`MODEL`) VALUES (%d,%d)",
        USER[playerid][ID],
        INGAME[playerid][BUY_WEAPONID]
	);
	mysql_query(mysql, query);

	INGAME[playerid][WEPBAG_INDEX] +=1;
    WEPBAG[playerid][INGAME[playerid][WEPBAG_INDEX]-1][MODEL] = INGAME[playerid][BUY_WEAPONID];
    INGAME[playerid][BUY_WEAPONID] = 0;
    return 0;
}

/* SHOP SKIN BUY
   @ shopSkinBuy(playerid)
*/
stock shopSkinBuy(playerid){
    formatMsg(playerid, COL_SYS, "    당신은 %d번 스킨을 구매하였습니다.",INGAME[playerid][BUY_SKINID]);
    giveMoney(playerid, -5000);

    USER[playerid][SKIN] = INGAME[playerid][BUY_SKINID];
    sync(playerid);
    
    INGAME[playerid][BUY_SKINID] = 0;
    SetPlayerSkin(playerid, USER[playerid][SKIN]);
	save(playerid);
}

/* SHOP NAME EDIT
   @ shopNameEdit(playerid)
*/
stock shopNameEdit(playerid){
    formatMsg(playerid, COL_SYS, "    당신은 %s로 닉네임을 변경하였습니다.",INGAME[playerid][EDIT_NAME]);
    giveMoney(playerid, -20000);

	new query[400];
	if(USER[playerid][NAME] == CLAN[USER[playerid][CLANID]-1][LEADER_NAME]){
		mysql_format(mysql, query, sizeof(query), "UPDATE `clan_info` SET `LEADER_NAME` = '%s' WHERE `LEADER_NAME` = '%s'", INGAME[playerid][EDIT_NAME], USER[playerid][NAME]);
		mysql_query(mysql, query);
		format(CLAN[USER[playerid][CLANID]-1][LEADER_NAME], 24,"%s",INGAME[playerid][EDIT_NAME]);
    }

    mysql_format(mysql, query, sizeof(query), "UPDATE `user_info` SET `NAME` = '%s'  WHERE `NAME` = '%s'", INGAME[playerid][EDIT_NAME], USER[playerid][NAME]);
    mysql_query(mysql, query);
    
    format(USER[playerid][NAME], 24,"%s",INGAME[playerid][EDIT_NAME]);
    format(INGAME[playerid][EDIT_NAME], 24,"");
    SetPlayerName(playerid, USER[playerid][NAME]);

}

/* NOTICE
    @ noticeSeason(playerid)
*/
stock noticeSeason(playerid){
    if(INGAME[playerid][SEASON] == 2) return 0;
    showDialog(playerid, DL_NOTICE_SEASON);
    return 0;
}

/* MYWEP SETUP
   @ setWep(playerid, listitem)
   @ setWepOption(playerid, listitem)
   @ holdWep(playerid)
   @ putWep(playerid)
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

    syncWep(playerid);
    formatMsg(playerid, COL_SYS, "    주무기 %d번 슬롯에 [%s] 무기를 장착합니다.",INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));
    save(playerid);
    showDialog(playerid, DL_MYWEP_SETUP);
    return 0;
}
stock putWep(playerid){
    formatMsg(playerid, COL_SYS, "    주무기 %d번 슬롯의 [%s] 무기를 탈착합니다.",INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));

	switch(INGAME[playerid][HOLD_WEPLIST]){
        case 0 : USER[playerid][WEP1] = 0;
        case 1 : USER[playerid][WEP2] = 0;
        case 2 : USER[playerid][WEP3] = 0;
	}
	
	syncWep(playerid);
    save(playerid);
    showDialog(playerid, DL_MYWEP_SETUP);
    return 0;
}

/* MYCAR SETUP
   @ setCar(playerid, listitem)
   @ spawnCar(playerid)
*/
stock setCar(playerid, listitem){
	switch(listitem){
		case 0 :{
            if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,COL_SYS,"    차량에 탑승하신 상태에서는 소환이 불가능합니다.");
            if(USER[playerid][MONEY] < 2000) return SendClientMessage(playerid,COL_SYS,"    차량을 소환할 자금이 부족합니다.");
            showDialog(playerid, DL_MYCAR_SETUP_SPAWN);
		}
	}
    return 0;
}
stock spawnCar(playerid){
    new vehicleid = INGAME[playerid][HOLD_CARID];
	new model = GetVehicleModel(vehicleid);
	
	GetPlayerPos(playerid,USER[playerid][POS_X],USER[playerid][POS_Y],USER[playerid][POS_Z]);
	GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);
    
    SetVehiclePos(vehicleid, USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z]);
    SetVehicleZAngle(vehicleid, USER[playerid][ANGLE]);
    PutPlayerInVehicle(playerid, vehicleid, 0);
	
	vehicleSave(vehicleid);
	formatMsg(playerid, COL_SYS, "    [%s] 차량을 자신의 앞으로 소환합니다.", vehicleName[model - 400]);
    giveMoney(playerid,-2000);
}
/* GARAGE
   @ repairCar(playerid)
   @ paintCar(playerid)
   @ turnCar(playerid)
*/
stock repairCar(playerid){
    new vehicleid = GetPlayerVehicleID(playerid);
   	new model = GetVehicleModel(vehicleid);
   	
	formatMsg(playerid, COL_SYS, "    [%s] 차량을 수리합니다.", vehicleName[model - 400]);
    RepairVehicle(vehicleid);
    giveMoney(playerid,-100);
}
stock paintCar(playerid){
    formatMsg(playerid, COL_SYS, "주유소 도색 %d",playerid);
}
stock turnCar(playerid){
    formatMsg(playerid, COL_SYS, "주유소 튜닝 %d",playerid);
}

public OnPlayerCommandText(playerid, cmdtext[]){
    if(!strcmp("/sav", cmdtext)){

        if(!INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    로그인후에 사용 가능합니다.");

        save(playerid);
		if(IsPlayerInAnyVehicle(playerid)) vehicleSave(GetPlayerVehicleID(playerid));

        SendClientMessage(playerid,COL_SYS,"    저장되었습니다.");
        return 1;
    }
   	if(!strcmp("/help", cmdtext)){
		showDialog(playerid, DL_INFO);
        return 1;
 	}
   	if(!strcmp("/wep", cmdtext)){
		showDialog(playerid, DL_MYWEP);
        return 1;
 	}
   	if(!strcmp("/car", cmdtext)){
		showDialog(playerid, DL_MYCAR);
        return 1;
 	}
    if(!strcmp("/carinit", cmdtext)){
	 	vehicleInit();
        return 1;
	}
    if(!strcmp("/zoneinit", cmdtext)){
        zoneInit();
	 	return 1;
 	}
    if(!strcmp("/carspawn", cmdtext)){
        for(new vehicleid=1; vehicleid<=230; vehicleid++){
            vehicleSapwn(vehicleid);
        }
        SendClientMessage(playerid,COL_SYS,"    모든 차량이 스폰되었습니다.");
		return 1;
    }
    if(!strcmp("/carbuy", cmdtext)){
        if(!IsPlayerInAnyVehicle(playerid))return 1;
        if(!strcmp("N", VEHICLE[GetPlayerVehicleID(playerid)][NAME]))return 1;
        if(USER[playerid][MONEY] < 30000) return SendClientMessage(playerid,COL_SYS,"    차량을 구매할 자금이 부족합니다. (입찰가 : 30000원)");
        
		vehicleBuy(playerid, GetPlayerVehicleID(playerid));
		return 1;
    }
    if(!strcmp("/hold", cmdtext)){
        if(isClan(playerid, IS_CLEN_NOT)) return 1;
 	    holdZone(playerid);
 	    return 1;
 	}
 	if(!strcmp("/money", cmdtext)){
        giveMoney(playerid, 5000);
        return 1;
 	}

 	if(!strcmp("/combo", cmdtext)){
	    if(INGAME[playerid][COMBO] < 10){
		    TextDrawShowForPlayer(playerid, TDrawG[INGAME[playerid][COMBO]][COMBO]);
		    INGAME[playerid][COMBO]+=1;
		}
        return 1;
 	}
 	if(!strcmp("/kd", cmdtext)){
		USER[playerid][KILLS] = 130;
		USER[playerid][DEATHS] = 78;
        return 1;
 	}

    return 0;
}

public OnPlayerDisconnect(playerid, reason){
    if(INGAME[playerid][LOGIN]) save(playerid);
    if(IsPlayerInAnyVehicle(playerid)) vehicleSave(GetPlayerVehicleID(playerid));
    
    ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN] -=1;
    CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX]-=1;

    cleaning(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
    if(INGAME[playerid][SYNC]) return 0;
    
	death(playerid, killerid, reason);
	return 1;
}

/* REG/LOG CHECK MANAGER
   @checked(playerid, password[])
   @join(playerid, type)
*/
stock checked(playerid, password[]){

    if(strlen(password) == 0) return join(playerid, 1), SendClientMessage(playerid,COL_SYS,"    비밀번호를 입력해주세요.");
    if(strcmp(password, USER[playerid][PASS])) return join(playerid, 1), SendClientMessage(playerid,COL_SYS,"    비밀번호가 틀립니다.");

    SendClientMessage(playerid,COL_SYS,"    로그인 하였습니다.");
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

/* SQL @ check(playerid)
       @ regist(playerid, pass)
       @ save(playerid)
	   @ load(playerid)
	   @ escape(str[])
*/
public check(playerid){
    new query[128], result;
    GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);

    mysql_format(mysql, query, sizeof(query), "SELECT ID, PASS FROM `user_info` WHERE `NAME` = '%s' LIMIT 1", escape(USER[playerid][NAME]));
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
	new query[400], sql[400];
    strcat(sql, "INSERT INTO `user_info`");
    strcat(sql, " (`NAME`,`PASS`,`USERIP`,`ADMIN`,`CLANID`");
    strcat(sql, ",`MONEY`,`LEVEL`,`EXP`,`KILLS`,`DEATHS`");
    strcat(sql, ",`SKIN`,`WEP1`,`WEP2`,`WEP3`,`INTERIOR`");
    strcat(sql, ",`WORLD`,`POS_X`,`POS_Y`,`POS_Z`");
    strcat(sql, ",`ANGLE`,`HP`,`AM`)");
    strcat(sql, " VALUES ('%s','%s','%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f)");
    
	mysql_format(mysql, query, sizeof(query), sql,
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

	SendClientMessage(playerid,COL_SYS,"    회원가입을 하였습니다.");
	INGAME[playerid][LOGIN] = true;
	spawn(playerid);
}
public save(playerid){
	GetPlayerPos(playerid,USER[playerid][POS_X],USER[playerid][POS_Y],USER[playerid][POS_Z]);
	GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

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
	
	new str[120];
	format(str,sizeof(str),"NAME : %s   CLAN : %s   LEVEL : %d   EXP : %d   MONEY : %d   KILLS : %d   DEATHS : %d   K/D : %.01f%",
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
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `user_info` WHERE `ID` = %d LIMIT 1", USER[playerid][ID]);
	mysql_query(mysql, query);

	USER[playerid][USERIP]   = cache_get_field_content_int(0, "USERIP");
	USER[playerid][ADMIN]   = cache_get_field_content_int(0, "ADMIN");
	USER[playerid][CLANID]   = cache_get_field_content_int(0, "CLANID");
	USER[playerid][MONEY]   = cache_get_field_content_int(0, "MONEY");
	USER[playerid][LEVEL]   = cache_get_field_content_int(0, "LEVEL");
	USER[playerid][EXP]   = cache_get_field_content_int(0, "EXP");
	USER[playerid][KILLS]   = cache_get_field_content_int(0, "KILLS");
	USER[playerid][DEATHS]  = cache_get_field_content_int(0, "DEATHS");
	USER[playerid][SKIN]    = cache_get_field_content_int(0, "SKIN");
	USER[playerid][WEP1]    = cache_get_field_content_int(0, "WEP1");
	USER[playerid][WEP2]    = cache_get_field_content_int(0, "WEP2");
	USER[playerid][WEP3]    = cache_get_field_content_int(0, "WEP3");
	USER[playerid][POS_X]   = cache_get_field_content_float(0, "POS_X");
	USER[playerid][POS_Y]   = cache_get_field_content_float(0, "POS_Y");
	USER[playerid][POS_Z]   = cache_get_field_content_float(0, "POS_Z");
	USER[playerid][ANGLE]   = cache_get_field_content_float(0, "ANGLE");
	USER[playerid][HP]      = cache_get_field_content_float(0, "HP");
	USER[playerid][AM]      = cache_get_field_content_float(0, "AM");

	new sql[400];
	strcat(sql, "SELECT weapon.MODEL FROM");
	strcat(sql, " `user_info` as user INNER JOIN");
	strcat(sql, " `weapon_info` as weapon");
	strcat(sql, " on user.ID = weapon.USER_ID");
	strcat(sql, " WHERE user.ID = %d");

	mysql_format(mysql, query, sizeof(query), sql, USER[playerid][ID]);
	mysql_query(mysql, query);

	new rows, fields;
	cache_get_data(rows, fields);

	INGAME[playerid][WEPBAG_INDEX] = rows;
    for(new i=0; i < rows; i++){
        WEPBAG[playerid][i][MODEL] = cache_get_field_content_int(i, "MODEL");
	}
	
	spawn(playerid);
}
stock escape(str[]){
    new result[24];
    mysql_real_escape_string(str, result);
    return result;
}
/* INGAME FUNCTION
   @ spawn(playerid)
*/
stock spawn(playerid){

	new ammo = 9999;
	SetSpawnInfo(playerid, 0, USER[playerid][SKIN], USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z], USER[playerid][ANGLE], USER[playerid][WEP1], ammo, USER[playerid][WEP2], ammo, USER[playerid][WEP3], ammo);
    
	SpawnPlayer(playerid);
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, USER[playerid][MONEY]);
	SetPlayerHealth(playerid, USER[playerid][HP]);
	SetPlayerArmour(playerid, USER[playerid][AM]);

	if(USER[playerid][CLANID] == 0)SetPlayerColor(playerid, 0xE6E6E699);
    else SetPlayerColor(playerid, CLAN[USER[playerid][CLANID]-1][COLOR]);
    
    save(playerid);
}

/* INIT
   @ dbcon()
   @ data()
   @ mode()
   @ thread()
   @ server()
   @ cleaning(playerid)
*/
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
	SetGameModeText("Blank Script");
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

    if(mysql_errno(mysql))print("DB연결오류");
}
stock data(){
	house_data();
	vehicle_data();
	zone_data();
	clan_data();
	weapon_data();
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
}

/* DB DATA
   @ house_data()
   @ vehicle_data()
   @ clan_data()
   @ zone_data()
   @ weapon_data()
*/
stock house_data(){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `house_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("집 DB 정상");
	else{
        print("집 DB 에러 테이블 생성 리로드");
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
		cache_get_field_content(i, "NAME", HOUSE[i][NAME], mysql, 24);
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
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `vehicle_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("차량 DB 정상");
	else{
        print("차량 DB 에러 테이블 생성 리로드");
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
		cache_get_field_content(i, "NAME", VEHICLE[i+1][NAME], mysql, 24);
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
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `clan_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("클랜 DB 정상");
	else{
        print("클랜 DB 에러 테이블 생성 리로드");
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
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `zone_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("갱존 DB 정상");
	else{
        print("갱존 DB 에러 테이블 생성 리로드");
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
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `weapon_info`");
	mysql_query(mysql, query);
	if(!mysql_errno(mysql))print("총기 DB 정상");
	else{
      mysql_format(mysql, query, sizeof(query), SQL_WEAPON_TABLE);
      mysql_query(mysql, query);
      weapon_data();
    }
}

/* SERVER THREAD*/
public ServerThread(){
    foreach (new i : Player){
	    event(i);
	    checkZone(i);
    }
}

/* stock
   @ zoneInit()
   @ zoneSave(id, owner_clan)
   @ vehicleInit()
   @ vehicleSave(vehicleid)
   @ vehicleSapwn(vehicleid)
   @ zoneSetup()
   @ showZone(playerid)
   @ vehicleBuy(playerid, carid)
   @ showRank(playerid)
   @ showTextDraw(playerid)
   @ fixPos(playerid)
   @ event(playerid)
   @ giveMoney(playerid,money)
   @ death(playerid, killerid, reason)
   @ killCombo(playerid)
   @ loadMisson()
   @ missonInit(name[24],Float:pos_x,Float:pos_y,Float:pos_z)
   @ object_init()
   @ textLabel_init()
   @ textDraw_init();
   @ searchMissonRange(playerid)
   @ searchGarageRange(playerid)
   @ showMisson(playerid, type)
   @ showGarage(playerid)
   @ showDialog(playerid, type)
   @ isPlayerZone(playerid, zoneid)
   @ checkZone(playerid)
   @ holdZone(playerid)
   @ isDeagle(playerid)
   @ isEmptyWep(playerid, listitem)
   @ isBuyWepMoney(weponid, money)
   @ isHoldWep(playerid, model)
   @ isClan(playerid, type)
   @ isClanHangul(playerid, str[])
   @ randomColor()
   @ getPlayerId(name[]
   @ wepID(model)
   @ wepName(model)
   @ syncWep(playerid)
   @ sync(playerid)
   @ kdRatio(kill, death)
   @ kdTier(kill, death)
*/

stock vehicleInit(){
	printf("차량 데이터 초기화 실행");
	for(new vehicleid=1; vehicleid<USED_VEHICLE; vehicleid++){
	    GetVehiclePos(vehicleid, VEHICLE[vehicleid][POS_X], VEHICLE[vehicleid][POS_Y], VEHICLE[vehicleid][POS_Z]);
	    GetVehicleZAngle(vehicleid, VEHICLE[vehicleid][ANGLE]);
		new query[400],sql[400];
		strcat(sql, "INSERT INTO `vehicle_info`");
		strcat(sql, " (NAME, POS_X, POS_Y, POS_Z, ANGLE, COLOR1, COLOR2)");
		strcat(sql, " VALUES ('N', %f, %f, %f, %f, 0, 0)");
		mysql_format(mysql, query, sizeof(query), sql,
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
	printf("갱존 데이터 초기화 실행");
	for(new i = 0; i < USED_ZONE; i++){
	    mysql_format(mysql, query, sizeof(query), "INSERT INTO `zone_info` (OWNER_CLAN) VALUES (%d)",-1);
        mysql_query(mysql, query);
        printf("%d/%d",i,USED_ZONE);
	}
}

stock zoneSave(id, owner_clan){
	new query[400];
    mysql_format(mysql, query, sizeof(query), "UPDATE `zone_info` SET `OWNER_CLAN` = %d WHERE `ID` = %d",owner_clan, id);
    mysql_query(mysql, query);
}
stock vehicleSave(vehicleid){
	    GetVehiclePos(vehicleid, VEHICLE[vehicleid][POS_X], VEHICLE[vehicleid][POS_Y], VEHICLE[vehicleid][POS_Z]);
	    GetVehicleZAngle(vehicleid, VEHICLE[vehicleid][ANGLE]);
		new query[400],sql[400];
		strcat(sql, "UPDATE `vehicle_info`");
		strcat(sql, " SET POS_X = %f, POS_Y = %f, POS_Z = %f, ANGLE = %f WHERE ID = %d");
		mysql_format(mysql, query, sizeof(query), sql,
		VEHICLE[vehicleid][POS_X],
		VEHICLE[vehicleid][POS_Y],
		VEHICLE[vehicleid][POS_Z],
		VEHICLE[vehicleid][ANGLE],
		vehicleid
		);
		mysql_query(mysql, query);
}
public vehicleSapwn(vehicleid){
    SetVehiclePos(vehicleid, VEHICLE[vehicleid][POS_X], VEHICLE[vehicleid][POS_Y], VEHICLE[vehicleid][POS_Z]);
    SetVehicleZAngle(vehicleid, VEHICLE[vehicleid][ANGLE]);
    ChangeVehicleColor(vehicleid, VEHICLE[vehicleid][COLOR1], VEHICLE[vehicleid][COLOR2]);
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
}

stock showZone(playerid){
	new zoneCol[2] = { 0xFFFFFF99, 0xAFAFAF99};
	new flag = 0, flag2 = 0, tick = 0;

	new query[400];
    mysql_format(mysql, query, sizeof(query), "SELECT OWNER_CLAN From `zone_info`");
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
	return 0;
}

stock vehicleBuy(playerid, vehicleid){
    new query[400],sql[400];
    new model = GetVehicleModel(vehicleid);
    
    format(VEHICLE[vehicleid][NAME], 24, "%s",USER[playerid][NAME]);
    formatMsg(playerid, COL_SYS, "    당신은 [%s] 차량을 구매하였습니다.", vehicleName[model - 400]);
    
	strcat(sql, "UPDATE `vehicle_info`");
	strcat(sql, " SET NAME = '%s' WHERE ID = %d");
	mysql_format(mysql, query, sizeof(query), sql,
	USER[playerid][NAME],
    vehicleid
	);
	mysql_query(mysql, query);
}
stock showRank(playerid){
	new str[50];
    format(str, sizeof(str),"[LV.%d %s{7FFF00}]",USER[playerid][LEVEL], kdTier(USER[playerid][KILLS],USER[playerid][DEATHS]));
    SetPlayerChatBubble(playerid, str, 0x7FFF00FF, 14.0, 10000);
}

stock showTextDraw(playerid){
    TextDrawShowForPlayer(playerid, TDrawG[0][ID]);
    TextDrawShowForPlayer(playerid, TDrawG[1][ID]);
    TextDrawShowForPlayer(playerid, TDrawG[2][ID]);
    
    TextDrawShowForPlayer(playerid, TDraw[playerid][ZONETEXT]);
    TextDrawShowForPlayer(playerid, TDraw[playerid][CP]);
}
stock isPlayerZone(playerid, zoneid){
    new	Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(x > ZONE[zoneid][MIN_X] && x < ZONE[zoneid][MAX_X] && y > ZONE[zoneid][MIN_Y] && y < ZONE[zoneid][MAX_Y])return 1;
    
    return 0;
}

stock checkZone(playerid){
	for(new z = 0; z < USED_ZONE; z++){
        if(isPlayerZone(playerid, z)){
            if(z == 714){
                TextDrawSetString(TDraw[playerid][CP], "~g~~h~NOT DEATH MATCH ZONE");
			    return 0;
			}
			if(INGAME[playerid][ENTER_ZONE] == z){
				if(ZONE[z][OWNER_CLAN] == USER[playerid][CLANID]){
                    new str[120];
                    format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d ~r~~h~- CP : ~w~CLAN HAVED",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN]);
                    TextDrawSetString(TDraw[playerid][CP],str);
				    return 0;
				}
				
				ZONE[z][STAY_CLAN] = 0;
				for(new i=0; i < USED_CLAN; i++)if(CLAN_CP[z][i][INDEX])ZONE[z][STAY_CLAN] +=1;
				
				if(ZONE[z][STAY_CLAN] > 1){
				    new str[120];
				    format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d ~r~~h~- ~w~BATTLE ~r~~h~ IN ZONE CLAN LENGTH : ~w~%d",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN], ZONE[z][STAY_CLAN]);
				    TextDrawSetString(TDraw[playerid][CP],str);
				    return 0;
				}
				
				tickZone(playerid);
			    return 0;
			}

			if(INGAME[playerid][ENTER_ZONE]) ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN] -=1;
			ZONE[z][STAY_HUMAN]+=1;
			
			if(INGAME[playerid][ENTER_ZONE]){
				CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX]-=1;
                if(CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][INDEX] == 0)CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] = 0;
			}
            CLAN_CP[z][USER[playerid][CLANID]][INDEX]+=1;
			
            INGAME[playerid][ENTER_ZONE] = z;
			INGAME[playerid][ZONE_TICK] = 0;
        }
	}
	
	return 0;
}

stock tickZone(playerid){

    if(USER[playerid][CLANID])INGAME[playerid][ZONE_TICK] +=1;

    if(INGAME[playerid][ZONE_TICK] == 2){
        INGAME[playerid][ZONE_TICK] = 0;

        CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] +=1;

        if(CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] > 80)PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
        if(CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] == 100){
			holdZone(playerid);
            CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP] = 0;
        }
    }
    
	new str[120];
	if(!USER[playerid][CLANID])format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN]);
	else format(str,sizeof(str),"~r~~h~%d ZONE IN ~w~HUMAN %d ~r~~h~- CP : ~w~%d%",INGAME[playerid][ENTER_ZONE], ZONE[INGAME[playerid][ENTER_ZONE]][STAY_HUMAN], CLAN_CP[INGAME[playerid][ENTER_ZONE]][USER[playerid][CLANID]][CP]);
	TextDrawSetString(TDraw[playerid][CP],str);
}
stock holdZone(playerid){
	new zoneid = INGAME[playerid][ENTER_ZONE];
    if(ZONE[zoneid][OWNER_CLAN] == USER[playerid][CLANID])return 0;
    
    new zoneOwner;
    new query[400];
    
    if(ZONE[zoneid][OWNER_CLAN] == -1)zoneOwner = ZONE[zoneid][OWNER_CLAN]+1;
	else zoneOwner = ZONE[zoneid][OWNER_CLAN]-1;
	
	if(ZONE[zoneid][OWNER_CLAN] != -1){
        CLAN[zoneOwner][ZONE_LENGTH] -=1;
        mysql_format(mysql, query, sizeof(query), "UPDATE `clan_info` SET `ZONE_LENGTH` = %d WHERE `ID` = %d", CLAN[zoneOwner][ZONE_LENGTH], zoneOwner);
        mysql_query(mysql, query);
	}
	
    CLAN[USER[playerid][CLANID]-1][ZONE_LENGTH] +=1;
    mysql_format(mysql, query, sizeof(query), "UPDATE `clan_info` SET `ZONE_LENGTH` = %d WHERE `ID` = %d", CLAN[USER[playerid][CLANID]-1][ZONE_LENGTH], USER[playerid][CLANID]);
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
		case 20:{
            showRank(playerid);
            INGAME[playerid][EVENT_TICK] = 0;
		}
    }
}

stock giveMoney(playerid,money){
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, USER[playerid][MONEY]+=money);
	formatMsg(playerid, COL_SYS,"%d원",money);
}

stock death(playerid, killerid, reason){
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    CreateExplosion(x, y, z, 16, 32.0);
    CreateExplosion(x, y, z+10, 0, 0.1);

	fixPos(playerid);
	USER[playerid][POS_X]   = INGAME[playerid][SPAWN_POS_X];
 	USER[playerid][POS_Y]   = INGAME[playerid][SPAWN_POS_Y];
	USER[playerid][POS_Z]   = INGAME[playerid][SPAWN_POS_Y];
	USER[playerid][ANGLE]   = INGAME[playerid][SPAWN_ANGLE];
	USER[playerid][DEATHS] += 1;
	USER[playerid][HP]      = 100.0;
	USER[playerid][AM]      = 100.0;

    for(new i=0; i < INGAME[playerid][COMBO]; i++){
        TextDrawHideForPlayer(playerid, TDrawG[i][COMBO]);
    }
    INGAME[playerid][COMBO] = 0;

	spawn(playerid);
	if(reason == 255) return 1;
    SendDeathMessage(killerid, playerid, reason);
	new str[128];
	format(str, sizeof(str), "~y~You got killed by ~r~%s", USER[killerid][NAME]);
    GameTextForPlayer( playerid, str, 3000, 1 );
    
	USER[killerid][KILLS] += 1;
	giveMoney(killerid, 500);
    save(killerid);

	if(INGAME[killerid][COMBO] < 10){
        TextDrawShowForPlayer(killerid, TDrawG[INGAME[killerid][COMBO]][COMBO]);
        INGAME[killerid][COMBO]+=1;
    }
    killCombo(killerid);
    
	return 1;
}

stock killCombo(playerid){
	new str[50];
	format(str, sizeof(str), "~r~~>~~y~%s~r~~<~",comboText[INGAME[playerid][COMBO]]);
	GameTextForPlayer(playerid, str, 2500, 6);
}

stock loadGarage(){
    garageInit("남부 주유소",1936.2174,-1774.7317,13.0537);
    garageInit("남부 주유소 2층",1941.7302,-1772.3066,19.5250);
    garageInit("카워셔 정비소",2454.6113,-1461.0303,23.7785);
    garageInit("북부 주유소",1002.5181,-941.1222,41.8907);
    garageInit("플린트 카운티 주유소",-91.1692,-1169.8002,2.1782);
}
stock loadMisson(){
	missonInit("대한 전쟁 협회",1910.2273,-1714.3197,13.3307);
	missonInit("카푸치노 상점",1909.9907,-1707.3611,13.3251);
	missonInit("만남의 광장",1909.9747,-1700.0070,13.3236);
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
	CreateObject(1504, 1909.60229, -1713.55371, 12.30253,   0.00000, 0.00000, 269.91336);
	CreateObject(1505, 1909.58008, -1708.08728, 12.14866,   0.00000, 0.00000, 89.91272);
	CreateObject(1507, 1909.53870, -1699.33984, 12.30817,   0.00000, 0.00000, 269.92120);
}

stock textLabel_init(){

	for(new i = 0;i<USED_GARAGE;i++){
		new str[60];
		format(str, sizeof(str),"%s (경적(Caps Lock))",GARAGE[i][NAME]);
		Create3DTextLabel(str, 0x8D8DFFFF, GARAGE[i][POS_X], GARAGE[i][POS_Y], GARAGE[i][POS_Z], 25.0, 0, 1);
	}
	
	for(new i = 0;i<USED_MISSON;i++){
		new str[40];
		format(str, sizeof(str),"%s (F키)",MISSON[i][NAME]);
		Create3DTextLabel(str, 0x8D8DFFFF, MISSON[i][POS_X], MISSON[i][POS_Y], MISSON[i][POS_Z], 7.0, 0, 1);
	}
}

stock textDraw_init(){
    TDrawG[0][ID] = TextDrawCreate(20.000000,428.000000,"SA:MP KOREA ~b~~h~WAR~w~ Server");
	TextDrawAlignment(TDrawG[0][ID],0);
	TextDrawBackgroundColor(TDrawG[0][ID],0x000000ff);
	TextDrawFont(TDrawG[0][ID],2);
	TextDrawLetterSize(TDrawG[0][ID],0.199999,0.899999);
	TextDrawColor(TDrawG[0][ID],0xffffffff);
	TextDrawSetOutline(TDrawG[0][ID],1);
	TextDrawSetProportional(TDrawG[0][ID],1);
	TextDrawSetShadow(TDrawG[0][ID],1);
	
    TDrawG[1][ID] = TextDrawCreate(-0.500, 436.000, "LD_PLAN:tvbase");
    TextDrawFont(TDrawG[1][ID], 4);
    TextDrawTextSize(TDrawG[1][ID], 641.500, 13.000);
    TextDrawColor(TDrawG[1][ID], -1);

	TDrawG[2][ID] = TextDrawCreate(520,438.000,"~b~~h~S~w~hot:");
	TextDrawLetterSize(TDrawG[2][ID],0.199999,0.899999);
	TextDrawFont(TDrawG[2][ID],1);
	TextDrawSetOutline(TDrawG[2][ID],1);

    for(new i = 0; i <= GetMaxPlayers(); i++){
		TDraw[i][ZONETEXT] = TextDrawCreate(1,438.000,"NAME :       LEVEL :       EXP :       MONEY :       KILLS :       DEATHS :");
		TextDrawLetterSize(TDraw[i][ZONETEXT], 0.199999,0.899999);
		TextDrawFont(TDraw[i][ZONETEXT], 1);
		TextDrawSetOutline(TDraw[i][ZONETEXT],1);

		TDraw[i][CP] = TextDrawCreate(302.500, 2.500,"~r~~h~NEAR ZONE IN ~w~HUMAN 6 ~r~~h~- CP : ~w~00%");
		TextDrawAlignment(TDraw[i][CP],0);
		TextDrawBackgroundColor(TDraw[i][CP],0x000000ff);
		TextDrawFont(TDraw[i][CP],2);
		TextDrawLetterSize(TDraw[i][CP],0.199999,0.899999);
		TextDrawColor(TDraw[i][CP],0xffffffff);
		TextDrawSetOutline(TDraw[i][CP],1);
		TextDrawSetProportional(TDraw[i][CP],1);
		TextDrawSetShadow(TDraw[i][CP],1);
    }

	new comboWidth = 540;
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
		case 0: ShowPlayerDialog(playerid, DL_MISSON_CLAN, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}클랜 생성\n클랜 목록\n클랜 랭킹\n클랜 정보\n클랜 탈퇴","확인", "닫기");
		case 1: ShowPlayerDialog(playerid, DL_MISSON_SHOP, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}무기\n스킨\n악세사리\n닉네임 변경","확인", "닫기");
		case 2: ShowPlayerDialog(playerid, DL_MISSON_NOTICE, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}시즌 랭킹","확인", "닫기");
	}
    ClearAnimations(playerid);
	return 1;
}

stock showGarage(playerid){
	showDialog(playerid, DL_GARAGE);
	
}

stock showDialog(playerid, type){
    switch(type){
        case DL_LOGIN : ShowPlayerDialog(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, "{FFFFFF}로그인을 해주세요", DIALOG_ENTER, "나가기");
        case DL_REGIST : ShowPlayerDialog(playerid, DL_REGIST, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, "{FFFFFF}회원가입을 해주세요.", DIALOG_ENTER, "나가기");

        case DL_INFO  : ShowPlayerDialog(playerid, DL_INFO, DIALOG_STYLE_LIST, DIALOG_TITLE, "서버 규정\n내 프로필\n문의\n", DIALOG_ENTER, DIALOG_PREV);
        case DL_MYWEP :{
            new str[256];
            strcat(str, "{FFFFFF}");
		    for(new i=0; i < INGAME[playerid][WEPBAG_INDEX]; i++){
				new temp[20];
                format(temp, sizeof(temp), "%s\n", wepName(WEPBAG[playerid][i][MODEL]));
                strcat(str, temp);
			}
			
		    ShowPlayerDialog(playerid, DL_MYWEP, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_MYCAR :{
            new query[400], sql[400], str[600];

            strcat(sql,"SELECT ID");
            strcat(sql," FROM `vehicle_info` ");
            strcat(sql," WHERE NAME='%s'");

			mysql_format(mysql, query, sizeof(query), sql, USER[playerid][NAME]);
			mysql_query(mysql, query);

			new rows, fields;
			cache_get_data(rows, fields);
			strcat(str, "{FFFFFF}");

		    for(new i=0; i < rows; i++){
                new temp[60];
                
				new vehicleid = cache_get_field_content_int(i, "ID");
                CARBAG[playerid][i][ID] = vehicleid;
                
                new model = GetVehicleModel(vehicleid);

				format(temp, sizeof(temp), "번호판 : %d번\t\t모델명 : %s\n\n", vehicleid, vehicleName[model - 400]);
                strcat(str, temp);
		    }
		    
            ShowPlayerDialog(playerid, DL_MYCAR, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_GARAGE :ShowPlayerDialog(playerid, DL_GARAGE, DIALOG_STYLE_LIST, DIALOG_TITLE, "수리\n도색\n튜닝", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_LIST :{
            new query[400], sql[400], str[1286];

            strcat(sql,"SELECT NAME");
            strcat(sql," FROM `clan_info` ");
            strcat(sql," LIMIT 10");

			mysql_format(mysql, query, sizeof(query), sql);
			mysql_query(mysql, query);

			new rows, fields;
			cache_get_data(rows, fields);
			strcat(str, "{8D8DFF}\t\t클랜 목록{FFFFFF}\n\n");

		    for(new i=0; i < rows; i++){
                new temp[128], name[24];

				cache_get_field_content(i, "NAME", name, mysql, 24);

				format(temp, sizeof(temp), "클랜이름 \t\t {%06x}%s{FFFFFF}\n\n", CLAN[i][COLOR] >>> 8, name);
                strcat(str, temp);
		    }
		    
            ShowPlayerDialog(playerid, DL_CLAN_LIST, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_RANK :{
            new query[400], sql[400], str[1286];

            strcat(sql,"SELECT NAME, ZONE_LENGTH");
            strcat(sql," FROM `clan_info` ");
            strcat(sql," ORDER BY ZONE_LENGTH DESC LIMIT 10");

			mysql_format(mysql, query, sizeof(query), sql);
			mysql_query(mysql, query);

			new rows, fields;
			cache_get_data(rows, fields);
			strcat(str, "{8D8DFF}\t\t클랜 랭킹{FFFFFF}\n\n");

		    for(new i=0; i < rows; i++){
                new temp[128], name[24];

				cache_get_field_content(i, "NAME", name, mysql, 24);

				format(temp, sizeof(temp), "%d위 \t 총 점령구역 : %d\t\t{%06x}%s{FFFFFF}\n\n", i+1, cache_get_field_content_int(i, "ZONE_LENGTH"), CLAN[i][COLOR] >>> 8, name);
                strcat(str, temp);
		    }
		    
            ShowPlayerDialog(playerid, DL_CLAN_RANK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_SETUP :{
            if(isClan(playerid, IS_CLEN_NOT)) return 0;
            
		    ShowPlayerDialog(playerid, DL_CLAN_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}클랜원 초대\n클랜원 목록", DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_LEAVE :{
            if(isClan(playerid, IS_CLEN_NOT)) return 0;
            if(isClan(playerid, IS_CLEN_LEADER)) return 0;
		    ShowPlayerDialog(playerid, DL_CLAN_LEAVE, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}정말로 클랜을 탈퇴하시겠습니까?", DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_INSERT :{
            if(isClan(playerid, IS_CLEN_HAVE)) return 0;
            
		    ShowPlayerDialog(playerid, DL_CLAN_INSERT, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}클랜명을 입력해주세요.", DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_INSERT_COLOR : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}랜덤색보기", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT_COLOR_RANDOM :{
            new str[256];
            format(str, sizeof(str),"{%06x}색상 :\t\t%s\n\n{FFFFFF}랜덤으로 색을 뽑아붑니다.", CLAN_SETUP[playerid][COLOR] >>> 8, CLAN_SETUP[playerid][NAME]);
		    ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR_RANDOM, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_PREV, DIALOG_ENTER);
		}
//        case DL_CLAN_INSERT_COLOR_CHOICE : ShowPlayerDialog(playerid, DL_CLAN_INSERT_COLOR_CHOICE, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}클랜 색상을 지정해주세요.", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT_SUCCESS :{
            new str[256];
            format(str, sizeof(str),"{FFFFFF}클랜 명 :\t\t%s\n\n클랜 색상 : \t\t{%06x}%06x{FFFFFF}\n\n위 조건으로 클랜을 창설하시겠습니까?\n\n(차감액 : 20000원)", CLAN_SETUP[playerid][NAME],CLAN_SETUP[playerid][COLOR] >>> 8, CLAN_SETUP[playerid][COLOR] >>> 8);
            ShowPlayerDialog(playerid, DL_CLAN_INSERT_SUCCESS, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}

        case DL_CLAN_SETUP_INVITE :{
            if(isClan(playerid, IS_CLEN_LEADER)) return 0;
		    ShowPlayerDialog(playerid, DL_CLAN_SETUP_INVITE, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}초대하실분의 닉네임을 입력해주세요.", DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_SETUP_MEMBER :{
			new query[400], sql[400], str[256];
			
			strcat(sql, "SELECT ID , NAME, LEVEL, KILLS, DEATHS");
			strcat(sql, " FROM`user_info`");
			strcat(sql, " WHERE CLANID = %d");
			
			mysql_format(mysql, query, sizeof(query), sql,USER[playerid][CLANID]);
			mysql_query(mysql, query);

			new rows, fields;
			cache_get_data(rows, fields);
			strcat(str, "{FFFFFF}");
			
		    for(new i=0; i < rows; i++){
                new temp[128], name[24];
                
				cache_get_field_content(i, "NAME", name, mysql, 24);
				
				format(temp, sizeof(temp), "이름 : %20s\t\t레벨 %d\t킬 - %d 데쓰 - %d K/D - %.01f% 랭크 - %s\n{FFFFFF}",
					name,
					cache_get_field_content_int(i, "LEVEL"),
					cache_get_field_content_int(i, "KILLS"),
					cache_get_field_content_int(i, "DEATHS"),
					kdRatio(cache_get_field_content_int(i, "KILLS"), cache_get_field_content_int(i, "DEATHS")),
					kdTier(cache_get_field_content_int(i, "KILLS"),  cache_get_field_content_int(i, "DEATHS")));
                strcat(str, temp);
		    }

		    ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_CLAN_SETUP_MEMBER_SETUP :{
            if(isClan(playerid, IS_CLEN_LEADER)) return 0;
            ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}직위 변경\n강제 추방", DIALOG_ENTER, DIALOG_PREV);
		}
        case DL_CLAN_SETUP_MEMBER_SETUP_RANK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}1등급\n2등급\n3등급", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP_KICK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}정말로 추방하시겠습니까?", DIALOG_ENTER, DIALOG_PREV);

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
		case DL_SHOP_SKIN : ShowPlayerDialog(playerid, DL_SHOP_SKIN, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF} 변경하실 스킨번호를 입력해주세요.", DIALOG_ENTER, DIALOG_PREV);
		case DL_SHOP_ACC : ShowPlayerDialog(playerid, DL_SHOP_ACC, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}모자\n마스크", DIALOG_ENTER, DIALOG_PREV);
		case DL_SHOP_NAME : ShowPlayerDialog(playerid, DL_SHOP_NAME, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF} 변경하실 닉네임을 입력해주세요.", DIALOG_ENTER, DIALOG_PREV);
		case DL_SHOP_WEAPON_BUY : {
            new str[256];
            format(str, sizeof(str),"{FFFFFF}무기 모델명 :\t\t%s\n\n해당 무기를 정말로 구매하시겠습니까?\n\n(차감액 : %d원)", wepName(INGAME[playerid][BUY_WEAPONID]), wepPrice(INGAME[playerid][BUY_WEAPONID]));
            ShowPlayerDialog(playerid, DL_SHOP_WEAPON_BUY, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_SHOP_SKIN_BUY : {
            new str[256];
            format(str, sizeof(str),"{FFFFFF}스킨 번호 :\t\t%d\n\n해당 스킨을 정말로 구매하시겠습니까?\n\n(차감액 : 5000원)", INGAME[playerid][BUY_SKINID]);
            ShowPlayerDialog(playerid, DL_SHOP_SKIN_BUY, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_SHOP_NAME_EDIT : {
            new str[256];
            format(str, sizeof(str),"{FFFFFF}변경하실 닉네임 :\t\t%s\n\n해당 닉네임으로 정말로 변경하시겠습니까?\n\n(차감액 : 20000원)", INGAME[playerid][EDIT_NAME]);
            ShowPlayerDialog(playerid, DL_SHOP_NAME_EDIT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_NOTICE_SEASON :{
            new query[400], sql[400], str[1286];
            
			switch(INGAME[playerid][SEASON]){
				case 0:{
		            strcat(sql,"SELECT ID , NAME, LEVEL, KILLS, DEATHS ");
		            strcat(sql," FROM `user_info` ");
		            strcat(sql," ORDER BY LEVEL DESC LIMIT 10");
		            strcat(str, "{8D8DFF}\t\t샘프워 레벨 랭킹 - 총 10인{FFFFFF}\n\n");
	            }
	            case 1:{
		            strcat(sql,"SELECT ID , NAME, LEVEL, KILLS, DEATHS ");
		            strcat(sql," FROM `user_info` ");
		            strcat(sql," ORDER BY LEVEL DESC LIMIT 10");
		            strcat(str, "{8D8DFF}\t\t샘프워 최다킬수 랭킹 - 총 10인{FFFFFF}\n\n");
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

				format(temp, sizeof(temp), "%d위\t\t이름 : %s\t레벨 : %d\t킬 : %d 데쓰 : %d K/D %.01f% 랭크 %s{FFFFFF}\n\n",
					i+1,
					name,
					cache_get_field_content_int(i, "LEVEL"),
					cache_get_field_content_int(i, "KILLS"),
					cache_get_field_content_int(i, "DEATHS"),
					kdRatio(cache_get_field_content_int(i, "KILLS"), cache_get_field_content_int(i, "DEATHS")),
					kdTier(cache_get_field_content_int(i, "KILLS"),  cache_get_field_content_int(i, "DEATHS")));
                strcat(str, temp);
		    }
		    
            ShowPlayerDialog(playerid, DL_NOTICE_SEASON, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
		case DL_MYWEP_SETUP :{
			new str[256], temp[50];
			new slot[20] = {"주무기 슬롯"};
			new none[20] = {"(비어있음)"};

			strcat(str, "{FFFFFF}");
			/* HACK : 추후 코드리펙 : pawno enum에 배열 선언 불가? */
			strcat(str, slot);
			if(!USER[playerid][WEP1]) format(temp, sizeof(temp), "1\t\t%s\n", none);
			else format(temp, sizeof(temp), "1\t\t(%s)\n", wepName(USER[playerid][WEP1]));
            strcat(str, temp);

			strcat(str, slot);
			if(!USER[playerid][WEP2]) format(temp, sizeof(temp), "2\t\t%s\n", none);
			else format(temp, sizeof(temp), "2\t\t(%s)\n", wepName(USER[playerid][WEP2]));
            strcat(str, temp);
            
			strcat(str, slot);
			if(!USER[playerid][WEP3]) format(temp, sizeof(temp), "3\t\t%s\n", none);
			else format(temp, sizeof(temp), "3\t\t(%s)\n", wepName(USER[playerid][WEP3]));
			strcat(str, temp);
			
		    ShowPlayerDialog(playerid, DL_MYWEP_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
        }
        case DL_MYWEP_SETUP_OPTION : ShowPlayerDialog(playerid, DL_MYWEP_SETUP_OPTION, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}장착\n탈착\n", DIALOG_ENTER, DIALOG_PREV);
		case DL_MYWEP_SETUP_HOLD   :{
            new str[256];
            format(str, sizeof(str),"{FFFFFF}%d번 슬롯 :\t\t%s\n\n선택하신 무기를 정말로 장착하시겠습니까?\n", INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));
		    ShowPlayerDialog(playerid, DL_MYWEP_SETUP_HOLD, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_MYWEP_SETUP_PUT    :{
            new str[256];
            format(str, sizeof(str),"{FFFFFF}%d번 슬롯 :\t\t%s\n\n선택하신 무기를 정말로 탈착하시겠습니까?\n", INGAME[playerid][HOLD_WEPLIST]+1, wepName(INGAME[playerid][HOLD_WEPID]));
		    ShowPlayerDialog(playerid, DL_MYWEP_SETUP_PUT, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_MYCAR_SETUP : ShowPlayerDialog(playerid, DL_MYCAR_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}소환", DIALOG_ENTER, DIALOG_PREV);
		case DL_MYCAR_SETUP_SPAWN :{
	        new str[256];
            new model = GetVehicleModel(INGAME[playerid][HOLD_CARID]);
	        format(str, sizeof(str),"{FFFFFF}차량 모델명 :\t\t%s\n\n해당 차량을 정말로 소환하시겠습니까?\n\n(차감액 : 2000원)",vehicleName[model - 400]);
	        ShowPlayerDialog(playerid, DL_MYCAR_SETUP_SPAWN, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, str, DIALOG_ENTER, DIALOG_PREV);
		}
		case DL_GARAGE_REPAIR  : ShowPlayerDialog(playerid, DL_GARAGE_REPAIR, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}탑승하신 차량을 정말로 소환하시겠습니까?\n\n(차감액 : 100원)", DIALOG_ENTER, DIALOG_PREV);
		case DL_GARAGE_PAINT   : ShowPlayerDialog(playerid, DL_GARAGE_PAINT, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}컬러1\n컬러2\n페인트잡", DIALOG_ENTER, DIALOG_PREV);
		case DL_GARAGE_TURNING : ShowPlayerDialog(playerid, DL_GARAGE_TURNING, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}휠\n본넷\n범퍼", DIALOG_ENTER, DIALOG_PREV);
    }
    return 1;
}
/* HACK : 추후 코드리펙 : pawno enum에 배열 선언 불가? */
stock isHoldWep(playerid, model){
	if(USER[playerid][WEP1] == model ||
       USER[playerid][WEP2] == model ||
       USER[playerid][WEP3] == model) return SendClientMessage(playerid,COL_SYS,"    이미 주무기로 설정하신 무기입니다.");
	return 0;
}

stock isDeagle(playerid){
    for(new i=0; i < INGAME[playerid][WEPBAG_INDEX]; i++){
	    if(WEPBAG[playerid][i][MODEL] == 24)return 1;
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
		case IS_CLEN_HAVE   : if(USER[playerid][CLANID] != 0) return SendClientMessage(playerid,COL_SYS,"    당신은 이미 클랜에 소속되어 있습니다.");
		case IS_CLEN_NOT    : if(USER[playerid][CLANID] == 0)return SendClientMessage(playerid,COL_SYS,"    당신은 클랜에 소속되어 있지 않습니다.");
		case IS_CLEN_LEADER : if(USER[playerid][NAME] != CLAN[USER[playerid][CLANID]-1][LEADER_NAME])return SendClientMessage(playerid,COL_SYS,"    클랜 리더가 아닙니다.");
        case IS_CLEN_INSERT_MONEY   : if(USER[playerid][MONEY] < 20000) return SendClientMessage(playerid,COL_SYS,"    클랜을 창설할 만큼의 자금이 부족합니다.");
	}
    return 0;
}

stock isClanHangul(playerid, str[]){
    for (new i=0, j=strlen(str); i<j; i++){
        if((str[i] < 'a' || str[i] > 'z') && (str[i] < 'A' || str[i] > 'Z'))
        if(str[i] > '9' || str[i] < '0')return SendClientMessage(playerid,COL_SYS,"    클랜명에 한글이 포함되어 있습니다.");
    }
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
stock getPlayerId(name[]){
  for(new i = 0; i <= GetMaxPlayers(); i++){
    if(IsPlayerConnected(i)){
      if(strcmp(USER[i][NAME], name, true, strlen(name)) == 0)return i;
    }
  }
  return INVALID_PLAYER_ID;
}

stock wepID(model){
	new wep;
    switch(model){
        case 24 : wep = 0;
        case 25 : wep = 1;
        case 26 : wep = 2;
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
		case 26 : format(wep, sizeof(wep), "%s", wepModel[2]);
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

stock wepPrice(model){
	new price;
    switch(model){
        case 24 : price = 10000;
        case 25 : price = 10000;
        case 26 : price = 10000;
        case 27 : price = 10000;
        case 28 : price = 60000;
        case 29 : price = 10000;
        case 30 : price = 10000;
        case 31 : price = 30000;
        case 32 : price = 10000;
        case 33 : price = 10000;
        case 34 : price = 50000;
	}
	return price;
}

stock syncWep(playerid){
    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid, USER[playerid][WEP1], 9999);
    GivePlayerWeapon(playerid, USER[playerid][WEP2], 9999);
    GivePlayerWeapon(playerid, USER[playerid][WEP3], 9999);
    
    if(!isDeagle(playerid) && USER[playerid][LEVEL] < 10)GivePlayerWeapon(playerid, 24, 500);
}

stock sync(playerid){
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
    SetPlayerArmedWeapon(playerid, 0);
	INGAME[playerid][SYNC] = false;
}

public Float:kdRatio(kill, death){
    return float(kill*100) / float(kill+death);
}

stock kdTier(kill, death){
    new rank[30];
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
    return rank;
}
