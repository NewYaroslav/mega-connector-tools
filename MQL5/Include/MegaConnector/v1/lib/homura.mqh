//+------------------------------------------------------------------+
//|                                                       homura.mqh |
//|                      Copyright 2022-2023, MegaConnector Software |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef HOMURA_MQH
#define HOMURA_MQH

#include <Tools\DateTime.mqh>

#property copyright "Copyright 2022, MegaConnector Software"
#property link      "https://mega-connector.com/"
#property version   "1.00"
#property strict

class homura {
public:
                     homura() {};
                    ~homura() {};

    // The number of seconds in a minute, hour, etc.
    enum DurationTimePeriod {
        SEC_PER_MIN             = 60,           // Количество секунд в одной минуте
        SEC_PER_HALF_HOUR       = 1800,         // Количество секунд в получасе
        SEC_PER_HOUR            = 3600,         // Количество секунд в одном часе
        SEC_PER_DAY             = 86400,        // Количество секунд в одном дне
        SEC_PER_YEAR            = 31536000,     // Количество секунд за год
        SEC_PER_LEAP_YEAR       = 31622400,     // Количество секунд за високосный год
        AVERAGE_SEC_PER_YEAR    = 31557600,     // Среднее количество секунд за год
        SEC_PER_4_YEAR          = 126230400,    // Количество секунд за 4 года
        MIN_PER_HOUR            = 60,           // Количество минут в одном часе
        MIN_PER_DAY             = 1440,         // Количество минут в одном дне
        HOURS_PER_DAY           = 24,           // Количество часов в одном дне
        MONTHS_PER_YEAR         = 12,           // Количество месяцев в году
        DAYS_PER_WEEK           = 7,            // Количество дней в неделе
        DAYS_PER_LEAP_YEAR      = 366,          // Количество дней в високосом году
        DAYS_PER_YEAR           = 365,          // Количество дней в году
        DAYS_PER_4_YEAR         = 1461,         // Количество дней за 4 года
        UNIX_EPOCH              = 1970,         // Год начала UNIX времени
        MAX_DAY_MONTH           = 31,           // Максимальное количество дней в месяце
        OADATE_UNIX_EPOCH       = 25569,        // Дата автоматизации OLE с момента эпохи UNIX
    };
    
    /// Скоращенные имена месяцев
    enum MonthNumber {
        JAN = 1,    ///< Январь
        FEB,        ///< Февраль
        MAR,        ///< Март
        APR,        ///< Апрель
        MAY,        ///< Май
        JUNE,       ///< Июнь
        JULY,       ///< Июль
        AUG,        ///< Август
        SEPT,       ///< Сентябрь
        OCT,        ///< Октябрь
        NOV,        ///< Ноябрь
        DEC,        ///< Декабрь
    };
    
    // Day of the week number
    enum WeekdayNumber {
        SUN = 0,    ///< Воскресенье
        MON,        ///< Понедельник
        TUS,        ///< Вторник
        WED,        ///< Среда
        THU,        ///< Четверг
        FRI,        ///< Пятница
        SAT,        ///< Суббота
    };

    /** \brief Получить час дня
     * Данная функция вернет от 0 до 23 (час дня)
     * \param timestamp метка времени
     * \return час дня
     */
    static inline uint hour_of_day(const datetime timestamp) {
        return (uint)(((ulong)timestamp / SEC_PER_HOUR) % HOURS_PER_DAY);
    }

    /** \brief Получить минуту дня
     *
     * Данная функция вернет от 0 до 1439 (минуту дня)
     * \param timestamp метка времени
     * \return минута дня
     */
    static inline uint min_of_day(const datetime timestamp) {
        return (uint)(((ulong)timestamp / SEC_PER_MIN) % MIN_PER_DAY);
    }

    /** \brief Получить минуту часа
     *
     * Данная функция вернет от 0 до 59
     * \param timestamp метка времени
     * \return Минута часа
     */
    static inline uint min_of_hour(const datetime timestamp) {
        return (uint)(((ulong)timestamp / SEC_PER_MIN) % MIN_PER_HOUR);
    }

