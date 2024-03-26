//+------------------------------------------------------------------+
//|                                                  DarkPoint62.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <Trade/Trade.mqh>


CTrade trade;

int handleDarkPoint;
int totalBars;
ulong posTicket;

int chart_id = 0;

input group "MFI"
input ENUM_APPLIED_VOLUME dark_point_applied_volume = VOLUME_TICK;
input ENUM_TIMEFRAMES dark_point_timeframe = PERIOD_CURRENT;
input  int dark_point_ma_period = 14;      

int isTrendAllowed;

input group "TSL";
input double lots = 0.01;
input double LotsMultiplier = 2;
input int TpPoint = 300;
input int SlPoint = 150;
input int Magic = 111;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      handleDarkPoint = iCustom(_Symbol,dark_point_timeframe,"Market/Dark Point MT5.ex5","","DP_",40,3,1.0,"",14,"",true,0.8,true,1.6,true,3.2,true,1.6,true,3.2,false,5.0,"",true);
      totalBars = iBars(_Symbol,dark_point_timeframe);
      trade.SetExpertMagicNumber(Magic);
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
   int bars = iBars(_Symbol,dark_point_timeframe);   
   if(totalBars != bars ){
      totalBars = bars;
      
      double dpBuy[],dpSell[],dpBuyStar[],dpSellStar[];
      
      CopyBuffer(handleDarkPoint,0,1,1,dpBuy);
      CopyBuffer(handleDarkPoint,1,1,1,dpSell);
      CopyBuffer(handleDarkPoint,2,1,1,dpBuyStar);
      CopyBuffer(handleDarkPoint,3,1,1,dpSellStar);
      
      if(dpBuy[0] > 0 || dpBuyStar[0] > 0){
         Print(__FUNCTION__," > New buy signal ... ");
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         ask = NormalizeDouble(ask,_Digits);
         
         double tp = ObjectGetDouble(chart_id,"DP_TP_Line1"+IntegerToString(iTime(_Symbol,PERIOD_CURRENT,1)),OBJPROP_PRICE);
         tp = NormalizeDouble(tp,_Digits);
         
         double sl = ObjectGetDouble(chart_id,"DP_SL_Line1"+IntegerToString(iTime(_Symbol,PERIOD_CURRENT,1)),OBJPROP_PRICE);
         sl = NormalizeDouble(sl,_Digits);
      
         if(trade.Sell(lots,_Symbol,ask,sl,tp)){
            posTicket = trade.ResultOrder();
            isTrendAllowed = false;
         }
         
      }
      else if(dpSell[0] > 0 || dpSellStar[0] > 0){
         Print(__FUNCTION__," > New sell signal ... ");
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         bid = NormalizeDouble(bid,_Digits);
         
         double tp = ObjectGetDouble(chart_id,"DP_TP_Line1"+IntegerToString(iTime(_Symbol,PERIOD_CURRENT,1)),OBJPROP_PRICE);
         tp = NormalizeDouble(tp,_Digits);
         
         double sl = ObjectGetDouble(chart_id,"DP_SL_Line1"+IntegerToString(iTime(_Symbol,PERIOD_CURRENT,1)),OBJPROP_PRICE);
         sl = NormalizeDouble(sl,_Digits);
      
         if(trade.Sell(lots,_Symbol,bid,sl,tp)){
            posTicket = trade.ResultOrder();
            isTrendAllowed = false;
         }
      }
      
   }
   
  }
//+------------------------------------------------------------------+
