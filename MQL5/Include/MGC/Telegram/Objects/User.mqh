//+------------------------------------------------------------------+
//|                                                         User.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_USER_MQH
#define MGC_TELEGRAM_USER_MQH

#include "../../Libs/jason.mqh"
#include "../str_utils.mqh"

namespace mgc { 
namespace telegram {

    class User {
    public:
        long id;                /**< Уникальный идентификатор этого пользователя или бота. */
    	string first_name;
    	string last_name;
    	string username;
    	string language_code;   /**< Необязательно . Языковой тег IETF для языка пользователя. */
    	bool is_bot;
    	
    	User() {
    	    id = 0;
    	    is_bot = false;
    	}
    	
    	bool from_json(CJAVal *j) {
    		id              = j["id"].ToInt();
    		first_name      = string_decode(j["first_name"].ToStr());
    		last_name       = string_decode(j["last_name"].ToStr());
    		username        = string_decode(j["username"].ToStr());
    		language_code   = j["language_code"].ToStr();
    		is_bot          = j["is_bot"].ToBool();
    		return true;
    	}
    };

}; // telegram
}; // mgc

#endif
