//+------------------------------------------------------------------+
//|                              AutoConnectorLite (Intrade.Bar).mq5 |
//|                      Copyright 2022-2024, MegaConnector Software.|
//|                                       https://mega-connector.com |
//+------------------------------------------------------------------+

#define PROGRAM_VERSION "1.11"

#property strict
#property copyright "Copyright 2022-2024, MegaConnector Software."
#property link      "https://mega-connector.com"
#property description "Auto Connector Lite: connects MT5 to the MegaConnector V1 program."
#property description "Specifically designed for use with the Intrade Bar broker."
#property description " "
#property description "Automated Binary Optons Trading"
#property version PROGRAM_VERSION
#property icon "images\\icon.ico"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <MegaConnector\v1\api\bapi-v1.mqh>
#include <MegaConnector\v1\utils\connector-ui.mqh>
#include <MegaConnector\v1\utils\simple-bo-label.mqh>
#include <MegaConnector\v1\utils\tools.mqh>
#include <MegaConnector\v1\utils\signal-capture.mqh>

input string    hr1 =   "===== SIGNAL SETTINGS =========================";  // ===================================
input string    signal_name;                                //Signal Name (optional)
input bool      enable_signal_arrow_capture = false;        //Enable capture of graphical arrow signal

input string    shr1 =  "*Graphical arrow signal";   
input int       arrow_up_code = 233;                        //Up arrow code (Call/Buy)
input int       arrow_dn_code = 234;                        //Down arrow code (Put/Sell)

input string    shr2 =  "*Indicator signal";                                //---
input string    indicator_file_name;                        //Indicator File Name
input int       indicator_id_up = 0;                        //Signal Buffer Up (Call/Buy)
input int       indicator_id_dn = 1;                        //Signal Buffer Down (Put/Sell)

input string    shr3 =  "*Signal capture parameters";                       //---
input McEntryType entry_type                = MC_BO_INTRABAR;   //Entry Type
input bool      enable_zero_signal_ignore   = true;             //Enable zero signal ignore
input int       signal_block_time           = 0;                //Signal blocking Time [sec.]

input string    shr4 =  "*(Only for 'On the intrabar entry' type)";         //---
input bool      enable_capture_previous_bar = false;        //Enable capture on the previous bar
input int       previous_bar_wait_time = 0;                 //Signal waiting time (previous bar) [sec.]

input string    shr5 =  "*(Only for 'On the new bar entry' type)";          //---
input bool      enable_capture_before_bar_close = false;    //Enable capture before bar close
input int       bar_close_wait_time = 0;                    //Signal waiting time (before bar close) [sec.]
input bool      enable_capture_after_bar_close = true;      //Enable capture after bar close

input string    hr2 =   "===== TRADING SETTINGS ========================";  // ===================================
input bool      use_percentage  = false;                    //Use [%] of the Balance
input double    amount          = 1.0;                      //Trade Amount | [%] of the Balance
input double    max_amount      = 1.0;                      //Max. Trade Amount
input int       expiration      = 3;                        //Expiry Time [minutes]
input McBoType  bo_type         = MC_BO_SPRINT;             //Option type

input string    shr6 =  "*Payout filter";                                   //--- 
input bool      use_payout_filter   = false;                //Use Payout filter
input double    payout_filter       = 0;                    //Payout Filter [%]

input string    shr7 =  "*Trading time filter";                             //---
input string    str_time_start  = "00:00:00";               //Time to start trading
input string    str_time_stop   = "23:59:59";               //Time to stop trading

input string    hr3 =   "===== DISPLAY SETTINGS ========================";  // ===================================
input bool      show_trade  = true;                         //Show trade entry points
input bool      fix_panel   = true;                         //Pin status panel on the chart 
input McAnchorPoint anchor_point = MC_BOTTOM_LEFT;          //Anchor point on screen

