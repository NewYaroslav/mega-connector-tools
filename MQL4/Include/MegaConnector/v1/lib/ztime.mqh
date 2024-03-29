//+------------------------------------------------------------------+
//|                                                        ztime.mqh |
//|                     Copyright 2022-2023, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef ZTIME_MQH
#define ZTIME_MQH

/* original library: https://github.com/NewYaroslav/ztime-cpp */

#property copyright "Copyright 2022-2023, MegaConnector Software."
#property link      "https://mega-connector.com/"
#property version   "1.00"
#property strict

class ztime {
public:
                     ztime() {};
                    ~ztime() {};

    // The number of seconds in a minute, hour, etc.
    enum DurationTimePeriod {
        SECONDS_IN_MINUTE = 60,             // Количество секунд в одной минуте
        SECONDS_IN_HALF_HOUR = 1800,        // Количество секунд в получасе
        SECONDS_IN_HOUR = 3600,             // Количество секунд в одном часе
        SECONDS_IN_DAY = 86400,             // Количество секунд в одном дне
        SECONDS_IN_YEAR = 31536000,         // Количество секунд за год
        SECONDS_IN_LEAP_YEAR = 31622400,    // Количество секунд за високосный год
        AVERAGE_SECONDS_IN_YEAR = 31557600, // Среднее количество секунд за год
        SECONDS_IN_4_YEAR = 126230400,      // Количество секунд за 4 года
        MINUTES_IN_HOUR = 60,               // Количество минут в одном часе
        MINUTES_IN_DAY = 1440,              // Количество минут в одном дне
        HOURS_IN_DAY = 24,                  // Количество часов в одном дне
        MONTHS_IN_YEAR = 12,                // Количество месяцев в году
        DAYS_IN_WEEK = 7,                   // Количество дней в неделе
        DAYS_IN_LEAP_YEAR = 366,            // Количество дней в високосом году
        DAYS_IN_YEAR = 365,                 // Количество дней в году
        DAYS_IN_4_YEAR = 1461,              // Количество дней за 4 года
        FIRST_YEAR_UNIX = 1970,             // Год начала UNIX времени
        MAX_DAY_MONTH = 31,                 // Максимальное количество дней в месяце
        OADATE_UNIX_EPOCH = 25569,          // Дата автоматизации OLE с момента эпохи UNIX
    };

    /** \brief Получить час дня
     * Данная функция вернет от 0 до 23 (час дня)
     * \param timestamp метка времени
     * \return час дня
     */
    static inline uint get_hour_day(const datetime timestamp) {
        return (uint)(((ulong)timestamp / SECONDS_IN_HOUR) % HOURS_IN_DAY);
    }

    /** \brief Получить минуту дня
     *
     * Данная функция вернет от 0 до 1439 (минуту дня)
     * \param timestamp метка времени
     * \return минута дня
     */
    static inline uint get_minute_day(const datetime timestamp) {
        return (uint)(((ulong)timestamp / SECONDS_IN_MINUTE) % MINUTES_IN_DAY);
    }

    /** \brief Получить минуту часа
     *
     * Данная функция вернет от 0 до 59
     * \param timestamp метка времени
     * \return Минута часа
     */
    static inline uint get_minute_hour(const datetime timestamp) {
        return (uint)(((ulong)timestamp / SECONDS_IN_MINUTE) % MINUTES_IN_HOUR);
    }

    /** \brief Get timestamp at start of period
     *
     * \param period    Period
     * \param timestamp Timestamp
     * \return Timestamp at the beginning of the period
     */
    static inline datetime get_first_timestamp_period(const uint period, const datetime timestamp) {
        return timestamp - (datetime)((ulong)timestamp % (ulong)period);
    }

    /** \brief Get a second of the day
     *
     * This function will return from 0 to 86399 (second of the day)
     * \param timestamp Timestamp
     * \return Second of the day
     */
    static inline uint get_second_day(const datetime timestamp) {
        return (uint)((ulong)timestamp % SECONDS_IN_DAY);
    }

