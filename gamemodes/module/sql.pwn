/* DB INIT CREATE */
#define SQL_USER_TABLE_1 "\
CREATE TABLE \
	user_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT \
	    ,NAME VARCHAR(24) NOT NULL \
	    ,PASS VARCHAR(24) NOT NULL \
	    ,USERIP VARCHAR(16) NOT NULL \
	    ,ADMIN INT(1) NOT NULL \
	    ,CLANID INT(2) NOT NULL \
	    ,MONEY INT(10) NOT NULL \
	    ,LEVEL INT(3) NOT NULL \
	    ,EXP INT(3) NOT NULL) \
	ENGINE=INNODB"

#define SQL_USER_TABLE_2 "\
ALTER TABLE user_info \
    ADD( \
        KILLS INT(5) NOT NULL \
        ,DEATHS INT(5) NOT NULL \
        ,SKIN INT(5) NOT NULL \
        ,WEP1 INT(2) NOT NULL \
        ,WEP2 INT(2) NOT NULL \
        ,WEP3 INT(2) NOT NULL \
        ,INTERIOR INT(2) NOT NULL \
        ,WORLD INT(1) NOT NULL)"

#define SQL_USER_TABLE_3 "\
ALTER TABLE user_info \
    ADD(\
        POS_X DECIMAL (10,5) NOT NULL \
        ,POS_Y DECIMAL (10,5) NOT NULL \
        ,POS_Z DECIMAL (10,5) NOT NULL \
        ,ANGLE DECIMAL (10,5) NOT NULL \
        ,HP DECIMAL (3,0) NOT NULL \
        ,AM DECIMAL (3,0) NOT NULL)"

#define SQL_CLAN_TABLE "\
CREATE TABLE \
	clan_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT \
	    ,NAME VARCHAR(20) NOT NULL \
	    ,LEADER_ID INT NOT NULL \
	    ,KILLS INT(5) NOT NULL \
	    ,DEATHS INT(5) NOT NULL \
	    ,COLOR INT(10) NOT NULL \
	    ,ZONE_LENGTH INT(3) NOT NULL \
	    ,SKIN INT(3) NOT NULL \
	) ENGINE=INNODB"

#define SQL_ZONE_TABLE "\
CREATE TABLE \
	zone_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT \
	    ,OWNER_CLAN INT(3) NOT NULL \
	) ENGINE=INNODB"

#define SQL_VEHICLE_TABLE "\
CREATE TABLE \
	vehicle_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT \
	    ,OWNER_ID INT NOT NULL \
	    ,POS_X DECIMAL (10,5) NOT NULL \
	    ,POS_Y DECIMAL (10,5) NOT NULL \
	    ,POS_Z DECIMAL (10,5) NOT NULL \
	    ,ANGLE DECIMAL (10,5) NOT NULL \
	    ,COLOR1 INT(3) NOT NULL \
	    ,COLOR2 INT(3) NOT NULL \
    ) ENGINE=INNODB;"

#define SQL_HOUSE_TABLE "\
CREATE TABLE \
	house_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT \
	    ,OWNER_ID INT NOT NULL \
	    ,OPEN INT(1) NOT NULL \
	    ,ENTER_POS_X DECIMAL (10,5) NOT NULL \
	    ,ENTER_POS_Y DECIMAL (10,5) NOT NULL \
	    ,ENTER_POS_Z DECIMAL (10,5) NOT NULL \
	    ,LEAVE_POS_X DECIMAL (10,5) NOT NULL \
	    ,LEAVE_POS_Y DECIMAL (10,5) NOT NULL \
	    ,LEAVE_POS_Z DECIMAL (10,5) NOT NULL \
	) ENGINE=INNODB"

#define SQL_WEAPON_TABLE "\
CREATE TABLE \
	weapon_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT \
	    ,USER_ID INT NOT NULL \
	    ,MODEL INT(4) NOT NULL \
    ) ENGINE=INNODB"

#define SQL_DUEL_TABLE "\
CREATE TABLE \
	duel_info( \
	    ID INT PRIMARY KEY AUTO_INCREMENT, \
	    WIN_ID INT, \
	    LOSS_ID INT, \
	    TYPE INT(1), \
	    MONEY INT, \
	    WIN_HP DECIMAL (3,0) NOT NULL, \
	    WIN_AM DECIMAL (3,0) NOT NULL \
	) ENGINE=INNODB"

/* DB DATA LOAD SELECT */
#define SQL_DATA_LOAD_USER "\
SELECT \
	ID \
FROM user_info \
LIMIT 1"

#define SQL_DATA_LOAD_HOUSE "\
SELECT \
	* \
FROM house_info"

