#include <a_samp>
#include <a_mysql>
#include <foreach>

#define DL_LOGIN    100
#define DL_REGIST   101
#define DL_INFO     103
#define DL_MENU     104

#define DL_MISSON_CLEN     200
#define DL_MISSON_ITEM     201
#define DL_MISSON_CAR      202

#define DL_CLAN_INSERT    300
#define DL_CLAN_LIST      301
#define DL_CLAN_RANK      302
#define DL_CLAN_SETUP     303
#define DL_CLAN_DELETE    304

#define DL_CLAN_SETUP_INVITE 3030
#define DL_CLAN_SETUP_MEMBER 3031

#define DL_CLAN_SETUP_MEMBER_SETUP 30310
#define DL_CLAN_SETUP_MEMBER_SETUP_RANK 30311
#define DL_CLAN_SETUP_MEMBER_SETUP_KICK 30312

#define COL_SYS  0xAFAFAF99
#define DIALOG_TITLE "{8D8DFF}샘프워코리아"
#define DIALOG_ENTER "확인"
#define DIALOG_PREV "뒤로"

/*ZONE BASE */
#define USED_ZONE 932
#define USED_VEHICLE 500
#define USED_HOUSE 500
#define USED_CLAN 500

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

main(){}

forward check(playerid);
forward regist(playerid, pass[]);
forward save(playerid);
forward load(playerid);
forward ServerThread();

/* variable */
new infoMessege[3][502] = {
	"{8D8DFF}모드설명{FFFFFF}\n\n샘프워 코리아 모드입니다.\n세력을 넑혀가는 갱전쟁 형식의 모드입니다.\n\n{8D8DFF}게임방법{FFFFFF}\n\n샘프워코리아 전쟁 규정을 따릅니다.",
	"{8D8DFF}프로필란{FFFFFF}\n\n이름\t\t%s\n클랜\t\t%d\n레벨\t\t%d\n경험치\t\t%d\n머니\t\t%d\n사살\t\t%d\n죽음\t\t%d",
	"{FFFFFF}github.com/u4bi\n하이오"
};

new Float:SPAWN_MODEL[54][3] = {
{966.1048,-989.9128,37.2340},
{962.3964,-1116.9700,23.2486},
{950.3869,-1300.3815,13.6064},
{920.7906,-1455.4015,12.9489},
{924.9973,-1625.6708,13.1147},
{927.0760,-1721.5812,13.1130},
{971.6392,-1783.2766,13.6663},
{1055.4865,-1827.3129,13.1389},
{1156.0485,-1842.3470,13.1321},
{1290.2769,-1654.4058,13.1165},
{1339.3270,-1405.3234,12.8955},
{1342.7333,-1144.6208,23.0736},
{1455.6702,-931.4559,36.4865},
{1731.4502,-996.1880,37.0469},
{2003.4839,-997.8493,30.4699},
{2167.6299,-1008.4839,62.3470},
{2318.4614,-1081.1084,48.7639},
{2478.3054,-1041.4218,65.4280},
{2559.4429,-1046.9205,68.9830},
{2639.7302,-1105.1461,68.2334},
{2643.7573,-1265.6605,49.4164},
{2646.8152,-1648.6918,10.2685},
{2762.2893,-1899.5236,10.6282},
{2781.6448,-1955.9955,13.1126},
{2866.5471,-2002.4600,10.6712},
{2541.8572,-2048.5984,24.6788},
{2264.0598,-2059.6448,12.9434},
{2217.0745,-1908.1469,12.9306},
{2197.6003,-1720.4226,12.9003},
{2214.3330,-1496.7076,23.3969},
{2224.3547,-1338.9926,23.5501},
{2346.3220,-1300.1836,23.5530},
{2050.4668,-1510.7344,2.9247},
{1738.6357,-1519.4613,16.4589},
{1622.8074,-1879.1394,24.7065},
{1878.2582,-2101.2280,13.1126},
{1962.1466,-2162.7034,12.9478},
{2529.6860,-2359.3992,13.1846},
{2709.0210,-2403.9048,13.0419},
{2759.2827,-2450.5840,13.0941},
{2450.6238,-2658.6941,13.1995},
{2220.2039,-2527.2659,12.9367},
{2431.5249,-1571.0193,23.3151},
{1928.6094,-1339.6660,16.7498},
{1645.4243,-1296.1215,15.0287},
{1499.8965,-1302.9801,13.5986},
{1433.9067,-1548.1550,12.9369},
{1478.5696,-1722.9683,13.1144},
{2039.7603,-1707.0786,13.1175},
{2292.6577,-1485.3090,22.5775},
{2242.8240,-1142.7300,25.3468},
{2032.0940,-1063.1873,24.3020},
{1685.1388,-1062.4604,23.4700},
{1188.4440,-1331.1532,13.5488}
};

