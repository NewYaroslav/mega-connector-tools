//+------------------------------------------------------------------+
//|                                                         Chat.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_MESSAGE_MQH
#define MGC_TELEGRAM_MESSAGE_MQH

#include "User.mqh"
#include "Chat.mqh"
#include "../../Utils/pointer.mqh"
#include "../../Libs/jason.mqh"
#include "../str_utils.mqh"

namespace mgc { 
namespace telegram {

    class Message {
    public:
        long message_id;                /**< Unique message identifier inside this chat */
    	long message_thread_id;         /**< Optional. Unique identifier of a message thread to which the message belongs; for supergroups only */
    	datetime date;
    	string text;
    	User *from;
    	User *new_chat_member;
    	User *left_chat_member;
    	User *forward_from;             /**< Optional. For forwarded messages, sender of the original message */
    	Chat *forward_from_chat;        /**< Optional. For messages forwarded from channels or from anonymous administrators, information about the original sender chat */
    	long forward_from_message_id;   /**< Optional. For messages forwarded from channels, identifier of the original message in the channel */
    	datetime forward_date;          /**< Optional. For forwarded messages, date the original message was sent in Unix time */
    	Chat *sender_chat;
    	Chat *chat;
        
        Message() {
            message_id          = 0;
            message_thread_id   = 0;
            date                = 0;
            forward_from_message_id = 0;
            forward_date        = 0; 
            //---
            from                = NULL;
            new_chat_member     = NULL;
            left_chat_member    = NULL;
            forward_from        = NULL;
            forward_from_chat   = NULL;
            sender_chat         = NULL;
            chat                = NULL;
        }
        
        ~Message() {
            MGC_FREE(from);
            MGC_FREE(new_chat_member);
            MGC_FREE(left_chat_member);
            MGC_FREE(forward_from);
            MGC_FREE(forward_from_chat);
            MGC_FREE(sender_chat);
            MGC_FREE(chat);
        }
     
    	bool from_json(CJAVal *j) {
    		message_id = j["message_id"].ToInt();
    		if (j.FindKey("message_thread_id")) {
    		    message_thread_id = j["message_thread_id"].ToInt();
    		}
    		date = (datetime)j["date"].ToInt();
    		text = string_decode(j["text"].ToStr());
    		
    		if (j.FindKey("chat")) {
                chat = new Chat();
                if (!chat.from_json(j["chat"])) return false;
    		}
    		if (j.FindKey("forward_from_chat")) {
                forward_from_chat = new Chat();
                if (!forward_from_chat.from_json(j["forward_from_chat"])) return false;
    		}
    		if (j.FindKey("forward_from_message_id")) forward_from_message_id = j["forward_from_message_id"].ToInt();
    		if (j.FindKey("forward_date")) forward_date = (datetime)j["forward_date"].ToInt();
    		if (j.FindKey("sender_chat")) {
                sender_chat = new Chat();
                if (!sender_chat.from_json(j["sender_chat"])) return false;
    		}
    		if (j.FindKey("from")) {
    			from = new User();
    			if (!from.from_json(j["from"])) return false;
    		}
    		if (j.FindKey("new_chat_member")) {
    			new_chat_member = new User();
    			if (!new_chat_member.from_json(j["new_chat_member"])) return false;
    		}
    		if (j.FindKey("left_chat_member")) {
    			left_chat_member = new User();
    			if (!left_chat_member.from_json(j["left_chat_member"])) return false;
    		}
    		if (j.FindKey("forward_from")) {
    			forward_from = new User();
    			if (!forward_from.from_json(j["forward_from"])) return false;
    		}
    		return true;
    	}
    };

}; // telegram
}; // mgc

#endif
