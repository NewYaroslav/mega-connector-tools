//+------------------------------------------------------------------+
//|                                                      methods.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
namespace mgc { 
namespace telegram {
    
    bool    BotClient::set_token(const string& _token) {
        string token = string_trim(_token);
        if (!token.Length()) return false;
        m_token = token;
        return true;
    }
    
    string  BotClient::get_error_message() {
        return m_error_message;
    }
    
    bool    BotClient::get_me(GetMe& response) {
        if (!check_token()) return false;
        string out;
        string url = StringFormat("%s/bot%s/getMe", MGC_TELEGRAM_BASE_URL, m_token);
        string params;
        
        if (!post_request(out, url, params, MGC_WEB_TIMEOUT)) return false;
    
        CJAVal j(NULL, jtUNDEF);
        
        if (!j.Deserialize(out)) {
            m_error_message = "Failed to deserialize JSON response.";
            return false;
        }
        
        if (!response.from_json(&j)) {
            m_error_message = "Failed to convert JSON response to GetMe structure.";
            return false;
        }
        
        if (!response.ok) {
            m_error_message = "Response 'ok' field is false.";
            return false;
        }
        return true;
    }
    
    bool    BotClient::get_updates(GetUpdates& response) {
        if (!check_token()) return false;
    
        string out;
        string url = StringFormat("%s/bot%s/getUpdates", MGC_TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("offset=%lld", m_update_id);

        if (!post_request(out, url, params, MGC_WEB_TIMEOUT)) return false;

        CJAVal js(NULL, jtUNDEF);
        
        if (!js.Deserialize(out)) {
            m_error_message = "Failed to deserialize JSON response.";
            return false;
        }
        
        if (!response.from_json(&js)) {
            m_error_message = "Failed to convert JSON response to GetUpdates structure.";
            return false;
        }
    
        if (!response.ok) {
            m_error_message = "Response 'ok' field is false.";
            return false;
        }
    
        int total = ArraySize(response.updates);
        if (total) {
            for(int i = 0; i < total; ++i) {
                m_update_id = MathMax(m_update_id, response.updates[i].update_id);
            }
            ++m_update_id;
        }
        return true;
    }
    
    bool    BotClient::set_my_commands(
                const SetMyCommands& my_commands) {
        if (!check_token()) return false;
        if (ArraySize(my_commands.commands) == 0) return false;
        
        string out;
        string url = StringFormat("%s/bot%s/setMyCommands", MGC_TELEGRAM_BASE_URL, m_token);
        string params;
        if (!my_commands.to_args(params)) {
            m_error_message = "Error constructing request parameters.";
            return false;
        }
        if (!post_request(out, url, params, MGC_WEB_TIMEOUT)) return false;
        return true;
    }
    
    bool    BotClient::send_chat_action(
                const long& _chat_id,
                const ChatAction& _action) {
        if (!check_token()) return false;
        
        string out;
        string url = StringFormat("%s/bot%s/sendChatAction", MGC_TELEGRAM_BASE_URL, m_token);
        string params = StringFormat("chat_id=%lld&action=%s", _chat_id, to_str(_action));
        
        if (!post_request(out, url, params, MGC_WEB_TIMEOUT)) return false;
        return true;
    }
    
    bool    BotClient::send_message(SendMessage& message) {
        if (!check_token()) return false;
    
        string out;
        string url = StringFormat("%s/bot%s/sendMessage", MGC_TELEGRAM_BASE_URL, m_token);
        string params;
        if (!message.to_args(params)) {
            m_error_message = "Error constructing request parameters.";
            return false;
        }
        
        if (!post_request(out, url, params, MGC_WEB_TIMEOUT)) return false;
        
        CJAVal js(NULL, jtUNDEF);
        
        if (!js.Deserialize(out)) {
            m_error_message = "Failed to deserialize JSON response.";
            return false;
        }
        
        return message.result.from_json(&js);
    }
    
}; // telegram
}; // mgc