    /** \brief Get timestamp at start of period
     *
     * \param period    Period
     * \param timestamp Timestamp
     * \return Timestamp at the beginning of the period
     */
    static inline datetime start_of_period(const uint period, const datetime timestamp) {
        return timestamp - (datetime)((ulong)timestamp % (ulong)period);
    }

    /** \brief Get a second of the day
     *
     * This function will return from 0 to 86399 (second of the day)
     * \param timestamp Time
     * \return Second of the day
     */
    static inline uint sec_of_day(const datetime timestamp) {
        return (uint)((ulong)timestamp % SEC_PER_DAY);
    }

    /** \brief Get a second of the day
     * This function will return from 0 to 86399 (second of the day)
     * \param hour      Hour of the day
     * \param minute    Minute of the hour
     * \param second    Second of the minute
     * \return Second of the day
     */
    static inline uint sec_of_day(const int hour, const int minute, const int second) {
        return hour * SEC_PER_HOUR + minute * SEC_PER_MIN + second;
    }
    
   /** \brief Get the second of the minute
	 * This function will return from 0 to 59 (second of the minute)
	 * \param timestamp Time
	 * \return Second of the minute
	 */
	static inline uint sec_of_min(const datetime timestamp) {
		return (uint)((ulong)timestamp % SEC_PER_MIN);
	}
//+------------------------------------------------------------------+
    /** \brief Convert string with time of day to second of day
     *
     * This function supports time formats:
     * HH:MM:SS Example: 23:25:59
     * HH:MM    Example: 23:25
     * HH       Example: 23
     * \param str_time  Time in string format
     * \return Returns the second of the day if the conversion succeeded, or SECONDS_IN_DAY if it failed.
     */
    static inline uint sec_of_day(const string str) {
        uint _hour = 0, _minute = 0, _second = 0;

        string result[];               // массив для получения строк
        const ushort u_sep = StringGetCharacter(":", 0);
        const int k = StringSplit(str, u_sep, result);
        if (k == 0) {
            ArrayFree(result);
            return SEC_PER_DAY;
        }
        switch(k) {
        case 1:
            _hour = (uint)StringToInteger(result[0]);
            break;
        case 2:
            _hour = (uint)StringToInteger(result[0]);
            _minute = (uint)StringToInteger(result[1]);
            break;
        case 3:
            _hour = (uint)StringToInteger(result[0]);
            _minute = (uint)StringToInteger(result[1]);
            _second = (uint)StringToInteger(result[2]);
            break;
        }
        if (_hour >= 24 ||
                _minute >= 60 ||
                _second >= 60) {
            ArrayFree(result);
            return SEC_PER_DAY;
        }
        ArrayFree(result);
        return sec_of_day(_hour, _minute, _second);
    }
//+------------------------------------------------------------------+
    static inline uint day_of_week(const uint day, const uint month, const uint year) {
        uint a = ( 14 - month ) / 12;
        uint y = year - a;
        uint m = month + 12 * a - 2;
        uint R = 7000 + ( day + y + y / 4 - y / 100 + y / 400 + (31 * m) / 12 );
        return R % 7;
    }
//+------------------------------------------------------------------+
    static inline datetime cet_to_gmt(const datetime cet) {
        const datetime ONE_HOUR = DurationTimePeriod::SEC_PER_HOUR;
        const int OLD_START_SUMMER_HOUR    = 2;
        const int OLD_STOP_SUMMER_HOUR     = 3;
        const int NEW_SUMMER_HOUR          = 1;
        const int MONTH_MARSH              = MonthNumber::MAR;
        const int MONTH_OCTOBER            = MonthNumber::OCT;
        
        MqlDateTime date_time;
        TimeToStruct(cet, date_time);
   
        CDateTime cdate_time;
        cdate_time.DateTime(cet);
        const int max_days = cdate_time.DaysInMonth();

        if(date_time.year < 2002) {
            // До 2002 года в Европе переход на летнее время осуществлялся в последнее воскресенье марта в 2:00 переводом часов на 1 час вперёд
            // а обратный переход осуществлялся в последнее воскресенье октября в 3:00 переводом на 1 час назад
            if(date_time.mon > MONTH_MARSH && date_time.mon < MONTH_OCTOBER) { // летнее время
                return cet - ONE_HOUR * 2;
            } else
            if(date_time.mon == MONTH_MARSH) {
                for(int d = max_days; d >= date_time.day; d--) {
                    uint _wday = day_of_week(d, MONTH_MARSH, date_time.year);
                    if(_wday == SUN) {
                        if(d == date_time.day) { // если сейчас воскресенье
                            if(date_time.hour >= OLD_START_SUMMER_HOUR) return cet - ONE_HOUR * 2; // летнее время
                            return cet - ONE_HOUR; // зимнее время
                        }
                        return cet - ONE_HOUR; // зимнее время
                    }
                }
                return cet - ONE_HOUR * 2; // летнее время
            } else
            if(date_time.mon == MONTH_OCTOBER) {
                for(int d = max_days; d >= date_time.day; d--) {
                    uint _wday = day_of_week(d, MONTH_OCTOBER, date_time.year);
                    if(_wday == SUN) {
                        if(d == date_time.day) { // если сейчас воскресенье
                            if(date_time.hour >= OLD_STOP_SUMMER_HOUR) return cet - ONE_HOUR; // зимнее время
                            return cet - ONE_HOUR; // зимнее время
                        }
                        return cet - ONE_HOUR * 2; // летнее время
                    }
                }
                return cet - ONE_HOUR; // зимнее время
            }
            return cet - ONE_HOUR; // зимнее время
        } else {
            // Начиная с 2002 года, согласно директиве ЕС(2000/84/EC) в Европе переход на летнее время осуществляется в 01:00 по Гринвичу.
            if(date_time.mon > MONTH_MARSH && date_time.mon < MONTH_OCTOBER) { // летнее время
                return cet - ONE_HOUR * 2;
            } else
            if(date_time.mon == MONTH_MARSH) {
                for(int d = max_days; d >= date_time.day; d--) {
                    uint _wday = day_of_week(d, MONTH_MARSH, date_time.year);
                    if(_wday == WeekdayNumber::SUN) {
                        if(d == date_time.day) { // если сейчас воскресенье
                            if(date_time.hour >= (NEW_SUMMER_HOUR + 2)) return cet - ONE_HOUR * 2; // летнее время
                            return cet - ONE_HOUR; // зимнее время
                        }
                        return cet - ONE_HOUR; // зимнее время
                    }
                }
                return cet - ONE_HOUR * 2; // летнее время
            } else
            if(date_time.mon == MONTH_OCTOBER) {
                for(int d = max_days; d >= date_time.day; d--) {
                    uint _wday = day_of_week(d, MONTH_OCTOBER, date_time.year);
                    if(_wday == SUN) {
                        if(d == date_time.day) { // если сейчас воскресенье
                            if(date_time.hour >= (NEW_SUMMER_HOUR + 1)) return cet - ONE_HOUR; // зимнее время
                            return cet - ONE_HOUR * 2; // летнее время
                        }
                        return cet - ONE_HOUR * 2; // летнее время
                    }
                }
                return cet - ONE_HOUR; // зимнее время
            }
            return cet - ONE_HOUR; // зимнее время
        }
        return cet - ONE_HOUR; // зимнее время
    }
//+------------------------------------------------------------------+
    static inline datetime eet_to_gmt(const datetime eet) {
        return cet_to_gmt(eet - DurationTimePeriod::SEC_PER_HOUR);
    }
//+------------------------------------------------------------------+
    /** \brief Time point class
     */
    class TimePoint {
    private:
    
