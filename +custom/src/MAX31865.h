extern "C"{
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "LibraryBase.h"
#include "Adafruit_MAX31865.h"
}

//FIXME: figure out why it can't find map.
//temporary fix: use array instead.
//#include <map>

#define CREATE_MAX31865 0x00
#define DELETE 0x01
#define BEGIN 0x02
#define READ_FAULT 0x03
#define CLEAR_FAULT 0x04
#define READ_RTD 0x05
#define SET_WIRES 0x06
#define AUTO_CONVERT 0x07
#define ENABLE_BIAS 0x08
#define READ_TEMPERATURE 0x09

const char DEBUG_MESSAGE[]			PROGMEM = "text string\n";
const char DEBUG_TEMP_VALS[]		PROGMEM = "%d, %d, %d, %d, %d\n%d, %d, %d, %d, %d\n";
const char DEBUG_SPI_SOFTWARE[]     PROGMEM = "software spi init\n";
const char DEBUG_SPI_HARDWARE[]     PROGMEM = "spi_hardware_init\n";
const char DEBUG_NOT_INITIALIZED[]  PROGMEM = "Error: Device not initialized.\n";
const char DEBUG_CS[]				PROGMEM = "%d\n";



class MAX31865 : public LibraryBase {
public:
	//std::map<int, Adafruit_MAX31865*> amax31865_m;
	Adafruit_MAX31865 * amax31865_a[10];
	int cs2index[20];
	int devices = 0;
	
public:
	MAX31865(MWArduinoClass& a) {
		libName = "custom/MAX31865";
		a.registerLibrary(this);
	}
	
	void commandHandler(byte cmdID, byte* dataIn, unsigned int payloadSize)
	{ 
		
      switch (cmdID){
               
         case CREATE_MAX31865: {
			 //device with this cs is already created. No-go
			 //fixme: fix me
			 
			 if(payloadSize == 1){
				cs2index[*dataIn] = devices;
				amax31865_a[devices] = new Adafruit_MAX31865(*dataIn);
				debugPrint(DEBUG_SPI_HARDWARE);
			 }
			 else if(payloadSize == 4){
				 amax31865_a[devices] = new Adafruit_MAX31865(*dataIn, *(dataIn+1), *(dataIn+2), *(dataIn+3));
				 debugPrint(DEBUG_SPI_SOFTWARE);
			 }
			 ++devices;
			 sendResponseMsg(cmdID, 0, 0);
		 break;}
		 
		 case BEGIN:{
			byte success = amax31865_a[cs2index[*dataIn]]->begin((max31865_numwires_t) *(dataIn+1));
			sendResponseMsg(cmdID, &success, 1);
		 break;}
		 
		 case READ_FAULT:{
			byte val = amax31865_a[cs2index[*dataIn]]->readFault();
			sendResponseMsg(cmdID, &val, 1);
		 break;}
		 
		 case CLEAR_FAULT:
			amax31865_a[cs2index[*dataIn]]->clearFault();
			sendResponseMsg(cmdID, 0, 0);
		 break;
		 
		 case READ_RTD:{
			//send 2 bytes MSByte
			uint16_t rtd = amax31865_a[cs2index[*dataIn]]->readRTD();
			rtd = 1057;
			byte* value = (byte*) calloc(2, 1);
			*(value+1) = (byte) rtd & 0xFF;
			*value = (byte)((rtd >> 8) & 0xff);
			sendResponseMsg(cmdID, value, 2);
		 break;}
		 
		 case SET_WIRES:
			amax31865_a[cs2index[*dataIn]]->setWires((max31865_numwires_t) *dataIn);
			sendResponseMsg(cmdID, 0, 0);
		 break;
		 
		 case AUTO_CONVERT:
			if(*(dataIn+1) != 0 && *(dataIn+1) != 1 ){
				//error
				return;
			}
			amax31865_a[cs2index[*dataIn]]->autoConvert(*dataIn);
			sendResponseMsg(cmdID, 0, 0);
		 break;
		 
		 case ENABLE_BIAS:
			if(*(dataIn+1) !=0 && *(dataIn+1) != 1){
				//error
				return;
			}
			amax31865_a[cs2index[*dataIn]]->enableBias(*dataIn);
			sendResponseMsg(cmdID, 0, 0);
		 break;
		 
		 case READ_TEMPERATURE:{
			//needs 8 bytes - 4 for each value
			float RTDnominal, refResistor;
			memcpy(&RTDnominal, (float*) (dataIn+1), 4);
			memcpy(&refResistor, (float*)(dataIn+5), 4);
			float temp = amax31865_a[cs2index[*dataIn]]->temperature(RTDnominal, refResistor);
			sendResponseMsg(cmdID, (byte*)&temp, 4);
			debugPrint(DEBUG_CS, amax31865_a[cs2index[*dataIn]]->_cs);
		 break;}

		 case DELETE:
			delete amax31865_a[cs2index[*dataIn]];
			sendResponseMsg(cmdID, 0, 0);
		 break;
         default:{
            // Do nothing
         }
      }
   }
   
   void setup() {
	   
   }

	
	
	
};

