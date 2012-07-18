/**
 *-трайлинг-стоп
 *-блок принятия решений (тип ордера, размер лота, покупка-продажа существующего ордера, изменение профита-стопов и т.п.)
 *-расстояние между последовательным открытием ордеров (бары, тики, points)
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
extern int maxOpenOrders = 10; //max количество открытых ордеров
extern double tradeLot = 0.1; //объем ордера
extern int maxSpread = 4;

//extern int openDistanceTic = 20; //расстояние между открытиями ордеров (в тиках)
extern int openDistanceBar = 1; //расстояние между открытиями ордеров (в барах) - имеет больший приоритет. Отсчет от нуля
extern int minMarginPercent = 80; //Процент свободной маржи от Баланса при котором новые ордера не выставляются

//Локер
extern bool lockUse = false; //использовать локирование
extern int lockLevel = 10; //уровень локирования позиции
extern bool lockManagement = false; //использовать управление локами
extern bool lockOpenBySignal = false; //открывать лок только по сигналам

//Трал
extern bool trailingUse = false;
extern int trailingProfStart = 7; //первичный порог для увеличения профита;эти величины расчитывать как величину "шума" цены
extern int trailingProfStep = 10; //порог дальнешего увеличения профита(дельта)
extern bool trailingLoss = false;
extern int trailingLossLevel = 7;

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
	//при трайлинге профит = трайлингстарт
	if (trailingUse == true) {
//		takeProfit = trailingProfStart;
		takeProfitKoef = 0;
	}

    //Учитываем работу 5-ти знака
    if (MarketInfo(workSymb, MODE_DIGITS) == 3 || MarketInfo(workSymb, MODE_DIGITS) == 5) {
    	fiveSign = true;
        numSign = 10;
        slipPage *= 10;
        maxSpread *= 10;
        takeProfit *= 10;
        stopLoss *= 10;
        trailingProfStart *= 10;
        trailingProfStep *= 10;
        trailingLossLevel *= 10;
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
	changeIndicatorState("sprd=" + DoubleToStr(spread, 0)
						 + " BO=" + DoubleToStr(mrktState & sgnlBuyOpen != 0, 0)
			  			 + " BC=" + DoubleToStr(mrktState & sgnlBuyClose != 0, 0)
			  			 + " SO=" + DoubleToStr(mrktState & sgnlSellOpen != 0, 0)
			  			 + " SC=" + DoubleToStr(mrktState & sgnlSellClose != 0, 0));

//	int signalLong = chkLongSignal(workSymb);

	if (dsplSgnl == true && (mrktState > 0))
		Print("BuyOpen=", (mrktState & sgnlBuyOpen != 0),
			  " BuyClose=", (mrktState & sgnlBuyClose != 0),
			  " SellOpen=", (mrktState & sgnlSellOpen != 0),
			  " SellClose=", (mrktState & sgnlSellClose != 0),
			  " spread=", spread,
			  " Ask=", Ask,
			  " Bid=", Bid);
			  /*, || signalLong > 0
			  " BuyOpenLong=", (signalLong & sgnlBuyOpen != 0) ,
			  " BuyCloseLong=", (signalLong & sgnlBuyClose != 0),
			  " SellOpenLong=", (signalLong & sgnlSellOpen != 0),
			  " SellCloseLong=", (signalLong & sgnlSellClose != 0));
*/
	//найти величину профита на интервале(экстремумы и разница между ними)
	//решить что делать с открытыми позициями
  	doSolveWithOpened(mrktState);
	//проверка разрешений открытия новой позиции
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

