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

#define sgnlObjectPosY 14

//��������� ������
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

//���������� ������� ����������� �������� ���� ��������
string getStringNameOfOperation(int cmd) {
	switch (cmd) {
		case OP_BUY:
			return ("BUY");
		case OP_SELL:
			return ("SELL");
		default:
			return ("");
	}
}

void changeIndicatorMoney(int state, double percent_buy = 0, double percent_sell = 0) {
	if (ObjectFind("moneyChk_object") == -1) {
		ObjectCreate("moneyChk_object", OBJ_LABEL, 0, 0, 0);
	} else {
//		ObjectDelete("moneyChk_object");
	}

	ObjectSet("moneyChk_object", OBJPROP_CORNER, 1);
	ObjectSet("moneyChk_object", OBJPROP_XDISTANCE, 15);
	ObjectSet("moneyChk_object", OBJPROP_YDISTANCE, sgnlObjectPosY);
	ObjectSetText("moneyChk_object", "$B" + StringTrimLeft(StringTrimRight(DoubleToStr(percent_buy, 0))) + "% S" + StringTrimLeft(StringTrimRight(DoubleToStr(percent_sell, 0))) + "%", 10);

	switch (state) {
		case stateDisableMoney:
			ObjectSet("moneyChk_object", OBJPROP_COLOR, Gray);

        	break;
		case stateNoMoney:
			ObjectSet("moneyChk_object", OBJPROP_COLOR, Red);

        	break;
		case stateHaveMoney:
			ObjectSet("moneyChk_object", OBJPROP_COLOR, Lime);

        	break;
	}
}
//�������� ��������� �������
bool chkMoney(string symb, int cmd, double marginPercent, double lot = 0.01, bool dsplMsg = true) {
	if (symb == "") {
		symb = Symbol();
	}

	double freeMargin = AccountFreeMarginCheck(symb, cmd, lot);
	double freeMargin_buy = AccountFreeMarginCheck(symb, OP_BUY, lot);
	double freeMargin_sell = AccountFreeMarginCheck(symb, OP_SELL, lot);
//	Print(DoubleToStr(cmd, 0) + "-" + DoubleToStr((freeMargin / AccountBalance()) * 100, 0));
// ��������� ��������/ �������� �� ����� * 100 = �������\
	double percentfree = 0, percentfree_buy = 0, percentfree_sell = 0, accbal = AccountBalance();
    if (accbal != 0) {
		percentfree = (freeMargin / accbal) * 100;
		percentfree_buy = (freeMargin_buy / accbal) * 100;
		percentfree_sell = (freeMargin_sell / accbal) * 100;
	}
	if (percentfree <= marginPercent || GetLastError() == ERR_NOT_ENOUGH_MONEY) {
		changeIndicatorMoney(stateNoMoney, percentfree_buy, percentfree_sell);
		
		if (dsplMsg == true) {
			Print(symb + " " + getStringNameOfOperation(cmd) + " " + DoubleToStr(lot, 2) + " �� ����� ��������� ����� " + DoubleToStr((freeMargin / AccountBalance()) * 100, 0) + "%<" + DoubleToStr(marginPercent, 0) + "%");
		}

		return (false);
	} else {
		changeIndicatorMoney(stateHaveMoney, percentfree_buy, percentfree_sell);
		
		return (true);
	}
}

