#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

#import  "shell32.dll"           //Connect a dll (provided with Windows)             
  int ShellExecuteA(int hwnd, string Operation, string File, string Parameters, string Directory, int ShowCmd); 
#import

extern int maxDrawTicks = 1000;

double ask[];
double bid[];
int myBars;
int tickCounter;

//инициализация
int init() {
//   IndicatorBuffers(2); 

   SetIndexBuffer(0, ask);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexDrawBegin(0, 0);
   SetIndexLabel(0, "ask");
   SetIndexShift(0, 0);

   SetIndexBuffer(1, bid);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexDrawBegin(1, 0);
   SetIndexLabel(1, "bid");
   SetIndexShift(1, 0);

   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));

   return (0);
}
  
//деструктор
int deinit() {
	closeDelimeter();

	return(0);
}

int start(){
    double a = Ask;
    double b = Bid; //MarketInfo(Symbol(), MODE_BID);
    ask[0] = a;
    bid[0] = b;

	if (isNewBar()) {
        // установить разделитель
		setDelimeter();
   	} else {
		tickCounter++;

    	for (int j = maxDrawTicks; j >= 1; j--) {
    		ask[j] = ask[j - 1];
    		bid[j] = bid[j - 1];
    	}

    	leftDelimeter();
   	}

	return (0);
}

void setDelimeter() {
	string delimeterDate = TimeToStr(Time[0]);

	if (myBars != 0) {
    	int handle = WindowFind("ticks");

        if (!ObjectCreate(delimeterDate, OBJ_VLINE, handle, Time[0], 0)) {
         //Alert("Недачная попытка создания разделителя в окне ",
         //handle," по времени ",TimeToStr(CurTime()));
         //Print("Ошибка №",GetLastError(),", имя разделителя ",delimeterDate);
        } else {
        	ObjectSet(delimeterDate, OBJPROP_COLOR, Yellow);
         	ObjectSet(delimeterDate, OBJPROP_STYLE, STYLE_DASHDOT);
         	ObjectsRedraw();
    	}
	}

	return (0);
}

void leftDelimeter() {
   	string delimeterName;
   	datetime firstTime;
   	int barFirstTime;
   
	for (int i = 0; i < ObjectsTotal(); i++) {
		delimeterName = ObjectName(i); 

		if (ObjectFind(delimeterName) != -1) {
			if (ObjectType(delimeterName) == OBJ_VLINE) {
            	firstTime = ObjectGet(delimeterName, OBJPROP_TIME1);
            	barFirstTime = iBarShift(NULL, 0, firstTime);
            	firstTime = Time[barFirstTime + 1];

            	ObjectSet(delimeterName, OBJPROP_TIME1, firstTime);
            }
        }       
	}

	return (0);
}

void closeDelimeter() {
   	int handle = WindowFind("ticks");

	ObjectsDeleteAll(handle, OBJ_VLINE);

	return (0);
}

bool isNewBar() {
	bool res = false;

   	if (myBars != Bars) {
      	res = true;
    	myBars = Bars;
    }   

	return(res);
}