enum ZONE_MODEL{
	ID,
	COLOR,
	OWNER_CLEN,
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
	CLEN,
	ADMIN,
	MONEY,
	LEVEL,
	EXP,
	KILLS,
	DEATHS,
	SKIN,
	WEP1, AMMO1,
	WEP2, AMMO2,
	WEP3, AMMO3,
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

enum VEHICLE_MODEL{
 	ID,
	NAME[MAX_PLAYER_NAME],
	VEH_NUM,
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
 	LOCK,
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
 	LEADER_NAME[MAX_PLAYER_NAME],
 	KILLS,
 	DEATHS,
    COLOR
}
new CLAN[USED_CLAN][CLAN_MODEL];

enum INGAME_MODEL{
	bool:LOGIN,
	Float:SPAWN_POS_X,
	Float:SPAWN_POS_Y,
	Float:SPAWN_POS_Z,
	Float:SPAWN_ANGLE,
	ENTER_ZONE
}
new INGAME[MAX_PLAYERS][INGAME_MODEL];

enum MISSON_MODEL{
	NAME[24],
	Float:POS_Y,
	Float:POS_X,
	Float:POS_Z
}
new MISSON[3][MISSON_MODEL];

/* global variable */
new missonTick=0;

/* static */
static mysql;

public OnGameModeExit(){return 1;}
public OnGameModeInit(){
    mode();
	server();
	dbcon();
	thread();
    return 1;
}
public OnPlayerRequestClass(playerid, classid){

    if(INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    이미 로그인 하셨습니다.");

    join(playerid, check(playerid));
    showZone(playerid);
	SetPlayerColor(playerid, 0x8D8DFF99); //E6E6E699
    return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	if (PRESSED(KEY_YES)){
	    searchMissonRange(playerid);
	}
    return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){

	if(!response){
		switch(dialogid){
			case DL_LOGIN, DL_REGIST: return Kick(playerid);
			case DL_MISSON_CLEN, DL_MISSON_ITEM, DL_MISSON_CAR : return 0;
			case DL_CLAN_INSERT, DL_CLAN_LIST, DL_CLAN_RANK, DL_CLAN_SETUP, DL_CLAN_DELETE : return showMisson(playerid, 0);
			case DL_CLAN_SETUP_INVITE, DL_CLAN_SETUP_MEMBER : return ShowPlayerDialog(playerid, DL_CLAN_SETUP, DIALOG_STYLE_LIST, "{8D8DFF}샘프워코리아", "{FFFFFF}클랜원 초대\n클랜원 관리", "확인", "닫기");
			case DL_CLAN_SETUP_MEMBER_SETUP : return ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER, DIALOG_STYLE_LIST, "{8D8DFF}샘프워코리아", "{FFFFFF}클랜원1\n클랜원2", "확인", "닫기");
			case DL_CLAN_SETUP_MEMBER_SETUP_RANK, DL_CLAN_SETUP_MEMBER_SETUP_KICK : return ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP, DIALOG_STYLE_LIST, "{8D8DFF}샘프워코리아", "{FFFFFF}직위 변경\n강제 추방", "확인", "닫기");
		}
	}
	
