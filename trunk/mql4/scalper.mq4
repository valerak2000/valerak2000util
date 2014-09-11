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
extern int exControlPeriod = PERIOD_M5; //������, �� ������� ��������� ������� (�������� ����������)
extern int exMaxOpenOrders = 10; //max ���������� �������� �������
extern double exTradeLot = 0.01; //����� ������
extern int exMaxSpread = 4;

//extern int openDistanceTic = 20; //���������� ����� ���������� ������� (� �����)
extern int exOpenDistanceBar = 1; //���������� ����� ���������� ������� (� �����) - ����� ������� ���������. ������ �� ����
extern int exMinMarginPercent = 50; //������� ��������� ����� �� ������� ��� ������� ����� ������ �� ������������

//�����
extern bool exLockUse = false; //������������ �����������
extern int exLockLevel = 10; //������� ����������� �������
extern bool exLockManagement = false; //������������ ���������� ������
extern bool exLockOpenBySignal = false; //��������� ��� ������ �� ��������

//����
extern bool exTrailingProf = true; //����� ������ ����� ����
extern int exTrailingProfStart = 0; //��������� ����� ��� ���������� �������;������������� ��� �������� "����" ���� * 1.5
extern int exTrailingProfStep = 6; //����� ���������� ���������� �������(������)
extern bool exTrailingLoss = true; //����� ���� ����� ����
extern int exTrailingLossStart = 10;
extern int exTrailingLossStep = 2;

//��������� ��������, ����� #
extern string exGovernor = "ALG#";

//���������� ���������
#include <defvars.mqh>
//����� �������� ������
datetime prevOrderBar;
//int ticCnt = 0;
int numSign, stopLossVar, takeProfitVar, takeProfitBuyVar, takeProfitSellVar;

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
	if (exTrailingProf == true) {
//		takeProfit = trailingProfStart;
		exTakeProfitKoef = 0;
		exStopLossKoef = 0;
	}
	//������������ ��������� ����������
	takeProfitVar = exTakeProfit;
	stopLossVar = exStopLoss;
    //��������� ������ 5-�� �����
    if (MarketInfo(workSymb, MODE_DIGITS) == 3 || MarketInfo(workSymb, MODE_DIGITS) == 5) {
    	fiveSign = true;
        numSign = 10;
        exSlipPage *= 10;
        exMaxSpread *= 10;
 
        takeProfitVar *= 10;
        stopLossVar *= 10;

        exTrailingProfStart *= 10;
        exTrailingProfStep *= 10;
        exTrailingLossStart *= 10;
        exTrailingLossStep *= 10;

        exDltAligBuy *= 10;
        exDltAligSell *= 10;
//    	exTakeProfitKoef *= 10;
//    	exStopLossKoef *= 10;
     	exLockLevel *= 10;
     } else {
    	fiveSign = false;
     	numSign = 1;
     }

    if (exTradeLot < minLot) {
    	exTradeLot = minLot;
    }

    if (exTradeLot > maxLot) {
    	exTradeLot = maxLot;
    }

    createIndicator(expert_name);

    return (0);
}

//����������
int deinit() {
	closeIndicator();

	return(0);
}

int start() {
	string state = "";
    //���������� ���������
    bool allowTrade = false;
	//���.���������
	minStop = MarketInfo(workSymb, MODE_STOPLEVEL);
	//����� ��� � ������� � ������ ��������� ��������� 
	spread = MarketInfo(workSymb, MODE_SPREAD);
	
	if (exTakeProfit == 0) {
		//������ ������� ������� � ���� �� ������� 2�
		takeProfitBuyVar = getProfitValue(workSymb, OP_BUY, 600, takeProfitVar);
    	takeProfitSellVar = getProfitValue(workSymb, OP_SELL, 600, takeProfitVar);
    	takeProfitVar = MathMax(takeProfitBuyVar, takeProfitSellVar) * 3.0;
    	exTrailingProfStart = MathMax(takeProfitBuyVar, takeProfitSellVar) * 2;
    }
    //�������� �������� �������� ����� - ������
	int mrktState = chkMarketState();

	if ((mrktState & sgnlBuyOpen) != 0) {
		state = " BO";
	}
	if ((mrktState & sgnlBuyClose) != 0) {
		state = state + " BC";
	}
	if ((mrktState & sgnlSellOpen) != 0) {
		state = state + " SO";
	}
	if ((mrktState & sgnlSellClose) != 0) {
		state = state + " SC";
	}
	//disable ��������� "�����"
	changeIndicatorMoney(stateDisableMoney, 0);
	//�������� ����������� ���������
	changeIndicatorState("SP=" + DoubleToStr(spread, 0)
						 + " S=" + DoubleToStr(takeProfitSellVar, 0)
			  	   		 + " B=" + DoubleToStr(takeProfitBuyVar, 0)
			  	   		 + " TP=" + DoubleToStr(exTrailingProfStart, 0)
			  	   		 + " [" + state + " ]");

//	int signalLong = chkLongSignal(workSymb);

	if (exDsplSgnl == true && mrktState > 0) {
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
	}
	//����� �������� ������� �� ���������(���������� � ������� ����� ����)
	//������ ��� ������ � ��������� ���������
  	doSolveWithOpened(mrktState);
	//�������� ���������� �������� ����� �������
	if (exTradingOpen == true
			&& spread <= exMaxSpread
			&& mrktState > 0
			&& OrdersTotal() < exMaxOpenOrders
			&& Time[0] != prevOrderBar) {
        allowTrade = true;
    }

   	if (allowTrade == true) {
		doOpenNew(mrktState);
    }

   	return (0);
}

