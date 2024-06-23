//+------------------------------------------------------------------+
//|                                                SetMyCommands.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_SET_MY_COMMANDS_MQH
#define MGC_TELEGRAM_SET_MY_COMMANDS_MQH

#include "BotCommand.mqh"

namespace mgc { 
namespace telegram {

    class SetMyCommands {
    public:
        BotCommand commands[];
        string language_code;
        
        SetMyCommands() {
        
        }
        
        ~SetMyCommands() {
            ArrayFree(commands);
        }
        
        void add_command(string _command, string _description) {
            const int index = ArraySize(commands);
            ArrayResize(commands, index + 1);
            commands[index].add_command(_command, _description);
        }
        
        bool to_args(string& args) const {
            args += "commands=[";
            for (int i = 0; i < ArraySize(commands); ++i) {
                if (i) args += ",";
                if (!commands[i].to_json_dump(args)) return false;
            }
            args += "]";
            if (language_code.Length()) {
                args += "&language_code=" + language_code;
            }
            return true;
        }

    }; // SetMyCommands

}; // telegram
}; // mgc

#endif
