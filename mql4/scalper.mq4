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
extern int exControlPeriod = PERIOD_M5; //Период, на котором принимаем решение (работают индикаторы)
extern int exMaxOpenOrders = 10; //max количество открытых ордеров
extern double exTradeLot = 0.01; //объем ордера
extern int exMaxSpread = 4;

//extern int openDistanceTic = 20; //расстояние между открытиями ордеров (в тиках)
extern int exOpenDistanceBar = 1; //расстояние между открытиями ордеров (в барах) - имеет больший приоритет. Отсчет от нуля
extern int exMinMarginPercent = 50; //Процент свободной маржи от Баланса при котором новые ордера не выставляются

//Локер
extern bool exLockUse = false; //использовать локирование
extern int exLockLevel = 10; //уровень локирования позиции
extern bool exLockManagement = false; //использовать управление локами
extern bool exLockOpenBySignal = false; //открывать лок только по сигналам

//Трал
extern bool exTrailingProf = true; //вести профит вдоль цены
extern int exTrailingProfStart = 0; //первичный порог для увеличения профита;расчитывается как величина "шума" цены * 1.5
extern int exTrailingProfStep = 6; //порог дальнешего увеличения профита(дельта)
extern bool exTrailingLoss = true; //вести лось вдоль цены
extern int exTrailingLossStart = 10;
extern int exTrailingLossStep = 2;

//генератор сигналов, через #
extern string exGovernor = "ALG#";

//переменные советника
#include <defvars.mqh>
//время открытия ордера
datetime prevOrderBar;
//int ticCnt = 0;
int numSign, stopLossVar, takeProfitVar, takeProfitBuyVar, takeProfitSellVar;

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
	if (exTrailingProf == true) {
//		takeProfit = trailingProfStart;
		exTakeProfitKoef = 0;
		exStopLossKoef = 0;
	}
	//инициаизация расчетных переменных
	takeProfitVar = exTakeProfit;
	stopLossVar = exStopLoss;
    //Учитываем работу 5-ти знака
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

//деструктор
int deinit() {
	closeIndicator();

	return(0);
}

