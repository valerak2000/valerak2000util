//+------------------------------------------------------------------+
//|                                                   commonlibs.mq4 |
//|                                                     valera_k2000 |
//|                                           valera_k2000@gmail.com |
//+------------------------------------------------------------------+
#import "commonlibs.ex4"
bool chkError(int error);
bool chkMoney(string symb, int cmd, double lot = 0.01);

double getSl(string symb, int cmd, double stopLossKoef, int stopLoss);
double getTp(string symb, int cmd, double takeProfitKoef, int takeProfit);
bool openOrder(string symb, int cmd, double lot, int magicNum, int slipPage = 1, bool ndd = true, 
			   double stopLossKoef = 0.0, double stopLoss = 0.0, double takeProfitKoef = 0.0, double takeProfit = 0.0,
			   bool dsplMsg = true, string comment = "");
bool closeOrder(int ticket, double lots, double price, int slipPage, color clrMarker);

int findLockOrder(int ticket);
int findLockedOrder(int ticket, string commentLock);
int getNumberOfBarLastOrder(string symb = "", int tf = 0, int op = -1, int mn = -1);

int chkAlligatorSignal(string symb, int jawsPeriod, int jawsShift, int teethPeriod, int teethShift, int lipsPeriod, int lipsShift,
					   double dltAligBuy, double dltAligSell);
int chkLongSignal(string symb);
int chkTarzanSignal(string symb);

bool createIndicator(string expertName);
bool closeIndicator();
bool changeIndicatorState(string text);

