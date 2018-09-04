classdef MAX31865 < arduinoio.LibraryBase

    %Serial wire types. Used to set wire mode.
    properties(Access = public, Constant = false)
       cs_pin; 
    end
    properties(Access = public, Constant = true)
        t_2WIRE = 0
        t_3WIRE = 1
        t_4WIRE = 0
    end
    properties(Access = private, Constant = true)
        %List of Commands
        CREATE_MAX31865 = hex2dec('00')
        DELETE = hex2dec('01')
        BEGIN = hex2dec('02')
        READ_FAULT = hex2dec('03')
        CLEAR_FAULT = hex2dec('04')
        READ_RTD = hex2dec('05')
        SET_WIRES = hex2dec('06')
        AUTO_CONVERT = hex2dec('07')
        ENABLE_BIAS = hex2dec('08')
        READ_TEMPERATURE = hex2dec('09')
    end
    
    properties(Access = protected, Constant = true)
        LibraryName = 'custom/MAX31865'
        DependentLibraries = {}
        ArduinoLibraryHeaderFiles = {}
        CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'MAX31865.h')
        CppClassName = 'MAX31865'
    end
    
    methods
        function this = MAX31865(parentObj)
            this.Parent = parentObj;
            this.Pins = [];
            %count = getResourceCount(this.Parent,this.ResourceOwner);
            %incrementResourceCount(obj.Parent,obj.ResourceOwner);    
        end
        %initialize device.
        %specify mosi, miso, clk for software spi (bitbanging)
        %otherwise use hardware spi. Pinout: mosi-11 miso-12 clk-13
        function Adafruit_MAX31865(this, spi_cs, spi_mosi, spi_miso, spi_clk)
            cmdID = this.CREATE_MAX31865;
            inputs = [];
            if nargin == 5
                inputs = [spi_cs, spi_mosi, spi_miso, spi_clk];
            elseif nargin == 2  
                inputs = spi_cs;
            else
                disp('Invalid Arguments.');
                disp('Use:');
                disp('Software SPI: obj.Adafruit_MAX31865(spi_cs, spi_mosi, spi_miso, spi_clk)');
                disp('Hardware SPI: obj.Adafruit(MAX31865(spi_cs)');
                return
            end
            this.cs_pin = spi_cs;
            this.Pins = cat(1,this.Pins, inputs);
            sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function success = begin(this, wires)
            cmdID = this.BEGIN;
            if nargin < 2
                inputs = this.cs_pin;
                success = sendCommand(this, this.LibraryName, cmdID, inputs);
            elseif (wires ~= 0 && wires ~= 1)
               disp('Invalid Input. Valid Inputs:');
               disp('    (obj name).t_2WIRE');
               disp('    (obj name).t_3WIRE');
               disp('    (obj name).t_4WIRE');
               return
            else
                inputs = [this.cs_pin, wires];
                success = sendCommand(this, this.LibraryName, cmdID, inputs);
            end 
        end
        function fault = readFault(this)
            cmdID = this.READ_FAULT;
            inputs = this.cs_pin;
            fault = sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function clearFault(this)
            cmdID = this.CLEAR_FAULT;
            inputs = this.cs_pin;
            sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function rtd = readRTD(this)
            cmdID = this.READ_RTD;
            inputs = this.cs_pin;
            buffer = sendCommand(this, this.LibraryName, cmdID, inputs);
            rtd = (buffer(1))*(256) + buffer(2);
        end
        function setWires(this, wires)
            %must be enumerated type
            cmdID = this.SET_WIRES;
            inputs = [this.cs_pin, wires];
            sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function autoConvert(this, b)
            cmdID = this.AUTO_CONVERT;
            inputs = [this.cs_pin, b];
            sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function enableBias(this, b)
            cmdID = this.ENABLE_BIAS;
            inputs = [this.cs_pin, b];
            sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function temp = temperature(this, RTDnominal, refResistor)
           cmdID = this.READ_TEMPERATURE;
           %send rtdnominal then ref resistor, msbyte
           RTDnominal = typecast(single(RTDnominal), 'uint8_t');
           refResistor = typecast(single(refResistor), 'uint8_t');
           inputs = [this.cs_pin, cat(2, RTDnominal, refResistor)];
           temp = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
        end
    end
    
    methods(Access = protected)
        function delete(obj)
            try
                parentObj = obj.Parent;

                % Clear the pins that have been configured to the LCD shield
                for iLoop = obj.Pins
                    configurePinResource(parentObj,iLoop{:},obj.ResourceOwner,'Unset');
                end

                % Decrement the resource count for the LCD
                %decrementResourceCount(parentObj, obj.ResourceOwner);
                cmdID = obj.DELETE;
                inputs = this.cs_pin;
                sendCommand(obj, obj.LibraryName, cmdID, inputs);
            catch
                % Do not throw errors on destroy.
                % This may result from an incomplete construction.
            end
        end  
    end





end