input string    hr4 =   "===== INTERNAL PARAMETERS =====================";  // ===================================
input int       timer_period    = 100;                          //EA update period [ms]
input string    pipe_name       = "intrade_bar_console_bot";    //Pipe Name

MegaConnectorBridgeApiV1        connector;
McSignalCapture                 signal_capture;
MegaConnectorTimeFilter         time_filter;
MegaConnectorSimpleBoLabel      bo_label;
McUI                            connector_ui;
MegaConnectorLogger             logger;
bool                            is_signal_canceled  = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void on_print(const string text);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    if (!enable_signal_arrow_capture) {
        if (StringLen(indicator_file_name) == 0) {
            on_print("Indicator file name not specified!");
            return(INIT_FAILED);
        }
    }
//---
    if (!EventSetMillisecondTimer(timer_period)) return(INIT_FAILED);
    connector.set_pipe_name(pipe_name);
    const string app_id = IntegerToString(ChartID());
    connector.set_app_id(app_id);
//---   
    if (enable_signal_arrow_capture) {
        logger.open("AutoConnectorLite-" + Symbol() + "-M" + IntegerToString(Period()));
    } else {
        logger.open("AutoConnectorLite-" + Symbol() + "-M" + IntegerToString(Period()) + "-" + indicator_file_name);
    }
//---
    if (!time_filter.set(str_time_start, str_time_stop)) {
        switch(time_filter.get_error_code()) {
        case 1:
            on_print("Wrong trading start time!");
            break;
        case 2:
            on_print("Wrong trading stop time!");
            break;
        case 3:
            on_print("Wrong trading start and stop time!");
            break;
        };
        return(INIT_FAILED);
    }
//---
    signal_capture.config.entry_type = entry_type;
    signal_capture.config.enable_signal_arrow_capture = enable_signal_arrow_capture;
    signal_capture.config.arrow_up_code = arrow_up_code;
    signal_capture.config.arrow_dn_code = arrow_dn_code;
    signal_capture.config.indicator_file_name   = indicator_file_name;
    signal_capture.config.indicator_id_up = indicator_id_up;
    signal_capture.config.indicator_id_dn = indicator_id_dn;
    signal_capture.config.enable_zero_signal_ignore = enable_zero_signal_ignore;
    signal_capture.config.signal_block_time = signal_block_time;
    
    signal_capture.config.enable_capture_previous_bar = enable_capture_previous_bar;
    signal_capture.config.previous_bar_wait_time = previous_bar_wait_time;
    
    signal_capture.config.enable_capture_before_bar_close = enable_capture_before_bar_close;
    signal_capture.config.bar_close_wait_time = bar_close_wait_time;
    signal_capture.config.enable_capture_after_bar_close = enable_capture_after_bar_close;
    
    signal_capture.set_connected(false);
    signal_capture.set_logger(&logger);
    if (!signal_capture.init()) {
        on_print("Indicator '" + indicator_file_name + "' initialization error!");
        logger.log("Indicator '" + indicator_file_name + "' initialization error!");
        return(INIT_FAILED);
    }
//---
    if(!connector_ui.init("Auto Connector Lite " PROGRAM_VERSION, !fix_panel, anchor_point)) return(INIT_FAILED);
    if(!connector_ui.Run()) return(INIT_FAILED);
    connector_ui.set_software_connection(false);
    
    bo_label.show(show_trade);
//---
    logger.log("Start connector. Indicator '" + indicator_file_name + "'; App ID: " + connector.get_app_id());
    on_print("Start connector. Indicator '" + indicator_file_name + "'; App ID: " + connector.get_app_id());
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//--- destroy timer
    EventKillTimer();
    connector.close();
    connector_ui.Destroy(reason);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
    signal_capture.update();
    return (0);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---
    signal_capture.update();
    connector.update();
    bo_label.update();
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void MegaConnectorBridgeApiV1::on_connection(const bool status) {
    connector_ui.set_software_connection(status);
    on_print("MegaConnector '"+ pipe_name + "': " + get_str_connection_status(status));
};

