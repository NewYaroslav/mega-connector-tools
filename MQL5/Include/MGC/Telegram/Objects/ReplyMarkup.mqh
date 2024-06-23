//+------------------------------------------------------------------+
//|                                                  ReplyMarkup.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_REPLY_MARKUP_MQH
#define MGC_TELEGRAM_REPLY_MARKUP_MQH

namespace mgc { 
namespace telegram {

    class ReplyMarkup {
    public:

        ReplyMarkup() {
            m_reply_markup = NULL;
        }
        
        ~ReplyMarkup() {
            MGC_FREE(m_reply_markup);
        }
        
        ReplyMarkupBase *get() {
            return m_reply_markup;
        }

    private:
        ReplyMarkupBase* m_reply_markup = NULL;
    };

}; // telegram
}; // mgc

#endif
