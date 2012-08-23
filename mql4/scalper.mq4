/**
 *-��������-����
 *-���� �������� ������� (��� ������, ������ ����, �������-������� ������������� ������, ��������� �������-������ � �.�.)
 *-���������� ����� ���������������� ��������� ������� (����, ����, points)
 *-���������� ������, ����������� �������� ��������� ������� ������ -- ��� �� ���������???? - ���������� ���� - ���������
 *-�������� ��������� ����� �� �������� ������
 *-���� ������ ��� ����������
 *-���� ������� ��������
 *-���� ������ ��� ������ �������� �����
 *-��������� �������� ��, ��, ���� (�� ������� �� NN-�����)
*/
#define expert_name "�������� v.0.1"

#property copyright expert_name
#include <signal.mqh>
#include <commonlibs.mqh>
#include <stderror.mqh>

#include <defvarsExtrn.mqh>
//��������� ���������
extern int �ontrolPeriod = PERIOD_M5; //������, �� ������� ��������� ������� (�������� ����������)
extern int maxOpenOrders = 10; //max ���������� �������� �������
extern double tradeLot = 0.1; //����� ������
extern int maxSpread = 4;

//extern int openDistanceTic = 20; //���������� ����� ���������� ������� (� �����)
extern int openDistanceBar = 1; //���������� ����� ���������� ������� (� �����) - ����� ������� ���������. ������ �� ����
extern int minMarginPercent = 80; //������� ��������� ����� �� ������� ��� ������� ����� ������ �� ������������

//�����
extern bool lockUse = false; //������������ �����������
extern int lockLevel = 10; //������� ����������� �������
extern bool lockManagement = false; //������������ ���������� ������
extern bool lockOpenBySignal = false; //��������� ��� ������ �� ��������

//����
extern bool trailingProf = true; //����� ������ ����� ����
extern int trailingProfStart = 10; //��������� ����� ��� ���������� �������;��� �������� ����������� ��� �������� "����" ����
extern int trailingProfStep = 6; //����� ���������� ���������� �������(������)
extern bool trailingLoss = true; //����� ���� ����� ����
extern int trailingLossStart = 13;
extern int trailingLossStep = 4;

//���������� ���������
#include <defvars.mqh>
//����� �������� ������
datetime prevOrderBar;
//int ticCnt = 0;
int numSign, takeProfitBuy, takeProfitSell;

#include "useFunction.mqh"
//�������������
int init() {
    //������� ������
	workSymb = Symbol();
	//������� ��������� ������� � �������
	freezeLevel = MarketInfo(workSymb, MODE_FREEZELEVEL);
	//������ min ����������� ����
	minLot = MarketInfo(workSymb, MODE_MINLOT);
	//������ max ����������� ����
    maxLot = MarketInfo(workSymb, MODE_MAXLOT);
	//��� ��������� ������ = �������������
	if (trailingProf == true && takeProfitKoef > 0) {
//		takeProfit = trailingProfStart;
		takeProfitKoef = 0;
		stopLossKoef = 0;
	}

    //��������� ������ 5-�� �����
    if (MarketInfo(workSymb, MODE_DIGITS) == 3 || MarketInfo(workSymb, MODE_DIGITS) == 5) {
    	fiveSign = true;
        numSign = 10;
        slipPage *= 10;
        maxSpread *= 10;
 
        takeProfit *= 10;
        stopLoss *= 10;

        trailingProfStart *= 10;
        trailingProfStep *= 10;
        trailingLossStart *= 10;
        trailingLossStep *= 10;

        dltAligBuy *= 10;
        dltAligSell *= 10;
//    	takeProfitKoef *= 10;
//    	stopLossKoef *= 10;
     	lockLevel *= 10;
     } else {
    	fiveSign = false;
     	numSign = 1;
     }

    if (tradeLot < minLot)
    	tradeLot = minLot;

    if (tradeLot > maxLot)
    	tradeLot = maxLot;

    createIndicator(expert_name);

    return (0);
}

