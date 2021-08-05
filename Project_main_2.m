clear all
clc

a = arduino('COM4','uno','Libraries',{'Ultrasonic','ExampleLCD/LCDAddOn'},'ForceBuildOn',true);
lcd = addon(a,"ExampleLCD/LCDAddon",'RegisterSelectPin','D7','EnablePin','D6','DataPins',{'D5','D4','D3','D2'});    % LCD Object
initializeLCD(lcd); % Initializing LCD
ultrasonicObj = ultrasonic(a,'A4','A5');    % Ultra sonic Sensor Object
s = 0;    % Speed counter
 printLCD(lcd, char("Speed: " + s + " km/h")); % Printing on LCD

%% Button Definitions and Pins attached
% increase_speed :- D9
% decrease_speed - D8
% cruise_control - D12
% Adaptive_cruise_control - D10
% cancel - D11

%% Variable Creation
y = 0;          % checking which is button pressed
CC = 0;  % Cruise Control ON/OFF
ACC = 0;     % Adaptive Cruise Control ON/OFF
CCS = 0;        % Cruise Control Speed
ACCS = 0;       % Adaptive Cruise Control Speed

%% Logic Implementation
while true  % Continuous Loop until program is cancelled
while true  % Continuous Loop until button is presses and input variable is set
    IB = readDigitalPin(a, 'D9');     % Reading increase Button pin - DIGITAL PIN
    DB = readDigitalPin(a, 'D8');         % Reading decrese Button pin - ANALOG PIN
    CCB = readDigitalPin(a, 'D12');    % Reading Cruise Control Button pin - ANALOG PIN
    ACCB = readDigitalPin(a, 'D10');    % Reading Adaptive Cruise Control Button pin - DIGITAL PIN
    CLB = readDigitalPin(a, 'D11');       % Reading Cancel Button pin - DIGITAL PIN
    
    if(IB == 1)            % Increse Button pressed
        y = 1;
        break;
    elseif(DB == 1)         % Decrese Button Pressed
        y = 2;
        break;
    elseif(CCB == 1)    % Cruise Control Button Pressed
        CC = 1;          % Setting cruiseControl
        CCS = s;          % Setting cruiseControl Speed to current Speed
        break;                      
    elseif(ACCB == 1)      % Adaptive Cruise Control Button Pressed
        ACC = 1;             % Setting Adaptive Cruise Control
        ACCS = s;         % Setting Adaptive Cruise Control to Current Speed(Counter)
        break;
    elseif(CLB == 1)          % Cancel Button Pressed
        CC = 0;          % Cancel Cruise Control Mode
        ACC = 0;             % Cancel Adaptive Cruise Control Mode
        ACCS = 0;               % Set Adaptive Cruise Control Speed to 0
        CCS = 0;                % Set Cruise Control Speed to 0
        break;
    else
        y = 0;                  % If none of the button will be pressed
        break;
    end
end


switch y    % Swtch-Case
    
    case 1                      % if Input will be 1 (Increase Speed)
        s = s + 2;  % Increse counter by 2
    case 2                          % if Input will be 2 (Decrease Speed)
        if (s > 0)            % checking is speed is greater than 0
            s = s - 2;  % Decrease counter by 2
        end
    otherwise                                                       % If Input will be 0
        if(s > 0 && CC == 0 && ACC == 0)    % If cruise Control and adaptive cruise control mode are not set
            s = s - 1;                                  % Decrease counter by 1
        elseif(ACC == 1)                                     % If Adaptive Cruise Control mode is ON
            distance = readDistance(ultrasonicObj);                     % Read Sensor Value
             if(distance < 0.1 && s > 0)                    % Object is detected in ultrasonic sensor
                s = s - 3;                              % Decrease counter by 1
            elseif(distance < 0.2 && distance > 0.1 && s > 0)                    % Object is detected in ultrasonic sensor
                s = s - 2;                              % Decrease counter by 1
            elseif(distance < 0.3 && distance > 0.2 && s > 0)                    % Object is detected in ultrasonic sensor
                s = s - 1;                              % Decrease counter by 1
            elseif(s < ACCS)                              % If object is removed in front of ultrasonic sensor
                s = s + 1;                              % increse counter by 1
            end
            printLCD(lcd, char("Adaptive CC"));                                % Print on LCD
            pause(0.3); 
            thingSpeakWrite(1459076,[s,distance],'WriteKey','7VDAZ9RZE1WL0W0B');
        end
end
printLCD(lcd, char("Speed: " + s + " km/h"));                 % Print on LCD
pause(15);                                                         % Pause for 0.5 seconds
end