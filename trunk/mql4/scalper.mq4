/**
 *-трайлинг-стоп
 *-блок принятия решений (тип ордера, размер лота, покупка-продажа существующего ордера, изменение профита-стопов и т.п.)
 *-расстояние между последовательным открытием ордеров (бары и тики)
 *-локирующие ордера, отслеживать скорость изменения прибыли ордера -- как их закрывать???? - расстояние лока - расчетное
 *-проверка доступной маржи на открытие ордера
 *-флаг вывода доп информации
 *-флаг запрета торговли
 *-учет дельты при чтении сигналов рынка
 *-расчетная величина СЛ, ТП, лока (по истории на NN-баров)
*/
#define expert_name "скальпер v.0.1"

#property copyright expert_name
#include <signal.mqh>
#include <commonlibs.mqh>
#include <stderror.mqh>

#include <defvarsExtrn.mqh>
//Параметры советника
extern int сontrolPeriod = PERIOD_M5; //Период, на котором принимаем решение (работают индикаторы)
extern int maxOpenOrders = 6; //max количество открытых ордеров
extern double tradeLot = 0.1; //объем ордера
extern int maxSpread = 4;

//extern int openDistanceTic = 20; //расстояние между открытиями ордеров (в тиках)
extern int openDistanceBar = 1; //расстояние между открытиями ордеров (в барах) - имеет больший приоритет. Отсчет от нуля

//Локер
extern bool lockUse = true; //использовать локирование
extern int lockLevel = 10; //уровень локирования позиции

//Трал
extern bool trailingUse = false;
extern int trailingProfStart = 12;
extern int trailingProfTake = 15;
extern int minMarginPercent = 30; //Процент свободной маржи от Баланса при котором новые ордера не выставляются

//переменные советника
#include <defvars.mqh>
//время открытия ордера
datetime prevOrderBar;
//int ticCnt = 0;
int numSign;

#include "useFunction.mqh"
//инициализация
int init() {
    //текущий символ
	workSymb = Symbol();
	//уровень заморозки ордеров в пунктах
	freezeLevel = MarketInfo(workSymb, MODE_FREEZELEVEL);
	//размер min допустимого лота
	minLot = MarketInfo(workSymb, MODE_MINLOT);
	//размер max допустимого лота
    maxLot = MarketInfo(workSymb, MODE_MAXLOT);
    //Учитываем работу 5-ти знака
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

//деструктор
int deinit() {
	closeIndicator();

	return(0);
}

int start() {
    //разрешение торговать
    bool allowTrade = false;

	//мин.дистанция
	minStop = MarketInfo(workSymb, MODE_STOPLEVEL);
	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(workSymb, MODE_SPREAD);
    //проверка торговых сигналов рынка - оракул
	int mrktState = chkMarketState();
	//моргнуть индикатором состояния
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

	//проверка разрешений открытия новой позиции
	if (tradingUse
			&& spread <= maxSpread
			&& mrktState > 0
			&& OrdersTotal() < maxOpenOrders
			&& Time[0] != prevOrderBar)
        allowTrade = true;

   	if (allowTrade) {
		doOpenNew(mrktState);
    }
	//решить что делать с открытыми позициями 
  	doSolveWithOpened(mrktState);

   	return (0);
}

//Принятие решений о судьбе ордера
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
				//это основной ордер
				switch(cmd) {
				case OP_BUY:
        			if (prof >= 0) {
	        			if (mrktState & sgnlBuyClose != 0) {
        					//закрыть открытый бай, если есть профит
        					closeOrder(ticket, OrderLots(), Bid, slipPage, Yellow);
        				}
        			} else {
						//выставить лок или нет?
						//цена меньше допустимой и тренд вниз
						if (lockUse && ((OrderOpenPrice() - NormalizeDouble(lockLevel * Point, Digits)) >= Ask)
								&& (mrktState & sgnlSellOpen != 0)) {	
							mkLockOrder(OP_BUY, ticket, magicNum, dsplMsg);
						}
					}

					break;
				case OP_SELL:
        			if (prof >= 0) {
        				if (mrktState & sgnlSellClose != 0) {
        					//закрыть открытый sell, если есть профит
        					closeOrder(ticket, OrderLots(), Ask, slipPage, Yellow);
        				}
        			} else {
						//выставить лок или нет?
						//цена больше допустимой и тренд вверх
						if (lockUse && ((OrderOpenPrice() + NormalizeDouble(lockLevel * Point, Digits)) <= Bid)
								&& (mrktState & sgnlBuyOpen != 0)) {
							mkLockOrder(OP_SELL, ticket, magicNum, dsplMsg);
						}
					}

					break;
				//default:
				}
			} else {
				//это лок -- ориентируемся по направлению тренда
				switch(cmd) {
				case OP_BUY:
        			if (prof > 0 && (mrktState & sgnlBuyClose != 0)) {
    					//закрыть открытый бай, если есть профит
    					closeOrder(ticket, OrderLots(), Bid, slipPage, Yellow);
        			} else {
					}

					break;
				case OP_SELL:
        			if (prof > 0 && (mrktState & sgnlSellClose != 0)) {
    					//закрыть открытый sell, если есть профит
    					closeOrder(ticket, OrderLots(), Ask, slipPage, Yellow);
        			} else {
					}

					break;
				//default:
				}
			}

    		//Трейлинг Профита
    		if (trailingUse) {
    			trailingProf(ticket);
			}
    	} else {
    		chkError(GetLastError());
    	}
}

