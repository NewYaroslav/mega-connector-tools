//+------------------------------------------------------------------+
//|                              AutoConnectorLite (Intrade.Bar).mq5 |
//|                      Copyright 2022-2023, MegaConnector Software.|
//|                                       https://mega-connector.com |
//+------------------------------------------------------------------+

#define INDICATOR_VERSION "1.07"

#property strict
#property copyright "Copyright 2022-2024, MegaConnector Software."
#property link      "https://mega-connector.com"
#property description "Custom signal builder with integrated connector for MegaConnector Trading Platform."
#property description " "
#property description "Automated Binary Optons Trading"
#property version INDICATOR_VERSION
#property icon "images\\icon.ico"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <MegaConnector\v1\utils\connector-ui.mqh>

#include <MegaConnector\v1\api\bapi-v1.mqh>
#include <MegaConnector\v1\utils\simple-bo-label.mqh>
#include <MegaConnector\v1\utils\tools.mqh>
#include <MegaConnector\v1\utils\signal_capture.mqh>

input McAnchorPoint anchor_point = MC_BOTTOM_LEFT;   //Anchor point on screen
//+------------------------------------------------------------------+
McUI connector_ui;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    if(!connector_ui.init("Auto Connector Lite " INDICATOR_VERSION, false, anchor_point)) return(INIT_FAILED);
    if(!connector_ui.Run()) return(INIT_FAILED);
    if (!EventSetMillisecondTimer(500)) return(INIT_FAILED);
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    EventKillTimer();
    connector_ui.Destroy(reason);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
    return (0);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
    static int tick = 0;
    tick++;
    Print("tick ",tick);
    if (tick == 5) {
        connector_ui.set_software_connection(true);
    } else
    if (tick == 10) {
        connector_ui.set_broker_connection(true);
    } else
    if (tick == 15) {
        connector_ui.set_balance(true, "USD", 101.2, 2);
    } else
    if (tick == 18) {
        connector_ui.set_balance(true, "RUB", 1000001.2, 2);
    } else if (tick >= 20) {
        tick = 0;
        connector_ui.set_software_connection(false);
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
    connector_ui.chart_event(id,lparam,dparam,sparam);
}
