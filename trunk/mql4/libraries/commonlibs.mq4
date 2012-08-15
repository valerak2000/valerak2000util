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
bool chkMoney(string symb, int cmd, double marginPercent, double lot = 0.01) {
	if (symb == "")
		symb = Symbol();
//AccountFreeMargin()
//средства / залог * 100 = уровень
	if (((AccountEquity() / AccountBalance()) * 100) <= marginPercent) {
		return (false);
	} else {
		return (!(AccountFreeMarginCheck(symb, cmd, lot) <= 0 || GetLastError() == ERR_NOT_ENOUGH_MONEY));
	}
}

//расчет профита
double getTp(string symb, int cmd, double takeProfitKoef, int takeProfit, double inPrice = 0.0) {
	double tp, spread, price;

	if (symb == "")
		symb = Symbol();

	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(symb, MODE_SPREAD);

	switch (cmd) {
	case OP_BUY:
		if (inPrice == 0.0) {
			price = Ask;
		} else {
			price = inPrice;
		}

    	if (takeProfit != 0) {
        	tp = NormalizeDouble(price + (spread + takeProfit) * Point, Digits);
    	} else {
        	if (takeProfitKoef > 0) {
            	tp = NormalizeDouble(price + (spread + MathFloor(takeProfitKoef * spread)) * Point, Digits);
        	} else {
        		tp = 0.0;
        	}
        }

        break;
	case OP_SELL:
		if (inPrice == 0.0) {
			price = Bid;
		} else {
			price = inPrice;
		}

    	if (takeProfit != 0) {
        	tp = NormalizeDouble(price - (spread + takeProfit) * Point, Digits);
    	} else {
        	if (takeProfitKoef > 0) {
            	tp = NormalizeDouble(price - (spread + MathFloor(takeProfitKoef * spread)) * Point, Digits);
        	} else {
        		tp = 0.0;
        	}
        }

        break;
    default:
		tp = 0.0;    
    }

    return (NormalizeDouble(tp, Digits));
}

//расчет лосей
double getSl(string symb, int cmd, double stopLossKoef, int stopLoss, double inPrice = 0.0) {
	double sl, spread, minStop, price;

	if (symb == "")
		symb = Symbol();

	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(symb, MODE_SPREAD);
	//мин.дистанция
	minStop = MarketInfo(symb, MODE_STOPLEVEL);

	if (stopLoss != 0) {
		sl = stopLoss;
	} else {
    	if (stopLossKoef > 0) {
        	sl = MathFloor(stopLossKoef * spread);
    	} else {
    		sl = 0.0;
    	}
    }

	switch (cmd) {
	case OP_BUY:
		if (inPrice == 0.0) {
			price = Bid;
		} else {
			price = inPrice;
		}

    	if (sl != 0.0) {
    		if (minStop > sl) {
        		sl = minStop + Point;
        	}

	    	sl = NormalizeDouble(price - sl * Point, Digits);
        }
    	
        break;
	case OP_SELL:
		if (inPrice == 0.0) {
			price = Ask;
		} else {
			price = inPrice;
		}

    	if (sl != 0.0) {
    		if (minStop > sl) {
        		sl = minStop + Point;
        	}

    		sl = NormalizeDouble(price + sl * Point, Digits);
    	}

        break;
    default:
		sl = 0.0;    
    }

	if (sl < 0.0) {
		sl = 0.0;
	}

    return (NormalizeDouble(sl, Digits));
}

