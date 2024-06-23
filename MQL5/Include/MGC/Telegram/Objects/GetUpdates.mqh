//+------------------------------------------------------------------+
//|                                                    GetUpdate.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_GET_UPDATES_MQH
#define MGC_TELEGRAM_GET_UPDATES_MQH

#include "Update.mqh"

namespace mgc { 
namespace telegram {

    class GetUpdates {
    public:
        bool ok;
        Update updates[];
        
        GetUpdates() {
            ok = false;
        };
        
        ~GetUpdates() {
            ArrayFree(updates);
        };
        
        bool from_json(CJAVal *j) {
    		ok = j["ok"].ToBool();
    		if (!ok) return false;
    		int total = ArraySize(j["result"].m_e);
            ArrayResize(updates, total);
            for(int i = 0; i < total; ++i) {
                CJAVal item = j["result"].m_e[i];
                if (!updates[i].from_json(&item)) return false;
            }
    		return true;
    	}
    
    }; // Updates
    
}; // telegram
}; // mgc

#endif
