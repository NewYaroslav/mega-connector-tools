//+------------------------------------------------------------------+
//|                                                       Update.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_MESSAGE_FILTER_MQH
#define MGC_TELEGRAM_MESSAGE_FILTER_MQH
//+------------------------------------------------------------------+
//|   Include                                                        |
//+------------------------------------------------------------------+
#include "Objects\Update.mqh"
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|   MessageFilter                                                   |
//+------------------------------------------------------------------+
namespace mgc { 
namespace telegram {

    class MessageFilter {
    public:
    
        MessageFilter() {
        };
        
        ~MessageFilter() {
        };
    
        void    set_sender_id_filter(const string sender_id_list) {
            m_sender_id_filter.Clear();
            string text = prepare_text(sender_id_list);
        
            //---
            string array[];
            int array_size = StringSplit(text,' ',array);
            for(int i = 0; i < array_size; ++i) {
                string user_id_str = string_trim(array[i]);
                if (!user_id_str.Length()) continue;
                m_sender_id_filter.Add(StringToInteger(user_id_str));
            }
            ArrayFree(array);
        }
        
        void    set_sender_username_filter(const string sender_username_list) {
            m_sender_username_filter.Clear();
            string text = prepare_text(sender_username_list);
        
            //---
            string array[];
            int array_size = StringSplit(text,' ',array);
            for(int i = 0; i < array_size; ++i) {
                string user_name = string_trim(array[i]);
                if (!user_name.Length()) continue;
                //--- remove first @
                if (StringGetCharacter(user_name, 0) == '@') {
                    user_name = StringSubstr(user_name, 1);
                }
                m_sender_username_filter.Add(user_name);
            }
            ArrayFree(array);
        }
        
        void    set_chat_id_filter(const string chat_id_list) {
            m_chat_id_filter.Clear();
            string text = prepare_text(chat_id_list);
        
            //---
            string array[];
            int array_size = StringSplit(text,' ',array);
            for(int i = 0; i < array_size; ++i) {
                string user_id_str = string_trim(array[i]);
                if (!user_id_str.Length()) continue;
                m_chat_id_filter.Add(StringToInteger(user_id_str));
            }
            ArrayFree(array);
        }
        
        void    set_chat_username_filter(const string chat_username_list) {
            m_chat_username_filter.Clear();
            string text = prepare_text(chat_username_list);
        
            //---
            string array[];
            int array_size = StringSplit(text,' ',array);
            for(int i = 0; i < array_size; ++i) {
                string user_name = string_trim(array[i]);
                if (!user_name.Length()) continue;
                //--- remove first @
                if (StringGetCharacter(user_name, 0) == '@') {
                    user_name = StringSubstr(user_name, 1);
                }
                m_chat_username_filter.Add(user_name);
            }
            ArrayFree(array);
        }
        
        bool check_sender(Update& update) {
            long    sender_id = update.get_sender_id();
            string  sender_username = update.get_sender_username();
            if (m_sender_id_filter.Total()) {
                if (m_sender_id_filter.SearchLinear(sender_id) >= 0) return true;
            }
            if (m_sender_username_filter.Total()) {
                if (m_sender_username_filter.SearchLinear(sender_username) >= 0) return true;
            }
            return false;
        }
        
        bool check_chat(Update& update) {
            long    chat_id = update.get_chat_id();
            string  chat_username = update.get_chat_username();
            if (m_chat_id_filter.Total()) {
                if (m_chat_id_filter.SearchLinear(chat_id) >= 0) return true;
            }
            if (m_chat_username_filter.Total()) {
                if (m_chat_username_filter.SearchLinear(chat_username) >= 0) return true;
            }
            return false;
        }
    
    private:
    
        string prepare_text(const string &list) {
            string text = string_trim(list);
            if (!text.Length()) return "";
            //---
            while (StringReplace(text, "  ", " ") > 0);
            StringReplace(text, ";", " ");
            StringReplace(text, ",", " ");
            return text;
        }
        
        CArrayLong      m_sender_id_filter;
        CArrayString    m_sender_username_filter;
        CArrayLong      m_chat_id_filter;
        CArrayString    m_chat_username_filter;
    };

}; // telegram
}; // mgc

#endif
