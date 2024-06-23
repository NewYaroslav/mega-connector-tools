//+------------------------------------------------------------------+
//|                                                        utils.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
//
//+------------------------------------------------------------------+
namespace mgc { 
namespace telegram {

    bool    BotClient::check_token() {
        if (m_token == NULL) {
            m_error_message = "Token is null.";
            return false;
        }
        return true;
    }

    bool    BotClient::post_request(
            string &out,
            const string url,
            const string params,
            const int timeout = 5000) {
        char data[];
        int data_size = StringLen(params);
        StringToCharArray(params, data, 0, data_size);
    
        uchar result[];
        string result_headers;
    
        //--- application/x-www-form-urlencoded
        int res = WebRequest("POST", url, NULL, NULL, timeout, data, data_size, result, result_headers);
        ArrayFree(data);
        if (res != 200) {
            if (res == -1) {
                ArrayFree(result);
                m_error_message = "WebRequest failed with error: " + IntegerToString(_LastError);
                return false;
            }
            //--- HTTP errors
            if (res >= 100 && res <= 511) {
                out = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
                ArrayFree(result);
                m_error_message = "HTTP error with status code: " + IntegerToString(res);
                return false;
            }
            m_error_message = "Unknown error with status code: " + IntegerToString(res);
            return false;
        }
        // OK
        
        //--- delete BOM
        int start_index=0;
        int size = ArraySize(result);
        for(int i = 0; i < fmin(size, 8); ++i) {
            if(result[i] == 0xef || result[i] == 0xbb || result[i] == 0xbf) {
                start_index = i + 1;
            } else {
                break;
            }
        }
        //---
        out = CharArrayToString(result, start_index, WHOLE_ARRAY, CP_UTF8);
        ArrayFree(result);
        return true;
    }
    
}; // telegram
}; // mgc

