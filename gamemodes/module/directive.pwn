    tierInfo(){
        new str[1024];
        strcat( str, "\t\t\t\t\t{8D8DFF}시즌랭크 도움말{FFFFFF}\n\n");
        strcat( str, "{804040}◎Bronze {FFFFFF}K/D Ratio 50% {7FFF00}↓\n\n");
        strcat( str, "{C0C0C0}▼Sliver {FFFFFF}K/D Ratio 50% {7FFF00}↑\n\n");
        strcat( str, "{FFFF00}▣Gold {FFFFFF}K/D Ratio 55% {7FFF00}↑\n\n");
        strcat( str, "{00FFFF}⊙Platinum {FFFFFF}K/D Ratio 60% {7FFF00}↑\n\n");
        strcat( str, "{1229FA}◈Diamond {FFFFFF}K/D Ratio 70% {7FFF00}↑\n\n");
        strcat( str, "{FF0000}▩Challenger {FFFFFF}K/D Ratio 80%  {7FFF00}↑{FFFFFF} K/D 서버 랭킹 3위권 {7FFF00}↑\n\n");
        strcat( str, "\n");
        strcat( str, "{8D8DFF}레벨 10부터{FFFFFF} 머리 상단에 티어가 표시됩니다.");
        return str;
    }

    adminInfo(){
        new str[1024];
        strcat( str, "\t\t\t\t\t{8D8DFF}어드민 도움말{FFFFFF}\n\n");
        strcat( str, "{8D8DFF}1등급{FFFFFF}\n");
        strcat( str, "/kick\n");
        strcat( str, "/time\n");
        strcat( str, "{8D8DFF}2등급{FFFFFF}\n");
        strcat( str, "/bomb\n");
        strcat( str, "/ip\n");
        strcat( str, "{8D8DFF}3등급{FFFFFF}\n");
        strcat( str, "/ban\n");
        strcat( str, "/call\n");
        strcat( str, "/go\n");
        strcat( str, "{8D8DFF}4등급{FFFFFF}\n");
        strcat( str, "/admin\n");
        strcat( str, "/restart\n");
        strcat( str, "\n");
        strcat( str, "{8D8DFF}어드민채널{FFFFFF}: @할말\n");
        return str;
    }
