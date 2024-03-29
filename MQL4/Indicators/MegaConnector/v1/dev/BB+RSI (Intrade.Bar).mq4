//+------------------------------------------------------------------+
//|                                             BB+RSI (Intrade.Bar) |
//|                      Copyright 2022-2023, MegaConnector Software |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#property strict

// Эти файлы находятся в папке:
// MQL4\Include\
#include <MegaConnector\v1\api\bapi-v1.mqh>
#include <MegaConnector\v1\utils\tools.mqh>




// Далее идут настройки индикатора или советника, которые в большинстве случаев менять нет смысла

input string    hr3 =   "===== INTERNAL PARAMETERS =====================";  // ===================================
// Период таймера, это период опроса API библиотеки MegaConnector. Не стоит брать слишком большое время
input int       timer_period = 100;                     // EA update period [ms]
// Это имя именнованного канала, по которому подключается MegaConnector. В примере оно представлено значением по умолчанию
input string    pipe_name = "intrade_bar_console_bot";  // Pipe Name




// Это класс, который реализует работу с API программы MegaConnector
MegaConnectorBridgeApiV1    connector;
// Это строка, которая будет хранить уникальный номер нашего индикатора или советника
// Этот номер нужен для того, чтобы отличать сообщения о результатах сделок индикатора или совтеника, когда их запущено несколько экземпляров
string                      app_id;



// Функция возвращает строку с состоянием подключения
string get_connection_str(const bool status);
// Функция возвращает строку с типом аккаунта
string get_account_type_str(const bool is_demo);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
// Инициализируем таймер для опроса API
    if (!EventSetMillisecondTimer(timer_period)) return(INIT_FAILED);
// Устанавливаем имя именнованных каналов
    connector.set_pipe_name(pipe_name);
// Устанавливаем уникальный номер советника или индикатора
    app_id = get_str_unique_id();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
// Останавливаем таймер
    EventKillTimer();
// Закрываем соединение с MegaConnector
    connector.close();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[]) {
//---
// Получаем цену закрытия, значения полос боллинджера и индикатора RSI
    const double close = iClose(NULL,0,0);
    const double bb_upper = iBands(NULL,0,20,2.0,0,PRICE_CLOSE,MODE_UPPER,0);
    const double bb_lower = iBands(NULL,0,20,2.0,0,PRICE_CLOSE,MODE_LOWER,0);
    const double rsi = iRSI(NULL,0,14,PRICE_CLOSE,0);

    string signal_id; // Это строка, в которую будет записан уникальный ID сделки

    if (close > bb_upper && rsi > 70) {
        // Сигнал на покупку

        // Сначала нам нужно определиться с параметрами сделки:
        // Размер сделки, валютная пара, направление, экспирация и т.д.
        // Все перечисления, типа MegaConnectorBoContractType, MegaConnectorBoType, можно найти тут:
        // Include\MegaConnector\v1\part\common.mqh


        // Для примера, получим баланс через метод get_balance() и вычислим, какой размер ставки, равный 1% от баланса
        const double amount = connector.get_balance() * 0.01;
        // Строка с пользовательскими данными,
        // которые можно будет прочитать в функции обратного вызова MegaConnectorBridgeApiV1::on_update_bo(MegaConnectorBoResult &bo_result)
        // Это может пригодиться, если нужно отследить состояние конкретной сделки, например для мартингейла
        // В данном примере это не нужно
        const string user_data = "";
        // Получаем имя символа
        const string symbol = Symbol();
        // Указываем название сигнала, если нужно. Для примера укажем "test signal"
        const string signal_name = "test signal";
        // Укажем направление сделки BUY или SELL
        const MegaConnectorBoContractType contract_type = MC_BO_SELL;
        // Укажем экспирацию в минутах
        const int expiration = 3;
        // Укажем тип бинарного опциона - спринт
        const MegaConnectorBoType  bo_type = MC_BO_SPRINT;

        // Все настройки готовы, можно открыть сделку
        connector.place_bo(signal_id, symbol, signal_name, user_data, contract_type, (datetime)expiration, bo_type, amount);
    } else if (close < bb_lower && rsi < 70) {
        // Сигнал на продажу

        // В данном случае мы сразу укажем все параметры сделки, без имени сигнала и без пользователськой строки user_data
        connector.place_bo(signal_id, Symbol(), "", "", MC_BO_BUY, (datetime)3, MC_BO_SPRINT, 50.0);
    }
//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---
// Вызываем обработчик сообщений API по таймеру
    connector.update();
}
//+------------------------------------------------------------------+