//создать ордер
bool openOrder(string symb, int cmd, double lot, int magicNum, int slipPage = 1, bool ndd = true, 
			   double stopLossKoef = 0.0, double stopLoss = 0.0, double takeProfitKoef = 0.0, double takeProfit = 0.0,
//			   bool trailingUse, int trailingProfStart,
			   bool dsplMsg = true, string comment = "") {
    double sl, tp;
    int ticket;
    bool Repeat = true;

	if (symb == "")
		symb = Symbol();

    //создать ордер    
    while (Repeat == true) {
        if (IsTradeAllowed() == true) {
            switch (cmd) {
            case OP_BUY:
                //покупать
                if (comment == "") {
                	comment = "BUY"; //+ "#Tp#" + DoubleToStr(tp, Digits);
                }

                if (ndd == true) {
                	ticket = OrderSend(symb, OP_BUY, lot, Ask, slipPage, 0, 0, comment, magicNum, 0, Blue);
                } else {
            		tp = getTp(symb, OP_BUY, takeProfitKoef, takeProfit);
            		sl = getSl(symb, OP_BUY, stopLossKoef, stopLoss);

                	ticket = OrderSend(symb, OP_BUY, lot, Ask, slipPage, sl, tp, comment, magicNum, 0, Blue);
                }

                break;
            case OP_SELL:
                //продавать
                if (comment == "") {
                	comment = "SELL";
                }

                if (ndd == true) {
	                ticket = OrderSend(symb, OP_SELL, lot, Bid, slipPage, 0, 0, comment, magicNum, 0, Red);
                } else {
            		tp = getTp(symb, OP_SELL, takeProfitKoef, takeProfit);
            		sl = getSl(symb, OP_SELL, stopLossKoef, stopLoss);

/*					if (trailingUse == true) {
						comment = comment +  "#TS#" + DoubleToStr(getTp(symb, OP_SELL, 0, trailingProfStart), Digits));
					}
*/
	                ticket = OrderSend(symb, OP_SELL, lot, Bid, slipPage, sl, tp, comment, magicNum, 0, Red);
                }

                break;
            default:
                ticket = -1;
            }
        }
    
        if (ticket == -1) {  
            if (chkError(GetLastError()) == true) {
                Repeat = false;
            } else {
                RefreshRates();
            }
        } else {
//        	Print(GetLastError());
/*        	if (GetLastError() != 0)
        		chkError(GetLastError());
*/
        	Repeat = false;
        }
    }

 	if (ndd == true && ticket != -1) {
    	//изменить ордер - выставить стоп и профит
    	int cntAttempt = 10;
    	Repeat = true;

    	while (Repeat == true && cntAttempt > 0) {
    		cntAttempt--;
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
            	sl = 0.0;
            	tp = 0.0;
        	}

//
        	if (IsTradeAllowed() == true && (sl != 0.0 || tp != 0.0)) {
        		if (OrderModify(ticket, OrderOpenPrice(), sl, tp, CLR_NONE) == true) {
            		Repeat = false;
        		} else {
	           		if (chkError(GetLastError()) == true) {
            			//критическая ощибка
            			Repeat = false;
            		}
	        	}
	        }
    	}
    }

	if (dsplMsg == true && ticket > 0) {
		Print("ticket=", ticket,
//			" ndd=", ndd,
			" comment=", comment,
			" spread=", DoubleToStr(MarketInfo(symb, MODE_SPREAD), Digits), 
//      		" stoplevel=", DoubleToStr(MarketInfo(symb, MODE_STOPLEVEL), Digits),
      		" Ask=", DoubleToStr(Ask, Digits), " Bid=", DoubleToStr(Bid, Digits),
//      		" !tp=", DoubleToStr(takeProfit, Digits),
//      		" !sl=", DoubleToStr(stopLoss, Digits),
      		" tp=", DoubleToStr(tp, Digits),
      		" sl=", DoubleToStr(sl, Digits),
//      		" point=", DoubleToStr(NormalizeDouble(Point, Digits), Digits),
//      		" balance=", AccountBalance(),
//			" margin=", AccountFreeMargin(),
      		" %=", (AccountEquity() / AccountBalance()) * 100);
//      		" %=", (AccountFreeMargin() / AccountBalance()) * 100,
	}

    return (ticket);
}

//установить локу его профит
bool setProfitToLockOrder(int ticket, double stopLossKoef = 0.0, int stopLoss = 0) {
   	if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
		string comment = OrderComment();
		int endTicketInComment = StringFind(comment, "#Tp#");
		double sl, tp = StrToDouble(StringSubstr(comment, endTicketInComment + 4));

		if (stopLossKoef != 0 || stopLoss != 0) {
			sl = getSl(OrderSymbol(), OrderType(), stopLossKoef, stopLoss, 0.0);
		} else {
			sl = 0.0;
		}

		if (OrderModify(ticket, OrderOpenPrice(), sl, tp, CLR_NONE) == false) {
			chkError(GetLastError());

			return (false);
		}
	}
}