//������ �������
double getTp(string symb, int cmd, double takeProfitKoef, int takeProfit, double inPrice = 0.0) {
	double tp, spread, price;

	if (symb == "") {
		symb = Symbol();
	}

	//����� ��� � ������� � ������ ��������� ��������� 
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

//������ �����
double getSl(string symb, int cmd, double stopLossKoef, int stopLoss, double inPrice = 0.0) {
	double sl, spread, minStop, price;

	if (symb == "") {
		symb = Symbol();
	}

	//����� ��� � ������� � ������ ��������� ��������� 
	spread = MarketInfo(symb, MODE_SPREAD);
	//���.���������
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

//������� �����
bool openOrder(string symb, int cmd, double lot, int magicNum, int slipPage = 1, bool ndd = true, 
			   double stopLossKoef = 0.0, double stopLoss = 0.0, double takeProfitKoef = 0.0, double takeProfit = 0.0,
//			   bool trailingUse, int trailingProfStart,
			   bool dsplMsg = true, string comment = "") {
    double sl, tp;
    int ticket;
    bool Repeat = true;

	if (symb == "") {
		symb = Symbol();
	}

    //������� �����    
    while (Repeat == true) {
        if (IsTradeAllowed() == true) {
            switch (cmd) {
            case OP_BUY:
                //��������
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
                //���������
                if (comment == "") {
                	comment = "SELL";
                }

                if (ndd == true) {
	                ticket = OrderSend(symb, OP_SELL, lot, Bid, slipPage, 0, 0, comment, magicNum, 0, Red);
                } else {
            		tp = getTp(symb, OP_SELL, takeProfitKoef, takeProfit);
            		sl = getSl(symb, OP_SELL, stopLossKoef, stopLoss);

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
        	Repeat = false;
        }
    }

 	if (ndd == true && ticket != -1) {
    	//�������� ����� - ��������� ���� � ������
    	int cntAttempt = 10;
    	Repeat = true;

    	while (Repeat == true && cntAttempt > 0) {
    		cntAttempt--;
    		//�������� ����
        	RefreshRates();

        	switch (cmd) {
        	case OP_BUY:
            	//��������
            	tp = getTp(symb, OP_BUY, takeProfitKoef, takeProfit);
            	sl = getSl(symb, OP_BUY, stopLossKoef, stopLoss);

            	break;
        	case OP_SELL:
            	//���������
            	tp = getTp(symb, OP_SELL, takeProfitKoef, takeProfit);
            	sl = getSl(symb, OP_SELL, stopLossKoef, stopLoss);

            	break;
            default:
            	sl = 0.0;
            	tp = 0.0;
        	}


        	if (IsTradeAllowed() == true && (sl != 0.0 || tp != 0.0)) {
        		if (OrderModify(ticket, OrderOpenPrice(), sl, tp, CLR_NONE) == true) {
            		Repeat = false;
        		} else {
	           		if (chkError(GetLastError()) == true) {
            			//����������� ������
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
      		" %=", (AccountFreeMargin() / AccountBalance()) * 100);
	}

    return (ticket);
}

//���������� ���� ��� ������
bool setProfitToLockOrder(int ticket, double stopLossKoef = 0.0, int stopLoss = 0) {
   	if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
		string comment = OrderComment();
		int endTicketInComment = StringFind(comment, "#Tp#");
		double sl, tp = StrToDouble(StringSubstr(comment, endTicketInComment + 4));

		if (stopLossKoef != 0 || stopLoss != 0) {
			sl = getSl(OrderSymbol(), OrderType(), stopLossKoef, stopLoss, 0.0);
		} else {
			sl = NormalizeDouble(0.0, Digits);
		}

		if (OrderModify(ticket, OrderOpenPrice(), sl, tp, CLR_NONE) == false) {
			chkError(GetLastError());

			return (false);
		}
	}
}

//������� ����� � ���������� �������
bool closeOrder(int ticket, double lots, double price, int slipPage, color clrMarker, double stopLossKoef = 0.0, int stopLoss = 0) {
	if (OrderClose(ticket, lots, price, slipPage, clrMarker) == true) {
		//��������� ���� �� ���������� �����
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

//����� ���� ���������� ��������� ������
int getNumberOfBarLastOrder(string symb = "", int tf = 0, int cmd = -1, int magicNum = -1) {
	datetime tmOpenOrder;

	if (symb == "") {
		symb = Symbol();
	}

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

//����� ���������� ����� ��� ������ �������
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

//����� ���������� ����� ��� ������ �������
int findLockedOrder(int ticket, string commentLock) {
	int ticketLckd = -1;

	if (commentLock == "") {
	   	if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true) {
	       	commentLock = OrderComment();
		}
	}

	if (StringFind(commentLock, "Lckd") != -1) {
		//��� ���
		int endTicket = StringFind(commentLock, "#Tp#");

		ticketLckd = StrToInteger(StringSubstr(commentLock, 6, endTicket - 6));

	   	if (ticketLckd != -1) {
	   		if (OrderSelect(ticketLckd, SELECT_BY_TICKET) == true && OrderCloseTime() == 0) {
	   			//����� �� ������
//	   			chkError(GetLastError());
	   		} else {
	   			//�������� ��������
	   			ticketLckd = -1;
//	   			chkError(GetLastError());
//				if (ticket == 8)
//					Print("findLockedOrder=", ticketLckd);
	   		}
	   	}
	}

	return (ticketLckd);
}

//���� �� ����� � ������� ����� ��������?
bool findLikePriceOrder(string symb, int cmd, int magicNum = -1, double takeProfitKoef = 0.0, double takeProfit = 0.0) {
	double tp, deltaTp, price;

	if (symb == "") {
		symb = Symbol();
	}
	//�������� ���� ������� ��� ������� ���
	//tp = getTp(symb, cmd, takeProfitKoef, takeProfit);

	switch (cmd) {
	case OP_BUY:
    	price = Ask;

        break;
	case OP_SELL:
    	price = Bid;

        break;
    }
	//������ ���� ��� ��������� ���������� �������
	tp = NormalizeDouble(getTp(symb, cmd, takeProfitKoef, takeProfit), Digits);
	deltaTp = NormalizeDouble(MathAbs(NormalizeDouble(tp - price, Digits)) * 10.0, Digits);

	for (int i = 0; i < OrdersTotal(); i++) {
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true) {
			if (OrderSymbol() == symb && OrderType() == cmd) {
				double ordProf = OrderTakeProfit();

				if (ordProf > 0) {
					//���������� ������
					if (NormalizeDouble(MathAbs(NormalizeDouble(ordProf - price, Digits)), Digits) <= deltaTp) {
						//"������� ������" ������ ���� "����" 150% ������� ���������� ��� ��������� ������, ��� ������� ���
						//�������� �� ���� ��������(��) �� ���� �������, �.�. ���� ������ ��������� ���� �� ������, �� ��� ����� ������				
						switch (cmd) {
						case OP_BUY:
							if (OrderOpenPrice() < tp) {
								return (true);
							}

    						break;
						case OP_SELL:
							if (OrderOpenPrice() > tp) {
								return (true);
							}

    						break;
						}					
//						if (cmd == OP_SELL)
//							Print("1 ", OrderTicket(), " ", ordProf, " ", price, " ", deltaTp);
//						return (true);
					} else {
//Print("price=", NormalizeDouble(MathAbs(NormalizeDouble(ordProf - price, Digits)), Digits), " delta=", deltaTp);
					}

				}
			}
		}
	}

	return (false);
}

//������ �������� �������� ������� �� �������, �������� ��������� ��� sell � buy
int getProfitValue(string symb, int cmd, int controlPerod = 120, double takeProfit = 0.0) {
	double retProfValue, avgProfBears, avgProfBulls;
	double bulls[], bears[];
	double sumBears = 0,
		   sumBulls = 0;
	int cntBarBears, cntBarBulls, i = 0;

	if (symb == "") {
		symb = Symbol();
	}
	//�������  �������� �� ������
	while (((Time[0] - Time[i]) / 60) < controlPerod) {
		if (Close[i] > Open[i]) {
			//����� �����
			ArrayResize(bulls, cntBarBulls + 1);
			bulls[cntBarBulls] = (High[i] - Low[i]) / Point;
			avgProfBulls += bulls[cntBarBulls];
			cntBarBulls++;
		} else {
			if (Close[i] < Open[i]) {
				//�������� �����
				ArrayResize(bears, cntBarBears + 1);
				bears[cntBarBears] = (High[i] - Low[i]) / Point;
				avgProfBears += bears[cntBarBears];
				cntBarBears++;
			}
		}

		i++;
	}
//MathSqrt(1 / (sum(MathPow((High[i] - Low[i]) - avgProfBears / cntBarBears, 2))))
	//��.��������������
	if (cntBarBulls == 0) {
		avgProfBulls = 0;
		avgProfBears = 0;
	} else {
		avgProfBulls = avgProfBulls / cntBarBulls;
		avgProfBears = avgProfBears / cntBarBears;
	}
	//����� ��������� ��������� ��� �����
	for (i = 0; i < cntBarBulls; i++) {
		sumBulls += MathPow(bulls[i] - avgProfBulls, 2);
	}
	//����� ��������� ��������� ��� ��������
	for (i = 0; i < cntBarBears; i++) {
		sumBears += MathPow(bears[i] - avgProfBears, 2);
	}

	switch (cmd) {
	case OP_BUY:
		if (cntBarBulls == 0) {
			retProfValue = takeProfit;
		} else {
			//�������������������� ����������
			retProfValue = MathCeil(MathSqrt(1.0 / cntBarBulls * sumBulls));// / Point);
		}

        break;
	case OP_SELL:
		if (cntBarBears == 0) {
			retProfValue = takeProfit;
		} else {
			//�������������������� ����������
			retProfValue = MathCeil(MathSqrt(1.0 / cntBarBears * sumBears));// / Point);
		}

        break;
    default:
    	retProfValue = 0;
    }

   	return (retProfValue);
}

//�������� �������� ����������
int chkAlligatorSignal(string symb, int jawsPeriod, int jawsShift, int teethPeriod, int teethShift, int lipsPeriod,
					   int lipsShift, double dltAligBuy, double dltAligSell) {
	int signal = sgnlNothing;
	double valMAGrNow, valMARdNow, valMARdHist, valMAGrHist, valMABlNow, valMABlHist; 

	if (symb == "") {
		symb = Symbol();
	}

	//MODE_SMMA, PRICE_CLOSE
	//MODE_LWMA, PRICE_WEIGHTED
	valMAGrNow = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORLIPS, 0); // ������ -3
	valMARdNow = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORTEETH, 0); // ������� ����� -4
	valMARdHist = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORTEETH, 0 + 1); // �������
	valMAGrHist = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORLIPS, 0 + 1); // ������
	valMABlNow = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORJAW, 0); // ����� ����� -8
	valMABlHist = iAlligator(symb, 0, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod, lipsShift, MODE_LWMA, PRICE_WEIGHTED, MODE_GATORJAW, 0 + 1); // ����� �����

	//��������� ������ "����"
	ObjectDelete("alligHistUp_object");
	ObjectCreate("alligHistUp_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("alligHistUp_object", OBJPROP_CORNER, 1);
	ObjectSet("alligHistUp_object", OBJPROP_XDISTANCE, 97);
	ObjectSet("alligHistUp_object", OBJPROP_YDISTANCE, 12);

	ObjectDelete("alligHistDown_object");
	ObjectCreate("alligHistDown_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("alligHistDown_object", OBJPROP_CORNER, 1);
	ObjectSet("alligHistDown_object", OBJPROP_XDISTANCE, 97);
	ObjectSet("alligHistDown_object", OBJPROP_YDISTANCE, 17);

	if (valMARdHist > valMAGrHist) {
		ObjectSetText("alligHistUp_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("alligHistUp_object", OBJPROP_COLOR, Red);

		ObjectSetText("alligHistDown_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("alligHistDown_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("alligHistUp_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("alligHistUp_object", OBJPROP_COLOR, Lime);

		ObjectSetText("alligHistDown_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("alligHistDown_object", OBJPROP_COLOR, Red);
	}
	//��������� ������ "������"
	ObjectDelete("alligNowUp_object");
	ObjectCreate("alligNowUp_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("alligNowUp_object", OBJPROP_CORNER, 1);
	ObjectSet("alligNowUp_object", OBJPROP_XDISTANCE, 90);
	ObjectSet("alligNowUp_object", OBJPROP_YDISTANCE, 12);

	ObjectDelete("alligNowDown_object");
	ObjectCreate("alligNowDown_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("alligNowDown_object", OBJPROP_CORNER, 1);
	ObjectSet("alligNowDown_object", OBJPROP_XDISTANCE, 90);
	ObjectSet("alligNowDown_object", OBJPROP_YDISTANCE, 17);

	if (valMARdNow > valMAGrNow) {
		ObjectSetText("alligNowUp_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("alligNowUp_object", OBJPROP_COLOR, Red);

		ObjectSetText("alligNowDown_object", CharToStr(218), 10, "Wingdings");//
		ObjectSet("alligNowDown_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("alligNowUp_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("alligNowUp_object", OBJPROP_COLOR, Lime);

		ObjectSetText("alligNowDown_object", CharToStr(217), 10, "Wingdings");//
		ObjectSet("alligNowDown_object", OBJPROP_COLOR, Red);
	}
	//Print("Gr=", valMAGr, " Red=", valMARd, " Gr1=", valMAGr1, " Red1=", valMARd1, " Bl=", valMABl, " Bl1=", valMABl1);
	//up CCI > 70 ��� ���� ����� ���������� ������� ����� �����, �� ��������
	//down CCI < -70 ��� ���� ����� ���������� ������� ������ ����, �� ���������

    if (NormalizeDouble(valMAGrNow - valMARdNow, Digits) >= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& ((NormalizeDouble(valMARdHist - valMAGrHist, Digits) >= NormalizeDouble(dltAligBuy * Point, Digits)))) {
    			//|| (valMAGr1 - valMARd1 >= NormalizeDouble(dltAligBuy * Point, Digits)))
    	//������� ��� ������� � ����. ������� ��� �������
        signal = signal | sgnlBuyOpen | sgnlSellClose;
	}

    if (NormalizeDouble(valMARdNow - valMAGrNow, Digits) >= NormalizeDouble(dltAligSell * Point, Digits) 
    		&& ((NormalizeDouble(valMAGrHist - valMARdHist, Digits) >= NormalizeDouble(dltAligSell * Point, Digits)))) {
    			//|| (valMARd1 - valMAGr1 >= NormalizeDouble(dltAligSell * Point, Digits)))
    	//������� ��� ������� � ����. ������� ��� �������
        signal = signal | sgnlSellOpen | sgnlBuyClose;
	}

	//
    if (NormalizeDouble(valMAGrNow - valMABlNow, Digits) >= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& NormalizeDouble(valMAGrHist - valMABlHist, Digits) < NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//������� ��� ����� � ���������� ������� ��� �����
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if (NormalizeDouble(valMAGrNow - valMABlNow, Digits) <= NormalizeDouble(dltAligSell * Point, Digits)
    		&& NormalizeDouble(valMAGrHist - valMABlHist, Digits) > NormalizeDouble(dltAligSell * Point, Digits)) {
    	//������� ��� ����� � ����. ������� ��� �����
		signal = signal | sgnlSellOpen | sgnlBuyClose;
   	}

    if (NormalizeDouble(valMAGrNow - valMARdNow, Digits) <= NormalizeDouble(dltAligBuy * Point, Digits)
    		&& NormalizeDouble(valMAGrHist - valMARdHist, Digits) > NormalizeDouble(dltAligBuy * Point, Digits)) {
    	//������� ��� ������� � ����. ������� ��� �������
        signal = signal | sgnlSellOpen | sgnlBuyClose;
    }

	if (NormalizeDouble(valMAGrNow - valMARdNow, Digits) >= NormalizeDouble(dltAligSell * Point, Digits)
			&& NormalizeDouble(valMAGrHist - valMARdHist, Digits) < NormalizeDouble(dltAligSell * Point, Digits)) {
    	//������� ��� ������� � ����. ������� ��� �������
        signal = signal | sgnlBuyOpen | sgnlSellClose;
	}

/*
    if ((valAlligatorGr - valAlligatorGr1 >= dltAlig * Point) && (valAlligatorGr >= valAlligatorRed)) { 
		return (sgnlBUY);
    } else
        if ((valAlligatorGr1 - valAlligatorGr >= dltAlig * Point) && (valAlligatorRed >= valAlligatorGr)) {
			return (sgnlSELL);
        }

            blue            = -8,         //��������� ����������         
            red             = -3,
            green           = 8,          
      bylo_buy = seychas_buy;       //"������� ����� ��� �����" :)
      bylo_sell = seychas_sell;
      double blue_line=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_WEIGHTED, MODE_GATORJAW, blue);
      double red_line=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_WEIGHTED, MODE_GATORTEETH , red);
      double green_line=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_WEIGHTED, MODE_GATORLIPS , green);
      double  PriceHigh= High[0];
      if (green_line>blue_line+shirina1)        // ������� �����
      seychas_buy=1;                
      if (green_line<blue_line-shirina1)
      seychas_sell=1;
      if (green_line+shirina2<red_line)         // ������� ������
      seychas_buy=0;
      if (blue_line+shirina2<red_line)
      seychas_sell=0;

*/
	return (signal);
}

//�������� �������� Longa
int chkLongSignal(string symb) {
	int signal = sgnlNothing;
 	int t1 = 6, t2 = 2, delta_L = 6, delta_S = 21, tradeTime = 7;
	static bool cantrade = true;

	if (symb == "") {
		symb = Symbol();
	}

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

//�������� �������� Tarzan
int chkTarzanSignal(string symb) {
	int signal = sgnlNothing;
	bool destUpHist, destUpNow;

	if (symb == "") {
		symb = Symbol();
	}
	//���������
    double valTarzanRsi = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 0, 0);
    double valTarzanMa = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 1, 0);

	if (valTarzanRsi > valTarzanMa) {
		destUpNow = true;
	} else {
		destUpNow = false;
	}
	//�������
    double valTarzanRsi1 = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 0, 1);
    double valTarzanMa1 = iCustom(symb, 0, "TARZAN", 0, 5, 6, 50, 3, 5, 1, 1);

	if (valTarzanRsi1 > valTarzanMa1) {
		destUpHist = true;
	} else {
		destUpHist = false;
	}
	//��������� ���������
	//��������� ������ "����"
	ObjectDelete("trandHist_object");
	ObjectCreate("trandHist_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("trandHist_object", OBJPROP_CORNER, 1);
	ObjectSet("trandHist_object", OBJPROP_XDISTANCE, 87);
	ObjectSet("trandHist_object", OBJPROP_YDISTANCE, 15);

	if (destUpHist == true) {
		ObjectSetText("trandHist_object", CharToStr(236), 10, "Wingdings");//
		ObjectSet("trandHist_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("trandHist_object", CharToStr(238), 10, "Wingdings");//
		ObjectSet("trandHist_object", OBJPROP_COLOR, Red);
	}
	//��������� ������ "������"
	ObjectCreate("trandNow_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("trandNow_object", OBJPROP_CORNER, 1);
	ObjectSet("trandNow_object", OBJPROP_XDISTANCE, 80);
	ObjectSet("trandNow_object", OBJPROP_YDISTANCE, 15);

	if (destUpNow == true) {
		ObjectSetText("trandNow_object", CharToStr(236), 10, "Wingdings");//
		ObjectSet("trandNow_object", OBJPROP_COLOR, Lime);
	} else {
		ObjectSetText("trandNow_object", CharToStr(238), 10, "Wingdings");//
		ObjectSet("trandNow_object", OBJPROP_COLOR, Red);
	}
	//������ CCI ��� ����������� ����������� ������
    double valCCINew = iCCI(symb, 0, 22, PRICE_WEIGHTED, 0),
    	   valCCIOld = iCCI(symb, 0, 22, PRICE_WEIGHTED, 1);

	//������� �������
    if ((destUpHist == true && destUpNow == true) && (valCCINew > valCCIOld)) {
    	//���������� ���������� �����
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if ((destUpHist == false && destUpNow == false) && (valCCINew < valCCIOld)) {
    	//���������� ���������� �����
		signal = signal | sgnlSellOpen | sgnlBuyClose;
    }

    if (destUpHist == false && destUpNow == true) {
    	//����� �������� �����
		signal = signal | sgnlBuyOpen | sgnlSellClose;
    }

    if (destUpHist == true && destUpNow == false) {
    	//����� ����������� ����
		signal = signal | sgnlSellOpen | sgnlBuyClose;
    }

	return (signal);
}

//�������� �������� �� ��������
int chkPatternSignal(string symb) {
//3 ���������������� �������� ����: (O=H)>(L=C) ������ O1>O2>O3 � C1>C2>C3 - ����� �����
//3 ��������������� �������� ����: (O=L)<(H=C) ������ O1<O2<O3 � C1<C2<C3 - ����� ������
	int signal = sgnlNothing;

	if (symb == "") {
		symb = Symbol();
	}

	return (signal);
}

int chkTradeLinesSignal(string symb) {
	int signal = sgnlNothing;
	int otstup = 0;
	//Up
	double price = ObjectGetValueByShift("TrendlineUp", 1);
    if(price != 0) {
	    if(iHigh(NULL, 0, 1) > price && iClose(NULL, 0, 1) < price && (iHigh(NULL, 0, 2) + otstup * Point != EMPTY_VALUE)) signal = signal | sgnlSellOpen | sgnlBuyClose;
	    if(iOpen(NULL, 0, 1) < price && iClose(NULL, 0, 1) > price && (iLow(NULL, 0, 2) - otstup * Point != EMPTY_VALUE)) signal = signal | sgnlBuyOpen | sgnlSellClose;
	    //PrintFormat("TrendlineUp=%f %i iHigh1=%f iClose=%f iHigh2=%f iLow=%f", price, signal, iHigh(NULL, 0, 1), iClose(NULL, 0, 1), iHigh(NULL, 0, 2), iLow(NULL, 0, 2));
	}     
	//Down
	price = ObjectGetValueByShift("TrendlineDn", 1);
    if(price != 0) {
	    if(iLow(NULL, 0, 1) < price && iClose(NULL, 0, 1) > price && (iLow(NULL, 0, 2) - otstup * Point != EMPTY_VALUE)) signal = signal | sgnlBuyOpen | sgnlSellClose;
	    if(iOpen(NULL, 0, 1) > price && iClose(NULL, 0, 1) < price && (iHigh(NULL, 0, 2) + otstup * Point != EMPTY_VALUE)) signal = signal | sgnlSellOpen | sgnlBuyClose;
	    //PrintFormat("TrendlineDn=%f %i", price, signal);
    }

	return (signal);
}
//������� ������ "���������-������"
bool createIndicator(string expertName) {
	ObjectCreate("labelproj_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("labelproj_object", OBJPROP_CORNER, 1);
	ObjectSet("labelproj_object", OBJPROP_XDISTANCE, 50);
	ObjectSet("labelproj_object", OBJPROP_YDISTANCE, 4);
	ObjectSetText("labelproj_object", expertName, 8, "@Luxi Mono");
	ObjectSet("labelproj_object", OBJPROP_COLOR, White);
}

//������� ������ "���������-������" 
bool closeIndicator() {
	ObjectDelete("labelproj_object");
}

//�������� ��������� ������� "���������-������" 
bool changeIndicatorState(string text) {
//	static int chrIndx, clrIndx = Green;
	//"�������" ������ ����, 183-194 ����
/*	if(chrIndx < 195) chrIndx++;
	else chrIndx = 183; 
   if(clrIndx == Green) clrIndx = Red;
   else clrIndx = Green;
   clrIndx++;
   Print(clrIndx);
*/
	ObjectSetText("labelproj_object", text, 8, "@Luxi Mono");
//	ObjectSet("indicator_object", OBJPROP_COLOR, Green); //����� DarkGreen Green ForestGreen LimeGreen Lime - Red Maroon - Black
}