//+------------------------------------------------------------------+
//|                                                 Fibinancci32.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <Trade/Trade.mqh>

#define  FIBO_OBJ "Fibo Retracement"

CTrade trade;

int handleFibo;
int totalBars;
ulong posTicket;

int chart_id = 0;

input int ExpirationHours = 15;
input double RetracementLevel = 61.8;
input ENUM_TIMEFRAMES fibo_timeframe = PERIOD_D1;
input ENUM_TIMEFRAMES fibo_expiration_timeframe = PERIOD_H1;

input double lots = 0.01;
input int TpPoint = 100;
input int SlPoint = 100;
input int Magic = 111;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      //handleFibo = iF(_Symbol,pa_timeframe,pa_step,pa_maximum);
      totalBars = iBars(_Symbol,fibo_timeframe);
      
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
   int bars = iBars(_Symbol,fibo_timeframe);   
   if(totalBars != bars && TimeCurrent() > StringToTime("00:05") ){
      totalBars = bars;
      
      ObjectDelete(chart_id,FIBO_OBJ);
      
      double open = iOpen(_Symbol,fibo_timeframe,1);
      double close = iClose(_Symbol,fibo_timeframe,1);
      
      double high = iHigh(_Symbol,fibo_timeframe,1);
      double low = iLow(_Symbol,fibo_timeframe,1);
      
      datetime timeStart = iTime(_Symbol,fibo_timeframe,1);
      datetime timeEnd = iTime(_Symbol,fibo_timeframe,0) - 1;
      
      datetime expiertion = iTime(_Symbol,fibo_timeframe,0) + ExpirationHours * PeriodSeconds(fibo_expiration_timeframe);
      
      double entry;
      if(close > open){
         ObjectCreate(chart_id,FIBO_OBJ,OBJ_FIBO,0,timeStart,low,timeEnd,high);
         entry = high - (high - low) * RetracementLevel / 100;
         entry = NormalizeDouble(entry,_Digits);
         
         double sl = entry - SlPoint *_Point;
         sl = NormalizeDouble(sl,_Digits);
         
         double tp = entry + TpPoint *_Point;
         tp = NormalizeDouble(tp,_Digits);
         
         if(trade.BuyLimit(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiertion,"buy by fibonancci strategy ...")){
            Print(__FUNCSIG__,"> Buy Order send...");
         }
      }
      else{
         ObjectCreate(chart_id,FIBO_OBJ,OBJ_FIBO,0,timeStart,high,timeEnd,low);
         entry = high - (high - low) * RetracementLevel / 100;
         entry = NormalizeDouble(entry,_Digits);
         
         double sl = entry + SlPoint *_Point;
         sl = NormalizeDouble(sl,_Digits);
         
         double tp = entry - TpPoint *_Point;
         tp = NormalizeDouble(tp,_Digits);
         
         if(trade.SellLimit(lots,entry,_Symbol,sl,tp,ORDER_TIME_SPECIFIED,expiertion,"buy by fibonancci strategy ...")){
            Print(__FUNCSIG__,"> Sell Order send...");
         }
      }
      ObjectSetInteger(chart_id,FIBO_OBJ,OBJPROP_COLOR,clrWhite);
      
      for(int i =0; i <ObjectGetInteger(chart_id,FIBO_OBJ,OBJPROP_LEVELS);i++){
         ObjectSetInteger(chart_id,FIBO_OBJ,OBJPROP_LEVELCOLOR,i,clrWhite);  
      }
      
      
      Comment("\n Start Time: ",timeStart,
      "\n End Time : ",timeEnd);
   }
  }
//+------------------------------------------------------------------+
