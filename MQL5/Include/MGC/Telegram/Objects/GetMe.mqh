//+------------------------------------------------------------------+
//|                                                        GetMe.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_GET_ME_MQH
#define MGC_TELEGRAM_GET_ME_MQH

#include "User.mqh"
#include "../../Libs/jason.mqh"
#include "../str_utils.mqh"

namespace mgc { 
namespace telegram {

    class GetMe {
    public:
        bool ok;
        User user;
        
        GetMe() {
            ok = false;
        }
        
        bool from_json(CJAVal *j) {
    		ok = j["ok"].ToBool();
    		return user.from_json(j["result"]);
    	}
    };

}; // telegram
}; // mgc

#endif
