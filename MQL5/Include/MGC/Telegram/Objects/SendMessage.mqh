//+------------------------------------------------------------------+
//|                                                  SendMessage.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_SEND_MESSAGE_MQH
#define MGC_TELEGRAM_SEND_MESSAGE_MQH

#include "Message.mqh"
#include "../Enums.mqh"

namespace mgc { 
namespace telegram {

    /** \brief SendMessage
     * https://tlgrm.ru/docs/bots/api#sendmessage
     */
	class SendMessage {
	public:
        long chat_id;               /**< Уникальный идентификатор целевого чата */
        string username;            /**< Имя пользователя целевого канала (в формате @channelusername) */
		string text;                /**< Текст сообщения, которое необходимо отправить */
        long reply_to_message_id;   /**< Если сообщение является ответом, идентификатор исходного сообщения */
		ParseMode parse_mode;       /**< Отправьте Markdown или HTML , если вы хотите, чтобы приложения Telegram отображали жирный, курсив, текст фиксированной ширины или встроенные URL-адреса в сообщении вашего бота. */
		bool disable_notification;  /**< Отправляет сообщение молча . Пользователи iOS не получат уведомление, пользователи Android получат уведомление без звука. */
        //ReplyMarkup reply_markup;   /**< Дополнительные возможности интерфейса. Объект, сериализованный в формате JSON, для встроенной клавиатуры , пользовательской клавиатуры ответа , инструкций по скрытию клавиатуры ответа или принудительному ответу пользователя. */
	
	    class Result {
        public:
            bool ok;
            Message message;
            
            Result() {
                ok = false;
            }

            bool from_json(CJAVal *j) {
        		ok = j["ok"].ToBool();
        	    return message.from_json(j["result"]);
        	}
        } result;
                
	    SendMessage() {
	        chat_id = 0;
	        reply_to_message_id = 0;
	        parse_mode = ParseMode::PARSE_MODE_UNDEFINED;
	        disable_notification = false; 
	    }
	    
	    bool to_args(string &args) const {
            if (chat_id) {
                args += StringFormat("chat_id=%lld&text=%s", chat_id, url_encode(text));
            } else
            if (username.Length()) {
                string _username = string_trim(username);
                if (StringGetCharacter(_username, 0) != '@') _username = "@" + _username;
                args += StringFormat("chat_id=%s&text=%s", _username, url_encode(text));
            } else {
                return false;
            }
            
            if (parse_mode != ParseMode::PARSE_MODE_UNDEFINED) args += "&parse_mode=" + to_str(parse_mode);
            if (disable_notification) args += "&disable_notification=true";
            if (reply_to_message_id) args += "&reply_to_message_id=" + IntegerToString(reply_to_message_id);
            return true;
        }
	};

}; // telegram
}; // mgc

#endif