int start() {
	string state = "";
    //разрешение торговать
    bool allowTrade = false;
	//мин.дистанция
	minStop = MarketInfo(workSymb, MODE_STOPLEVEL);
	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(workSymb, MODE_SPREAD);
	
	if (exTakeProfit == 0) {
		//расчет величин профита и лося на периоде 2ч
		takeProfitBuyVar = getProfitValue(workSymb, OP_BUY, 600, takeProfitVar);
    	takeProfitSellVar = getProfitValue(workSymb, OP_SELL, 600, takeProfitVar);
    	takeProfitVar = MathMax(takeProfitBuyVar, takeProfitSellVar) * 3.0;
    	exTrailingProfStart = MathMax(takeProfitBuyVar, takeProfitSellVar) * 2;
    }
    //проверка торговых сигналов рынка - оракул
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
	//disable индикатор "денег"
	changeIndicatorMoney(stateDisableMoney, 0);
	//моргнуть индикатором состояния
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
	//найти величину профита на интервале(экстремумы и разница между ними)
	//решить что делать с открытыми позициями
  	doSolveWithOpened(mrktState);
	//проверка разрешений открытия новой позиции
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

//Принятие решений о судьбе ордера
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
			//проверка разрешений лока
			if (exLockUse == true && OrdersTotal() < exMaxOpenOrders) {
        		allowLock = true;
    		} else {
        		allowLock = false;
    		}
			//проверка на лок-ордер
			if (StringFind(comment, "Lckd") == -1) {
				thisLock = false;
			} else {
				if (findLockedOrder(ticket, comment) == -1) {
					thisLock = false;
					//проверить установлен ли профит для бывшего лока - если нет то установить его
					if (takeProfOrd == 0) { // && (takeProfitKoef != 0 || takeProfit != 0)) {
						setProfitToLockOrder(ticket, exStopLossKoef, stopLossVar);
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
	        			if (exTradingManagement == true && ((mrktState & sgnlBuyClose) != 0)) {
        					//закрыть открытый бай, если есть профит
        					closeOrder(ticket, lots, Bid, exSlipPage, Yellow, 0.0, 0);
        				}
        			} else {
						//выставить лок или нет?
						//цена меньше допустимой и тренд вниз
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
        					//закрыть открытый sell, если есть профит
        					closeOrder(ticket, lots, Ask, exSlipPage, Yellow, 0.0, 0);
        				}
        			} else {
						//выставить лок или нет?
						//цена больше допустимой и тренд вверх
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
    			//Трейлинг Профита
    			if (exTrailingProf == true || exTrailingLoss == true) {
    				trailingProf(workSymb, ticket, exTakeProfitKoef, takeProfitVar, exTrailingProfStart, exTrailingProfStep);
				}
			} else {
				//это лок -- ориентируемся по направлению тренда
				if (exLockUse == true && exLockManagement == true) {
					switch(cmd) {
					case OP_BUY:
        				if (profOrd > 0 && ((mrktState & sgnlBuyClose) != 0)) {
    						//закрыть открытый бай, если есть профит
    						closeOrder(ticket, lots, Bid, exSlipPage, Yellow, exStopLossKoef, stopLossVar);
        				} else {
						}

						break;
					case OP_SELL:
        				if (profOrd > 0 && ((mrktState & sgnlSellClose) != 0)) {
    						//закрыть открытый sell, если есть профит
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

//открыть новые позиции
int doOpenNew(int mrktState) {
	int ticket;
	//проверять историю на 10 баров на разницу между open и closed, она должна быть >= takeprofit - если это не так то вероятен флет
    if ((mrktState & sgnlBuyOpen) != 0) {
		if (chkAllowNewOrder(workSymb, OP_BUY, exTradeLot, exMagicNum) == true) {
			//покупка
   			ticket = openOrder(workSymb, OP_BUY, exTradeLot, exMagicNum, exSlipPage, exNdd,
         					   exStopLossKoef, stopLossVar, exTakeProfitKoef, takeProfitVar, exDsplMsg, "");
   		} else {
//   			Print("Ордер создавать нельзя!");
   		}
	} else {
        if ((mrktState & sgnlSellOpen) != 0) {
        	if (chkAllowNewOrder(workSymb, OP_SELL, exTradeLot, exMagicNum) == true) {
 				//продажа
         		ticket = openOrder(workSymb, OP_SELL, exTradeLot, exMagicNum, exSlipPage, exNdd,
         						   exStopLossKoef, stopLossVar, exTakeProfitKoef, takeProfitVar, exDsplMsg, "");
   			} else {
//   				Print("Ордер создавать нельзя!");
        	}
        }
    }

	if (ticket > 0) {
	   	prevOrderBar = Time[0]; //Свежий бар, запоминаем время
	}

    return (ticket);
}

//Oracul - узнать сигналы рынка
int chkMarketState() {
	//комбинация сигналов от индикаторов
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
//	return (signalLong); //плохо
//	return (signalLong | (signalAlligator & signalTarzan));
//	return (signalLong | signalTarzan); //+ красивый график(M1-грааль, M5, H24),
										//но распознало слишком мало "лочных" ситуаций - за счет этого сливает
//	return (signalAlligator); //много ложных срабатываний
//	return (signalAlligator & signalTarzan); //за счет тарзана график роста более ровный,
											 //но распознало слишком мало "лочных" ситуаций - за счет этого сливает
//	return (signalTarzan); //++ убыток пропорционален только размеру лока

	return (signalLong | signalAlligator | signalTarzan);
}

//создать локирующий ордер с привязкой в комментариях
int mkLockOrder(int cmd, int ticket, int magicNum, bool dsplMsg = true) {
	int nwTicket = -1,
		i = 0;
//	bool chngTake = false;
//	int signalLong = chkTarzanSignal(workSymb);

	if (findLockOrder(ticket) == -1) {
		if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
			//убрать лосс с основного
			double opPriceBsc = OrderOpenPrice();

			while (OrderStopLoss() != 0 && i < cntAttempt) {
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
//				Print("Попытка модификации ", i, " Loss=", OrderStopLoss(), " Prof=", OrderTakeProfit());
			}

			if (OrderStopLoss() == 0) {
				//лосс на лок = цене окрытия осн.ордера -- либо 1/3 от уровня открытия лока
				//чем больше было локов тем раньше нужно закрыть основной ордер
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

//проверка разрешения открытия ордера
bool chkAllowNewOrder(string symb, int cmd, double lot = 0.01, int magicNum = -1) {
	if (symb == "") {
		symb = Symbol();
	}
	//"текущий профит" должен быть "выше" профита некоторого уже открытого ордера (в том же направлении) на 25%, для текущих цен
//	if (getNumberOfBarLastOrder(symb, 0, cmd, magicNum) > openDistanceBar && chkMoney(symb, cmd, minMarginPercent, lot) == true)
	if (findLikePriceOrder(symb, cmd, magicNum, exTakeProfitKoef, takeProfitVar) == false
			&& chkMoney(symb, cmd, exMinMarginPercent, lot, exDsplSgnl) == true) {
		return (true);
	} else {
		return (false);
	}
}

//управление прибылью
//при уходе ордера в "-"-са профит возвращать в первоначальное значение
void trailingProf(string symb, int ticket, double takeProfitKoef = 0.0, double takeProfit = 0.0,
				  double trailingProfStart = 0.0, double trailingProfStep = 0.0) {
    double tp, sl, takeProfOrd, takeLossOrd, opPrice, trailProf, trailLoss;
//хранить массив ордеров ведущихся трейлингом, они будут игнорироваться при tradingManagement=true
   	if (OrderSelect(ticket, SELECT_BY_TICKET) == true) {
        RefreshRates();

		takeProfOrd = OrderTakeProfit();
		takeLossOrd = OrderStopLoss();
		opPrice = OrderOpenPrice();
		//-прфтТекущейЦены - прфтОрдера >= TrailingProfStart
		//прфт ордера += trailingProfStep
		switch (OrderType()) {
		case OP_BUY:
			//управление профитом
        	if (exTrailingProf == true) {
        		//в случае если прибыль по ордеру <0 - нужно восстановить уровень профита в первоначальный вид
        		if (OrderProfit() < 0) {
					tp = NormalizeDouble(getTp(symb, OP_BUY, 0, takeProfit, opPrice), Digits);

        		    if (NormalizeDouble(MathAbs(tp - takeProfOrd), Digits) <= NormalizeDouble(0.01 / numSign, Digits)) {
        		        //при отличии менее чем на 1% профит не изменять
        				tp = takeProfOrd;
	        		}
	       		} else {
		    		//прфт текущей цены
					tp = NormalizeDouble(getTp(symb, OP_BUY, 0, takeProfit, 0.0), Digits);

					if (takeProfOrd <= 0) {
						takeProfOrd = tp;
					}
//        			tp = NormalizeDouble(Ask + takeProfit * Point, Digits);
        			//профит ордера в пунктах больше "текущего" на 1й или 2й порог
        			if (NormalizeDouble(takeProfOrd - opPrice, Digits) <= NormalizeDouble(tp - Ask, Digits)) {
        				//первый порог
        				trailProf = trailingProfStart;
        			} else {
        				//второй порог
        				trailProf = trailingProfStep;
        			}
	    			//расстояние в пунктах между "текущим" и установленным профитом >= порогу срабатывания трейлинга
        			if (NormalizeDouble(tp - takeProfOrd, Digits) >= NormalizeDouble(trailProf * Point, Digits)) {
						tp = NormalizeDouble(takeProfOrd + trailingProfStep * Point, Digits);
        			} else {
        				tp = takeProfOrd;
        			}
        		}
        	} else {
       			tp = takeProfOrd;
        	}
			//управление лоссем
    		if (exTrailingLoss == true) {
				sl = NormalizeDouble(getSl(symb, OP_BUY, 0, exTrailingLossStart, 0.0), Digits);
				//если разница между предыдущим лоссем и новым >= trailingLossStep
       			if (NormalizeDouble(sl - takeLossOrd, Digits) < NormalizeDouble(exTrailingLossStep * Point, Digits)) {
       				sl = takeLossOrd;
       			}
				//если новый лоссь меньше цены открытия
  				if (opPrice >= sl) {
       				sl = takeLossOrd;
       			}
      		} else {
   				sl = takeLossOrd;
       		}

        	break;
		case OP_SELL:
			//управление профитом
        	if (exTrailingProf == true) {
        		//в случае если прибыль по ордеру <0 - нужно восстановить уровень профита в первоначальный вид
        		if (OrderProfit() < 0) {
					tp = NormalizeDouble(getTp(symb, OP_SELL, 0, takeProfit, opPrice), Digits);

        		    if (NormalizeDouble(MathAbs(tp - takeProfOrd), Digits) <= NormalizeDouble(0.01 / numSign, Digits)) {
        		        //при отличии менее чем на 1% профит не изменять
        				tp = takeProfOrd;
        		    }
	       		} else {
		    		//прфт текущей цены
					tp = NormalizeDouble(getTp(symb, OP_SELL, 0, takeProfit, 0.0), Digits);
//		        	tp = NormalizeDouble(Bid - takeProfit * Point, Digits);
					if (takeProfOrd <= 0) {
						takeProfOrd = tp;
					}
        			//профит ордера в пунктах больше "текущего" на 1й или 2й порог
					//цена выше или ниже порога срабатывания трейлинга?
        			if (NormalizeDouble(opPrice - takeProfOrd, Digits) <= NormalizeDouble(Bid - tp, Digits)) {
        				//первый порог
        				trailProf = trailingProfStart;
        			} else {
        				//второй порог
        				trailProf = trailingProfStep;
        			}
	    			//расстояние в пунктах между "текущим" и установленным профитом >= порогу срабатывания трейлинга
        			if (NormalizeDouble(takeProfOrd - tp, Digits) >= NormalizeDouble(trailProf * Point, Digits)) {
						tp = NormalizeDouble(takeProfOrd - NormalizeDouble(trailingProfStep * Point, Digits), Digits);
        			} else {
        				tp = takeProfOrd;
        			}
        		}
        	} else {
       			tp = takeProfOrd;
        	}
			//управление лоссем
    		if (exTrailingLoss == true) {
			    double loss;

    			if (takeLossOrd == 0.0) {
    				loss = NormalizeDouble(1000000.0, Digits);
    			} else {
    				loss = takeLossOrd;
    			}

				sl = NormalizeDouble(getSl(symb, OP_SELL, 0, exTrailingLossStart, 0.0), Digits);
				//если разница между предыдущим лоссем и новым >= trailingLossStep
       			if (NormalizeDouble(loss - sl, Digits) < NormalizeDouble(exTrailingLossStep * Point, Digits)) {
       				sl = takeLossOrd;
       			}
				//если новый лоссь меньше цены открытия
  				if (opPrice <= sl) {
       				sl = takeLossOrd;
       			}
       		} else {
   				sl = takeLossOrd;
       		}

        	break;
    	}
		//установить новый прфт или лоссь
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