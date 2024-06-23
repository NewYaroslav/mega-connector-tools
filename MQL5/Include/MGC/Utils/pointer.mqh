//+------------------------------------------------------------------+
//|                                                      Pointer.mqh |
//|                     Copyright 2022-2024, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MGC_UTILS_POINTER_MQH
#define MGC_UTILS_POINTER_MQH

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define MGC_FREE(P) if(CheckPointer(P) == POINTER_DYNAMIC) delete (P)

#endif

