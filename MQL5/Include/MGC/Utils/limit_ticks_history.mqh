//+------------------------------------------------------------------+
//|                                          limit_ticks_history.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef MGC_UTILS_LIMIT_TICKS_HISTORY_MQH
#define MGC_UTILS_LIMIT_TICKS_HISTORY_MQH

#include <WinAPI\fileapi.mqh>

namespace mgc { 
namespace utils { 

    void limit_ticks_history() {
        const uint _GENERIC_WRITE    = 0x40000000;
        const uint _SHARE_READ       = 1;
        const uint _CREATE_ALWAYS    = 2;
        string path_ticks = "\\bases\\"+ AccountInfoString(ACCOUNT_SERVER)+"\\ticks\\";
        string path = TerminalInfoString(TERMINAL_DATA_PATH) + path_ticks;
        Print("MarketWatch:");
        for (int i = SymbolsTotal(true) - 1; i >= 0; --i) {
            string symbol = SymbolName(i, true);
            Print("symbol:", symbol);
            SymbolSelect(symbol, true);
            int x = CreateDirectoryW(path + symbol, 0);
            for (int y = 2010; y <= 2023; ++y) {
                for (int m = 1; m <=12; ++m) {
                    string mon;
                    
                    if (m >= 1 && m < 10) mon = "0" + IntegerToString(m);
                    else mon = IntegerToString(m);
                    
                    string filename = path + symbol + "\\" + IntegerToString(y) + mon + ".tkc";
                    long handle = CreateFileW(filename, _GENERIC_WRITE, _SHARE_READ, 0, _CREATE_ALWAYS, 0, 0);
                }
            }
        }
    }

}; // utils
}; // mgc

#endif
