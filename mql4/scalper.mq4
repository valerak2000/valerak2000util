/**
 *-��������-����
 *-���� �������� ������� (��� ������, ������ ����, �������-������� ������������� ������, ��������� �������-������ � �.�.)
 *-���������� ����� ���������������� ��������� ������� (���� � ����)
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
extern int maxOpenOrders = 6; //max ���������� �������� �������
extern double tradeLot = 0.1; //����� ������
extern int maxSpread = 4;

//extern int openDistanceTic = 20; //���������� ����� ���������� ������� (� �����)
extern int openDistanceBar = 1; //���������� ����� ���������� ������� (� �����) - ����� ������� ���������. ������ �� ����

//�����
extern bool lockUse = true; //������������ �����������
extern int lockLevel = 10; //������� ����������� �������

//����
extern bool trailingUse = false;
extern int trailingProfStart = 12;
extern int trailingProfTake = 15;
extern int minMarginPercent = 30; //������� ��������� ����� �� ������� ��� ������� ����� ������ �� ������������

//���������� ���������
#include <defvars.mqh>
//����� �������� ������
datetime prevOrderBar;
//int ticCnt = 0;
int numSign;

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
    //��������� ������ 5-�� �����
    if (MarketInfo(workSymb, MODE_DIGITS) == 3 || MarketInfo(workSymb, MODE_DIGITS) == 5) {
    	fiveSign = true;
        numSign = 10;
        slipPage *= 10;
        maxSpread *= 10;
        trailingProfStart *= 10;
        trailingProfTake *= 10;
        takeProfit *= 10;
        stopLoss *= 10;
        dltAligBuy *= 10;
        dltAligSell *= 10;
     } else {
    	fiveSign = false;
     	numSign = 1;
     	takeProfitKoef *= 10;
     	stopLossKoef *= 10;
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
    //�������� �������� �������� ����� - ������
	int mrktState = chkMarketState();
	//�������� ����������� ���������
	changeIndicatorState("sprd=" + DoubleToStr(spread, 0));

	int signalLong = chkLongSignal(workSymb);

	if (dsplSgnl && (mrktState > 0 || signalLong > 0))
		Print("BuyOpen=", (mrktState & sgnlBuyOpen != 0) ,
			  " BuyClose=", (mrktState & sgnlBuyClose != 0),
			  " SellOpen=", (mrktState & sgnlSellOpen != 0),
			  " SellClose=", (mrktState & sgnlSellClose != 0),
			  " spread=", spread,
			  " Ask=", Ask,
			  " Bid=", Bid,
			  " BuyOpenLong=", (signalLong & sgnlBuyOpen != 0) ,
			  " BuyCloseLong=", (signalLong & sgnlBuyClose != 0),
			  " SellOpenLong=", (signalLong & sgnlSellOpen != 0),
			  " SellCloseLong=", (signalLong & sgnlSellClose != 0));

	//�������� ���������� �������� ����� �������
	if (tradingUse
			&& spread <= maxSpread
			&& mrktState > 0
			&& OrdersTotal() < maxOpenOrders
			&& Time[0] != prevOrderBar)
        allowTrade = true;

   	if (allowTrade) {
		doOpenNew(mrktState);
    }
	//������ ��� ������ � ��������� ��������� 
  	doSolveWithOpened(mrktState);

   	return (0);
}

//�������� ������� � ������ ������
void doSolveWithOpened(int mrktState) {
  	for (int i = 0; i < OrdersTotal(); i++)
    	if (OrderSelect(i, SELECT_BY_POS) == true
        		&& OrderSymbol() == workSymb
        		&& OrderMagicNumber() == magicNum) {
        	int ticket = OrderTicket();
        	string comment = OrderComment();
        	double prof = OrderProfit();
        	int cmd = OrderType();
/*			if (ticket == 28)
				Print(" i=", i, " prof=", prof, " if=", OrderOpenPrice() - NormalizeDouble(lockLevel * Point, Digits), " Ask=", Ask);
*/
			if (StringFind(comment, "Lckd") == -1) {
				//��� �������� �����
				switch(cmd) {
				case OP_BUY:
        			if (prof >= 0) {
	        			if (mrktState & sgnlBuyClose != 0) {
        					//������� �������� ���, ���� ���� ������
        					closeOrder(ticket, OrderLots(), Bid, slipPage, Yellow);
        				}
        			} else {
						//��������� ��� ��� ���?
						//���� ������ ���������� � ����� ����
						if (lockUse && ((OrderOpenPrice() - NormalizeDouble(lockLevel * Point, Digits)) >= Ask)
								&& (mrktState & sgnlSellOpen != 0)) {	
							mkLockOrder(OP_BUY, ticket, magicNum, dsplMsg);
						}
					}

					break;
				case OP_SELL:
        			if (prof >= 0) {
        				if (mrktState & sgnlSellClose != 0) {
        					//������� �������� sell, ���� ���� ������
        					closeOrder(ticket, OrderLots(), Ask, slipPage, Yellow);
        				}
        			} else {
						//��������� ��� ��� ���?
						//���� ������ ���������� � ����� �����
						if (lockUse && ((OrderOpenPrice() + NormalizeDouble(lockLevel * Point, Digits)) <= Bid)
								&& (mrktState & sgnlBuyOpen != 0)) {
							mkLockOrder(OP_SELL, ticket, magicNum, dsplMsg);
						}
					}

					break;
				//default:
				}
			} else {
				//��� ��� -- ������������� �� ����������� ������
				switch(cmd) {
				case OP_BUY:
        			if (prof > 0 && (mrktState & sgnlBuyClose != 0)) {
    					//������� �������� ���, ���� ���� ������
    					closeOrder(ticket, OrderLots(), Bid, slipPage, Yellow);
        			} else {
					}

					break;
				case OP_SELL:
        			if (prof > 0 && (mrktState & sgnlSellClose != 0)) {
    					//������� �������� sell, ���� ���� ������
    					closeOrder(ticket, OrderLots(), Ask, slipPage, Yellow);
        			} else {
					}

					break;
				//default:
				}
			}

    		//�������� �������
    		if (trailingUse) {
    			trailingProf(ticket);
			}
    	} else {
    		chkError(GetLastError());
    	}
}