    /** \brief Get a second of the day
     * This function will return from 0 to 86399 (second of the day)
     * \param hour      Hour of the day
     * \param minute    Minute of the hour
     * \param second    Second of the minute
     * \return Second of the day
     */
    static inline uint get_second_day(const int hour, const int minute, const int second) {
        return hour * SECONDS_IN_HOUR + minute * SECONDS_IN_MINUTE + second;
    }

    /** \brief Convert string with time of day to second of day
     *
     * This function supports time formats:
     * HH:MM:SS Example: 23:25:59
     * HH:MM    Example: 23:25
     * HH       Example: 23
     * \param str_time  Time in string format
     * \return Returns the second of the day if the conversion succeeded, or SECONDS_IN_DAY if it failed.
     */
    static inline uint to_second_day(const string str_time) {
        uint _hour = 0, _minute = 0, _second = 0;

        string result[];               // массив для получения строк
        const ushort u_sep = StringGetCharacter(":", 0);
        const int k = StringSplit(str_time, u_sep, result);
        if (k == 0) {
            ArrayFree(result);
            return SECONDS_IN_DAY;
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
            return SECONDS_IN_DAY;
        }
        ArrayFree(result);
        return get_second_day(_hour, _minute, _second);
    }
};
//+------------------------------------------------------------------+
    /** \brief Time point class
     */
    class ZtimeTimePoint {
    private:
    
        inline int get_second_day(const int hour, const int minute, const int second) {
    		return hour * (int)DurationTimePeriod::SECONDS_IN_HOUR + 
    		    minute * (int)DurationTimePeriod::SECONDS_IN_MINUTE + second;
    	}
    	
    public:
    
        int second_day;
    
        inline void set(const int hh, const int mm, const int ss) {
            second_day = get_second_day(hh, mm, ss);
        }
    
        ZtimeTimePoint() {
            second_day = 0;
        };
        
        ZtimeTimePoint(const int hh, const int mm, const int ss) { 
            set(hh, mm, ss); 
        };
    }; // TimePoint
//+------------------------------------------------------------------+
    /** \brief Time period class
     */
    class ZtimeTimePeriod {
    public:
        ZtimeTimePoint start;
        ZtimeTimePoint stop;
        int id;
    
        inline void set(
                const ZtimeTimePoint &user_start,
                const ZtimeTimePoint &user_stop,
                const int user_id = 0) {
            start = user_start;
            stop = user_stop;
            id = user_id;
        }
    
        ZtimeTimePeriod() {
            id = 0;
        };
        
        ZtimeTimePeriod(
                const ZtimeTimePoint &user_start,
                const ZtimeTimePoint &user_stop,
                const int user_id = 0) { set(user_start, user_stop, user_id); };
    }; // TimePeriod
//+------------------------------------------------------------------+
    /** \brief Timer for delay measurements
	 */
	class ZtimeTimer {
	private:
		ulong start_time;
		ulong sum;
		ulong counter;
		
		uint prev_tick_count;
		ulong tick_count_offset;
		
		ulong get_tick_count_64() {
		    const ulong MAX_INT = 4294967295;
		    if (GetTickCount() < prev_tick_count) {
		        tick_count_offset += MAX_INT;
		    }
		    prev_tick_count = GetTickCount();
		    return tick_count_offset + prev_tick_count;
		}
		
	public:

		ZtimeTimer() {
		    tick_count_offset = 0;
		    prev_tick_count = 0;
		    start_time = get_tick_count_64();
		    sum = 0;
		    counter = 0;
		}
		
		~ZtimeTimer() {};

		/** \brief Reset timer value
		 * This method should only be used in conjunction with the elapsed() method.
		 * When using the get_average_measurements() method, there is no need to reset the timer!
		 */
		inline void reset() {
			start_time = get_tick_count_64();
		}

		/** \brief Get elapsed time in milliseconds
		 * \return Time in milliseconds since class initialization or since reset()
		 */
		inline ulong get_elapsed_ms() {
			return get_tick_count_64() - start_time;
		}
		
		/** \brief Get elapsed time in seconds
		 * \return Time in seconds since class initialization or since reset()
		 */
		inline double get_elapsed() {
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
#endif
//+------------------------------------------------------------------+
