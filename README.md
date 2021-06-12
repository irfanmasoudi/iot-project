# iot-project: Keep your distance
## Author: 
## Abednego WAMUHINDO KAMBALE 10740158
## Muhammad Irfan Mas’udi 10672914

Design and implement a software prototype for a so- cial distancing application using TinyOS and Node-Red and test it with Cooja. The application is meant to understand and alert you when two people (motes) are close to each other. The operation of the software is as follow:
* Each mote broadcasts its presence every 500ms with a message con- taining the ID number.
* When a mote is in the proximity area of another mote and receives 10 consecutive messages from that mote, it triggers an alarm. Such alarm contains the ID number of the two motes. It is shown in Cooja and forwarded to Node-Red via socket (a different one for each mote).
* Upon the reception of the alert, Node-red sends a notification through IFTTT to your mobile phone.
Use at least 5 motes. Start the simulation with all the mote far away from each other and move them with the mouse testing different configurations.

## How to use:
* final_project folder contains TinyOS and TOSSIm source code.
* node-red folder includes flows that make the connection between cooja simulator then make a notification with IFTTT.
