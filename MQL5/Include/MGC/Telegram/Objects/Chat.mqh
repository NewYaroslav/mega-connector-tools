//+------------------------------------------------------------------+
//|                                                         Chat.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_CHAT_MQH
#define MGC_TELEGRAM_CHAT_MQH

#include "../../Libs/jason.mqh"
#include "../str_utils.mqh"

namespace mgc { 
namespace telegram {

    class Chat {
    public:
        long id;
    	string type;
    	string title;
    	string first_name;
    	string last_name;
    	string username;
        
        Chat() {
            id = 0;
        }
        
        bool from_json(CJAVal *j) {
    		id          = j["id"].ToInt();
    		type        = j["type"].ToStr();
    	    title       = string_decode(j["title"].ToStr());
    	    username    = string_decode(j["username"].ToStr());
    	    first_name  = string_decode(j["first_name"].ToStr());
    		last_name   = string_decode(j["last_name"].ToStr());
    		return true;
    	}
    };

}; // telegram
}; // mgc

#endif