    switch(dialogid){
		/* CORE */
		case DL_LOGIN  : checked(playerid, inputtext);
        case DL_REGIST : regist(playerid, inputtext);
        case DL_INFO   : info(playerid,listitem);

        /* MISSON */
        case DL_MISSON_CLEN : clan(playerid,listitem);
        case DL_MISSON_ITEM : item(playerid,listitem);
        case DL_MISSON_CAR  : car(playerid,listitem);

        /* CLAN */
        case DL_CLAN_INSERT : clanInsert(playerid, inputtext);
        case DL_CLAN_LIST   : clanList(playerid);
        case DL_CLAN_RANK   : clanRank(playerid);
        case DL_CLAN_SETUP  : clanSetup(playerid, listitem);
        case DL_CLAN_DELETE : clanDelete(playerid);
        
        /* CLAN SETUP */
        case DL_CLAN_SETUP_INVITE : clanInvite(playerid, inputtext);
        case DL_CLAN_SETUP_MEMBER : clanMember(playerid, listitem);
        
        /* CLAN MEMBER SETUP */
        case DL_CLAN_SETUP_MEMBER_SETUP : clanMemberSetup(playerid,listitem);
		case DL_CLAN_SETUP_MEMBER_SETUP_RANK : clanMemberRank(playerid,listitem);
		case DL_CLAN_SETUP_MEMBER_SETUP_KICK : clanMemberKick(playerid);
        
    }
    return 1;
}
/* OnDialogResponse stock
   @ info()
   @ clan(playerid,listitem)
   @ item(playerid,listitem)
   @ car(playerid,listitem)
*/
stock info(playerid, listitem){
	new result[502];
	if(listitem ==1) format(result,sizeof(result), infoMessege[listitem],USER[playerid][NAME],USER[playerid][CLEN],USER[playerid][LEVEL],USER[playerid][EXP],USER[playerid][MONEY],USER[playerid][KILLS],USER[playerid][DEATHS]);
	else format(result,sizeof(result), infoMessege[listitem]);
	ShowPlayerDialog(playerid, DL_MENU, DIALOG_STYLE_MSGBOX, "{8D8DFF}샘프워코리아",result, "닫기", "");
}