//Принятие решений о судьбе ордера
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
			//проверка разрешений лока
			if (lockUse == true && OrdersTotal() < maxOpenOrders) {
        		allowLock = true;
    		} else {
        		allowLock = false;
    		}
			//проверка на лок-ордер
			if (StringFind(comment, "Lckd") == -1) {
				thisLock = false;
			} else {
//					if (ticket == 8)
//						Print("prof=", OrderSelect(3, SELECT_BY_TICKET, MODE_TRADES));
				if (findLockedOrder(ticket, comment) == -1) {
					thisLock = false;
					//проверить установлен ли профит для бывшего лока - если нет то установить его
					if (takeProfOrd == 0) { // && (takeProfitKoef != 0 || takeProfit != 0)) {
						setProfitToLockOrder(ticket);
					}
				} else {
					//это лок
					/*
					-закрывать лок и хозяина при достижении одним из них
					прибыли(положит. значения профита) >39% от противоположного ордера.
					-при объеме лота > minlot делать частичное закрытие ордеров(в зависимости что сейчас в прибыли)
					*/
					thisLock = true;
				}
			}

			if (thisLock == false) {
				//это основной ордер
				switch(cmd) {
				case OP_BUY:
        			if (profOrd >= 0) {
	        			if (tradingManagement == true && (mrktState & sgnlBuyClose != 0)) {
        					//закрыть открытый бай, если есть профит
        					closeOrder(ticket, lots, Bid, slipPage, Yellow);
        				}
        			} else {
						//выставить лок или нет?
						//цена меньше допустимой и тренд вниз
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
        				if (tradingManagement == true && (mrktState & sgnlSellClose != 0)) {
        					//закрыть открытый sell, если есть профит
        					closeOrder(ticket, lots, Ask, slipPage, Yellow);
        				}
        			} else {
						//выставить лок или нет?
						//цена больше допустимой и тренд вверх
						if (allowLock == true
								&& (NormalizeDouble(opPrice + NormalizeDouble(lockLevel * Point, Digits), Digits)) <= Bid) {
							if (lockOpenBySignal == true) {
								if (mrktState & sgnlBuyOpen != 0) {
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
    			//Трейлинг Профита
    			if (trailingUse == true) {
    				trailingProf(workSymb, ticket, takeProfitKoef, takeProfit, trailingProfStart, trailingProfStep);
				}
			} else {
				//это лок -- ориентируемся по направлению тренда
				if (lockUse == true && lockManagement == true) {
					switch(cmd) {
					case OP_BUY:
        				if (profOrd > 0 && (mrktState & sgnlBuyClose != 0)) {
    						//закрыть открытый бай, если есть профит
    						closeOrder(ticket, lots, Bid, slipPage, Yellow);
        				} else {
						}

						break;
					case OP_SELL:
        				if (profOrd > 0 && (mrktState & sgnlSellClose != 0)) {
    						//закрыть открытый sell, если есть профит
    						closeOrder(ticket, lots, Ask, slipPage, Yellow);
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

//открыть новые позиции
int doOpenNew(int mrktState) {
	int ticket;
	//проверять историю на 10 баров на разницу между open и closed, она должна быть >= takeprofit - если это не так то вероятен флет
    if (mrktState & sgnlBuyOpen != 0) {
		if (chkAllowNewOrder(workSymb, OP_BUY, tradeLot, magicNum) == true) {
			//покупка
   			ticket = openOrder(workSymb, OP_BUY, tradeLot, magicNum, slipPage, ndd,
         					   stopLossKoef, stopLoss, takeProfitKoef, takeProfit, dsplMsg, "");
   		}
	} else {
        if (mrktState & sgnlSellOpen != 0) {
        	if (chkAllowNewOrder(workSymb, OP_SELL, tradeLot, magicNum) == true) {
 				//продажа
         		ticket = openOrder(workSymb, OP_SELL, tradeLot, magicNum, slipPage, ndd,
         						   stopLossKoef, stopLoss, takeProfitKoef, takeProfit, dsplMsg, "");
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

//	return (signalLong); //плохо
//	return (signalLong | (signalAlligator & signalTarzan));
	return (signalLong | signalTarzan); //+ красивый график(M1-грааль, M5, H24),
										//но распознало слишком мало "лочных" ситуаций - за счет этого сливает
//	return (signalAlligator); //много ложных срабатываний
//	return (signalAlligator & signalTarzan); //за счет тарзана график роста более ровный,
											 //но распознало слишком мало "лочных" ситуаций - за счет этого сливает
//	return (signalTarzan); //++ убыток пропорционален только размеру лока
}

//создать локирующий ордер с привязкой в комментариях
int mkLockOrder(int cmd, int ticket, int magicNum, bool dsplMsg = true) {
	int nwTicket = -1;
	int i = 0;
//	bool chngTake = false;
//	int signalLong = chkTarzanSignal(workSymb);

	if (findLockOrder(ticket) == -1) {
		if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
			//убрать лосс с основного
			double opPriceBsc = OrderOpenPrice();

			while ((OrderStopLoss() != 0) && (i < cntAttempt)) {
				if (OrderModify(ticket, opPriceBsc, 0, OrderTakeProfit(), 0, CLR_NONE) == true) {
//					chngTake = true;

					break;
				} else {
					if (chkError(GetLastError()) == true) {
						//серьезная ошибка
						break;
					}
				}

				i++;
				Print("Попытка модификации ", i, " Loss=", OrderStopLoss(), " Prof=", OrderTakeProfit());
			}

			if (OrderStopLoss() == 0) {
				//лосс на лок = цене окрытия осн.ордера -- либо 1/3 от уровня открытия лока
				//чем больше было локов тем раньше нужно закрыть основной ордер
				double sl = 0, //lockLevel / 3,
					   tp = 0;

				switch(cmd) {
				case OP_BUY:
					//sl = (opPriceBsc - Ask) / Point;
					tp = getTp(workSymb, OP_SELL, takeProfitKoef, takeProfit);
					nwTicket = openOrder(workSymb, OP_SELL, OrderLots(), magicNum, slipPage, ndd, 0, sl, 0, 0,
							 			 dsplMsg, "LckdB#" + DoubleToStr(ticket, 0) + "#Tp#" + DoubleToStr(tp, Digits));

					break;
				case OP_SELL:
					//sl = (Bid - opPriceBsc) / Point;
				    tp = getTp(workSymb, OP_BUY, takeProfitKoef, takeProfit);
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

//проверка разрешения открытия ордера
bool chkAllowNewOrder(string symb, int cmd, double lot = 0.01, int magicNum = -1) {
	if (symb == "")
		symb = Symbol();
	//"текущий профит" должен быть "выше" профита некоторого уже открытого ордера (в том же направлении) на 25%, для текущих цен
//	if (getNumberOfBarLastOrder(symb, 0, cmd, magicNum) > openDistanceBar && chkMoney(symb, cmd, minMarginPercent, lot) == true)
	if (findLikePriceOrder(symb, cmd, magicNum, takeProfitKoef, takeProfit) == false
			&& chkMoney(symb, cmd, minMarginPercent, lot) == true)
		return (true);
	else
		return (false);
}

//управление прибылью
void trailingProf(string symb, int ticket, double takeProfitKoef = 0.0, double takeProfit = 0.0,
				  double trailingProfStart = 0.0, double trailingProfStep = 0.0) {
    double tp, sl, takeProfOrd, opPrice, trail;

   	if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
        RefreshRates();

		takeProfOrd = OrderTakeProfit();
		opPrice = OrderOpenPrice();
		/*-прфтТекущейЦены - прфтОрдера >= TrailingProfStart
		прфт ордера += trailingProfStep
	    */
		switch (OrderType()) {
		case OP_BUY:
		    //прфт текущей цены
			tp = getTp(symb, OP_BUY, 0, takeProfit); //;
//        	tp = NormalizeDouble(Ask + takeProfit * Point, Digits);

			//цена выше или ниже порога срабатывания трейлинга?
        	if (NormalizeDouble(takeProfOrd - opPrice, Digits) <= NormalizeDouble(tp - Ask, Digits)) {
        		//первый порог
        		trail = trailingProfStart;
        	} else {
        		//второй порог
        		trail = trailingProfStep;
        	}

        	if (NormalizeDouble(tp - takeProfOrd, Digits) >= NormalizeDouble(trail * Point, Digits)) {
        		if (trailingLoss == true) {
					//более прибыльный вариант №2
	       			sl = getSl(symb, OP_BUY, 0, trailingLossLevel);
//	       			sl = getSl(symb, OP_BUY, 0, trailingProfStart + trailingProfStep); //1
//	       			sl = getSl(symb, OP_BUY, 0, trailingProfStep); //2

	       			if (opPrice >= sl)
	       				sl = OrderStopLoss();
	       		} else {
       				sl = OrderStopLoss();
	       		}

//	       		if (IsTesting())
//	       			Sleep(1000);
        		//новый прфт
            	if (OrderModify(ticket, opPrice,
            					sl, NormalizeDouble(takeProfOrd + trailingProfStep * Point, Digits), CLR_NONE) == false) {
		    		chkError(GetLastError());
                }
        	}

        	break;
		case OP_SELL:
		    //прфт текущей цены
			tp = getTp(symb, OP_SELL, 0, takeProfit);
//        	tp = NormalizeDouble(Bid - takeProfit * Point, Digits);

			//цена выше или ниже порога срабатывания трейлинга?
        	if (NormalizeDouble(opPrice - takeProfOrd, Digits) <= NormalizeDouble(Bid - tp, Digits)) {
        		//первый порог
        		trail = trailingProfStart;
        	} else {
        		//второй порог
        		trail = trailingProfStep;
        	}

//            if (OrderTakeProfit() - tp >= NormalizeDouble(trailingProfStart * Point, Digits)) {
            if (NormalizeDouble(takeProfOrd - tp, Digits) >= NormalizeDouble(trail * Point, Digits)) {
        		if (trailingLoss == true) {
					//более прибыльный вариант №2
	       			sl = getSl(symb, OP_SELL, 0, trailingLossLevel);
//	       			sl = getSl(symb, OP_SELL, 0, trailingProfStart + trailingProfStep); //1
//	       			sl = getSl(symb, OP_SELL, 0, trailingProfStep); //2

	       			if (opPrice <= sl)
	       				sl = OrderStopLoss();
	       		} else {
       				sl = OrderStopLoss();
	       		}

/*			if (ticket == 2)// && ((takeProfOrd - tp) > 0))
				Print(ticket,
						" ordprof=", NormalizeDouble(opPrice - takeProfOrd, Digits), " currprof=", NormalizeDouble(Bid - tp, Digits),
						" trail=", NormalizeDouble(trail * Point, Digits), " delta=", NormalizeDouble(takeProfOrd - tp, Digits),
						" ", NormalizeDouble(takeProfOrd - tp, Digits) >= NormalizeDouble(trail * Point, Digits));
*/
//	       		if (IsTesting())
//	       			Sleep(1000);
        		//новый прфт    
             	if (OrderModify(ticket, opPrice,
            					sl, NormalizeDouble(takeProfOrd - trailingProfStep * Point, Digits), CLR_NONE) == false) {
		    		chkError(GetLastError());
		    	}
            }

        	break;
    	}
    }
}