        inline int get_second_of_day(const int hour, const int minute, const int second) {
    		return hour * (int)DurationTimePeriod::SEC_PER_HOUR + 
    		    minute * (int)DurationTimePeriod::SEC_PER_MIN + second;
    	}
    	
    public:
    
        int sec;
    
        inline bool set(const int hh, const int mm, const int ss) {
            if (hh < 0 || hh > 23) return false;
            if (mm < 0 || mm > 59) return false;
            if (ss < 0 || ss > 59) return false;
            sec = get_second_of_day(hh, mm, ss);
            return true;
        }
        
        inline bool set(const string &str) {
            string items[];
            StringSplit(str,StringGetCharacter(":",0),items);
            const int items_size = ArraySize(items);
            if (items_size == 3) {
                const bool res = set(
                    (int)StringToInteger(items[0]), 
                    (int)StringToInteger(items[1]), 
                    (int)StringToInteger(items[2]));
                ArrayFree(items);
                return res;
            } else
            if (items_size == 2) {
                const bool res = set(
                    (int)StringToInteger(items[0]), 
                    (int)StringToInteger(items[1]), 
                    0);
                ArrayFree(items);
                return res;
            }
            ArrayFree(items);
            return false;
        }
    
        TimePoint() {
            sec = 0;
        };
        
