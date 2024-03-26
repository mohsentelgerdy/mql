//+------------------------------------------------------------------+
//|                                                  Bollinger21.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs

#include <Trade/Trade.mqh>

input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input int ma_period = 20;
input int ma_shift = 0;
input double ma_deviation = 2.0;
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;

input bool IsMAFilter = true;
input int moving_av_period = 200;
input ENUM_MA_METHOD moving_av_method = MODE_SMA;
input ENUM_TIMEFRAMES moving_av_timeframe = PERIOD_CURRENT;
input ENUM_APPLIED_PRICE moving_av_applied_price = PRICE_CLOSE;

input double lots = 0.01;
input int TpPoint = 100;
input int SlPoint = 100;

CTrade trade;

int handleBollinger;
int handleMa;
int totalBars;
ulong posTicket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   handleBollinger = iBands(_Symbol,timeframe,ma_period,ma_shift,ma_deviation,applied_price);
   handleMa = iMA(_Symbol,moving_av_timeframe,moving_av_period,0,moving_av_method,moving_av_applied_price);
   totalBars = iBars(_Symbol,timeframe);
   
   
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
   int bars = iBars(_Symbol,timeframe);
   if(totalBars < bars ){
      totalBars = bars;
      double bbUpper[],bbLowr[],bbMiddle[];
      CopyBuffer(handleBollinger,BASE_LINE,1,2,bbMiddle);
      CopyBuffer(handleBollinger,UPPER_BAND,1,2,bbUpper);
      CopyBuffer(handleBollinger,LOWER_BAND,1,2,bbLowr);
      
      double ma[];
      CopyBuffer(handleMa,BASE_LINE,1,1,ma);
      
      double close1 = iClose(_Symbol,timeframe,1);
      double close2 = iClose(_Symbol,timeframe,2);
      
      double difference = bbUpper[1] - bbLowr[1];
      
      
      
      
      for(int i= PositionsTotal()-1;i >= 0;i--){
         ulong posTicket =PositionGetTicket(i);
         
         CPositionInfo  pos;
         
         if(pos.SelectByTicket(posTicket)){
         
            double posOpen = PositionGetDouble(POSITION_PRICE_OPEN);
            double posSL = PositionGetDouble(POSITION_SL);
            double posTP = PositionGetDouble(POSITION_TP);
            double posLots = PositionGetDouble(POSITION_VOLUME);
            
            double lotsToClose = posLots / 2;
            lotsToClose = NormalizeDouble(lotsToClose,_Digits);
            
            if(pos.PositionType() == POSITION_TYPE_BUY){
               if(close1 > bbMiddle[0]){
                  if(posLots == lots){
                     if(trade.PositionClosePartial(pos.Ticket(),lotsToClose)){
                        Print("pos #",posTicket," we close partially ...");
                        posLots = lots - lotsToClose;
                     }
                  }
               }
               
               if(posLots < lots){
                  double sl = bbLowr[1];
                  sl = NormalizeDouble(sl,_Digits);
                  
                  if(sl > posSL){
                     if(trade.PositionModify(posTicket,sl,posTP)){
                        Print("pos #",posTicket," was modified by Tsl ...");
                     }
                  }
               }
            }
            else if(pos.PositionType() == POSITION_TYPE_SELL){
               if(close1 < bbMiddle[0]){
                  if(posLots == lots){
                     if(trade.PositionClosePartial(pos.Ticket(),lotsToClose)){
                        Print("pos #",posTicket," we close partially ...");
                        posLots = lots - lotsToClose;
                     }
                  }
               }
               
               if(posLots < lots){
                  double sl = bbUpper[1];
                  sl = NormalizeDouble(sl,_Digits);
                  
                  if(sl < posSL || posSL == 0){
                     if(trade.PositionModify(posTicket,sl,posTP)){
                        Print("pos #",posTicket," was modified by Tsl ...");
                     }
                  }
               }
               
            }
         }
      }
         
      
      
      if(close1 > bbUpper[1] && close2 < bbUpper[0]){
         Print("close is above the bbUpper ...");

         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         bid = NormalizeDouble(bid,_Digits);
         
         if(!IsMAFilter || bid < ma[0]){
            double tp = bid - difference;
            tp = NormalizeDouble(tp,_Digits);
            
            double sl = bid + difference;
            sl = NormalizeDouble(sl,_Digits);
         
            if(trade.Sell(lots,_Symbol,bid,sl,tp)){
               posTicket = trade.ResultOrder();
            }
         }
         
      }
      else if(close1 < bbLowr[1] && close2 > bbUpper[0]){
         Print("close is below the bbLower ...");
         
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         ask = NormalizeDouble(ask,_Digits);
         
         if(!IsMAFilter || ask > ma[0]){
            double tp = ask + difference;
            tp = NormalizeDouble(tp,_Digits);
            
            double sl = ask - difference;
            sl = NormalizeDouble(sl,_Digits);
            
            if(trade.Buy(lots,_Symbol,ask,sl ,tp)){
               posTicket = trade.ResultOrder();
            }
         }
         
      }
      
      Comment(
      "\n bbUpper[0] ", DoubleToString(bbUpper[0],_Digits)," | bbUpper[1] ",DoubleToString(bbUpper[1]), 
      "\n bbLowr[0] ", DoubleToString(bbLowr[0],_Digits)," | bbLowr[1] ",DoubleToString(bbLowr[1]),
      "\n bbMiddle[0] ", DoubleToString(bbMiddle[0],_Digits)," | bbMiddle[1] ",DoubleToString(bbMiddle[1]),
      "\n clsoe1 ", DoubleToString(close1,_Digits),
      "\n clsoe2 ", DoubleToString(close2,_Digits),
      "\n ma[0] ", DoubleToString(ma[0],_Digits)
      );
   }  
  }
//+------------------------------------------------------------------+