//����������
int deinit() {
	closeIndicator();

	return(0);
}

int start() {
    //���������� ���������
    bool allowTrade = false;
	//���.���������
	minStop = MarketInfo(workSymb, MODE_STOPLEVEL);
	//����� ��� � ������� � ������ ��������� ��������� 
	spread = MarketInfo(workSymb, MODE_SPREAD);
	
	if (takeProfitKoef == -1.0) {
		//������ ������� ������� � ���� �� ������� 2�
		takeProfitBuy = getProfitValue(workSymb, OP_BUY, 120, takeProfit);
    	takeProfitSell = getProfitValue(workSymb, OP_SELL, 120, takeProfit);
    	takeProfit = MathMax(takeProfitBuy, takeProfitSell) * 1.5;
    }
    //�������� �������� �������� ����� - ������
	int mrktState = chkMarketState();
	string state;

	if ((mrktState & sgnlBuyOpen) != 0)
		state = state + " BO";
	if ((mrktState & sgnlBuyClose) != 0)
		state = state + " BC";
	if ((mrktState & sgnlSellOpen) != 0)
		state = state + " SO";
	if ((mrktState & sgnlSellClose) != 0)
		state = state + " SC";
	//�������� ����������� ���������
	changeIndicatorState("sd=" + DoubleToStr(spread, 0)
						 + " S=" + DoubleToStr(takeProfitSell, 0)
			  	   		 + " B=" + DoubleToStr(takeProfitBuy, 0)
			  	   		 + " [" + state + " ]");

//	int signalLong = chkLongSignal(workSymb);

	if (dsplSgnl == true && mrktState > 0)
		Print("BuyOpen=", ((mrktState & sgnlBuyOpen) != 0),
			  " BuyClose=", ((mrktState & sgnlBuyClose) != 0),
			  " SellOpen=", ((mrktState & sgnlSellOpen) != 0),
			  " SellClose=", ((mrktState & sgnlSellClose) != 0),
			  " spread=", spread,
			  " Ask=", Ask,
			  " Bid=", Bid);
			  /*, || signalLong > 0
			  " BuyOpenLong=", (signalLong & sgnlBuyOpen != 0) ,
			  " BuyCloseLong=", (signalLong & sgnlBuyClose != 0),
			  " SellOpenLong=", (signalLong & sgnlSellOpen != 0),
			  " SellCloseLong=", (signalLong & sgnlSellClose != 0));
*/
	//����� �������� ������� �� ���������(���������� � ������� ����� ����)
	//������ ��� ������ � ��������� ���������
  	doSolveWithOpened(mrktState);
	//�������� ���������� �������� ����� �������
	if (tradingOpen == true
			&& spread <= maxSpread
			&& mrktState > 0
			&& OrdersTotal() < maxOpenOrders
			&& Time[0] != prevOrderBar)
        allowTrade = true;

   	if (allowTrade == true) {
		doOpenNew(mrktState);
    }

   	return (0);
}

