//+------------------------------------------------------------------+
//|                                                    str_utils.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_STR_UTILS_MQH
#define MGC_TELEGRAM_STR_UTILS_MQH

namespace mgc { 
namespace telegram {

    string  url_encode(const string text) {
        string result = NULL;
        int length = StringLen(text);
        for(int i = 0; i < length; ++i) {
            ushort ch = StringGetCharacter(text, i);
            if (    (ch>=48 && ch<=57) ||       // 0-9
                    (ch>=65 && ch<=90) ||       // A-Z
                    (ch>=97 && ch<=122) ||      // a-z
                    (ch=='!') || (ch=='\'') || (ch=='(') ||
                    (ch==')') || (ch=='*') || (ch=='-') ||
                    (ch=='.') || (ch=='_') || (ch=='~')) {
                result += ShortToString(ch);
            } else {
                if (ch == ' ') {
                    result += ShortToString('+');
                } else {
                    uchar array[];
                    int total = short_to_utf8(ch, array);
                    for(int k = 0; k < total; ++k) {
                        result += StringFormat("%%%02X", array[k]);
                    }
                }
            }
        }
        return result;
    }
    
    int short_to_utf8(const ushort _ch, uchar &out[]) {
        //---
        if (_ch < 0x80) {
            ArrayResize(out,1);
            out[0] = (uchar)_ch;
            return(1);
        }
        //---
        if (_ch < 0x800) {
            ArrayResize(out,2);
            out[0] = (uchar)((_ch >> 6)|0xC0);
            out[1] = (uchar)((_ch & 0x3F)|0x80);
            return(2);
        }
        //---
        if (_ch < 0xFFFF) {
            if(_ch >= 0xD800 && _ch <= 0xDFFF) { //Ill-formed
                ArrayResize(out, 1);
                out[0] = ' ';
                return 1;
            } else if(_ch>=0xE000 && _ch<=0xF8FF) { //Emoji
                int ch=0x10000|_ch;
                ArrayResize(out,4);
                out[0] = (uchar)(0xF0 | (ch >> 18));
                out[1] = (uchar)(0x80 | ((ch >> 12) & 0x3F));
                out[2] = (uchar)(0x80 | ((ch >> 6) & 0x3F));
                out[3] = (uchar)(0x80 | ((ch & 0x3F)));
                return 4;
            } else {
                ArrayResize(out,3);
                out[0] = (uchar)((_ch>>12)|0xE0);
                out[1] = (uchar)(((_ch>>6)&0x3F)|0x80);
                out[2] = (uchar)((_ch&0x3F)|0x80);
                return 3;
            }
        }
        ArrayResize(out, 3);
        out[0] = 0xEF;
        out[1] = 0xBF;
        out[2] = 0xBD;
        return 3;
    }
    
    int string_replace_ex(
            string &string_var,
            const int start_pos,
            const int length,
            const string replacement) {
        string temp = (start_pos == 0) ? "" : StringSubstr(string_var, 0, start_pos);
        if (start_pos) temp += StringSubstr(string_var, 0, start_pos);
        temp += replacement;
        temp += StringSubstr(string_var, (start_pos + length));
        string_var = temp;
        return StringLen(replacement);
    }
    
    string string_decode(string text) {
        //--- replace \n
        StringReplace(text, "\n", ShortToString(0x0A));
    
        //--- replace \u0000
        int haut = 0;
        int pos = StringFind(text, "\\u");
        while (pos != -1) {
            string strcode = StringSubstr(text, pos, 6);
            string strhex = StringSubstr(text, pos+2, 4);
    
            StringToUpper(strhex);
    
            int total = StringLen(strhex);
            int result = 0;
            for (int i=0, k = (total - 1); i < total; ++i, --k) {
                int coef = (int)pow(2, 4 * k);
                ushort ch = StringGetCharacter(strhex, i);
                if (ch >= '0' && ch <= '9') result += (ch - '0') * coef;
                else
                if (ch >= 'A' && ch <= 'F') result += (ch - 'A' + 10) * coef;
            }
    
            if (haut != 0) {
                if(result >= 0xDC00 && result <= 0xDFFF) {
                    int dec = ((haut - 0xD800) << 10) + (result - 0xDC00);//+0x10000;
                    string_replace_ex(text, pos, 6, ShortToString((ushort)dec));
                    haut = 0;
                } else {
                    //--- error: Second byte out of range
                    haut = 0;
                }
            } else {
                if(result >= 0xD800 && result <= 0xDBFF) {
                    haut = result;
                    string_replace_ex(text, pos, 6, "");
                } else {
                    string_replace_ex(text, pos, 6, ShortToString((ushort)result));
                }
            }
    
            pos = StringFind(text, "\\u", pos);
        }
        return text;
    }
    
    string bool_to_string(const bool _value) {
        if (_value) return("true");
        return("false");
    }
    
    string string_trim(string text) {
    #ifdef __MQL4__
        text = StringTrimLeft(text);
        text = StringTrimRight(text);
    #endif
    #ifdef __MQL5__
        StringTrimLeft(text);
        StringTrimRight(text);
    #endif
        return(text);
    }

}; // telegram
}; // mgc

#endif
