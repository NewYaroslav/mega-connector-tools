//+------------------------------------------------------------------+
//|                                                       Update.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_UPDATE_MQH
#define MGC_TELEGRAM_UPDATE_MQH

#include "Message.mqh"
#include "../../Utils/pointer.mqh"
#include "../../Libs/jason.mqh"
#include "../str_utils.mqh"
// Подбробнее: https://tlgrm.ru/docs/bots/api#update

namespace mgc { 
namespace telegram {

    class Update {
    public:
    	long update_id;
    	Message *message;
    	Message *edited_message;
    	Message *channel_post;
    	Message *edited_channel_post;
    	//CallbackQuery *callback_query;

    	Update() {
    	    update_id           = 0;
    	    message             = NULL;
    	    edited_message      = NULL;
    	    channel_post        = NULL;
    	    edited_channel_post = NULL;
    	}
    	
    	~Update() {
    	    MGC_FREE(message);
    	    MGC_FREE(edited_message);
    	    MGC_FREE(channel_post);
    	    MGC_FREE(edited_channel_post);
    	}
    
    	bool from_json(CJAVal *j) {
    		update_id = j["update_id"].ToInt();
    		if (j.FindKey("message")) {
                message = new Message();
    			if (!message.from_json(j["message"])) return false;
    		}
    		if (j.FindKey("edited_message")) {
                edited_message = new Message();
    			if (!edited_message.from_json(j["edited_message"])) return false;
    		}
    		if (j.FindKey("channel_post")) {
                channel_post = new Message();
    			if (!channel_post.from_json(j["channel_post"])) return false;
    		}
    		if (j.FindKey("edited_channel_post")) {
                edited_channel_post = new Message();
    			if (!edited_channel_post.from_json(j["edited_channel_post"])) return false;
    		}
    		/*
    		if (j.FindKey("callback_query")) {
                callback_query = CallbackQuery();
    			if (!callback_query.get().from_json(j["callback_query"])) return false;
    		}
    		*/
    		return true;
    	}
    	
    	long get_sender_id() {
            if (message) {
                if (message.from) {
                    return message.from.id;
                }
            } else
            if (edited_message) {
                if (edited_message.from) {
                    return edited_message.from.id;
                }
            } else
            if (channel_post) {
                if (channel_post.sender_chat) {
                    return channel_post.sender_chat.id;
                }
            } else
            if (edited_channel_post) {
                if (edited_channel_post.from) {
                    return edited_channel_post.sender_chat.id;
                }
            }
            return 0;
        }
        
        string get_sender_username() {
            if (message) {
                if (message.from) {
                    return message.from.username;
                }
            } else
            if (edited_message) {
                if (edited_message.from) {
                    return edited_message.from.username;
                }
            } else
            if (channel_post) {
                if (channel_post.sender_chat) {
                    return channel_post.sender_chat.username;
                }
            } else
            if (edited_channel_post) {
                if (edited_channel_post.from) {
                    return edited_channel_post.sender_chat.username;
                }
            }
            return "";
        }
        
        long get_chat_id() {
            if (message) {
                if (message.chat) {
                    return message.chat.id;
                }
            } else
            if (edited_message) {
                if (edited_message.chat) {
                    return edited_message.chat.id;
                }
            } else
            if (channel_post) {
                if (channel_post.chat) {
                    return channel_post.chat.id;
                }
            } else
            if (edited_channel_post) {
                if (edited_channel_post.chat) {
                    return edited_channel_post.chat.id;
                }
            }
            return 0;
        }
        
        string get_chat_username() {
            if (message) {
                if (message.chat) {
                    return message.chat.username;
                }
            } else
            if (edited_message) {
                if (edited_message.chat) {
                    return edited_message.chat.username;
                }
            } else
            if (channel_post) {
                if (channel_post.chat) {
                    return channel_post.chat.username;
                }
            } else
            if (edited_channel_post) {
                if (edited_channel_post.chat) {
                    return edited_channel_post.chat.username;
                }
            }
            return "";
        }
        
        string get_text() {
            if (message) {
                return message.text;
            } else
            if (edited_message) {
                return edited_message.text;
            } else
            if (channel_post) {
                return channel_post.text;
            } else
            if (edited_channel_post) {
                return edited_channel_post.text;
            }
            return "";
        }
    }; // Update

}; // telegram
}; // mgc

#endif