// Функция обратного вызова библиотеки API MegaConnector
// Данная функция вызывается в момент установки или разрыва соединения с ПО MegaConnector
void MegaConnectorBridgeApiV1::on_connection(const bool status) {
// Для примера просто выводим сообщения о состоянии подключения к программе MegaConnector
    Print("MegaConnector '"+ pipe_name + "': " + get_connection_str(status));
};

// Функция обратного вызова библиотеки API MegaConnector
// Данная функция вызывается в момент обновления информации об аккаунте
// Например, если изменился баланс аккаунта, если было подключение или если установилась или оборвалась связь с брокером
void MegaConnectorBridgeApiV1::on_account_info(const MegaConnectorAccountInfo &info) {
// Для примера просто выводим сообщения о состоянии подключения, балансе, валюте счета и типе счета
// Подробнее о всех переменных структуры MegaConnectorAccountInfo смотрте в файле:
// Include\MegaConnector\v1\part\common.mqh
    Print("Intrade.Bar: " + get_connection_str(info.is_connected));
    if (info.is_connected) {
        Print("Balance " + DoubleToString(connector.get_balance(), 2) + " " + info.currency + " " + get_account_type_str(info.is_demo));
    }
};

// Функция обратного вызова библиотеки API MegaConnector
// Данная функция вызывается в момент изменения состояния сделки:
// Ожидание открытия сделки
// Сделка открыла или ошибка октрытия
// Сделка закрыта или ошибка проверки результата сделки
void MegaConnectorBridgeApiV1::on_update_bo(MegaConnectorBoResult &bo_result) {
// Так как советников или индикаторов может быть несколько
// Мы проверяем, что сообщение пришло именно от нашего индикатора и/или советника
// Если вам не нужно проверять, от какого именно индикатора сообщение о сделке, то проверку через check_app_id можно убрать
    string signal_id; // это уникальный ID сигнала
    if (check_app_id(app_id, bo_result.user_data, signal_id)) {
        // Для примера просто выводим сообщения о состоянии сделки
        // Подробнее о всех переменных структуры MegaConnectorBoResult смотрте в файле:
        // Include\MegaConnector\v1\part\common.mqh
        Print("Update bo, signal id [" + signal_id +
              "], amount " + DoubleToString(bo_result.amount, 2) +
              " status " + get_str_mc_bo_staus(bo_result.status));
    }
};

// Функция обратного вызова библиотеки API MegaConnector
// Данная функция вызывается, когда от ПО MegaConnector приходит цена брокера
// Функция на данный момент не используется, но ее нужно объявить
void MegaConnectorBridgeApiV1::on_update_prices(string &symbols[], double &prices[]) {};

// Функция обратного вызова библиотеки API MegaConnector
// Данная функция вызывается, когда происходит Ping
void MegaConnectorBridgeApiV1::on_ping() {
// Для примера можно выводить сообщение о Ping каждый раз, когда он произошел
// Print("Ping");
};

// Функция обратного вызова библиотеки API MegaConnector
// Данная функция вызывается, когда происходит Pошибка.
void MegaConnectorBridgeApiV1::on_error(const string &message) {
// Выводим сообщение об ошибке
    Print(message);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Функция возвращает строку с состоянием подключения               |
//+------------------------------------------------------------------+
string get_connection_str(const bool status) {
    if (status) return "Connected";
    return "Disconnected";
}

//+------------------------------------------------------------------+
//| Функция возвращает строку с типом аккаунта                       |
//+------------------------------------------------------------------+
string get_account_type_str(const bool is_demo) {
    if (is_demo) return "Demo";
    return "Real";
}
//+------------------------------------------------------------------+