//закрыть ордер и локирующую позицию
bool closeOrder(int ticket, double lots, double price, int slipPage, color clrMarker, double stopLossKoef = 0.0, int stopLoss = 0) {
	if (OrderClose(ticket, lots, price, slipPage, clrMarker) == true) {
		//проверить есть ли локирующий ордер
		int opposite = findLockOrder(ticket);
	
		if (opposite != -1 && setProfitToLockOrder(opposite, stopLossKoef, stopLoss) == false) {
			return (false);
    	}
	} else {
		chkError(GetLastError());

		return (false);
	}

	/*		if (OrderCloseBy(ticket, opposite, clrMarker) == false) {
				chkError(GetLastError());

				return (false);
			}
	*/	
	return (true);
}

//номер бара последнего открытого ордера
int getNumberOfBarLastOrder(string symb = "", int tf = 0, int cmd = -1, int magicNum = -1) {
	datetime tmOpenOrder;

	if (symb == "")
		symb = Symbol();

	for (int i = 0; i < OrdersTotal(); i++) {
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true) {
			int ordType = OrderType();

			if (OrderSymbol() == symb) {
				if (ordType == OP_BUY || ordType == OP_SELL) {
					if (cmd < 0 || ordType == cmd) {
						if (magicNum < 0 || OrderMagicNumber() == magicNum) {
							if (tmOpenOrder < OrderOpenTime()) {
								tmOpenOrder = OrderOpenTime();
							}
						}
					}
				}
			}
		}
	}

//	return (iBarShift(symb, tf, tmOpenOrder, true));
	return (iBarShift(symb, tf, tmOpenOrder, false));
}

//найти локирующий ордер для данной позиции
int findLockOrder(int ticket) {
	string commentLocked, commentChk;

   	if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
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
    		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true) {
    			commentChk = OrderComment();
    			int endTicket = StringFind(commentChk, "#Tp#");

				if (endTicket != -1 && StringSubstr(commentChk, 0, endTicket) == commentLocked) {
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
int findLockedOrder(int ticket, string commentLock) {
	int ticketLckd = -1;

	if (commentLock == "") {
	   	if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true) {
	       	commentLock = OrderComment();
		}
	}

	if (StringFind(commentLock, "Lckd") != -1) {
		//это лок
		int endTicket = StringFind(commentLock, "#Tp#");

		ticketLckd = StrToInteger(StringSubstr(commentLock, 6, endTicket - 6));

	   	if (ticketLckd != -1) {
	   		if (OrderSelect(ticketLckd, SELECT_BY_TICKET) == true && OrderCloseTime() == 0) {
	   			//ордер не закрыт
//	   			chkError(GetLastError());
	   		} else {
	   			//привязка устарела
	   			ticketLckd = -1;
//	   			chkError(GetLastError());
//				if (ticket == 8)
//					Print("findLockedOrder=", ticketLckd);
	   		}
	   	}
	}

	return (ticketLckd);
}

//есть ли ордер с близкой ценой открытия?
bool findLikePriceOrder(string symb, int cmd, int magicNum = -1, double takeProfitKoef = 0.0, double takeProfit = 0.0) {
	double tp, price;

	if (symb == "")
		symb = Symbol();
	//значения цены профита для текущих цен
	//tp = getTp(symb, cmd, takeProfitKoef, takeProfit);

	switch (cmd) {
	case OP_BUY:
    	price = Ask;

        break;
	case OP_SELL:
    	price = Bid;

        break;
    }
	//дельта цены для получения требуемого профита
	tp = NormalizeDouble(MathAbs(NormalizeDouble(getTp(symb, cmd, takeProfitKoef, takeProfit) - price, Digits)) * 0.25, Digits);

	for (int i = 0; i < OrdersTotal(); i++) {
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true) {
			if (OrderSymbol() == symb && OrderType() == cmd) {
				double ordProf = OrderTakeProfit();
				
				if (ordProf > 0) {
					if (NormalizeDouble(MathAbs(NormalizeDouble(ordProf - price, Digits)), Digits) >= tp) {
						//"текущий профит" должен быть "выше" 75% профита некоторого уже открытого ордера, для текущих цен
						return (true);
					}
				}
			}
		}
	}

	return (false);
}