//�������� ������� � ������ ������
void doSolveWithOpened(int mrktState) {
  	for (int i = 0; i < OrdersTotal(); i++) {
    	if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true
        		&& OrderSymbol() == workSymb
        		&& OrderMagicNumber() == magicNum) {
        	int ticket = OrderTicket(),
        		cmd = OrderType();
        	string comment = OrderComment();
        	double profOrd = OrderProfit(),
        		   takeProfOrd = OrderTakeProfit(),
        		   lots = OrderLots(),
        		   opPrice = OrderOpenPrice();
			bool allowLock, thisLock;
			//�������� ���������� ����
			if (lockUse == true && OrdersTotal() < maxOpenOrders) {
        		allowLock = true;
    		} else {
        		allowLock = false;
    		}
			//�������� �� ���-�����
			if (StringFind(comment, "Lckd") == -1) {
				thisLock = false;
			} else {
//					if (ticket == 8)
//						Print("prof=", OrderSelect(3, SELECT_BY_TICKET, MODE_TRADES));
				if (findLockedOrder(ticket, comment) == -1) {
					thisLock = false;
					//��������� ���������� �� ������ ��� ������� ���� - ���� ��� �� ���������� ���
					if (takeProfOrd == 0) { // && (takeProfitKoef != 0 || takeProfit != 0)) {
						setProfitToLockOrder(ticket, stopLossKoef, stopLoss);
					}
				} else {
					//��� ���
					/*
					-��������� ��� � ������� ��� ���������� ����� �� ���
					�������(�������. �������� �������) >39% �� ���������������� ������.
					-��� ������ ���� > minlot ������ ��������� �������� �������(� ����������� ��� ������ � �������)
					*/
					thisLock = true;
				}
			}

			if (thisLock == false) {
				//��� �������� �����
				switch(cmd) {
				case OP_BUY:
        			if (profOrd >= 0) {
	        			if (tradingManagement == true && ((mrktState & sgnlBuyClose) != 0)) {
        					//������� �������� ���, ���� ���� ������
        					closeOrder(ticket, lots, Bid, slipPage, Yellow, 0.0, 0);
        				}
        			} else {
						//��������� ��� ��� ���?
						//���� ������ ���������� � ����� ����
//						Print("BuyLckd=", (mrktState & sgnlSellOpen != 0), " prof=", prof, " if=", opPrice - NormalizeDouble(lockLevel * Point, Digits), " Ask=", Ask);

						if (allowLock == true
								&& (NormalizeDouble(opPrice - NormalizeDouble(lockLevel * Point, Digits), Digits)) >= Ask) {
							if (lockOpenBySignal == true) {
								if (mrktState & sgnlSellOpen != 0) { 
									mkLockOrder(OP_BUY, ticket, magicNum, dsplMsg);
								}
							} else {
								mkLockOrder(OP_BUY, ticket, magicNum, dsplMsg);
							}
						}
					}

					break;
				case OP_SELL:
        			if (profOrd >= 0) {
        				if (tradingManagement == true && ((mrktState & sgnlSellClose) != 0)) {
        					//������� �������� sell, ���� ���� ������
        					closeOrder(ticket, lots, Ask, slipPage, Yellow, 0.0, 0);
        				}
        			} else {
						//��������� ��� ��� ���?
						//���� ������ ���������� � ����� �����
						if (allowLock == true
								&& (NormalizeDouble(opPrice + NormalizeDouble(lockLevel * Point, Digits), Digits)) <= Bid) {
							if (lockOpenBySignal == true) {
								if ((mrktState & sgnlBuyOpen) != 0) {
									mkLockOrder(OP_SELL, ticket, magicNum, dsplMsg);
								}
							} else {
								mkLockOrder(OP_SELL, ticket, magicNum, dsplMsg);
							}
						}
					}

					break;
				//default:
				}
    			//�������� �������
    			if (trailingProf == true || trailingLoss == true) {
    				trailingProf(workSymb, ticket, takeProfitKoef, takeProfit, trailingProfStart, trailingProfStep);
				}
			} else {
				//��� ��� -- ������������� �� ����������� ������
				if (lockUse == true && lockManagement == true) {
					switch(cmd) {
					case OP_BUY:
        				if (profOrd > 0 && ((mrktState & sgnlBuyClose) != 0)) {
    						//������� �������� ���, ���� ���� ������
    						closeOrder(ticket, lots, Bid, slipPage, Yellow, stopLossKoef, stopLoss);
        				} else {
						}

						break;
					case OP_SELL:
        				if (profOrd > 0 && ((mrktState & sgnlSellClose) != 0)) {
    						//������� �������� sell, ���� ���� ������
    						closeOrder(ticket, lots, Ask, slipPage, Yellow, stopLossKoef, stopLoss);
        				} else {
						}

						break;
					//default:
					}
				}
			}
    	} else {
    		chkError(GetLastError());
    	}
    }
}

