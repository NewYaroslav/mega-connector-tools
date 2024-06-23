//+------------------------------------------------------------------+
//|                                                   BotCommand.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_TELEGRAM_SET_BOT_COMMAND_MQH
#define MGC_TELEGRAM_SET_BOT_COMMAND_MQH

#include "../str_utils.mqh"

namespace mgc { 
namespace telegram {

    class BotCommand {
    public:
        string command;
        string description;
            
        BotCommand() {}
        
        BotCommand(string& _command, string& _description) : 
            command(_command), description(_description) {}
        
        ~BotCommand() {}
        
        void add_command(string& _command, string& _description) {
            command = _command;
            description = _description;
        }
        
        bool to_json_dump(string &text) const {
            if (!command.Length()) return false;
            if (!description.Length()) return false;
            text += "{\"command\":\"";
            if (command.Length() > 32) text += StringSubstr(command, 0, 32);
            else text += command;
            text += "\",\"description\":\"";
            if (description.Length() > 256) text += url_encode(StringSubstr(description, 0, 256));
            else text += url_encode(description);
            text += "\"}";
            return true;
        }
    
    }; // BotCommand

}; // telegram
}; // mgc

#endif