//расчет величины среднего профита на периоде, отдельно считается для sell и buy
int getProfitValue(string symb, int cmd, int controlPerod = 120, double takeProfit = 0.0) {
	double retProfValue, avgProfBears, avgProfBulls;
	int cntBarBears, cntBarBulls, i = 0;

	if (symb == "")
		symb = Symbol();

	while ((Time[0] - Time[i]) / 60 < controlPerod) {
		if (Close[i] > Open[i]) {
			//бычья свеча
			avgProfBulls += High[i] - Low[i];
			cntBarBulls++;
		} else {
			if (Close[i] < Open[i]) {
				//медвежья свеча
				avgProfBears += High[i] - Low[i];
				cntBarBears++;
			}
		}

		i++;
	}

	switch (cmd) {
	case OP_BUY:
		if (cntBarBulls == 0) {
			retProfValue = takeProfit;
		} else {
			retProfValue = MathCeil(avgProfBulls / Point / cntBarBulls);
		}

        break;
	case OP_SELL:
		if (cntBarBears == 0) {
			retProfValue = takeProfit;
		} else {
			retProfValue = MathCeil(avgProfBears / Point / cntBarBears);
		}

        break;
    default:
    	retProfValue = 0;
    }

//	Print(avgProfBulls, " ", cntBarBulls, " ", avgProfBears, " ", cntBarBears);

   	return (retProfValue);
}

