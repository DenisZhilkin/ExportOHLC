//+------------------------------------------------------------------+
//|                           Export.csv.mq5 |
//|                             ZDen |
//|               https://www.mql5.com/ru/users/zden |
//+------------------------------------------------------------------+
#property copyright "ZDen"
#property link    "https://www.mql5.com/ru/users/zden"
#property version   "1.00"
#property script_show_inputs

#define DEFAULT_FILE_NAME               "Symbol_tf_firstdate.csv"

input ENUM_TIMEFRAMES timeframe         = PERIOD_CURRENT;
input string    delimiter               = ",";
input string    filename                = DEFAULT_FILE_NAME;
// Fields:
input bool      open                    = true;
input bool      high                    = true;
input bool      low                     = true;
input bool      close                   = true;
input bool      tick_volume             = false;
input bool      real_volume             = false;
//+------------------------------------------------------------------+
//| Script program start function                    |
//+------------------------------------------------------------------+
void OnStart()
{
    string symbol = _Symbol;
    int maxlen = Bars(symbol, timeframe);
    datetime first = iTime(symbol, timeframe, maxlen - 1);
    datetime last = iTime(symbol, timeframe, 0);
    Print("Доступны данные от ", first, ". Итого значений: ", maxlen);
    MqlRates data[];
    int ncopied = CopyRates(symbol, timeframe, first, last, data);
    if(ncopied <= 0)
    {
        Print("Ошибка получения данных ", GetLastError());
        return;
    }
    int ngot = ArraySize(data);
    Print("Получено ", ngot, " значений из ", ncopied);
    MqlDateTime from; 
    if(!TimeToStruct(first, from))
        Print("Ошибка ", GetLastError());
    string fname;
    string month = from.mon < 10 ? "0" + (string)from.mon : (string)from.mon;
    string day = from.day < 10 ? "0" + (string)from.day : (string)from.day;
    if(filename == DEFAULT_FILE_NAME)
    {
        string symb = (symbol == "") ? Symbol() : symbol;
        string per = !timeframe ? EnumToString(Period()) : EnumToString(timeframe);
        fname = symb + "_" + (string)per + "_" + (string)from.year + "-" + month + "-" + day + ".csv";
    }
    else if(StringSubstr(filename, StringLen(filename) - 4) == ".csv")
        fname = filename;
    else
        fname = filename + ".csv";
    int handle = FileOpen(fname, FILE_WRITE|FILE_CSV|FILE_ANSI);
    string headers = "date";
    if(open) headers += delimiter + "open";
    if(high) headers += delimiter + "high";
    if(low) headers += delimiter + "low";
    if(close) headers += delimiter + "close";
    if(tick_volume) headers += delimiter + "tick_volume";
    if(real_volume) headers += delimiter + "real_volume";
    headers += "\r\n";
    FileWriteString(handle, headers);
    for(int i = 0; i < ngot; i++)
    {
        string row = (string)data[i].time;
        if(open) row += delimiter + (string)data[i].open;
        if(high) row += delimiter + (string)data[i].high;
        if(low) row += delimiter + (string)data[i].low;
        if(close) row += delimiter + (string)data[i].close;
        if(tick_volume) row += delimiter + (string)data[i].tick_volume;
        if(real_volume) row += delimiter + (string)data[i].real_volume;
        row += "\r\n";
        FileWriteString(handle, row);
    }
    FileClose(handle);
    Print("Данные сохранены в файл ", fname);
}
/*
* TODO:
*   Язык консольных логов рус или англ в зависимости от языка терминала
*/
//+------------------------------------------------------------------+