//������� ����� �������
int doOpenNew(int mrktState) {
	int ticket;
	//��������� ������� �� 10 ����� �� ������� ����� open � closed, ��� ������ ���� >= takeprofit - ���� ��� �� ��� �� �������� ����
    if ((mrktState & sgnlBuyOpen) != 0) {
		if (chkAllowNewOrder(workSymb, OP_BUY, tradeLot, magicNum) == true) {
			//�������
   			ticket = openOrder(workSymb, OP_BUY, tradeLot, magicNum, slipPage, ndd,
         					   stopLossKoef, stopLoss, takeProfitKoef, takeProfit, dsplMsg, "");
   		}
	} else {
        if ((mrktState & sgnlSellOpen) != 0) {
        	if (chkAllowNewOrder(workSymb, OP_SELL, tradeLot, magicNum) == true) {
 				//�������
         		ticket = openOrder(workSymb, OP_SELL, tradeLot, magicNum, slipPage, ndd,
         						   stopLossKoef, stopLoss, takeProfitKoef, takeProfit, dsplMsg, "");
        	}
        }
    }

	if (ticket > 0)
	   	prevOrderBar = Time[0]; //������ ���, ���������� �����

    return (ticket);
}

//Oracul - ������ ������� �����
int chkMarketState() {
	//���������� �������� �� �����������
/*        //CCI
        double valCCI60 = iCCI(Symbol(), PERIOD_M1, 14, PRICE_TYPICAL, 0);
        double valCCI360 = iCCI(Symbol(), PERIOD_M5, 14, PRICE_TYPICAL, 0);
*/
	int signalAlligator = chkAlligatorSignal(workSymb, jawsPeriod, jawsShift, teethPeriod, teethShift, lipsPeriod,
											 lipsShift, dltAligBuy, dltAligSell);

	int signalLong = chkLongSignal(workSymb);
	int signalTarzan = chkTarzanSignal(workSymb);

//	return (signalLong); //�����
//	return (signalLong | (signalAlligator & signalTarzan));
//	return (signalLong | signalTarzan); //+ �������� ������(M1-������, M5, H24),
										//�� ���������� ������� ���� "������" �������� - �� ���� ����� �������
//	return (signalAlligator); //����� ������ ������������
//	return (signalAlligator & signalTarzan); //�� ���� ������� ������ ����� ����� ������,
											 //�� ���������� ������� ���� "������" �������� - �� ���� ����� �������
	return (signalTarzan); //++ ������ �������������� ������ ������� ����
}

//������� ���������� ����� � ��������� � ������������
int mkLockOrder(int cmd, int ticket, int magicNum, bool dsplMsg = true) {
	int nwTicket = -1;
	int i = 0;
//	bool chngTake = false;
//	int signalLong = chkTarzanSignal(workSymb);

	if (findLockOrder(ticket) == -1) {
		if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
			//������ ���� � ���������
			double opPriceBsc = OrderOpenPrice();

			while (OrderStopLoss() != 0 && i < cntAttempt) {
				if (OrderModify(ticket, opPriceBsc, 0, OrderTakeProfit(), 0, CLR_NONE) == true) {
//					chngTake = true;

					break;
				} else {
					if (chkError(GetLastError()) == true) {
						//��������� ������
						break;
					}
				}

				i++;
				Print("������� ����������� ", i, " Loss=", OrderStopLoss(), " Prof=", OrderTakeProfit());
			}

			if (OrderStopLoss() == 0) {
				//���� �� ��� = ���� ������� ���.������ -- ���� 1/3 �� ������ �������� ����
				//��� ������ ���� ����� ��� ������ ����� ������� �������� �����
				double sl = 0, //lockLevel / 3,
					   tp = 0;

				switch(cmd) {
				case OP_BUY:
					//sl = (opPriceBsc - Ask) / Point;
					tp = getTp(workSymb, OP_SELL, takeProfitKoef, takeProfit, 0.0);
					nwTicket = openOrder(workSymb, OP_SELL, OrderLots(), magicNum, slipPage, ndd, 0, sl, 0, 0,
							 			 dsplMsg, "LckdB#" + DoubleToStr(ticket, 0) + "#Tp#" + DoubleToStr(tp, Digits));

					break;
				case OP_SELL:
					//sl = (Bid - opPriceBsc) / Point;
				    tp = getTp(workSymb, OP_BUY, takeProfitKoef, takeProfit, 0.0);
					nwTicket = openOrder(workSymb, OP_BUY, OrderLots(), magicNum, slipPage, ndd, 0, sl, 0, 0,
							 			 dsplMsg, "LckdS#" + DoubleToStr(ticket, 0) + "#Tp#" + DoubleToStr(tp, Digits));

					break;
				//default:
				}
			}
		}
	}

	return (nwTicket);
}