stock clan(playerid,listitem){
	new str[60];
	format(str, sizeof(str),"클랜 조합 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_INSERT);
        case 1 : showDialog(playerid, DL_CLAN_LIST);
        case 2 : showDialog(playerid, DL_CLAN_RANK);
        case 3 : showDialog(playerid, DL_CLAN_SETUP);
        case 4 : showDialog(playerid, DL_CLAN_DELETE);
	}
}
stock item(playerid,listitem){
	new str[60];
	format(str, sizeof(str),"아이템 상점 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
}
stock car(playerid,listitem){
	new str[60];
	format(str, sizeof(str),"차량 판매점 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
}

/* CLAN
   @ clanInsert(playerid, inputtext)
   @ clanList(playerid);
   @ clanRank(playerid);
   @ clanSetup(playerid, listitem);
   @ clanDelete(playerid);
*/
stock clanInsert(playerid, inputtext[]){
	new str[60];
	format(str, sizeof(str),"클랜 생성 %d - %s",playerid, inputtext);
	SendClientMessage(playerid,COL_SYS,str);
}
stock clanList(playerid){
	new str[60];
	format(str, sizeof(str),"클랜 리스트 %d - %d",playerid);
	SendClientMessage(playerid,COL_SYS,str);
}
stock clanRank(playerid){
	new str[60];
	format(str, sizeof(str),"클랜 랭킹 %d - %d",playerid);
	SendClientMessage(playerid,COL_SYS,str);
}
stock clanSetup(playerid, listitem){
	new str[60];
	format(str, sizeof(str),"클랜 관리 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_INVITE);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER);
	}
}
stock clanDelete(playerid){
	new str[60];
	format(str, sizeof(str),"클랜 해체 %d",playerid);
	SendClientMessage(playerid,COL_SYS,str);
}

/* CLAN SETUP
   @ clanInvite(playerid, inputtext)
   @ clanMember(playerid, listitem)
*/
stock clanInvite(playerid, inputtext[]){
	new str[60];
	format(str, sizeof(str),"클랜 초대 %d - %s",playerid, inputtext);
	SendClientMessage(playerid,COL_SYS,str);
}
stock clanMember(playerid, listitem){
	new str[60];
	format(str, sizeof(str),"클랜원 관리 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
	showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP);
}

/* CLAN MEMBER SETUP
   @ clanMemberSetup(playerid, listitem);
   @ clanMemberRank(playerid, listitem);
   @ clanMemberKick(playerid);
*/
stock clanMemberSetup(playerid, listitem){
	new str[60];
	format(str, sizeof(str),"클랜원 정보설정 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
	switch(listitem){
        case 0 : showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK);
        case 1 : showDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK);
	}
}

stock clanMemberRank(playerid, listitem){
	new str[60];
	format(str, sizeof(str),"클랜원 직위변경 %d - %d",playerid, listitem);
	SendClientMessage(playerid,COL_SYS,str);
}
stock clanMemberKick(playerid){
	new str[60];
	format(str, sizeof(str),"클랜원 강제추방 %d",playerid);
	SendClientMessage(playerid,COL_SYS,str);
}

public OnPlayerCommandText(playerid, cmdtext[]){
    if(!strcmp("/sav", cmdtext)){

        if(!INGAME[playerid][LOGIN]) return SendClientMessage(playerid,COL_SYS,"    로그인후에 사용 가능합니다.");

        save(playerid);
        SendClientMessage(playerid,COL_SYS,"    저장되었습니다.");
        return 1;
    }
   	if(!strcmp("/help", cmdtext)){
		showDialog(playerid, DL_INFO);
        return 1;
 	}
    if(!strcmp("/check", cmdtext)){
 	    checkZone(playerid);
 	    return 1;
 	}
    if(!strcmp("/hold", cmdtext)){
 	    holdZone(playerid);
 	    return 1;
 	}
 	
    return 0;
}
public OnPlayerDisconnect(playerid, reason){

    if(INGAME[playerid][LOGIN]) save(playerid);

    cleaning(playerid);
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
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

    mysql_format(mysql, query, sizeof(query), "SELECT ID, PASS FROM `userlog_info` WHERE `NAME` = '%s' LIMIT 1", escape(USER[playerid][NAME]));
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
	GetPlayerName(playerid, USER[playerid][NAME], MAX_PLAYER_NAME);
	mysql_format(mysql, query, sizeof(query), "INSERT INTO `userlog_info` (`NAME`,`PASS`,`USERIP`,`ADMIN`,`CLEN`,`MONEY`,`LEVEL`,`EXP`,`KILLS`,`DEATHS`,`SKIN`,`WEP1`,`AMMO1`,`WEP2`,`AMMO2`,`WEP3`,`AMMO3`,`INTERIOR`,`WORLD`,`POS_X`,`POS_Y`,`POS_Z`,`ANGLE`,`HP`,`AM`) VALUES ('%s','%s','%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f)",
	USER[playerid][NAME], USER[playerid][PASS], USER[playerid][USERIP],
	USER[playerid][ADMIN] = 0,
	USER[playerid][CLEN] = 0,
	USER[playerid][MONEY] = 1000,
	USER[playerid][LEVEL] = 1,
	USER[playerid][EXP] = 0,
	USER[playerid][KILLS] = 0,
	USER[playerid][DEATHS] = 0,
	USER[playerid][SKIN] = 170,
	USER[playerid][WEP1] = 24, USER[playerid][AMMO1] = 500,
	USER[playerid][WEP2] = 0, USER[playerid][AMMO2] = 0,
	USER[playerid][WEP3] = 0, USER[playerid][AMMO3] = 0,
	USER[playerid][INTERIOR] = 0,
    USER[playerid][WORLD] = 0,
	USER[playerid][POS_X] = 1913.1345,
 	USER[playerid][POS_Y] = -1710.5565,
	USER[playerid][POS_Z] = 13.4003,
	USER[playerid][ANGLE] = 89.3591,
	USER[playerid][HP] = 100.0,
	USER[playerid][AM] = 100.0);

	mysql_query(mysql, query);
	USER[playerid][ID] = cache_insert_id();

	SendClientMessage(playerid,COL_SYS,"    회원가입을 하였습니다.");
	INGAME[playerid][LOGIN] = true;
	spawn(playerid);
}
public save(playerid){
	GetPlayerPos(playerid,USER[playerid][POS_X],USER[playerid][POS_Y],USER[playerid][POS_Z]);
	GetPlayerFacingAngle(playerid, USER[playerid][ANGLE]);

	new query[400];
	mysql_format(mysql, query, sizeof(query), "UPDATE `userlog_info` SET `ADMIN`=%d,`CLEN`=%d,`MONEY`=%d,`LEVEL`=%d,`EXP`=%d,`KILLS`=%d,`DEATHS`=%d,`SKIN`=%d,`WEP1`=%d,`AMMO1`=%d,`WEP2`=%d,`AMMO2`=%d,`WEP3`=%d,`AMMO3`=%d, `INTERIOR`=%d, `WORLD`=%d, `POS_X`=%f,`POS_Y`=%f,`POS_Z`=%f,`ANGLE`=%f,`HP`=%f,`AM`=%f WHERE `ID`=%d",
	USER[playerid][ADMIN],
	USER[playerid][CLEN],
	USER[playerid][MONEY],
	USER[playerid][LEVEL],
	USER[playerid][EXP],
	USER[playerid][KILLS],
	USER[playerid][DEATHS],
	USER[playerid][SKIN],
	USER[playerid][WEP1], USER[playerid][AMMO1],
	USER[playerid][WEP2], USER[playerid][AMMO2],
	USER[playerid][WEP3], USER[playerid][AMMO3],
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
}
public load(playerid){
	new query[400];
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `userlog_info` WHERE `ID` = %d LIMIT 1", USER[playerid][ID]);
	mysql_query(mysql, query);

	USER[playerid][USERIP]   = cache_get_field_content_int(0, "USERIP");
	USER[playerid][ADMIN]   = cache_get_field_content_int(0, "ADMIN");
	USER[playerid][CLEN]   = cache_get_field_content_int(0, "CLEN");
	USER[playerid][MONEY]   = cache_get_field_content_int(0, "MONEY");
	USER[playerid][LEVEL]   = cache_get_field_content_int(0, "LEVEL");
	USER[playerid][EXP]   = cache_get_field_content_int(0, "EXP");
	USER[playerid][KILLS]   = cache_get_field_content_int(0, "KILLS");
	USER[playerid][DEATHS]  = cache_get_field_content_int(0, "DEATHS");
	USER[playerid][SKIN]    = cache_get_field_content_int(0, "SKIN");
	USER[playerid][WEP1]    = cache_get_field_content_int(0, "WEP1");
	USER[playerid][AMMO1]    = cache_get_field_content_int(0, "AMMO1");
	USER[playerid][WEP2]    = cache_get_field_content_int(0, "WEP2");
	USER[playerid][AMMO2]    = cache_get_field_content_int(0, "AMMO2");
	USER[playerid][WEP3]    = cache_get_field_content_int(0, "WEP3");
	USER[playerid][AMMO3]    = cache_get_field_content_int(0, "AMMO3");
	USER[playerid][POS_X]   = cache_get_field_content_float(0, "POS_X");
	USER[playerid][POS_Y]   = cache_get_field_content_float(0, "POS_Y");
	USER[playerid][POS_Z]   = cache_get_field_content_float(0, "POS_Z");
	USER[playerid][ANGLE]   = cache_get_field_content_float(0, "ANGLE");
	USER[playerid][HP]      = cache_get_field_content_float(0, "HP");
	USER[playerid][AM]      = cache_get_field_content_float(0, "AM");
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
	SetSpawnInfo(playerid, USER[playerid][CLEN], USER[playerid][SKIN], USER[playerid][POS_X], USER[playerid][POS_Y], USER[playerid][POS_Z], USER[playerid][ANGLE], USER[playerid][WEP1], USER[playerid][AMMO1], USER[playerid][WEP2], USER[playerid][AMMO2], USER[playerid][WEP3], USER[playerid][AMMO3]);
	SpawnPlayer(playerid);
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, USER[playerid][MONEY]);
	SetPlayerHealth(playerid, USER[playerid][HP]);
	SetPlayerArmour(playerid, USER[playerid][AM]);
}

/* INIT
   @ mode()
   @ thread()
   @ server()
   @ dbcon()
   @ cleaning(playerid)
*/
stock mode(){
	zoneSetup();
	loadMisson();
	textLabel_init();
	object_init();
}

stock thread(){ SetTimer("ServerThread", 500, true); }
stock server(){
	SetGameModeText("Blank Script");
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
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

    if(!mysql_errno(mysql))print("DB 정상");
}
stock cleaning(playerid){
    new temp[USER_MODEL], temp2[INGAME_MODEL];
    USER[playerid] = temp;
    INGAME[playerid] = temp2;
}

/* SERVER THREAD*/
public ServerThread(){
    foreach (new i : Player){
	    eventMoney(i);
	    checkZone(i);
    }
}

/* stock
   @ zoneSetup()
   @ showZone(playerid)
   @ fixPos(playerid)
   @ eventMoney(playerid)
   @ giveMoney(playerid,money)
   @ death(playerid, killerid, reason)
   @ loadMisson()
   @ missonInit(name[24],Float:pos_x,Float:pos_y,Float:pos_z)
   @ object_init()
   @ textLabel_init()
   @ searchMissonRange(playerid)
   @ showMisson(playerid, type)
   @ showDialog(playerid, type)
   @ isPlayerZone(playerid, zoneid)
   @ checkZone(playerid)
   @ holdZone(playerid)
*/

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
		ZONE[i][COLOR] = 0xFFFFFFFF;
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
	}
	return 0;
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
			if(INGAME[playerid][ENTER_ZONE] == z)return 0;
			
            new str[16];
            INGAME[playerid][ENTER_ZONE] = z;
            format(str, sizeof(str),"%d번 존", INGAME[playerid][ENTER_ZONE]);
            SendClientMessage(playerid,COL_SYS,str);
        }
	}
	return 0;
}