#define SQL_DATA_LOAD_VEHICLE "\
SELECT \
    vehicle.ID\
    ,vehicle.OWNER_ID \
    ,(SELECT \
		NAME \
    FROM user_info \
    WHERE ID = vehicle.OWNER_ID) \
    AS OWNER_NAME \
    ,vehicle.POS_X \
    ,vehicle.POS_Y \
    ,vehicle.POS_Z \
    ,vehicle.ANGLE \
    ,vehicle.COLOR1 \
    ,vehicle.COLOR2 \
FROM vehicle_info \
AS vehicle"

#define SQL_DATA_LOAD_CALN "\
SELECT \
    clan.ID \
    ,clan.NAME \
    ,clan.LEADER_ID \
    ,user.NAME AS LEADER_NAME \
    ,clan.KILLS \
    ,clan.DEATHS \
    ,clan.COLOR \
    ,clan.ZONE_LENGTH \
FROM clan_info \
AS clan \
INNER JOIN \
user_info \
AS user \
ON clan.LEADER_ID = user.ID"

#define SQL_DATA_LOAD_ZONE "\
SELECT * \
FROM zone_info"

#define SQL_DATA_LOAD_WEAPON "\
SELECT ID \
FROM weapon_info \
LIMIT 1"

#define SQL_DATA_LOAD_DUEL "\
SELECT ID \
FROM duel_info"

/* USER LOG */
#define SQL_USER_WEAPON_JOIN "\
SELECT weapon.MODEL \
FROM user_info AS user \
INNER JOIN weapon_info \
AS weapon \
ON user.ID = weapon.USER_ID \
WHERE user.ID = %d"

#define SQL_USER_PASS_CHECK "\
SELECT ID, PASS \
FROM user_info \
WHERE NAME = '%s' \
LIMIT 1"

#define SQL_USER_INSERT "\
INSERT INTO user_info( \
    NAME \
    ,PASS \
    ,USERIP \
    ,ADMIN \
    ,CLANID \
    ,MONEY \
    ,LEVEL \
    ,EXP \
    ,KILLS \
    ,DEATHS \
    ,SKIN \
    ,WEP1 \
    ,WEP2 \
    ,WEP3 \
    ,INTERIOR \
    ,WORLD \
    ,POS_X \
    ,POS_Y \
    ,POS_Z \
    ,ANGLE \
    ,HP \
    ,AM) \
