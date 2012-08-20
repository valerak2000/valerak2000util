extern bool dsplMsg = true; //выводить дополнительную информацию
extern bool dsplSgnl = false; //выводить информацию о сигналах
extern int magicNum = 777;
extern int slipPage = 1; //Максимально допустимое отклонение цены для рыночных ордеров
extern bool tradingOpen = true;
extern bool tradingManagement = false;
extern bool ndd = true;
//stop & profit
extern int stopLoss = 6000; //уровень SL, если 0, то SL не выставляется
extern double stopLossKoef = 0; //коэффициент SL от спреда
extern int takeProfit = 15; //уровень TP, если 0, то TP не выставляется
extern double takeProfitKoef = -1; //коэффициент профита от спреда
//Аллигатор
extern double dltAligBuy = 2; //ширина "зева" Alligator'а на открытие ордера - дельта погрешности показаний алигатора
extern double dltAligSell = 1; //ширина "зева" Alligator'а на закрытие ордера - дельта погрешности показаний алигатора
extern int jawsPeriod = 13;
extern int jawsShift = 5;
extern int teethPeriod = 8;
extern int teethShift = 2;
extern int lipsPeriod = 5;
extern int lipsShift = 0;
//13, 8, 8, 5, 5, 3
//13, 5, 8, 2, 5, 0