stock holdZone(playerid){
	new zoneid = INGAME[playerid][ENTER_ZONE];
	new color = GetPlayerColor(playerid);
	
    GangZoneShowForAll(ZONE[zoneid][ID], color);
    ZONE[zoneid][COLOR] = color;
    ZONE[zoneid][OWNER_CLEN] = USER[playerid][CLEN];

	new str[64];
	format(str, sizeof(str),"%d번 존 - %d번 클랜 - 유저 이름 : %s",zoneid, ZONE[zoneid][OWNER_CLEN], USER[playerid][NAME]);
	SendClientMessage(playerid,COL_SYS,str);
	return 0;
}

stock fixPos(playerid){
    new ran = random(sizeof(SPAWN_MODEL));
	INGAME[playerid][SPAWN_POS_X] = SPAWN_MODEL[ran][0];
	INGAME[playerid][SPAWN_POS_Y] = SPAWN_MODEL[ran][1];
	INGAME[playerid][SPAWN_POS_Z] = SPAWN_MODEL[ran][2];
	INGAME[playerid][SPAWN_ANGLE] = 89.3591;
}

stock eventMoney(playerid){ giveMoney(playerid, 1);
}
stock giveMoney(playerid,money){
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, USER[playerid][MONEY]+=money);
}

stock death(playerid, killerid, reason){
	fixPos(playerid);
	USER[playerid][POS_X]   = INGAME[playerid][SPAWN_POS_X];
 	USER[playerid][POS_Y]   = INGAME[playerid][SPAWN_POS_Y];
	USER[playerid][POS_Z]   = INGAME[playerid][SPAWN_POS_Y];
	USER[playerid][ANGLE]   = INGAME[playerid][SPAWN_ANGLE];
	USER[playerid][DEATHS] -= 1;
	USER[playerid][HP]      = 100.0;
	USER[playerid][AM]      = 100.0;

    save(playerid);
	spawn(playerid);
	if(reason == 255) return 1;
	USER[killerid][KILLS] += 1;
    save(killerid);
	return 1;
}

