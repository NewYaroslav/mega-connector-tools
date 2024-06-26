//+------------------------------------------------------------------+
//|                                                    BotClient.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_BOT_CLIENT_MQH
#define MGC_TELEGRAM_BOT_CLIENT_MQH

#define MGC_TELEGRAM_BASE_URL  "https://api.telegram.org"
#define MGC_WEB_TIMEOUT        5000

#include "Objects/GetMe.mqh"
#include "Objects/GetUpdates.mqh"
#include "Objects/SetMyCommands.mqh"
#include "Objects/SendMessage.mqh"

namespace mgc { 
namespace telegram {

    class BotClient {
    public:
    
        BotClient() {
            m_update_id = 0;
        }
        
        ~BotClient() {
        
        }
        
        // Установить токен
        bool    set_token(const string& _token);
        
        string  get_error_message();
        
        bool    get_me(GetMe& response);
        
        bool    get_updates(GetUpdates& response);
        
        bool    send_chat_action(
                    const long& _chat_id,
                    const ChatAction& _action);
                    
        bool    set_my_commands(
                    const SetMyCommands& my_commands);
        
        bool    send_message(SendMessage& message);

    private:
        string          m_token;
        string          m_error_message;
        long            m_update_id;
        
        bool    check_token();
        
        bool    post_request(
            string &out,
            const string url,
            const string params,
            const int timeout);
    }; // BotClient

}; // telegram
}; // mgc

#include "BotClient\utils.mqh"
#include "BotClient\methods.mqh"

#endif