/** \brief Callback function for the balance receipt event
 * \param b Current account balance
 */
void MegaConnectorBridgeApiV1::on_account_info(const MegaConnectorAccountInfo &info) {
    signal_capture.set_connected(info.is_connected);
    connector_ui.set_account_info(info);
    static bool is_broker_connected = false;
    if (is_broker_connected != info.is_connected) {
        on_print("Intrade.Bar (ID " + IntegerToString(connector.get_account_id()) + "): " + get_str_connection_status(info.is_connected));
        is_broker_connected = info.is_connected;
    }
    if (info.is_connected) {
        on_print("Balance: " + DoubleToString(connector.get_balance(), 2) + " " + info.currency + "; " + get_str_account_type(info.is_demo));
    }
};

/** \brief Callback function for getting the state of binary options
 * \param bo_result Binary option parameter structure
 */
void MegaConnectorBridgeApiV1::on_update_bo(MegaConnectorBoResult &bo_result) {
    bo_label.replace_bo(bo_result);
    if (bo_result.status == MC_BO_UNKNOWN_STATE) return;
    on_print("Signal ID: " + bo_result.signal_id +
            "; symbol: " + bo_result.symbol +
            "; amount: " + DoubleToString(bo_result.amount, 2) +
            "; status: " + get_str_mc_bo_staus(bo_result.status));
};

/** \brief Callback function for getting quotes of currency pairs
 * \param symbols   Character array
 * \param prices    Price array
 */
void MegaConnectorBridgeApiV1::on_update_prices(string &symbols[], double &prices[]) {};

/** \brief Callback function to handle the ping event
 */
void MegaConnectorBridgeApiV1::on_ping() {
    //on_print("Ping");
};

/** \brief Callback function to handle the error event
 */
void MegaConnectorBridgeApiV1::on_error(const string &message) {
    on_print(message);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool McSignalCapture::process_signal(const MegaConnectorBoContractType contract_type) {
    if (contract_type == MC_BO_CONTRACT_UNKNOWN_STATE) return false;
    if (!connector.connected()) return false;

//{ Trade time filter
    if (!time_filter.check()) return false;
//}

    const string symbol = Symbol();

//{ Low payout filter
    if (use_payout_filter) {
        const double payout = 100.0 * connector.get_payout(symbol, expiration, amount);
        if (payout < payout_filter) {
            if (!is_signal_canceled) {
                is_signal_canceled = true;
                on_print("Low Payout [" + DoubleToString(payout, 2) + "], signal canceled");
                if (logger) logger.log("Low Payout [" + DoubleToString(payout, 2) + "], signal canceled");
            }
            is_signal_canceled = true;
            return false;
        } else {
            is_signal_canceled = false;
        }
    }
//}

    string signal_id;
    if (use_percentage) {
        double calc_amount = connector.get_balance() * amount / 100.0;
        if (calc_amount > max_amount) calc_amount = max_amount;
        const string user_data = "";
        connector.place_bo(signal_id, symbol, signal_name, user_data, contract_type, (datetime)expiration, bo_type, calc_amount);
    } else {
        const string user_data = ""; 
        connector.place_bo(signal_id, symbol, signal_name, user_data, contract_type, (datetime)expiration, bo_type, amount);
    }

    on_print("Signal: " + symbol + "; " +
             get_str_mc_contract_type(contract_type) + "; id: " +
             signal_id + "; " +
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS | TIME_MINUTES));
    if (logger) logger.log("Signal: " + symbol + "; " +
             get_str_mc_contract_type(contract_type) + "; id: " +
             signal_id + "; " +
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS | TIME_MINUTES));
    return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void on_print(const string text) {
    Print(text);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
    connector_ui.chart_event(id,lparam,dparam,sparam);
}
