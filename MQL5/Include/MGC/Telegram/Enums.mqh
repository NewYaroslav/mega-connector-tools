//+------------------------------------------------------------------+
//|                                                       Update.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_ENUMS_MQH
#define MGC_TELEGRAM_ENUMS_MQH

namespace mgc { 
namespace telegram {

    enum ChatAction {
        ACTION_TYPING,          //typing..
        ACTION_UPLOAD_PHOTO,    //sending photo...
        ACTION_UPLOAD_DOCUMENT, //sending file...
        ACTION_CHOOSE_STICKER,  //choose sticker...
        ACTION_FIND_LOCATION,   //picking location...
        ACTION_RECORD_VIDEO,    //recording video...
        ACTION_UPLOAD_VIDEO,    //sending video...
        ACTION_RECORD_AUDIO,    //recording audio...
        ACTION_UPLOAD_AUDIO,    //sending audio...
    };

    string to_str(const ChatAction &_action) {
        string data[] = {
            "typing",
            "upload_photo",
            "upload_document",
            "choose_sticker",
            "find_location",
            "record_video",
            "upload_video",
            "record_voice",
            "upload_voice",
            "record_video_note",
            "upload_video_note"
        };
        return data[_action];
    }
    
    enum ParseMode {
        PARSE_MODE_UNDEFINED = 0,
        PARSE_MODE_MARKDOWN,
        PARSE_MODE_HTML,
    };
    
    string to_str(const ParseMode &_action) {
        string data[] = {
            "",
            "MarkdownV2",
            "HTML"
        };
        return data[_action];
    }

}; // telegram
}; // mgc

#endif 
