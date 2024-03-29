//+------------------------------------------------------------------+
//|                                                      mql5gui.mqh |
//|                     Copyright 2022-2023, MegaConnector Software. |
//|                                      https://mega-connector.com/ |
//+------------------------------------------------------------------+
#ifndef MQL5GUI_MQH
#define MQL5GUI_MQH

#include "..\part\common.mqh"
#include "..\utils\unique_id.mqh"
#include <Arrays\ArrayString.mqh>

#property copyright "Copyright 2022-2023, MegaConnector Software."
#property link      "https://mega-connector.com/"
#property version   "1.00"
#property strict

#define MQL5GUI_COLOR_TEXT C'207,216,220'

/** \brief Anchor point of a graphical object on the screen
 */
enum Mql5GUIAnchorPoint {
    MQL5GUI_TOP_LEFT,                // Top Left
    MQL5GUI_TOP_RIGHT,               // Top Right
    MQL5GUI_BOTTOM_LEFT,             // Bottom Left
    MQL5GUI_BOTTOM_RIGHT             // Bottom Right
};

class Mql5GUI {
private:
    string  m_uid;

    color   m_color_bg;
    color   m_color_bg_header;
    color   m_color_border;
    color   m_color_text;
    
    long    m_chart_id;
    int     m_border_width;
    
    long    m_pos_x;
    long    m_pos_y;
    
    int     m_width;
    int     m_height;
    
    long    m_chart_width;
    long    m_chart_height;
    
    int     m_sum_x;
    int     m_sum_y;
    
    int     m_text_id_counter;
    int     m_text_h;
    
    MegaConnectorAnchorPoint    m_anchor;
    CArrayString                m_obj_name_list;
     
    bool    m_init;
    
    void add_label_list(const string &obj_name) {
        if (m_obj_name_list.Search(obj_name) >= 0) return;
        m_obj_name_list.Add(obj_name);
        m_obj_name_list.Sort();
    }

    void remove() {
        ResetLastError();
        const int total = m_obj_name_list.Total();
        for (int i = 0; i < total; ++i) {
            const string obj_name = m_obj_name_list.At(i);
            ObjectDelete(0, obj_name);
        }
        m_obj_name_list.Clear();
        ChartRedraw();
    }
    
    inline string get_text_id(const int arg_id) {
        return "mql5gui_text_" + IntegerToString(arg_id) + "_" + m_uid;
    }
    
public:

    string  font;
    int     font_size;
    int     font_indent;

    int     indent_x;
    int     indent_y;
    
    int     border_indent_x;
    int     border_indent_y;

    Mql5GUI() {
        m_uid               = get_str_unique_id();

        m_color_bg          = C'50,50,50';
        m_color_bg_header   = C'33,33,33';
        m_color_border      = C'42,42,42';
        m_color_text        = MQL5GUI_COLOR_TEXT;
        
        m_chart_id          = 0;
        m_border_width      = 2;
        
        m_width             = 0;
        m_height            = 0;

        m_pos_x             = 0;
        m_pos_y             = 0;
        
        font                = "Arial";
        font_size           = 10;
        font_indent         = 2;
        
        indent_y            = 32;
        indent_x            = 32;
        
        border_indent_x     = 8;
        border_indent_y     = 8;
        
        m_chart_height      = 0;
        m_chart_width       = 0;
        
        m_sum_x             = 0;
        m_sum_y             = 0;
        
        m_text_id_counter   = 0;
        m_text_h            = 0;
        
        m_anchor            = MegaConnectorAnchorPoint::MC_TOP_LEFT;
        m_init              = false;
    };
    
    ~Mql5GUI() {
        remove();
    };
    
    inline void set_anchor_point(const MegaConnectorAnchorPoint arg_anchor) {
        m_anchor = arg_anchor;
    };
    