stock loadMisson(){
	missonInit("클랜 조합",1910.2273,-1714.3197,13.3307);
	missonInit("무기 상점",1909.9907,-1707.3611,13.3251);
	missonInit("차량 판매점",1909.9747,-1700.0070,13.3236);
}
stock missonInit(name[24],Float:pos_x,Float:pos_y,Float:pos_z){
	new num = missonTick++;
	format(MISSON[num][NAME], 24,"%s",name);
	MISSON[num][POS_X]=pos_x;
	MISSON[num][POS_Y]=pos_y;
	MISSON[num][POS_Z]=pos_z;
}

stock object_init(){
	CreateObject(1504, 1909.60229, -1713.55371, 12.30253,   0.00000, 0.00000, 269.91336);
	CreateObject(1505, 1909.58008, -1708.08728, 12.14866,   0.00000, 0.00000, 89.91272);
	CreateObject(1507, 1909.53870, -1699.33984, 12.30817,   0.00000, 0.00000, 269.92120);
}

stock textLabel_init(){
	for(new a = 0;a<3;a++){
		new str[40];
		format(str, sizeof(str),"%s (Y키)",MISSON[a][NAME]);
		Create3DTextLabel(str, 0x8D8DFFFF, MISSON[a][POS_X], MISSON[a][POS_Y], MISSON[a][POS_Z], 7.0, 0, 0);
	}
}