        TimePoint(const int hh, const int mm, const int ss) { 
            set(hh, mm, ss); 
        };
        
        TimePoint(const string &str) { 
            set(str); 
        };
    }; // TimePoint
//+------------------------------------------------------------------+
    /** \brief Time period class
     */
    class TimePeriod {
    public:
        TimePoint start;
        TimePoint stop;
        int id;
    
        inline void set(
                const TimePoint &user_start,
                const TimePoint &user_stop,
                const int user_id = 0) {
            start = user_start;
            stop = user_stop;
            id = user_id;
        }

        TimePeriod() {
            id = 0;
        };
        
        TimePeriod(
                const TimePoint &user_start,
                const TimePoint &user_stop,
                const int user_id = 0) { set(user_start, user_stop, user_id); };
    }; // TimePeriod
//+------------------------------------------------------------------+
    /** \brief Timer for delay measurements
	 */
	class Timer {
	private:
		ulong start_time;
		ulong sum;
		ulong counter;
	public:

		Timer() {
		    start_time = GetTickCount64();
		    sum = 0;
		    counter = 0;
		}

		/** \brief Reset timer value
		 * This method should only be used in conjunction with the elapsed() method.
		 * When using the get_average_measurements() method, there is no need to reset the timer!
		 */
		inline void reset() {
			start_time = GetTickCount64();
		}

		/** \brief Get elapsed time in milliseconds
		 * \return Time in milliseconds since class initialization or since reset()
		 */
		inline ulong get_elapsed_ms() const {
			return GetTickCount64() - start_time;
		}
		
		/** \brief Get elapsed time in seconds
		 * \return Time in seconds since class initialization or since reset()
		 */
		inline double get_elapsed() const {
			return (double)get_elapsed_ms() / 1000.0;
		}

		/** \brief Reset all measurements
		 * This method resets the sum of measurements and their number
		 */
		inline void reset_measurement() {
			sum = 0;
			counter = 0;
		}

		/** \brief Start measurement
		 * Use this method together with stop_measurement() and get_average_measurements() methods
		 */
		inline void start_measurement() {
			reset();
		}

		/** \brief Stop measurement
		 * Use this method together with stop_measurement() and get_average_measurements() methods
		 */
		inline void stop_measurement() {
			sum += get_elapsed_ms();
			++counter;
		}
		
		/** \brief Get measurement results
		 * Use this method together with stop_measurement() and get_average_measurements() methods
		 * The method returns the average measurement result
		 * \return Среднее время замеров в секундах
		 */
		inline ulong get_average_measurements_ms() const {
			return sum / counter;
		}

		/** \brief Get measurement results
		 * Use this method together with stop_measurement() and get_average_measurements() methods
		 * The method returns the average measurement result
		 * \return Average sampling time in milliseconds
		 */
		inline double get_average_measurements() const {
			return (double) sum / (double)counter;
		}
	};
};

#endif
//+------------------------------------------------------------------+