    bool begin(const int w = 0, const int h = 0) {
        // обнуляем счетчики
        m_text_id_counter = 0;
        m_text_h = 0;

        m_width  = w > 0 ? w : 0;
        m_height = h > 0 ? h : 0;
        const string name = "mql5gui_window_" + m_uid;
        if (!m_init) {
            if(!ObjectCreate(m_chart_id,name,OBJ_RECTANGLE_LABEL,0,0,0)) {
                Print(__FUNCTION__, ": failed to create label! Error code = ",GetLastError());
                return(false);
            }

            if (m_width) ObjectSetInteger(m_chart_id,name,OBJPROP_XSIZE, m_width);
            if (m_height) ObjectSetInteger(m_chart_id,name,OBJPROP_YSIZE, m_height);
  
            ObjectSetInteger(m_chart_id,name,OBJPROP_BGCOLOR, m_color_bg);
            ObjectSetInteger(m_chart_id,name,OBJPROP_BORDER_TYPE, BORDER_FLAT);
            ObjectSetInteger(m_chart_id,name,OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSetInteger(m_chart_id,name,OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
            ObjectSetInteger(m_chart_id,name,OBJPROP_COLOR,m_color_border);
            ObjectSetInteger(m_chart_id,name,OBJPROP_STYLE,STYLE_SOLID);
            ObjectSetInteger(m_chart_id,name,OBJPROP_WIDTH,m_border_width);
            ObjectSetInteger(m_chart_id,name,OBJPROP_BACK,true);
            ObjectSetInteger(m_chart_id,name,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(m_chart_id,name,OBJPROP_SELECTED,false);
            ObjectSetInteger(m_chart_id,name,OBJPROP_HIDDEN,true);
            ObjectSetInteger(m_chart_id,name,OBJPROP_ZORDER,0);
        } else {
            if (m_width) ObjectSetInteger(m_chart_id,name,OBJPROP_XSIZE, m_width);
            if (m_height) ObjectSetInteger(m_chart_id,name,OBJPROP_YSIZE, m_height);
        }
        add_label_list(name);
        return true;
    };
    
    inline void set_next_text_color(const color arg_value) {
        m_color_text = arg_value;
    }
    
    bool text(const string &arg_text) {
        // вычисляем параметры текста
        int text_w = 0;
        int text_h = 0;
        TextSetFont(font, font_size * -10);
        TextGetSize(arg_text, text_w, text_h);
        const int full_h = text_h + font_indent;
        m_text_h = MathMax(m_text_h, full_h);
        m_sum_x = MathMax(m_sum_x, text_w);
        m_sum_y += full_h;
        
        // рисуем метку с текстом
        const string name = get_text_id(m_text_id_counter);
        
        ResetLastError();
        if (!m_init) {
            if(!ObjectCreate(m_chart_id,name,OBJ_LABEL,0,0,0)) {
                Print(__FUNCTION__, ": failed to create text label! Error code = ",GetLastError());
                return false;
            }
            ObjectSetInteger(m_chart_id,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
            ObjectSetString(m_chart_id,name,OBJPROP_TEXT,arg_text);
            ObjectSetString(m_chart_id,name,OBJPROP_FONT,font);
            ObjectSetInteger(m_chart_id,name,OBJPROP_FONTSIZE,font_size);
            ObjectSetDouble(m_chart_id,name,OBJPROP_ANGLE,0);
            ObjectSetInteger(m_chart_id,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
            ObjectSetInteger(m_chart_id,name,OBJPROP_COLOR,m_color_text);
            ObjectSetInteger(m_chart_id,name,OBJPROP_BACK,false);
            ObjectSetInteger(m_chart_id,name,OBJPROP_SELECTABLE,false);
            ObjectSetInteger(m_chart_id,name,OBJPROP_SELECTED,false);
            ObjectSetInteger(m_chart_id,name,OBJPROP_HIDDEN,true);
            ObjectSetInteger(m_chart_id,name,OBJPROP_ZORDER,0);
        } else {
            ObjectSetString(m_chart_id,name,OBJPROP_TEXT,arg_text);
        }
        
        add_label_list(name);
        ++m_text_id_counter;
        
        m_color_text = MQL5GUI_COLOR_TEXT;
        return true;
    }
    
    void end() {
        //{ Работаем с главным окном
        const string window_name = "mql5gui_window_" + m_uid;
        if (m_width == 0) {
            m_width = m_sum_x + 2 * border_indent_x;
        }
        if (m_height == 0) {
            m_height = m_sum_y + 2 * border_indent_y;
        }
        
        m_chart_height = 0;
        m_chart_width = 0;
        ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0, m_chart_height);
        ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0, m_chart_width);
        
        switch (m_anchor) {
        case MegaConnectorAnchorPoint::MC_TOP_LEFT:
            m_pos_x = indent_x;
            m_pos_y = indent_y;
            break;
        case MegaConnectorAnchorPoint::MC_TOP_RIGHT:
            m_pos_x = m_chart_width - indent_x - m_width;
            m_pos_y = indent_y;
            break;
        case MegaConnectorAnchorPoint::MC_BOTTOM_LEFT:
            m_pos_x = indent_x;
            m_pos_y = m_chart_height - indent_y - m_height;
            break;
        case MegaConnectorAnchorPoint::MC_BOTTOM_RIGHT:
            m_pos_x = m_chart_width - indent_x - m_width;
            m_pos_y = m_chart_height - indent_y - m_height;
            break;
        }

        ObjectSetInteger(m_chart_id,window_name,OBJPROP_XDISTANCE,m_pos_x);
        ObjectSetInteger(m_chart_id,window_name,OBJPROP_YDISTANCE,m_pos_y);
        ObjectSetInteger(m_chart_id,window_name,OBJPROP_XSIZE, m_width);
        ObjectSetInteger(m_chart_id,window_name,OBJPROP_YSIZE, m_height);
        //}
        
        const long start_pos_x = m_pos_x + border_indent_x;
        const long start_pos_y = m_pos_y + border_indent_y;
        //{ Обрабатываем текстовые сообщения
        for(int i = 0; i < m_text_id_counter; ++i) {
            const string name = get_text_id(i);
            const long pos_y = start_pos_y + m_text_h * i;
            ObjectSetInteger(m_chart_id,name,OBJPROP_XDISTANCE,start_pos_x);
            ObjectSetInteger(m_chart_id,name,OBJPROP_YDISTANCE,pos_y);
        }
        //}
        
        m_init = true;
        ChartRedraw();
    }
};

#endif
//+------------------------------------------------------------------+