stock searchMissonRange(playerid){
	new Float:x,Float:y,Float:z;

	for(new i=0; i < sizeof(MISSON); i++){
	    x=MISSON[i][POS_X];
	    y=MISSON[i][POS_Y];
	    z=MISSON[i][POS_Z];
		if(IsPlayerInRangeOfPoint(playerid,3.0,x,y,z)) showMisson(playerid, i);
	}
}
stock showMisson(playerid, type){
	switch(type){
		case 0: ShowPlayerDialog(playerid, DL_MISSON_CLEN, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}클랜 생성\n클랜 목록\n클랜 랭킹\n클랜 관리\n클랜 해체","확인", "닫기");
		case 1: ShowPlayerDialog(playerid, DL_MISSON_ITEM, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}무기 구매\n무기 판매","확인", "닫기");
		case 2: ShowPlayerDialog(playerid, DL_MISSON_CAR, DIALOG_STYLE_LIST,DIALOG_TITLE,"{FFFFFF}차량 구매\n차량 판매","확인", "닫기");
	}
	return 1;
}

stock showDialog(playerid, type){
    switch(type){
        case DL_LOGIN : ShowPlayerDialog(playerid, DL_LOGIN, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, "{FFFFFF}로그인을 해주세요", DIALOG_ENTER, "나가기");
        case DL_REGIST : ShowPlayerDialog(playerid, DL_REGIST, DIALOG_STYLE_PASSWORD, DIALOG_TITLE, "{FFFFFF}회원가입을 해주세요.", DIALOG_ENTER, "나가기");
        case DL_INFO : ShowPlayerDialog(playerid, DL_INFO, DIALOG_STYLE_LIST, DIALOG_TITLE, "서버 규정\n내 프로필\n문의\n", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_INSERT : ShowPlayerDialog(playerid, DL_CLAN_INSERT, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}클랜명을 입력해주세요.", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_LIST : ShowPlayerDialog(playerid, DL_CLAN_LIST, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}클랜 목록", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_RANK : ShowPlayerDialog(playerid, DL_CLAN_RANK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}클랜 랭킹", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP : ShowPlayerDialog(playerid, DL_CLAN_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}클랜원 초대\n클랜원 관리", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_DELETE : ShowPlayerDialog(playerid, DL_CLAN_DELETE, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}정말로 클랜을 해체하시겠습니까?", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_INVITE : ShowPlayerDialog(playerid, DL_CLAN_SETUP_INVITE, DIALOG_STYLE_INPUT, DIALOG_TITLE, "{FFFFFF}초대하실분의 닉네임을 입력해주세요.", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}클랜원1\n클랜원2", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}직위 변경\n강제 추방", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP_RANK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_RANK, DIALOG_STYLE_LIST, DIALOG_TITLE, "{FFFFFF}1등급\n2등급\n3등급", DIALOG_ENTER, DIALOG_PREV);
        case DL_CLAN_SETUP_MEMBER_SETUP_KICK : ShowPlayerDialog(playerid, DL_CLAN_SETUP_MEMBER_SETUP_KICK, DIALOG_STYLE_MSGBOX, DIALOG_TITLE, "{FFFFFF}정말로 추방하시겠습니까?", DIALOG_ENTER, DIALOG_PREV);
    }
    return 1;
}

