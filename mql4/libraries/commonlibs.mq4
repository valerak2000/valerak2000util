//+------------------------------------------------------------------+
//|                                                   commonlibs.mq4 |
//|                                                     valera_k2000 |
//|                                           valera_k2000@gmail.com |
//+------------------------------------------------------------------+
#property copyright "valera_k2000"
#property link      "valera_k2000@gmail.com"
#property library

#include <stderror.mqh>
#include <signal.mqh>
//#include <defvarsExtrn.mqh>
//#include <defvars.mqh>

#import "stdlib.ex4"
    string ErrorDescription(int iError);
#import

//обработка ошибок
bool chkError(int error) {
	bool retStatus = false;

	if (error != ERR_NO_ERROR) {
    	Print("ChkError=" + ErrorDescription(error) + "#" + DoubleToStr(error, 0));

		switch (error) {
		case ERR_NO_RESULT:
			break;
    	case ERR_SERVER_BUSY:
    		Sleep(500);

			break;
    	case ERR_MARKET_CLOSED:
    		retStatus = true;
    	case ERR_TRADE_DISABLED:
    		retStatus = true;
    	case ERR_NOT_ENOUGH_MONEY:
    		retStatus = true;
    	case ERR_PRICE_CHANGED:
 	  		break;
    	case ERR_OFF_QUOTES:
    		Sleep(1); 

  			break;
    	case 137:
    		Sleep(500);

			break;
    	case ERR_REQUOTE:
			break;
    	case ERR_TRADE_CONTEXT_BUSY:
        	Sleep(500);

	    	break;
    	case ERR_TRADE_TOO_MANY_ORDERS:
    		retStatus = true;
    	case ERR_INVALID_STOPS:
        	break;
    	case ERR_COMMON_ERROR:  
    		retStatus = true;
    	case ERR_OLD_VERSION:
    		retStatus = true;
    	case ERR_INVALID_TRADE_PARAMETERS:
    		retStatus = true;
    	case ERR_ACCOUNT_DISABLED:
    		retStatus = true;
    	case ERR_INVALID_PRICE:
			break;
    	default:
    		retStatus = true;
		}
	}

    return (retStatus);     
}

//проверка доступных средств
bool chkMoney(string symb, int cmd, double lot = 0.01) {
	if (symb == "")
		symb = Symbol();

	return (!(AccountFreeMarginCheck(symb, cmd, lot) <= 0 || GetLastError() == ERR_NOT_ENOUGH_MONEY));
}

//расчет профита
double getTp(string symb, int cmd, double takeProfitKoef, int takeProfit) {
	double tp, spread, minStop;

	if (symb == "")
		symb = Symbol();

	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(symb, MODE_SPREAD);
	//мин.дистанция
	minStop = MarketInfo(symb, MODE_STOPLEVEL);

	switch (cmd) {
	case OP_BUY:
    	if (takeProfit != 0)
        	tp = NormalizeDouble(Ask + (spread + takeProfit) * Point, Digits);
    	else
        	if (takeProfitKoef != 0)
            	tp = NormalizeDouble(Ask + (spread + MathFloor(takeProfitKoef * spread)) * Point, Digits);
        	else
        		tp = 0;

        break;
	case OP_SELL:
    	//продавать
    	if (takeProfit != 0)
        	tp = NormalizeDouble(Bid - (spread + takeProfit) * Point, Digits);
    	else
        	if (takeProfitKoef != 0)
            	tp = NormalizeDouble(Bid - (spread + MathFloor(takeProfitKoef * spread)) * Point, Digits);
        	else
        		tp = 0;

        break;
    default:
		tp = 0;    
    }

    return (tp);
}

//расчет лосей
double getSl(string symb, int cmd, double stopLossKoef, int stopLoss) {
	double sl, spread, minStop;

	if (symb == "")
		symb = Symbol();

	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(symb, MODE_SPREAD);
	//мин.дистанция
	minStop = MarketInfo(symb, MODE_STOPLEVEL);

	switch (cmd) {
	case OP_BUY:
    	if (stopLoss != 0)
    		sl = stopLoss;
    	else
        	if (stopLossKoef != 0)
            	sl = MathFloor(stopLossKoef * spread);
        	else sl = 0;
    
    	if (sl != 0) {
    		if (minStop > sl)
        		sl = minStop + Point;

	    	sl = NormalizeDouble(Bid - sl * Point, Digits);
        }
    	
        break;
	case OP_SELL:
    	//продавать
    	if (stopLoss != 0) 
        	sl = stopLoss;
    	else
        	if (stopLossKoef != 0)
            	sl = MathFloor(stopLossKoef * spread);
        	else sl = 0;

    	if (sl != 0) {
    		if (minStop > sl)
        		sl = minStop + Point;

    		sl = NormalizeDouble(Ask + sl * Point, Digits);
    	}

        break;
    default:
		sl = 0;    
    }

	if (sl < 0) sl = 0;

    return (sl);
}