VALUES ('%s','%s','%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f,%f)"

#define SQL_USER_SELECT "\
SELECT \
    USERIP \
    ,ADMIN \
    ,CLANID \
    ,MONEY \
    ,LEVEL \
    ,EXP \
    ,KILLS \
    ,DEATHS \
    ,SKIN \
    ,WEP1 \
    ,WEP2 \
    ,WEP3 \
    ,INTERIOR \
    ,WORLD \
    ,(SELECT \
        COUNT(TYPE) \
    FROM duel_info \
    WHERE WIN_ID = %d) \
    AS DUEL_WIN \
    ,(SELECT \
        COUNT(TYPE) \
    FROM duel_info \
    WHERE LOSS_ID = %d) \
    AS DUEL_LOSS \
    ,POS_X \
    ,POS_Y \
    ,POS_Z \
    ,ANGLE \
    ,HP \
    ,AM \
FROM user_info \
WHERE ID = %d \
LIMIT 1"

/* USER LEVEL RANK LIST */
#define SQL_USER_LEVEL_RANK "\
SELECT \
    ID \
    ,NAME \
    ,LEVEL \
    ,KILLS \
    ,DEATHS \
FROM user_info \
ORDER BY LEVEL \
DESC LIMIT 10"

/* USER KILL RANK LIST */
#define SQL_USER_KILL_RANK "\
SELECT \
    ID \
    ,NAME \
    ,LEVEL \
    ,KILLS \
    ,DEATHS \
FROM user_info \
ORDER BY KILLS \
DESC LIMIT 10"

/* CALN INSERT */
#define SQL_CLAN_NAME_CHECK "\
SELECT \
    NAME \
FROM clan_info \
WHERE NAME = '%s' \
LIMIT 1"

#define SQL_CLAN_COLOR_CHECK "\
SELECT \
    NAME,COLOR \
FROM clan_info \
WHERE COLOR = %d \
LIMIT 1"

#define SQL_CLAN_INSERT_SUCCESS "\
INSERT INTO \
    clan_info( \
	    NAME \
	    ,LEADER_ID \
	    ,KILLS \
	    ,DEATHS \
	    ,COLOR \
	    ,ZONE_LENGTH \
	    ,SKIN) \
	VALUES('%s',%d,0,0,%d,0,0)"

/* CLAN SKIN UPDATE */
#define SQL_CLAN_SKIN_UPDATE "\
UPDATE \
clan_info \
SET \
	SKIN = %d \
WHERE CLANID = %d"

/* CLAN ZONE LENTH UPDATE */
#define SQL_CLAN_ZONE_LENGTH "\
UPDATE \
clan_info \
SET \
	ZONE_LENGTH = %d \
WHERE ID = %d"

/* CLAN LIST SELECT */
#define SQL_CLAN_LIST "\
SELECT \
    NAME \
FROM clan_info \
LIMIT 10"

/* CLAN RANK SELECT */
#define SQL_CLAN_RANK "\
SELECT \
    NAME \
    ,ZONE_LENGTH \
FROM clan_info \
ORDER BY ZONE_LENGTH \
DESC LIMIT 10"

/* CLAN MEMBER LIST SELECT */
#define SQL_CLAN_MEMBER_LIST "\
SELECT \
    ID \
    ,NAME \
    ,LEVEL \
    ,KILLS \
    ,DEATHS \
FROM user_info \
WHERE CLANID = %d"

/* WEAPON BUY */
#define SQL_WEAPON_BUY_CHECK "\
SELECT \
    USER_ID \
FROM weapon_info \
WHERE USER_ID = %d \
AND MODEL = %d \
LIMIT 1"

#define SQL_WEAPON_BUY_SUCCESS "\
INSERT INTO \
    weapon_info( \
        USER_ID \
        ,MODEL) \
    VALUES(%d,%d)"

/* NAME EDIT */
#define SQL_NAME_EDIT_CHECK "\
SELECT \
    NAME \
FROM user_info \
WHERE NAME = '%s' \
LIMIT 1"

#define SQL_NAME_CLAN_EDIT "\
UPDATE \
user_info \
SET \
	NAME = '%s' \
WHERE ID = %d"

/* VEHICLE DATA */
#define SQL_VEHICLE_INIT_INSERT "\
INSERT INTO \
vehicle_info( \
    OWNER_ID \
    ,POS_X \
    ,POS_Y \
    ,POS_Z \
    ,ANGLE \
    ,COLOR1 \
    ,COLOR2) \
VALUES (0, %f, %f, %f, %f, 0, 0)"

#define SQL_VEHICLE_DATA_UPDATE "\
UPDATE \
vehicle_info \
    SET POS_X = %f \
    ,POS_Y = %f \
    ,POS_Z = %f \
    ,ANGLE = %f \
WHERE ID = %d"

#define SQL_VEHICLE_COLOR_UPDATE "\
UPDATE \
vehicle_info \
	SET \
		COLOR1 = %d \
		,COLOR2 = %d \
	WHERE ID = %d"

#define SQL_VEHICLE_BUY_UPDATE "\
UPDATE \
vehicle_info \
	SET \
		OWNER_ID = %d \
	WHERE ID = %d"

/* MY VEHICLE LOG */
#define SQL_MYCAR_SELECT "\
SELECT \
	ID \
	FROM vehicle_info \
WHERE OWNER_ID=%d"

/* MY VEHICLE LENGTH CAR */
#define SQL_MYCAR_LENGTH "\
SELECT OWNER_ID \
FROM vehicle_info \
WHERE OWNER_ID=%d"

/* ZONE DATA */
#define SQL_ZONE_INIT_INSERT "\
INSERT INTO \
    zone_info( \
	OWNER_CLAN) \
VALUES (%d)"

#define SQL_ZONE_DATA_UPDATE "\
UPDATE \
    zone_info \
	SET \
OWNER_CLAN = %d \
WHERE ID = %d"

#define SQL_ZONE_DATA_SELECT "\
SELECT \
    OWNER_CLAN \
FROM zone_info"

/* DUEL INSERT */

#define SQL_DUEL_INSERT "\
INSERT INTO \
duel_info( \
    WIN_ID \
    ,LOSS_ID \
    ,TYPE \
    ,MONEY \
    ,WIN_HP \
    ,WIN_AM) \
VALUES(%d,%d,%d,%d,%f,%f)"

#define SQL_DUEL_SELECT "\
SELECT \
    ID \
    ,WIN_ID \
    ,(SELECT \
        NAME \
    FROM user_info \
    WHERE ID = duel.WIN_ID) \
    AS WIN_NAME \
    ,LOSS_ID \
    ,(SELECT \
        NAME \
    FROM user_info \
    WHERE ID = duel.LOSS_ID) \
    AS LOSS_NAME \
    ,TYPE \
    ,MONEY \
    ,WIN_HP \
    ,WIN_AM \
FROM duel_info \
AS duel \
ORDER BY ID \
DESC LIMIT 20"


