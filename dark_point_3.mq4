//+------------------------------------------------------------------+
//|                                                   dark_point.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- input parameters
input float    LOT=0.01;
input int      NO_OF_TRADES=3;
input int      MAGIC=838;

//+------------------------------------------------------------------+
//       Expert initialization function                  
//       US30   H1
//+------------------------------------------------------------------+
 
int OnInit()
  {
  
  double indicator =  iCustom(Symbol(), PERIOD_CURRENT, "Dark Point", 0, 0, 0);
      
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

int total_order = 1;

double lastTP = 0; //keep track of successful tp to prevent repeat entry (in consolidating market)
double lastSL = 0;

void OnTick()
  {
  
    //take profit
    string obj_name = ObjectName(ObjectsTotal()-1);
    double tp_price = ObjectGet(obj_name, OBJPROP_PRICE1);
    
    int tp2_object_index = ((ObjectsTotal()-4)/10*6)-1;
    obj_name = ObjectName(tp2_object_index+4);
    double tp2 =  ObjectGet(obj_name, OBJPROP_PRICE1);
    
    int tp1_object_index = ((ObjectsTotal()-4)/10*5)-1;
    obj_name = ObjectName(tp1_object_index+4);
    double tp1 =  ObjectGet(obj_name, OBJPROP_PRICE1);
    
    // Print((ObjectsTotal()-4)+";"+tp1_object_index);
    
    int sl_object_index = ((ObjectsTotal()-4)/10)-1;
    obj_name = ObjectName(sl_object_index+4);
    double sl =  ObjectGet(obj_name, OBJPROP_PRICE1);
    
   // Print(sl+";"+tp_price);
    
    bool orderType =  tp_price>sl;  //buy condition  
    
    double PRICE = (Ask+Bid)/2;    
    
    //Print(PRICE+"<>"+total_order);
    
  if((orderType? (PRICE<tp_price && PRICE>sl) : (PRICE>tp_price && PRICE<sl))){ //monitor completion of order
     
     if((TotalOrder(MAGIC)<=NO_OF_TRADES) && total_order<=NO_OF_TRADES){ // Limit number of trades per signal 
        if((lastTP!=tp_price) && (lastSL!=sl)){ //allow new orders after last order is complete
      
         tp_price = (total_order==2?tp2:(total_order==1?tp1 : tp_price));
         Print("(orderType,"+obj_name+",tp)SIGNAL("+(orderType?"buy":"Sell")+","+sl+","+tp_price+")");
         //OrderSend(Symbol(),(orderType?OP_BUY:OP_SELL),LOT,Ask,0,sl,tp_price,0,MAGIC);//0,clrBlack
         total_order++;   
         
        }
      }else if((orderType? (PRICE>tp2) : (PRICE<tp2) )){ //when price reaches tp2 move stoploss to tp1
         ModifyOrders(tp1,tp_price,MAGIC);
      }
      
   }else{ //order is now complete
      if((lastTP!=tp_price) && (lastSL!=sl)){ //allow new orders after last order is complete
            total_order=1;
            lastTP = tp_price;
            lastSL = sl; 
            Print("Total Order Reset");
      }
   }

  }
  
  void ModifyOrders(double sl,double tp,int magic){
      for(int a=0;a<OrdersTotal();a++){
      OrderSelect(a,SELECT_BY_POS);
           if(OrderMagicNumber() == magic)
         {
           OrderSelect(a,SELECT_BY_POS);
         //  OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp);//0,clrBlack
           Print("(sl,tp)MODIFY("+sl+","+tp+")");
         }  
      }
  }
    
    double TotalOrder(int magic)
  {   
   double GetTotalOrder = 0;
   for(int cnt = 0; cnt < OrdersTotal(); cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() == magic)
         {
           GetTotalOrder += (OrdersTotal());
         }   
     }
   return(GetTotalOrder);
  }