//создать ордер
bool openOrder(string symb, int cmd, double lot, int magicNum, int slipPage = 1, bool ndd = true, 
			   double stopLossKoef = 0.0, double stopLoss = 0.0, double takeProfitKoef = 0.0, double takeProfit = 0.0,
			   bool dsplMsg = true, string comment = "") {
    double sl, tp;
    int ticket;
    bool Repeat = true;

	if (symb == "")
		symb = Symbol();

    //создать ордер    
    while (Repeat) {
        if (IsTradeAllowed())
            switch (cmd) {
            case OP_BUY:
                //покупать
                if (comment == "")
                	comment = "BUY";

                if (ndd) {
                	ticket = OrderSend(symb, OP_BUY, lot, NormalizeDouble(Ask, Digits), slipPage, 0, 0, comment, magicNum, 0, Blue);
                } else {
            		tp = getTp(symb, OP_BUY, takeProfitKoef, takeProfit);
            		sl = getSl(symb, OP_BUY, stopLossKoef, stopLoss);

                	ticket = OrderSend(symb, OP_BUY, lot, NormalizeDouble(Ask, Digits), slipPage, sl, tp, comment, magicNum, 0, Blue);
                }

                break;
            case OP_SELL:
                //продавать
                if (comment == "")
                	comment = "SELL";

                if (ndd) {
	                ticket = OrderSend(symb, OP_SELL, lot, NormalizeDouble(Bid, Digits), slipPage, 0, 0, comment, magicNum, 0, Red);
                } else {
            		tp = getTp(symb, OP_SELL, takeProfitKoef, takeProfit);
            		sl = getSl(symb, OP_SELL, stopLossKoef, stopLoss);

	                ticket = OrderSend(symb, OP_SELL, lot, NormalizeDouble(Bid, Digits), slipPage, sl, tp, comment, magicNum, 0, Red);
                }

                break;
            default:
                ticket = -1;
            }
    
        if (ticket == -1) {  
            if (chkError(GetLastError()))
                Repeat = false;
            else
                RefreshRates();      
        } else {
//        	Print(GetLastError());
/*        	if (GetLastError() != 0)
        		chkError(GetLastError());
*/
        	Repeat = false;
        }
    }

 	if (ndd) {
    	//изменить ордер - выставить стоп и профит
    	Repeat = true;

    	while (Repeat) {
    		//обновить цены
        	RefreshRates();

        	switch (cmd) {
        	case OP_BUY:
            	//покупать
            	tp = getTp(symb, OP_BUY, takeProfitKoef, takeProfit);
            	sl = getSl(symb, OP_BUY, stopLossKoef, stopLoss);

            	break;
        	case OP_SELL:
            	//продавать
            	tp = getTp(symb, OP_SELL, takeProfitKoef, takeProfit);
            	sl = getSl(symb, OP_SELL, stopLossKoef, stopLoss);

            	break;
            default:
            	sl = 0;
            	tp = 0;
        	}

        	if (IsTradeAllowed()) {
        		if (OrderModify(ticket, OrderOpenPrice(), sl, tp, CLR_NONE) == true) {
            		Repeat = false;
        		} else {
	           		if (chkError(GetLastError())) {
            			//критическая ощибка
            			Repeat = false;
            		}
	        	}
	        }
    	}
    }

	if (dsplMsg && ticket > 0)
		Print("ticket=", ticket, " ndd=", ndd, " comment=", comment,
			" spread=", DoubleToStr(MarketInfo(symb, MODE_SPREAD), Digits), 
      		" stoplevel=", DoubleToStr(MarketInfo(symb, MODE_STOPLEVEL), Digits),
      		" Ask=", DoubleToStr(Ask, Digits), " Bid=", DoubleToStr(Bid, Digits),
      		" !tp=", DoubleToStr(takeProfit, Digits),
      		" !sl=", DoubleToStr(stopLoss, Digits),
      		" tp=", DoubleToStr(tp, Digits),
      		" sl=", DoubleToStr(sl, Digits),
      		" point=", DoubleToStr(NormalizeDouble(Point, Digits), Digits));

    return (ticket);
}

//закрыть ордер и локирующую позицию
bool closeOrder(int ticket, double lots, double price, int slipPage, color clrMarker) {
	//проверить есть ли локирующий ордер
	int opposite = findLockOrder(ticket);
	
	if (opposite == -1) {
		//лока нет
		if (OrderClose(ticket, lots, price, slipPage, clrMarker) == false) {
			chkError(GetLastError());

			return (false);
		}
	} else {
		//есть лок
		if (OrderCloseBy(ticket, opposite, clrMarker) == false) {
			chkError(GetLastError());

			return (false);
		}
	}

	return (true);
}