//�������� ���������� �������� ������
bool chkAllowNewOrder(string symb, int cmd, double lot = 0.01, int magicNum = -1) {
	if (symb == "")
		symb = Symbol();
	//"������� ������" ������ ���� "����" ������� ���������� ��� ��������� ������ (� ��� �� �����������) �� 25%, ��� ������� ���
//	if (getNumberOfBarLastOrder(symb, 0, cmd, magicNum) > openDistanceBar && chkMoney(symb, cmd, minMarginPercent, lot) == true)
	if (findLikePriceOrder(symb, cmd, magicNum, takeProfitKoef, takeProfit) == false
			&& chkMoney(symb, cmd, minMarginPercent, lot) == true)
		return (true);
	else
		return (false);
}

//���������� ��������
//��� ����� ������ � "-"-�� ������ ���������� � �������������� ��������
void trailingProf(string symb, int ticket, double takeProfitKoef = 0.0, double takeProfit = 0.0,
				  double trailingProfStart = 0.0, double trailingProfStep = 0.0) {
    double tp, sl, takeProfOrd, takeLossOrd, opPrice, trailProf, trailLoss;

   	if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
        RefreshRates();

		takeProfOrd = OrderTakeProfit();
		takeLossOrd = OrderStopLoss();
		opPrice = OrderOpenPrice();
		//-��������������� - ���������� >= TrailingProfStart
		//���� ������ += trailingProfStep
		switch (OrderType()) {
		case OP_BUY:
			//���������� ��������
        	if (trailingProf == true) {
        		//� ������ ���� ������� �� ������ <0 - ����� ������������ ������� ������� � �������������� ���
        		if (OrderProfit() < 0) {
					tp = NormalizeDouble(getTp(symb, OP_BUY, 0, takeProfit, opPrice), Digits);

        		    if (NormalizeDouble(MathAbs(tp - takeProfOrd), Digits) <= NormalizeDouble(0.01 / numSign, Digits)) {
        		        //��� ������� ����� ��� �� 1% ������ ��������
        				tp = takeProfOrd;
	        		}
	       		} else {
		    		//���� ������� ����
					tp = NormalizeDouble(getTp(symb, OP_BUY, 0, takeProfit, 0.0), Digits);
//        			tp = NormalizeDouble(Ask + takeProfit * Point, Digits);
        			//������ ������ � ������� ������ "��������" �� 1� ��� 2� �����
        			if (NormalizeDouble(takeProfOrd - opPrice, Digits) <= NormalizeDouble(tp - Ask, Digits)) {
        				//������ �����
        				trailProf = trailingProfStart;
        			} else {
        				//������ �����
        				trailProf = trailingProfStep;
        			}
	    			//���������� � ������� ����� "�������" � ������������� �������� >= ������ ������������ ���������
        			if (NormalizeDouble(tp - takeProfOrd, Digits) >= NormalizeDouble(trailProf * Point, Digits)) {
						tp = NormalizeDouble(takeProfOrd + trailingProfStep * Point, Digits);
        			} else {
        				tp = takeProfOrd;
        			}
        		}
        	} else {
       			tp = takeProfOrd;
        	}
			//���������� ������
    		if (trailingLoss == true) {
				sl = NormalizeDouble(getSl(symb, OP_BUY, 0, trailingLossStart, 0.0), Digits);
				//���� ������� ����� ���������� ������ � ����� >= trailingLossStep
       			if (NormalizeDouble(sl - takeLossOrd, Digits) < NormalizeDouble(trailingLossStep * Point, Digits)) {
       				sl = takeLossOrd;
       			}
				//���� ����� ����� ������ ���� ��������
  				if (opPrice >= sl) {
       				sl = takeLossOrd;
       			}
      		} else {
   				sl = takeLossOrd;
       		}

        	break;
		case OP_SELL:
			//���������� ��������
        	if (trailingProf == true) {
        		//� ������ ���� ������� �� ������ <0 - ����� ������������ ������� ������� � �������������� ���
        		if (OrderProfit() < 0) {
					tp = NormalizeDouble(getTp(symb, OP_SELL, 0, takeProfit, opPrice), Digits);

        		    if (NormalizeDouble(MathAbs(tp - takeProfOrd), Digits) <= NormalizeDouble(0.01 / numSign, Digits)) {
        		        //��� ������� ����� ��� �� 1% ������ ��������
        				tp = takeProfOrd;
        		    }
	       		} else {
		    		//���� ������� ����
					tp = NormalizeDouble(getTp(symb, OP_SELL, 0, takeProfit, 0.0), Digits);
//		        	tp = NormalizeDouble(Bid - takeProfit * Point, Digits);
        			//������ ������ � ������� ������ "��������" �� 1� ��� 2� �����
					//���� ���� ��� ���� ������ ������������ ���������?
        			if (NormalizeDouble(opPrice - takeProfOrd, Digits) <= NormalizeDouble(Bid - tp, Digits)) {
        				//������ �����
        				trailProf = trailingProfStart;
        			} else {
        				//������ �����
        				trailProf = trailingProfStep;
        			}
	    			//���������� � ������� ����� "�������" � ������������� �������� >= ������ ������������ ���������
        			if (NormalizeDouble(takeProfOrd - tp, Digits) >= NormalizeDouble(trailProf * Point, Digits)) {
						tp = NormalizeDouble(takeProfOrd - NormalizeDouble(trailingProfStep * Point, Digits), Digits);
        			} else {
        				tp = takeProfOrd;
        			}
        		}
        	} else {
       			tp = takeProfOrd;
        	}
			//���������� ������
    		if (trailingLoss == true) {
			    double loss;

    			if (takeLossOrd == 0.0) {
    				loss = NormalizeDouble(1000000.0, Digits);
    			} else {
    				loss = takeLossOrd;
    			}

				sl = NormalizeDouble(getSl(symb, OP_SELL, 0, trailingLossStart, 0.0), Digits);
				//���� ������� ����� ���������� ������ � ����� >= trailingLossStep
       			if (NormalizeDouble(loss - sl, Digits) < NormalizeDouble(trailingLossStep * Point, Digits)) {
       				sl = takeLossOrd;
       			}
				//���� ����� ����� ������ ���� ��������
  				if (opPrice <= sl) {
       				sl = takeLossOrd;
       			}
       		} else {
   				sl = takeLossOrd;
       		}

        	break;
    	}
		//���������� ����� ���� ��� �����
		if ((takeLossOrd != sl) || (takeProfOrd != tp)) {
    		if (OrderModify(ticket, opPrice, sl, tp, CLR_NONE) == false) {
/*					Print(ticket, " Ask=", NormalizeDouble(Ask, Digits), " Bid=", NormalizeDouble(Bid, Digits),
							" takeLossOrd=", NormalizeDouble(takeLossOrd, Digits), " takeProfOrd=", NormalizeDouble(takeProfOrd, Digits),
							" opPrice=", NormalizeDouble(opPrice, Digits), 
							" sl=", NormalizeDouble(sl, Digits), " tp=", NormalizeDouble(tp, Digits),
							" currloss=", NormalizeDouble(opPrice - takeLossOrd, Digits),
							" trailLoss=", NormalizeDouble(trailLoss * Point, Digits));
*/
    			chkError(GetLastError());
        	}
        }
    }
}