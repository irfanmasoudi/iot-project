#include "printf.h"
#include "Timer.h"
#include "FinalProject.h"
#define Mote_Number 50
#define INIT_ID 60

module FinalProjectC {
  uses {
    interface Boot;
    interface Packet;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Receive;
    interface AMSend;
    interface LocalTime<TMilli> ;
  }
}

implementation {
  uint8_t mote_number = 50;
  message_t packet;
  uint8_t i;
  uint8_t current_id = INIT_ID;
  bool locked;
  uint8_t index;
  uint8_t last_index;
  uint32_t current_time;
  
  //Stores the current 50 received Id and their related counter and lasttime
  uint8_t ids_received [Mote_Number];
  uint8_t counters [Mote_Number];
  uint32_t last_times [Mote_Number];
  
  void initializeArrays();
  uint8_t checkIDPresent(uint8_t received_id);
  uint8_t retrieveLastFreeId();
  void processMessage(uint8_t received_id, uint32_t _time);
  
  
  event void Boot.booted() {
  
  	//After the boot of the mote, start radio component
  	dbg("log", "The mote %u: has booted.\n", TOS_NODE_ID);
  	
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
  	dbg("log", "The radio module for mote %u is active.\n", TOS_NODE_ID);
   
    initializeArrays();
     //After radio module start, create timer (500ms)
    call MilliTimer.startPeriodic(500);	
        
  }

  event void MilliTimer.fired() {
    dbg("log", "The mote %u timer is fired.\n", TOS_NODE_ID);
    if (locked) {
      return;
    }
    else {

      msg_t* rcm = (msg_t*)call Packet.getPayload(&packet, sizeof(msg_t));
      if (rcm == NULL) {
      	dbg("log", "Mote %u: error while creating a message. No message will be sent.\n", TOS_NODE_ID);
        return;
      }
      
      //Send mote ID as broadcast message through radio component
      rcm->mote_id = TOS_NODE_ID;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(msg_t)) == SUCCESS) {
      	dbg("log", "The message sent from mote %u in broadcast.\n", TOS_NODE_ID);
      	
        locked = TRUE;
        
      }
    }
  }
 //Function to check if the received Id is already present in the array and return the index of the received Id in the array
 
 void initializeArrays(){
 
 	for(i=0; i<Mote_Number-1; i++){
 		
 		ids_received[i] = INIT_ID;
 		counters[i] = 0;
 		last_times[i] = 0;
 	
 	}
 
 }
 
 uint8_t checkIDPresent(uint8_t received_id){
 		index = INIT_ID;
 		for (i = 0; i < Mote_Number- 1; i++) {
          if(ids_received[i] == received_id ){
          	index = i;
          	break;
          }     
        }
      
        return index; 
 
 }
 
  uint8_t retrieveLastFreeId(){
  		index = INIT_ID;
 		for (i = 0; i < Mote_Number- 1; i++) {
          if(ids_received[i]==INIT_ID){
          	index = i;
          	break;
          }     
        }
        //printf("index %u.\n ",index);
        return index; 
 
 }
 
 void processMessage(uint8_t received_id, uint32_t _time){
 
  		current_id = checkIDPresent(received_id);
  	    if (current_id!=INIT_ID) {
      	dbg("log", "The mote %u is already registered in memory of mote %u.\n", received_id, TOS_NODE_ID);
      	//printf("The mote %u is already registered in memory of mote %u.\n", received_id, TOS_NODE_ID);
		dbg("log", "Check if the current time is within the range.\n");
      	//printf("Check if the current time is within the range.\n");	
      		
		/*check if the difference between time of the last received message and the current time from the mote is more than 500ms*/
			if((_time - last_times[current_id])>520){
			
				dbg("log", "The mote %u sent its message %u milliseconds ago.\n",received_id,(_time - last_times[current_id]));
				//printf("The mote %u sent its message %u milliseconds ago.\n",received_id,(time - last_times[current_id]));
					
				dbg("log", "Its counter is reset\n");
				//printf("Its counter is reset\n");
				counters[current_id] = 1;
				last_times[current_id] = _time;
			}else{
			
				counters[current_id] = counters[current_id]+1;
				last_times[current_id] = _time;
				dbg("log", "Counter for mote %u in mote %u is %u.\n", received_id, TOS_NODE_ID, counters[current_id]);
				//printf("Counter for mote %u in mote %u is %u.\n", received_id, TOS_NODE_ID, counters[current_id]);
				if(counters[current_id]==10){
				
				//we forward the message to node-red to set an alarm and reset the counter
					dbg("log", "Alarm!!! The mote %u is passing message to Node-Red. message: %u,%u.\n", TOS_NODE_ID, TOS_NODE_ID, received_id);
				//printf("Alarm!!! The mote %u is passing message to Node-Red. message: %u,%u.\n", TOS_NODE_ID, TOS_NODE_ID, received_id);				
					printf("%u,%u\n",TOS_NODE_ID,received_id);
					
					dbg("log", "The forwading operation from mote %u is done. message: %u,%u.\n", TOS_NODE_ID, TOS_NODE_ID, received_id);
					
					//reset the counter
					dbg("log", "The mote %u reset the counter for mote %u.\n", TOS_NODE_ID, received_id);
					counters[current_id] = 0;
						
					printfflush();		
				}	
			}		
      	}else{
			dbg("log", "The mote %u is not registered in memory of mote %u.\n", received_id, TOS_NODE_ID);
			//printf("The mote %u is not registered in memory of mote %u.\n", received_id, TOS_NODE_ID);
			dbg("log", "Registering mote %u in memory of mote %u...\n", received_id, TOS_NODE_ID);
			//printf("Registering mote %u in memory of mote %u...\n", received_id, TOS_NODE_ID);
			last_index = retrieveLastFreeId();
      		if(last_index!=INIT_ID){
      			dbg("log", "Memory available in %u : Registering mote %u...\n", TOS_NODE_ID, received_id);
      			//printf("Memory available in %u : Registering mote %u...\n", TOS_NODE_ID, received_id);
      			
      			counters[last_index]=1;
      			ids_received[last_index] = received_id;
      			last_times[last_index] = _time;
      			dbg("log", "Registering of mote %u finished.\n", received_id);
      			//printf("Registering of mote %u finished.\n", received_id);
      		}else{
      			dbg("log", "Memory not available in %u : discarding the old registered mote %u...\n", TOS_NODE_ID, ids_received[0]);
      			
      			
      			for (i = 0; i < Mote_Number- 2; i++) {
          			ids_received[i] = ids_received[i + 1];
          			counters[i] = counters[i + 1];
          			last_times[i] = last_times[i + 1];
        		}
        		dbg("log", "Memory available now in %u : Registering mote %u...\n", TOS_NODE_ID, received_id);
      			counters[Mote_Number- 1]=1;
      			ids_received[Mote_Number- 1] = received_id;
      			last_times[Mote_Number- 1] = _time;
      			dbg("log", "Registering of mote %u finished.\n", received_id);
      		}
      	}  
  }

 
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    if (len != sizeof(msg_t)) {
      dbg("log", "The mote %u received malformed packet.\n", TOS_NODE_ID);
      return bufPtr;
    }
    else {
      
      msg_t* rcm = (msg_t*)payload;
      current_time = call LocalTime.get();
      dbg("log", "The mote %u received packet from mote %u.\n", TOS_NODE_ID, rcm->mote_id);
      
      //Process the received packet
	  processMessage(rcm->mote_id,current_time);
      return bufPtr;
    }
  }
  

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
}
