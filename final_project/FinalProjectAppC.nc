#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "FinalProject.h"

configuration FinalProjectAppC{
}
implementation {

  /****** COMPONENTS *****/
  components MainC, FinalProjectC as App;
  components PrintfC;
  components new TimerMilliC();
  components SerialStartC;
  components ActiveMessageC;
  components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components LocalTimeMilliC;


/****** INTERFACES *****/
  App.Boot -> MainC.Boot;
  App.MilliTimer -> TimerMilliC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.AMControl -> ActiveMessageC;
  App.LocalTime -> LocalTimeMilliC;
  
}
