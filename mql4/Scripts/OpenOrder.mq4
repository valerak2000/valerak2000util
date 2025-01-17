#property copyright ""
#property link      ""
#property show_inputs

#include <signal.mqh>
#include <commonlibs.mqh>

#include <defvarsExtrn.mqh>
extern bool exSell = false, //открыть ордер SELL
            exBuy = false; //открыть ордер BUY
extern double exTradeLot = 0.1; //объем ордера

#include <defvars.mqh>
//int ticCnt = 0;
int numSign;
int openDistance = 1; //расстояние между открытиями ордеров (?в чем мерять?)

#include "..\experts\useFunction.mqh"
//инициализация
int init() {
	//текущий символ
	workSymb = Symbol();
	//размер min допустимого лота
	minLot = MarketInfo(workSymb, MODE_MINLOT);
	//размер max допустимого лота
   	maxLot = MarketInfo(workSymb, MODE_MAXLOT);
   	//Учитываем работу 5-ти знака
   	if (MarketInfo(workSymb, MODE_DIGITS) == 3 || MarketInfo(workSymb, MODE_DIGITS) == 5) {
      	numSign = 10;
      	exSlipPage *= 10;
      	exTakeProfit *= 10;
      	exStopLoss *= 10;
   	} else {
   		numSign = 1;
   	}

   	return (0);
}

int start() {
	int ticket;

   	if (exTradeLot < minLot) exTradeLot = minLot;
   	if (exTradeLot > maxLot) exTradeLot = maxLot;

	//мин.дистанция
	minStop = MarketInfo(workSymb, MODE_STOPLEVEL);
	//спред уже в пунктах с учетом значности котировок 
	spread = MarketInfo(workSymb, MODE_SPREAD); // * numSign * Point;

	if (exBuy && AccountFreeMarginCheck(workSymb, OP_BUY, exTradeLot) > 0) {
        ticket = openOrder(workSymb, OP_BUY, exTradeLot, exMagicNum, exSlipPage, exNdd, exStopLossKoef, exStopLoss, exTakeProfitKoef, exTakeProfit,
        			   	   exDsplMsg, "");
	}

   	if (exSell && AccountFreeMarginCheck(workSymb, OP_SELL, exTradeLot) > 0) {  
        ticket = openOrder(workSymb, OP_SELL, exTradeLot, exMagicNum, exSlipPage, exNdd, exStopLossKoef, exStopLoss, exTakeProfitKoef, exTakeProfit,
        			   	   exDsplMsg, "");
   	}
   	
   	Print("Баров=" + DoubleToStr(Bars, 0));

   	return (0);
}

