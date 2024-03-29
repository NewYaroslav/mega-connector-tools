//+------------------------------------------------------------------+
//|                                                post_bar_test.mq5 |
//|                      Copyright 2022-2023, MegaConnector Software |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "BUY"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "SELL"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//+------------------------------------------------------------------+
double  arr_up[];
double  arr_dn[];
//+------------------------------------------------------------------+
void set_arrow(const bool direction, const datetime bar_time, const double price);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    SetIndexBuffer(0, arr_up, INDICATOR_DATA);
    SetIndexBuffer(1, arr_dn, INDICATOR_DATA);
    
    SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID);
    SetIndexArrow(0, 233);
    SetIndexEmptyValue(0, EMPTY_VALUE);
    //SetIndexShift(0, 0);
    
    SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID);
    SetIndexArrow(1, 234);
    SetIndexEmptyValue(1, EMPTY_VALUE);
    //SetIndexShift(1, 0);

    ArraySetAsSeries(arr_up, true);
    ArraySetAsSeries(arr_dn, true);

    IndicatorShortName("post bar test");
//---
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    ObjectsDeleteAll(0, "post_test_arrow_");
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]) {
//---
    const int period = 2;
    if (rates_total <= period || rates_total <= 0) return(0);
    
    static bool is_once = false;
    bool is_redraw = false;
    
    const int limit = rates_total - prev_calculated;
    for (int shift = limit-1; shift >= 0; shift--) {  
        //const int index = begin + shift;
        const int index = shift;
        arr_up[index] = EMPTY_VALUE;
        arr_dn[index] = EMPTY_VALUE;
        
        if (!is_once) {
            if (shift > 100) continue;
        }
        
        if ((iTime(NULL, PERIOD_CURRENT, index) % (3*60*Period())) != 0) continue;
        
        const double offset = 0.0;
        const int prev_index = index + 1;
        if (prev_index >= rates_total) continue;
        if (iClose(NULL, PERIOD_CURRENT, index) > iOpen(Symbol(), PERIOD_CURRENT, index)) {
            arr_dn[prev_index] = iClose(NULL, PERIOD_CURRENT, prev_index) + offset * Point();
            arr_up[prev_index] = EMPTY_VALUE;
            set_arrow(false, iTime(NULL, PERIOD_CURRENT, prev_index), arr_dn[prev_index] + offset * Point());
            is_redraw = true;
        } else {
        //if (iClose(NULL, PERIOD_CURRENT, index) < iOpen(Symbol(), PERIOD_CURRENT, index)) {
            arr_up[prev_index] = iClose(NULL, PERIOD_CURRENT, prev_index) - offset * Point();
            arr_dn[prev_index] = EMPTY_VALUE;
            set_arrow(true, iTime(NULL, PERIOD_CURRENT, prev_index), arr_up[prev_index] - offset * Point());
            is_redraw = true;
        }
    }
    is_once = true;
    
    // Обновление графика
    if (is_redraw) ChartRedraw(0);

    return rates_total-1;
}
//+------------------------------------------------------------------+
void set_arrow(const bool direction, const datetime bar_time, const double price) {
    const string arrow_name = "post_test_arrow_" + IntegerToString(bar_time);
    
    if (ObjectFind(0, arrow_name) < 0) {
        if (!ObjectCreate(0, arrow_name, OBJ_ARROW, 0, bar_time, price)) return;
        ObjectSetInteger(0, arrow_name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
        ObjectSetInteger(0, arrow_name, OBJPROP_BACK, false);
        ObjectSetInteger(0, arrow_name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, arrow_name, OBJPROP_SELECTED, false);
        ObjectSetInteger(0, arrow_name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, arrow_name, OBJPROP_ZORDER, 0);
        const int arrow_code = direction ? 233 : 234;
        ObjectSetInteger(0, arrow_name, OBJPROP_ARROWCODE, arrow_code);  // Код стрелки (пользовательское значение)
        if (direction) {
            ObjectSetInteger(0, arrow_name, OBJPROP_COLOR, clrYellowGreen);
        } else {
            ObjectSetInteger(0, arrow_name, OBJPROP_COLOR, clrYellowGreen);
        }
        ObjectSetInteger(0, arrow_name, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, arrow_name, OBJPROP_WIDTH, 1);
        ResetLastError();
        return;
    }

    const int arrow_code = direction ? 233 : 234;
    ObjectSetInteger(0, arrow_name, OBJPROP_ARROWCODE, arrow_code);  // Код стрелки (пользовательское значение)
    if (direction) {
        ObjectSetInteger(0, arrow_name, OBJPROP_COLOR, clrYellowGreen);
    } else {
        ObjectSetInteger(0, arrow_name, OBJPROP_COLOR, clrYellowGreen);
    }
    ResetLastError();
}
//+------------------------------------------------------------------+