//номер бара последнего открытого ордера
int getNumberOfBarLastorder(string symb = "", int tf = 0, int cmd = -1, int magicNum = -1) {
	datetime tmOpenOrder;

	if (symb == "")
		symb = Symbol();

	for (int i = 0; i < OrdersTotal(); i++) {
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true) {
			int ordType = OrderType();

			if (OrderSymbol() == symb)
				if (ordType == OP_BUY || ordType == OP_SELL)
					if (cmd < 0 || ordType == cmd)
						if (magicNum < 0 || OrderMagicNumber() == magicNum)
							if (tmOpenOrder < OrderOpenTime())
								tmOpenOrder = OrderOpenTime();
		}
	}

//	return (iBarShift(symb, tf, tmOpenOrder, true));
	return (iBarShift(symb, tf, tmOpenOrder, false));
}

//проверка сигналов аллигатора
int chkAlligatorSignal(string symb, int jawsPeriod, int jawsShift, int teethPeriod, int teethShift, int lipsPeriod,
					   int lipsShift, double dltAligBuy, double dltAligSell) {
	int signal = 0;
	double valMAGr, valMARd, valMARd1, valMAGr1, valMABl, valMABl1; 

	if (symb == "")
		symb = Symbol();

	valMAGr = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_SMMA, PRICE_CLOSE, MODE_GATORLIPS, 1); // зелёная
	valMARd = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_SMMA, PRICE_CLOSE, MODE_GATORTEETH, 1); // красная линия
	valMARd1 = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_SMMA, PRICE_CLOSE, MODE_GATORTEETH, 2); // красная
	valMAGr1 = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_SMMA, PRICE_CLOSE, MODE_GATORLIPS, 2); // зелёная
	valMABl = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_SMMA, PRICE_CLOSE, MODE_GATORJAW, 1); // синия линия
	valMABl1 = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_SMMA, PRICE_CLOSE, MODE_GATORJAW, 2); // синия линия

	//up CCI > 70 или алиг красн пересекает зеленую снизу вверх, то покупать
	//down CCI < -70 или алиг красн пересекает зеленую сверху вниз, то продавать

/*    if (valMAGr - valMARd >= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& valMARd1 - valMAGr1 < NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//зеленая над красной и пред. зеленая под красной
        signal = signal | sgnlBuyOpen;
	}

    if (valMARd - valMAGr <= NormalizeDouble(dltAligSell * Point, Digits) 
    		&& valMAGr1 - valMARd1 < NormalizeDouble(dltAligSell * Point, Digits)) {
    	//зеленая под красной и пред. зеленая над красной
        signal = signal | sgnlSellOpen;
	}
*/
	//
    if (valMAGr - valMABl >= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& valMAGr1 - valMABl1 < NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//зеленая над синей и предыдущая зеленая под синей
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if (valMAGr - valMABl <= NormalizeDouble(dltAligSell * Point, Digits)
    		&& valMAGr1 - valMABl1 > NormalizeDouble(dltAligSell * Point, Digits)) {
    	//зеленая под синей и пред. зеленая над синей
		signal = signal | sgnlSellOpen | sgnlBuyClose;
   	}

    if (valMAGr - valMARd <= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& valMAGr1 - valMARd1 > NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//зеленая под красной и пред. зеленая над красной
        signal = signal | sgnlBuyClose;
    }

	if (valMAGr - valMARd >= NormalizeDouble(dltAligSell * Point, Digits)
			&& valMAGr1 - valMARd1 < NormalizeDouble(dltAligSell * Point, Digits)) {
    	//зеленая над красной и пред. зеленая под красной
        signal = signal | sgnlSellClose;
	}

/*
    if ((valAlligatorGr - valAlligatorGr1 >= dltAlig * Point) && (valAlligatorGr >= valAlligatorRed)) { 
		return (sgnlBUY);
    } else
        if ((valAlligatorGr1 - valAlligatorGr >= dltAlig * Point) && (valAlligatorRed >= valAlligatorGr)) {
			return (sgnlSELL);
        }

            blue            = -8,         //настройки Аллигатора         
            red             = -3,
            green           = 8,          
      bylo_buy = seychas_buy;       //"Сегодня также как вчера" :)
      bylo_sell = seychas_sell;
      double blue_line=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_WEIGHTED, MODE_GATORJAW, blue);
      double red_line=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_WEIGHTED, MODE_GATORTEETH , red);
      double green_line=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_WEIGHTED, MODE_GATORLIPS , green);
      double  PriceHigh= High[0];
      if (green_line>blue_line+shirina1)        // сигналы входа
      seychas_buy=1;                
      if (green_line<blue_line-shirina1)
      seychas_sell=1;
      if (green_line+shirina2<red_line)         // сигналы выхода
      seychas_buy=0;
      if (blue_line+shirina2<red_line)
      seychas_sell=0;

*/
	return (signal);
}

