classdef Vernier < arduinoio.LibraryBase

 
    properties(Access = private, Constant = true)
        %List of Commands
        CREATE_VERNIER = hex2dec('00')
        AUTO_ID = hex2dec('01')
        GET_CHANNEL = hex2dec('02')
        GET_VOLTAGE_ID = hex2dec('03')
        GET_SENSOR_NUMBER = hex2dec('04')
        GET_SENSOR_NAME = hex2dec('05')
        GET_SHORT_NAME = hex2dec('06')
        GET_SENSOR_UNITS = hex2dec('07')
        GET_SLOPE = hex2dec('08')
        GET_INTERCEPT = hex2dec('09')
		GET_CFACTOR = hex2dec('10')
		GET_CAL_EQUATION_TYPE = hex2dec('11')
		GET_PAGE = hex2dec('12')
		READ_SENSOR = hex2dec('13')
		GET_SENSOR_READING = hex2dec('14')
		DCUPWM = hex2dec('15')
		DCU = hex2dec('16')
		DCU_STEP = hex2dec('17')
		READ_MOTION_DETECTOR = hex2dec('18')
		GET_DISTANCE = hex2dec('19')
		DELETE = hex2dec('20')
    end
    
    properties(Access = protected, Constant = true)
        LibraryName = 'custom/Vernier'
        DependentLibraries = {}
        ArduinoLibraryHeaderFiles = {}
        CppHeaderFile = fullfile(arduinoio.FilePath(mfilename('fullpath')), 'src', 'Vernier.h')
        CppClassName = 'Vernier'
    end
    
    methods
        function this = Vernier(parentObj)
            this.Parent = parentObj;
            this.Pins = [];
            %count = getResourceCount(this.Parent,this.ResourceOwner);
            %incrementResourceCount(obj.Parent,obj.ResourceOwner);    
        end
		function Vernier_init(this)
            cmdID = this.CREATE_VERNIER;
            inputs = [];
            sendCommand(this, this.LibraryName, cmdID, inputs);
        end
        function autoID(this)
            cmdID = this.AUTO_ID;
			inputs = [];
			sendCommand(this, this.LibraryName, cmdID, inputs);
            end 
        end
        function val = channel(this)
			cmdID = this.GET_CHANNEL;
			inputs = [];
			%troubleshooting tip: check to see if sendCommand returns single column rather than a 
			%single row. If not, remove the transpose operator ('). We need a single row.
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'int32');
		end
		function val = voltageID(this)
			cmdID = this.GET_VOLTAGE_ID;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = sensorNumber(this)
			cmdID = this.GET_SENSOR_NUMBER;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'int32');
		end
		function val = sensorName(this)
			cmdID = this.GET_SENSOR_NAME;
			inputs = [];
			%Troubleshooting tip: Absolutely no idea if this works - problems could arise in multiple places.
			%first, debug the .h file to see if the string is actually being handled properly. Then check to see
			%if the raw bytes being sent to matlab make sense. Lastly, check to see if matlab's typecast function 
			%is working as expected. If not, try breaking the return value of sendCommand into 4-byte chunks and typecast
			%them seperately. 
			%This applies to all string responses.
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'char');
		end
		function val = shortName(this)
			cmdID = this.GET_SHORT_NAME;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'char');
		end
		function val = sensorUnits(this)
			cmdID = this.GET_SENSOR_UNITS;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'char');
		end
		function val = slope(this)
			cmdID = this.GET_SLOPE;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = intercept(this)
			cmdID = this.GET_INTERCEPT;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = cFactor(this)
			cmdID = this.GET_CFACTOR;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = calEquationType(this)
			cmdID = this.GET_CAL_EQUATION_TYPE;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'int32');
		end
		function val = page(this)
			cmdID = this.GET_PAGE;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = readSensor(this)
			cmdID = this.READ_SENSOR;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = sensorReading(this)
			cmdID = this.GET_SENSOR_READING;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function DCUPWM(this, PWMSetting)
			cmdID = this.DCUPWM;
			%not sure if int really needs to be cast to uint8. Also make sure
			%it turns out as a single row rather than a single column.
			inputs = [typecast(int32(PWMSetting), 'uint8')];
			sendCommand(this, this.LibraryName, cmdID, inputs);
		end
		function DCU(this, DCUSetting)
			cmdID = this.DCU;
			inputs = typecast(int32(DCUSetting), 'uint8');
			sendCommand(this, this.LibraryName, cmdID, inputs);
		end
		function DCUStep(this, stepCount, stepDirection, stepDelay)
			cmdID = this.DCU_STEP;
			%if the other DCU methods had their inputs set up wrong, this 
			%will be super wrong.
			stepCount_8 = typecast(int32(stepCount), 'uint8');
			stepDirection_8 = typecast(int32(stepDirection), 'uint8');
			stepDelay_8 = typecast(int32(stepDelay), 'uint8');
			inputs = cat(2,stepCount_8,stepDirection_8,stepDelay_8);
			sendCommand(this, this.LibraryName, cmdID, inputs);
		end
		function val = readMotionDetector(this)
			cmdID = this.READ_MOTION_DETECTOR;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
		end
		function val = distance(this)
			cmdID = this.GET_DISTANCE;
			inputs = [];
			val = typecast(uint8(sendCommand(this, this.LibraryName, cmdID, inputs)'), 'single');
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
                sendCommand(obj, obj.LibraryName, cmdID, inputs);
            catch
                % Do not throw errors on destroy.
                % This may result from an incomplete construction.
            end
        end  
    end





end
