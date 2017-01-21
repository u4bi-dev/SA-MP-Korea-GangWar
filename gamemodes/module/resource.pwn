    new infoMessege[3][502] = {
    "{8D8DFF}모드설명{FFFFFF}\n\n샘프워 코리아 모드입니다.\n세력을 넑혀가는 갱전쟁 형식의 모드입니다.\n\n{8D8DFF}게임방법{FFFFFF}\n\n샘프워코리아 전쟁 규정을 따릅니다.",
    "{8D8DFF}프로필란{FFFFFF}\n\n이름\t\t%s\n클랜\t\t%s\n레벨\t\t%d\n경험치\t\t%d\n머니\t\t%d\n사살\t\t%d\n죽음\t\t%d\nK/D\t\t%.01f%\n랭크\t\t%s\n\n{8D8DFF}듀얼전 기록{FFFFFF}\n\n승리 : %d회\n패배 : %d회\n승률 : %.01f%",
    "{8D8DFF}기본 명령어{FFFFFF}\n\n/help\n/lobby\n/kill\n/car\n/wep\n/carbuy\n/pm\n\n! : 클랜채팅\n/money\n/animhelp\n\n{8D8DFF}게임 방법{FFFFFF}\n\n알함브라(/lobby) 비전투구역에서는 총기, 스킨구매 클랜생성등 모든 활동이 가능합니다.\n\n{8D8DFF}갱존 점령방법{FFFFFF}\n\n갱존의 CP(Check Point)가 100퍼센트가 될시 해당 갱존은 당신의 클랜 소유가 됩니다.\nCP는 초당 해당 갱존에 머무르는 클랜원수만큼 비례하여 오릅니다."
    };
    new wepModel[11][50] = {
    {"데져트이글"},
    {"샷건"},
    {"손오브샷건"},
    {"SPAS 샷건"},
    {"UZI 머신건"},
    {"MP-5 라이플"},
    {"AK-47 자동소총"},
    {"M4카빈 자동소총"},
    {"TEC-9 머신건"},
    {"컨트리 라이플"},
    {"스나이퍼 라이플"}
    };
    new duelTypeName[6][50] = {
    {"주          먹"},
    {"데 져 트 이 글"},
    {"데    글 &샷건"},
    {"스나이퍼 &샷건"},
    {"SPAS &컨트리건"},
    {"M4자동소총 &샷건"}
    };
    new wepModelTD[11][50] = {
    {"Desert Eagle"},
    {"Shotgun"},
    {"Sawnoff Shotgun"},
    {"Combat Shotgun"},
    {"Micro SMG/Uzi"},
    {"MP5"},
    {"AK-47"},
    {"M4"},
    {"Tec-9"},
    {"Country Rifle"},
    {"Sniper Rifle"}
    };
    new comboText[12][30] = {
    {""},
    {"First Kill"},
    {"Double Kill"},
    {"Triple Kill"},
    {"Quadra Kill"},
    {"Penta Kill"},
    {"Hexa Kill"},
    {"Wicked Kill"},
    {"Monster Kill"},
    {"God Kill"},
    {"Legendary Kill"},
    {"WHAHAHAHAHAHA!!"}
    };

    new Float:DUEL_POS[2][4] ={
    {1921.2225,-1629.8002,13.5489,172.6391},
    {1919.8516,-1691.6798,13.5489,356.1345}
    };

    new Float:SPAWN_MODEL[25][3] = {
    {1732.8494,-1595.5840,12.9974},
    {1829.6360,-1610.3207,13.0021},
    {1940.0967,-1574.3601,13.2168},
    {2019.4558,-1612.8107,13.0138},
    {2139.4426,-1627.6359,13.0088},
    {2220.5039,-1707.9470,13.0694},
    {2210.4910,-1816.7891,12.9134},
    {2136.4072,-1895.3710,12.9918},
    {2040.1392,-1928.7294,13.0263},
    {1940.4465,-1933.6395,13.0062},
    {1822.1871,-1910.3248,13.0036},
    {1743.6857,-1827.9755,13.1687},
    {1686.5897,-1771.6533,13.0065},
    {1528.9404,-1687.9229,13.0063},
    {1559.1979,-1592.7367,13.0062},
    {1965.9456,-1751.2520,13.0088},
    {2054.8645,-1751.0645,13.0098},
    {2105.8059,-1777.3853,12.9879},
    {2095.6340,-1714.2476,13.1696},
    {2048.0432,-1676.9454,13.0903},
    {2042.0055,-1641.3363,13.1704},
    {2035.9061,-1814.6208,13.0063},
    {1886.8020,-1796.1086,13.1718},
    {1986.0946,-1681.0618,15.9694},
    {1922.3304,-1548.6619,13.6422}
    };

    new vehicleName[][20] =
    {
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
    "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
    };