//проверка сигналов Longa
int chkLongSignal(string symb) {
	int signal = 0;
 	int t1 = 6, t2 = 2, delta_L = 6, delta_S = 21, tradeTime = 7;
	static bool cantrade = true;

	if (symb == "")
		symb = Symbol();

//	if(TimeHour(TimeCurrent()) > tradeTime)
//		cantrade=true;

//    if(TimeHour(TimeCurrent()) == tradeTime && cantrade) {
    	if (Open[t1] - Open[t2] > NormalizeDouble(delta_S * Point, Digits)) {
        	//condition is fulfilled, enter a short position:
			signal = signal | sgnlSellOpen | sgnlBuyClose;
        
        	cantrade = false; //prohibit repeated trade until the next bar
    	}

      	if (Open[t2] - Open[t1] > NormalizeDouble(delta_L * Point, Digits)) {
        	// condition is fulfilled, enter a long position
			signal = signal | sgnlBuyOpen | sgnlSellClose;
        
        	cantrade = false;
      	}
//	}

	return (signal);
}

//проверка сигналов Tarzan
int chkTarzanSignal(string symb) {
	int signal = 0;

	if (symb == "")
		symb = Symbol();

    double valTarzan = iCustom(symb, 0, "TARZAN", 0, 5, 4, 50, 1, 5, 2, 0);
    double valTarzan1 = iCustom(symb, 0, "TARZAN", 0, 5, 4, 50, 1, 5, 2, 1);

    if (valTarzan > 50 && valTarzan1 > 50 ) {
    	//устойчивый восходящий тренд
		signal = signal | sgnlBuyOpen;// | sgnlSellClose;
    }

    if (valTarzan < 50 && valTarzan1 < 50 ) {
    	//устойчивый нисходящий тренд
		signal = signal | sgnlSellOpen;// | sgnlBuyClose;
    }

    if (valTarzan < 50 && valTarzan1 > 50 ) {
    	//тренд повернул вверх
		signal = signal | sgnlSellClose;
    }

    if (valTarzan > 50 && valTarzan1 < 50 ) {
    	//тренд переломился вниз
		signal = signal | sgnlBuyClose;
    }

	return (signal);
}

//найти локирующий ордер для данной позиции
int findLockOrder(int ticket) {
	string commentLocked, commentChk;

   	if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true) {

		switch(OrderType()) {
		case OP_BUY:
			commentLocked = "LckdB#" + DoubleToStr(ticket, 0);

			break;
		case OP_SELL:
			commentLocked = "LckdS#" + DoubleToStr(ticket, 0);

			break;
		default:
			commentLocked = "Noting";
		}

  		for (int i = 0; i < OrdersTotal(); i++) {
    		if (OrderSelect(i, SELECT_BY_POS) == true) {
    			commentChk = OrderComment();

        		if (commentChk == commentLocked) {
        			return (OrderTicket());
        		}
        	} else {
	    		chkError(GetLastError());
        	}
  		}
	} else {
		chkError(GetLastError());
	}

	return (-1);
}

//найти локируюмый ордер для данной позиции
int findLockedOrder(int ticket) {
	int ticketlckd = -1;
	string commentLock;

   	if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true) {
       	commentLock = OrderComment();

		if (StringFind(commentLock, "Lckd") == -1) {
			//это лок
			ticketlckd = StrToInteger(StringSubstr(commentLock, 7));
		}
	}

	return (ticketlckd);
}

//создать объект "индикатор-работы"
bool createIndicator(string expertName) {
	ObjectCreate("labelproj_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("labelproj_object", OBJPROP_CORNER, 1);
	ObjectSet("labelproj_object", OBJPROP_XDISTANCE, 50);
	ObjectSet("labelproj_object", OBJPROP_YDISTANCE, 6);
	ObjectSetText("labelproj_object", expertName, 10, "@Luxi Mono");
	ObjectSet("labelproj_object", OBJPROP_COLOR, White);
}

//удалить объект "индикатор-работы" 
bool closeIndicator() {
	ObjectDelete("labelproj_object");
}

//изменить состояние объекта "индикатор-работы" 
bool changeIndicatorState(string text) {
//	static int chrIndx, clrIndx = Green;
	//"вращать" символ часы, 183-194 часы
/*	if(chrIndx < 195) chrIndx++;
	else chrIndx = 183; 
   if(clrIndx == Green) clrIndx = Red;
   else clrIndx = Green;
   clrIndx++;
   Print(clrIndx);
*/
	ObjectSetText("labelproj_object", text, 10, "@Luxi Mono");
//	ObjectSet("indicator_object", OBJPROP_COLOR, Green); //цвета DarkGreen Green ForestGreen LimeGreen Lime - Red Maroon - Black
}