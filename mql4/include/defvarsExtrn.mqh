extern bool exDsplMsg = true; //выводить дополнительную информацию
extern bool exDsplSgnl = false; //выводить информацию о сигналах
extern int exMagicNum = 777;
extern int exSlipPage = 1; //Максимально допустимое отклонение цены для рыночных ордеров
extern bool exTradingOpen = true;
extern bool exTradingManagement = false;
extern bool exNdd = true;
//stop & profit
extern int exStopLoss = 0; //уровень SL, если 0, то SL расчитывается
extern double exStopLossKoef = 0; //коэффициент SL от спреда
extern int exTakeProfit = 0; //уровень TP, если 0, то TP расчитывается
extern double exTakeProfitKoef = 0; //коэффициент профита от спреда
//Аллигатор
extern double exDltAligBuy = 2; //ширина "зева" Alligator'а на открытие ордера - дельта погрешности показаний алигатора
extern double exDltAligSell = 1; //ширина "зева" Alligator'а на закрытие ордера - дельта погрешности показаний алигатора
extern int exJawsPeriod = 13;
extern int exJawsShift = 5;
extern int exTeethPeriod = 8;
extern int exTeethShift = 2;
extern int exLipsPeriod = 5;
extern int exLipsShift = 0;
//13, 8, 8, 5, 5, 3
//13, 5, 8, 2, 5, 0