//�������� ������� � ������ ������
void doSolveWithOpened(int mrktState) {
	int ticket, cmd;
	string comment;
	double profOrd, takeProfOrd, lots, opPrice;
	bool allowLock, thisLock;

  	for (int i = 0; i < OrdersTotal(); i++) {
    	if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true
        		&& OrderSymbol() == workSymb
        		&& OrderMagicNumber() == exMagicNum) {
			ticket = OrderTicket();
			cmd = OrderType();
			comment = OrderComment();
			profOrd = OrderProfit();
		   	takeProfOrd = OrderTakeProfit();
		   	lots = OrderLots();
		   	opPrice = OrderOpenPrice();

		   	if (StringLen(comment) == NULL) {
		   		comment = "";
		   	}
			//�������� ���������� ����
			if (exLockUse == true && OrdersTotal() < exMaxOpenOrders) {
        		allowLock = true;
    		} else {
        		allowLock = false;
    		}
			//�������� �� ���-�����
			if (StringFind(comment, "Lckd") == -1) {
				thisLock = false;
			} else {
				if (findLockedOrder(ticket, comment) == -1) {
					thisLock = false;
					//��������� ���������� �� ������ ��� ������� ���� - ���� ��� �� ���������� ���
					if (takeProfOrd == 0) { // && (takeProfitKoef != 0 || takeProfit != 0)) {
						setProfitToLockOrder(ticket, exStopLossKoef, stopLossVar);
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
	        			if (exTradingManagement == true && ((mrktState & sgnlBuyClose) != 0)) {
        					//������� �������� ���, ���� ���� ������
        					closeOrder(ticket, lots, Bid, exSlipPage, Yellow, 0.0, 0);
        				}
        			} else {
						//��������� ��� ��� ���?
						//���� ������ ���������� � ����� ����
//						Print("BuyLckd=", (mrktState & sgnlSellOpen != 0), " prof=", prof, " if=", opPrice - NormalizeDouble(lockLevel * Point, Digits), " Ask=", Ask);

						if (allowLock == true
								&& (NormalizeDouble(opPrice - NormalizeDouble(exLockLevel * Point, Digits), Digits)) >= Ask) {
							if (exLockOpenBySignal == true) {
								if (mrktState & sgnlSellOpen != 0) { 
									mkLockOrder(OP_BUY, ticket, exMagicNum, exDsplMsg);
								}
							} else {
								mkLockOrder(OP_BUY, ticket, exMagicNum, exDsplMsg);
							}
						}
					}

					break;
				case OP_SELL:
        			if (profOrd >= 0) {
        				if (exTradingManagement == true && ((mrktState & sgnlSellClose) != 0)) {
        					//������� �������� sell, ���� ���� ������
        					closeOrder(ticket, lots, Ask, exSlipPage, Yellow, 0.0, 0);
        				}
        			} else {
						//��������� ��� ��� ���?
						//���� ������ ���������� � ����� �����
						if (allowLock == true
								&& (NormalizeDouble(opPrice + NormalizeDouble(exLockLevel * Point, Digits), Digits)) <= Bid) {
							if (exLockOpenBySignal == true) {
								if ((mrktState & sgnlBuyOpen) != 0) {
									mkLockOrder(OP_SELL, ticket, exMagicNum, exDsplMsg);
								}
							} else {
								mkLockOrder(OP_SELL, ticket, exMagicNum, exDsplMsg);
							}
						}
					}

					break;
				//default:
				}
    			//�������� �������
    			if (exTrailingProf == true || exTrailingLoss == true) {
    				trailingProf(workSymb, ticket, exTakeProfitKoef, takeProfitVar, exTrailingProfStart, exTrailingProfStep);
				}
			} else {
				//��� ��� -- ������������� �� ����������� ������
				if (exLockUse == true && exLockManagement == true) {
					switch(cmd) {
					case OP_BUY:
        				if (profOrd > 0 && ((mrktState & sgnlBuyClose) != 0)) {
    						//������� �������� ���, ���� ���� ������
    						closeOrder(ticket, lots, Bid, exSlipPage, Yellow, exStopLossKoef, stopLossVar);
        				} else {
						}

						break;
					case OP_SELL:
        				if (profOrd > 0 && ((mrktState & sgnlSellClose) != 0)) {
    						//������� �������� sell, ���� ���� ������
    						closeOrder(ticket, lots, Ask, exSlipPage, Yellow, exStopLossKoef, stopLossVar);
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
		if (chkAllowNewOrder(workSymb, OP_BUY, exTradeLot, exMagicNum) == true) {
			//�������
   			ticket = openOrder(workSymb, OP_BUY, exTradeLot, exMagicNum, exSlipPage, exNdd,
         					   exStopLossKoef, stopLossVar, exTakeProfitKoef, takeProfitVar, exDsplMsg, "");
   		} else {
//   			Print("����� ��������� ������!");
   		}
	} else {
        if ((mrktState & sgnlSellOpen) != 0) {
        	if (chkAllowNewOrder(workSymb, OP_SELL, exTradeLot, exMagicNum) == true) {
 				//�������
         		ticket = openOrder(workSymb, OP_SELL, exTradeLot, exMagicNum, exSlipPage, exNdd,
         						   exStopLossKoef, stopLossVar, exTakeProfitKoef, takeProfitVar, exDsplMsg, "");
   			} else {
//   				Print("����� ��������� ������!");
        	}
        }
    }

	if (ticket > 0) {
	   	prevOrderBar = Time[0]; //������ ���, ���������� �����
	}

    return (ticket);
}

//Oracul - ������ ������� �����
int chkMarketState() {
	//���������� �������� �� �����������
	int signalTarzan, signalAlligator, signalLong;
/*        //CCI
        double valCCI60 = iCCI(Symbol(), PERIOD_M1, 14, PRICE_TYPICAL, 0);
        double valCCI360 = iCCI(Symbol(), PERIOD_M5, 14, PRICE_TYPICAL, 0);
*/

	if (StringFind(exGovernor, "LNG#") != -1) {
		signalLong = chkLongSignal(workSymb);
	}

	if (StringFind(exGovernor, "ALG#") != -1) {
		signalAlligator = chkAlligatorSignal(workSymb, exJawsPeriod, exJawsShift, exTeethPeriod, exTeethShift, exLipsPeriod,
											 exLipsShift, exDltAligBuy, exDltAligSell);
	}

	if (StringFind(exGovernor, "TRZ#") != -1) {
		signalTarzan = chkTarzanSignal(workSymb);
	}
//	return (signalLong); //�����
//	return (signalLong | (signalAlligator & signalTarzan));
//	return (signalLong | signalTarzan); //+ �������� ������(M1-������, M5, H24),
										//�� ���������� ������� ���� "������" �������� - �� ���� ����� �������
//	return (signalAlligator); //����� ������ ������������
//	return (signalAlligator & signalTarzan); //�� ���� ������� ������ ����� ����� ������,
											 //�� ���������� ������� ���� "������" �������� - �� ���� ����� �������
//	return (signalTarzan); //++ ������ �������������� ������ ������� ����

	return (signalLong | signalAlligator | signalTarzan);
}

//������� ���������� ����� � ��������� � ������������
int mkLockOrder(int cmd, int ticket, int magicNum, bool dsplMsg = true) {
	int nwTicket = -1,
		i = 0;
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
//				Print("������� ����������� ", i, " Loss=", OrderStopLoss(), " Prof=", OrderTakeProfit());
			}

			if (OrderStopLoss() == 0) {
				//���� �� ��� = ���� ������� ���.������ -- ���� 1/3 �� ������ �������� ����
				//��� ������ ���� ����� ��� ������ ����� ������� �������� �����
				double sl = 0, //lockLevel / 3,
					   tp = 0;

				switch(cmd) {
				case OP_BUY:
					//sl = (opPriceBsc - Ask) / Point;
					tp = getTp(workSymb, OP_SELL, exTakeProfitKoef, takeProfitVar, 0.0);
					nwTicket = openOrder(workSymb, OP_SELL, OrderLots(), exMagicNum, exSlipPage, exNdd, 0, sl, 0, 0,
							 			 dsplMsg, "LckdB#" + DoubleToStr(ticket, 0) + "#Tp#" + DoubleToStr(tp, Digits));

					break;
				case OP_SELL:
					//sl = (Bid - opPriceBsc) / Point;
				    tp = getTp(workSymb, OP_BUY, exTakeProfitKoef, takeProfitVar, 0.0);
					nwTicket = openOrder(workSymb, OP_BUY, OrderLots(), magicNum, exSlipPage, exNdd, 0, sl, 0, 0,
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
	if (symb == "") {
		symb = Symbol();
	}
	//"������� ������" ������ ���� "����" ������� ���������� ��� ��������� ������ (� ��� �� �����������) �� 25%, ��� ������� ���
//	if (getNumberOfBarLastOrder(symb, 0, cmd, magicNum) > openDistanceBar && chkMoney(symb, cmd, minMarginPercent, lot) == true)
	if (findLikePriceOrder(symb, cmd, magicNum, exTakeProfitKoef, takeProfitVar) == false
			&& chkMoney(symb, cmd, exMinMarginPercent, lot, exDsplSgnl) == true) {
		return (true);
	} else {
		return (false);
	}
}

//���������� ��������
//��� ����� ������ � "-"-�� ������ ���������� � �������������� ��������
void trailingProf(string symb, int ticket, double takeProfitKoef = 0.0, double takeProfit = 0.0,
				  double trailingProfStart = 0.0, double trailingProfStep = 0.0) {
    double tp, sl, takeProfOrd, takeLossOrd, opPrice, trailProf, trailLoss;
//������� ������ ������� ��������� ����������, ��� ����� �������������� ��� tradingManagement=true
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
        	if (exTrailingProf == true) {
        		//� ������ ���� ������� �� ������ <0 - ����� ������������ ������� ������� � �������������� ���
        		if (OrderProfit() < 0) {
					tp = NormalizeDouble(getTp(symb, OP_BUY, 0, takeProfit, opPrice), Digits);

        		    if (NormalizeDouble(MathAbs(tp - takeProfOrd), Digits) <= NormalizeDouble(0.01 / numSign, Digits)) {
        		        //��� ������� ����� ��� �� 1% ������ �� ��������
        				tp = takeProfOrd;
	        		}
	       		} else {
		    		//���� ������� ����
					tp = NormalizeDouble(getTp(symb, OP_BUY, 0, takeProfit, 0.0), Digits);

					if (takeProfOrd <= 0) {
						takeProfOrd = tp;
					}
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
    		if (exTrailingLoss == true) {
				sl = NormalizeDouble(getSl(symb, OP_BUY, 0, exTrailingLossStart, 0.0), Digits);
				//���� ������� ����� ���������� ������ � ����� >= trailingLossStep
       			if (NormalizeDouble(sl - takeLossOrd, Digits) < NormalizeDouble(exTrailingLossStep * Point, Digits)) {
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
        	if (exTrailingProf == true) {
        		//� ������ ���� ������� �� ������ <0 - ����� ������������ ������� ������� � �������������� ���
        		if (OrderProfit() < 0) {
					tp = NormalizeDouble(getTp(symb, OP_SELL, 0, takeProfit, opPrice), Digits);

        		    if (NormalizeDouble(MathAbs(tp - takeProfOrd), Digits) <= NormalizeDouble(0.01 / numSign, Digits)) {
        		        //��� ������� ����� ��� �� 1% ������ �� ��������
        				tp = takeProfOrd;
        		    }
	       		} else {
		    		//���� ������� ����
					tp = NormalizeDouble(getTp(symb, OP_SELL, 0, takeProfit, 0.0), Digits);
//		        	tp = NormalizeDouble(Bid - takeProfit * Point, Digits);
					if (takeProfOrd <= 0) {
						takeProfOrd = tp;
					}
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
    		if (exTrailingLoss == true) {
			    double loss;

    			if (takeLossOrd == 0.0) {
    				loss = NormalizeDouble(1000000.0, Digits);
    			} else {
    				loss = takeLossOrd;
    			}

				sl = NormalizeDouble(getSl(symb, OP_SELL, 0, exTrailingLossStart, 0.0), Digits);
				//���� ������� ����� ���������� ������ � ����� >= trailingLossStep
       			if (NormalizeDouble(loss - sl, Digits) < NormalizeDouble(exTrailingLossStep * Point, Digits)) {
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
					Print(ticket, " Ask=", NormalizeDouble(Ask, Digits), " Bid=", NormalizeDouble(Bid, Digits),
							" takeLossOrd=", NormalizeDouble(takeLossOrd, Digits), " takeProfOrd=", NormalizeDouble(takeProfOrd, Digits),
							" opPrice=", NormalizeDouble(opPrice, Digits), 
							" sl=", NormalizeDouble(sl, Digits), " tp=", NormalizeDouble(tp, Digits));
    			chkError(GetLastError());
        	}
        }
    }
}