//открыть новые позиции
int doOpenNew(int mrktState) {
	int ticket;

    if (mrktState & sgnlBuyOpen != 0) {
    		if ((getNumberOfBarLastorder(workSymb, 0, OP_BUY, magicNum) > openDistanceBar) && chkMoney(workSymb, OP_BUY, tradeLot)) {
				//покупка
       			ticket = openOrder(workSymb, OP_BUY, tradeLot, magicNum, slipPage, ndd, stopLossKoef, stopLoss, takeProfitKoef, takeProfit,
       					   		   dsplMsg, "");
       		}
	} else {
        if (mrktState & sgnlSellOpen != 0) {
        	if ((getNumberOfBarLastorder(workSymb, 0, OP_SELL, magicNum) > openDistanceBar) && chkMoney(workSymb, OP_SELL, tradeLot)) {
 				//продажа
         		ticket = openOrder(workSymb, OP_SELL, tradeLot, magicNum, slipPage, ndd, stopLossKoef, stopLoss, takeProfitKoef, takeProfit,
         					   	   dsplMsg, "");
        	}
        }
    }

	if (ticket > 0)
	   	prevOrderBar = Time[0]; //Свежий бар, запоминаем время

    return (ticket);
}

//Oracul - узнать сигналы рынка
int chkMarketState() {
	//комбинация сигналов от индикаторов
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

//создать локирующий ордер с привязкой в комментариях
int mkLockOrder(int cmd, int ticket, int magicNum, bool dsplMsg = true) {
	int nwTicket = -1;
	bool chngTake = false;
//	int signalLong = chkTarzanSignal(workSymb);

	if (findLockOrder(ticket) == -1) {
		if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) == true) {
			if (OrderStopLoss() != 0) {
				//убрать лосс с основного
				double opPriceBsc = OrderOpenPrice();

				for (int i = 0; i < cntAttempt; i++) {
					if (OrderModify(ticket, opPriceBsc, 0, OrderTakeProfit(), 0, CLR_NONE) == true) {
						chngTake = true;

						break;
					} else {
   						if (chkError(GetLastError())) {
   							//серьезная ошибка
							break;
						}
					}

//					Print("Попытка модификации ", i, " Loss=", OrderStopLoss(), " Prof=", OrderTakeProfit());
				}
			}

			if (chngTake == true) {
				//лосс на лок = цене окрытия осн.ордера -- либо 1/3 от уровня открытия лока
				//чем больше было локов тем раньше нужно закрыть основной ордер
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

//управление прибылью
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

