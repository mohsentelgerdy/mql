//+------------------------------------------------------------------+
//|                                                   BestMACD14.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <Trade/Trade.mqh>

input int maf = 12;
input int mas = 26;
input int ma_signal = 9;
input double lots = 0.01;
input int TpPoint = 100;
input int SlPoint = 100;

CTrade trade;

int handle_macd;
int barsTotal;
ulong posTicket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handle_macd =iMACD(_Symbol,PERIOD_CURRENT,maf,mas,ma_signal,PRICE_CLOSE);
   barsTotal = iBars(_Symbol,PERIOD_CURRENT);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double macd[],signal[];
   CopyBuffer(handle_macd,MAIN_LINE,1,2,macd);
   CopyBuffer(handle_macd,SIGNAL_LINE,1,2,signal);
   
   if(macd[1] > signal[1] && macd[0] < signal[0]){
      Print(__FUNCTION__,"> Buy CrossOver");
      
      if(posTicket > 0 && PositionSelectByTicket(posTicket)){
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            if(trade.PositionClose(posTicket)){
               Print(__FUNCTION__,"> Sell pos ",posTicket," closed...");
               posTicket = 0;
            }
         }
      }
      else{
         Print(__FUNCTION__,"> pos ",posTicket," was closed already ...");
         posTicket = 0;
      }
      
      if(posTicket<=0){
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         
         double tp = ask + TpPoint * _Point;
         tp = NormalizeDouble(tp,_Digits);
         
         double sl = ask - SlPoint * _Point;
         sl = NormalizeDouble(sl,_Digits);
      
         if(trade.Buy(lots,_Symbol,0,sl,tp)){
            posTicket = trade.ResultOrder();
         }
      }
   }
   else if(macd[1] < signal[1] && macd[0] > signal[0]){
      Print(__FUNCTION__,"> Sell CrossOver");
      
      if(posTicket > 0 && PositionSelectByTicket(posTicket)){
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            if(trade.PositionClose(posTicket)){
               Print(__FUNCTION__,"> Buy pos ",posTicket," closed...");
               posTicket = 0;
            }
         }
      }
      else{
         Print(__FUNCTION__,"> pos ",posTicket," was closed already ...");
         posTicket = 0;
      }
      
      if(posTicket <= 0){
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         
         double tp = bid - TpPoint * _Point;
         tp = NormalizeDouble(tp,_Digits);
         
         double sl = bid + SlPoint * _Point;
         sl = NormalizeDouble(sl,_Digits);
         
         if(trade.Sell(lots,_Symbol,0,sl ,tp)){
            posTicket = trade.ResultOrder();
         }
      }
   }
   
   Comment("\n macd[0]" , macd[0],
            "\n signal[0]", signal[0],
            "\n barsTotal", barsTotal
   );
  }
//+------------------------------------------------------------------+