//������� ����� �������
int doOpenNew(int mrktState) {
	int ticket;

    if (mrktState & sgnlBuyOpen != 0) {
    		if ((getNumberOfBarLastorder(workSymb, 0, OP_BUY, magicNum) > openDistanceBar) && chkMoney(workSymb, OP_BUY, tradeLot)) {
				//�������
       			ticket = openOrder(workSymb, OP_BUY, tradeLot, magicNum, slipPage, ndd, stopLossKoef, stopLoss, takeProfitKoef, takeProfit,
       					   		   dsplMsg, "");
       		}
	} else {
        if (mrktState & sgnlSellOpen != 0) {
        	if ((getNumberOfBarLastorder(workSymb, 0, OP_SELL, magicNum) > openDistanceBar) && chkMoney(workSymb, OP_SELL, tradeLot)) {
 				//�������
         		ticket = openOrder(workSymb, OP_SELL, tradeLot, magicNum, slipPage, ndd, stopLossKoef, stopLoss, takeProfitKoef, takeProfit,
         					   	   dsplMsg, "");
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

//	return (signalLong | (signalAlligator & signalTarzan));
//	return (signalLong | signalTarzan);
	return (signalTarzan);
}

//������� ���������� ����� � ��������� � ������������
int mkLockOrder(int cmd, int ticket, int magicNum, bool dsplMsg = true) {
	int nwTicket = -1;
	bool chngTake = false;
//	int signalLong = chkTarzanSignal(workSymb);

	if (findLockOrder(ticket) == -1) {
		if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true) {
			if (OrderStopLoss() != 0) {
				//������ ���� � ���������
				double opPriceBsc = OrderOpenPrice();

				for (int i = 0; i < cntAttempt; i++) {
					if (OrderModify(ticket, opPriceBsc, 0, OrderTakeProfit(), 0, CLR_NONE) == true) {
						chngTake = true;

						break;
					} else {
   						if (chkError(GetLastError())) {
   							//��������� ������
							break;
						}
					}

//					Print("������� ����������� ", i, " Loss=", OrderStopLoss(), " Prof=", OrderTakeProfit());
				}
			}

			if (chngTake == true) {
				//���� �� ��� = ���� ������� ���.������ -- ���� 1/3 �� ������ �������� ����
				//��� ������ ���� ����� ��� ������ ����� ������� �������� �����
				double sl = lockLevel / 3;!!!!!!!!!!!!

				switch(cmd) {
				case OP_BUY:
					//sl = (opPriceBsc - Ask) / Point;
					nwTicket = openOrder(workSymb, OP_SELL, OrderLots(), magicNum, slipPage, ndd, 0, sl, 0, 0,
							 			 dsplMsg, "LckdB#" + DoubleToStr(ticket, 0));

					break;
				case OP_SELL:
					//sl = (Bid - opPriceBsc) / Point;
					nwTicket = openOrder(workSymb, OP_BUY, OrderLots(), magicNum, slipPage, ndd, 0, sl, 0, 0,
							 			 dsplMsg, "LckdS#" + DoubleToStr(ticket, 0));

					break;
				//default:
				}
			}
		}
	}

	return (nwTicket);
}

//���������� ��������
void trailingProf(int ticket) {
/*    double l_price_0;
    int l_error_8;

    if (OrderType() == OP_BUY) {
        RefreshRates();

        if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) <= NormalizeDouble((-Point) * trailingProfStart, Digits)) {
            l_price_0 = NormalizeDouble(Bid + Point * trailingProfTake, Digits);

           if (NormalizeDouble(OrderTakeProfit(), Digits) > l_price_0 || NormalizeDouble(OrderTakeProfit(), Digits) == 0.0) {
                if (!IsTradeContextBusy()) {
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_price_0, 0, CLR_NONE)) {
                        l_error_8 = GetLastError();
                        Print("Error trailingprofit BUY " + OrderTicket() + " - " + l_error_8);
                    }
                }
           }
        }
    } else
        if (OrderType() == OP_SELL) {
            RefreshRates();

            if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) <= NormalizeDouble((-Point) * trailingProfStart, Digits)) {
                l_price_0 = NormalizeDouble(Ask - Point * trailingProfTake, Digits);

                if (!IsTradeContextBusy()) {
                    if (NormalizeDouble(OrderTakeProfit(), Digits) < l_price_0) {
                       if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), l_price_0, 0, CLR_NONE)) {
                          l_error_8 = GetLastError();
                          Print("Error trailingprofit SELL " + OrderTicket() + " - " + l_error_8);
                       }
                    }
                 } else {
                 }
            }
    }
*/
}