//проверка сигналов аллигатора
int chkAlligatorSignal(string symb, int jawsPeriod, int jawsShift, int teethPeriod, int teethShift, int lipsPeriod,
					   int lipsShift, double dltAligBuy, double dltAligSell) {
	int signal = 0;
	double valMAGrNow, valMARdNow, valMARdHist, valMAGrHist, valMABlNow, valMABlHist; 

	if (symb == "")
		symb = Symbol();

	//MODE_SMMA, PRICE_CLOSE
	//MODE_LWMA, PRICE_WEIGHTED
	valMAGrNow = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORLIPS, 0); // зелёная -3
	valMARdNow = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORTEETH, 0); // красная линия -4
	valMARdHist = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORTEETH, 0 + 1); // красная
	valMAGrHist = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORLIPS, 0 + 1); // зелёная
	valMABlNow = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORJAW, 0); // синия линия -8
	valMABlHist = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORJAW, 0 + 1); // синия линия

	//индикация тренда "было"
	ObjectDelete("aligHistUp_object");
	ObjectCreate("aligHistUp_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("aligHistUp_object", OBJPROP_CORNER, 1);
	ObjectSet("aligHistUp_object", OBJPROP_XDISTANCE, 37);
	ObjectSet("aligHistUp_object", OBJPROP_YDISTANCE, 12);

	ObjectDelete("aligHistDown_object");
	ObjectCreate("aligHistDown_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("aligHistDown_object", OBJPROP_CORNER, 1);
	ObjectSet("aligHistDown_object", OBJPROP_XDISTANCE, 37);
	ObjectSet("aligHistDown_object", OBJPROP_YDISTANCE, 17);

	if (valMARdHist > valMAGrHist) {
		ObjectSetText("aligHistUp_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("aligHistUp_object", OBJPROP_COLOR, Red);

		ObjectSetText("aligHistDown_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("aligHistDown_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("aligHistUp_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("aligHistUp_object", OBJPROP_COLOR, Lime);

		ObjectSetText("aligHistDown_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("aligHistDown_object", OBJPROP_COLOR, Red);
	}
	//индикация тренда "сейчас"
	ObjectDelete("aligNowUp_object");
	ObjectCreate("aligNowUp_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("aligNowUp_object", OBJPROP_CORNER, 1);
	ObjectSet("aligNowUp_object", OBJPROP_XDISTANCE, 30);
	ObjectSet("aligNowUp_object", OBJPROP_YDISTANCE, 12);

	ObjectDelete("aligNowDown_object");
	ObjectCreate("aligNowDown_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("aligNowDown_object", OBJPROP_CORNER, 1);
	ObjectSet("aligNowDown_object", OBJPROP_XDISTANCE, 30);
	ObjectSet("aligNowDown_object", OBJPROP_YDISTANCE, 17);

	if (valMARdNow > valMAGrNow) {
		ObjectSetText("aligNowUp_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("aligNowUp_object", OBJPROP_COLOR, Red);

		ObjectSetText("aligNowDown_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("aligNowDown_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("aligNowUp_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("aligNowUp_object", OBJPROP_COLOR, Lime);

		ObjectSetText("aligNowDown_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("aligNowDown_object", OBJPROP_COLOR, Red);
	}
	//Print("Gr=", valMAGr, " Red=", valMARd, " Gr1=", valMAGr1, " Red1=", valMARd1, " Bl=", valMABl, " Bl1=", valMABl1);
	//up CCI > 70 или алиг красн пересекает зеленую снизу вверх, то покупать
	//down CCI < -70 или алиг красн пересекает зеленую сверху вниз, то продавать

    if (NormalizeDouble(valMAGrNow - valMARdNow, Digits) >= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& ((NormalizeDouble(valMARdHist - valMAGrHist, Digits) >= NormalizeDouble(dltAligBuy * Point, Digits)))) {
    			//|| (valMAGr1 - valMARd1 >= NormalizeDouble(dltAligBuy * Point, Digits)))
    	//зеленая над красной и пред. зеленая под красной
        signal = signal | sgnlBuyOpen | sgnlSellClose;
	}

    if (NormalizeDouble(valMARdNow - valMAGrNow, Digits) >= NormalizeDouble(dltAligSell * Point, Digits) 
    		&& ((NormalizeDouble(valMAGrHist - valMARdHist, Digits) >= NormalizeDouble(dltAligSell * Point, Digits)))) {
    			//|| (valMARd1 - valMAGr1 >= NormalizeDouble(dltAligSell * Point, Digits)))
    	//зеленая под красной и пред. зеленая над красной
        signal = signal | sgnlSellOpen | sgnlBuyClose;
	}

	//
    if (NormalizeDouble(valMAGrNow - valMABlNow, Digits) >= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& NormalizeDouble(valMAGrHist - valMABlHist, Digits) < NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//зеленая над синей и предыдущая зеленая под синей
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if (NormalizeDouble(valMAGrNow - valMABlNow, Digits) <= NormalizeDouble(dltAligSell * Point, Digits)
    		&& NormalizeDouble(valMAGrHist - valMABlHist, Digits) > NormalizeDouble(dltAligSell * Point, Digits)) {
    	//зеленая под синей и пред. зеленая над синей
		signal = signal | sgnlSellOpen | sgnlBuyClose;
   	}

    if (NormalizeDouble(valMAGrNow - valMARdNow, Digits) <= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& NormalizeDouble(valMAGrHist - valMARdHist, Digits) > NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//зеленая под красной и пред. зеленая над красной
        signal = signal | sgnlSellOpen | sgnlBuyClose;
    }

	if (NormalizeDouble(valMAGrNow - valMARdNow, Digits) >= NormalizeDouble(dltAligSell * Point, Digits)
			&& NormalizeDouble(valMAGrHist - valMARdHist, Digits) < NormalizeDouble(dltAligSell * Point, Digits)) {
    	//зеленая над красной и пред. зеленая под красной
        signal = signal | sgnlBuyOpen | sgnlSellClose;
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

/*	if(TimeHour(TimeCurrent()) > tradeTime)
		cantrade=true;

    if(TimeHour(TimeCurrent()) == tradeTime && cantrade) {
*/
    	if (NormalizeDouble(Open[t1] - Open[t2], Digits) > NormalizeDouble(delta_S * Point, Digits)) {
        	//condition is fulfilled, enter a short position:
			signal = signal | sgnlSellOpen;// | sgnlBuyClose;
        
        	cantrade = false; //prohibit repeated trade until the next bar
    	}

      	if (NormalizeDouble(Open[t2] - Open[t1], Digits) > NormalizeDouble(delta_L * Point, Digits)) {
        	// condition is fulfilled, enter a long position
			signal = signal | sgnlBuyOpen;// | sgnlSellClose;
        
        	cantrade = false;
      	}
//	}

	return (signal);
}

//проверка сигналов Tarzan
int chkTarzanSignal(string symb) {
	int signal = 0;
	bool destUpHist, destUpNow;

	if (symb == "")
		symb = Symbol();
	//настоящее
    double valTarzanRsi = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 0, 0);
    double valTarzanMa = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 1, 0);

	if (valTarzanRsi > valTarzanMa)
		destUpNow = true;
	else
		destUpNow = false;
	//прошлое
    double valTarzanRsi1 = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 0, 1);
    double valTarzanMa1 = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 1, 1);

	if (valTarzanRsi1 > valTarzanMa1)
		destUpHist = true;
	else
		destUpHist = false;
	//индикация состояния
	//индикация тренда "было"
	ObjectDelete("trandHist_object");
	ObjectCreate("trandHist_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("trandHist_object", OBJPROP_CORNER, 1);
	ObjectSet("trandHist_object", OBJPROP_XDISTANCE, 20);
	ObjectSet("trandHist_object", OBJPROP_YDISTANCE, 15);

	if (destUpHist == true) {
		ObjectSetText("trandHist_object", CharToStr(236), 10, "Wingdings");//
		ObjectSet("trandHist_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("trandHist_object", CharToStr(238), 10, "Wingdings");//
		ObjectSet("trandHist_object", OBJPROP_COLOR, Red);
	}
	//индикация тренда "сейчас"
	ObjectCreate("trandNow_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("trandNow_object", OBJPROP_CORNER, 1);
	ObjectSet("trandNow_object", OBJPROP_XDISTANCE, 10);
	ObjectSet("trandNow_object", OBJPROP_YDISTANCE, 15);

	if (destUpNow == true) {
		ObjectSetText("trandNow_object", CharToStr(236), 10, "Wingdings");//
		ObjectSet("trandNow_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("trandNow_object", CharToStr(238), 10, "Wingdings");//
		ObjectSet("trandNow_object", OBJPROP_COLOR, Red);
	}
	//учесть CCI для определения направления тренда
    double valCCINew = iCCI(symb, 0, 22, PRICE_WEIGHTED, 0),
    	   valCCIOld = iCCI(symb, 0, 22, PRICE_WEIGHTED, 1);

	//рассчет сигнала
    if ((destUpHist == true && destUpNow == true) && (valCCINew > valCCIOld)) {
    	//устойчивый восходящий тренд
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if ((destUpHist == false && destUpNow == false) && (valCCINew < valCCIOld)) {
    	//устойчивый нисходящий тренд
		signal = signal | sgnlSellOpen | sgnlBuyClose;
    }

    if (destUpHist == false && destUpNow == true) {
    	//тренд повернул вверх
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if (destUpHist == true && destUpNow == false) {
    	//тренд переломился вниз
		signal = signal | sgnlSellOpen | sgnlBuyClose;
    }

	return (signal);
}

//проверка сигналов от шаблонов
int chkPatternSignal(string symb) {
//3 последовательных падающих бара: (O=H)>(L=C) причем O1>O2>O3 и C1>C2>C3 - будет расти
//3 последовательно растущих бара: (O=L)<(H=C) причем O1<O2<O3 и C1<C2<C3 - будет падать
	int signal = 0;

	if (symb == "")
		symb = Symbol();

	return (signal);
}

//создать объект "индикатор-работы"
bool createIndicator(string expertName) {
	ObjectCreate("labelproj_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("labelproj_object", OBJPROP_CORNER, 1);
	ObjectSet("labelproj_object", OBJPROP_XDISTANCE, 50);
	ObjectSet("labelproj_object", OBJPROP_YDISTANCE, 4);
	ObjectSetText("labelproj_object", expertName, 8, "@Luxi Mono");
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
	ObjectSetText("labelproj_object", text, 8, "@Luxi Mono");
//	ObjectSet("indicator_object", OBJPROP_COLOR, Green); //цвета DarkGreen Green ForestGreen LimeGreen Lime - Red Maroon - Black
}