function pdMonitoringAssistantGUI(h,database)
handles = struct;

handles.tempValue = 1;

handles.f = figure('Position',positionFigOnScreen(350,750),'MenuBar','none','Toolbar','none',...
    'Name','PD Monitoring Assistant','NumberTitle','off');

% 1 - START - Main Vertical Box --------------------------------------- 1 %
mainVBox = uix.VBox('parent',handles.f);

% Create the title
createKinectricsHeader(mainVBox,'PD Monitoring Assistant');

% 2 - START - Connection Information Panel/VBox -------------------- 2 %%%%
connectInfoPanel = uix.BoxPanel('Parent',mainVBox,...
    'Title','1 - Connection Information',...
    'TitleColor',TAASKData.kinBlue,...
    'TitleTextColor',[1 1 1],...
    'MinimizeFcn',@(src,evt)minimizeObject(src,mainVBox));
connectVBox = uix.VBox('Parent',connectInfoPanel,'Spacing',2,'Padding',7);

% 3 - Software Status HBox -------------------------------------- 3 %%%%%
instStatHBox = uix.HBox('Parent',connectVBox,'Spacing',1);

% Status Text
uicontrol(instStatHBox,'Style','text',...
    'String','Software Status:',...
    'HorizontalAlignment','center');

% Connection String
handles.connectionText = uicontrol(instStatHBox,'Style','text',...
    'String','DISCONNECTED',...
    'FontWeight','bold',...
    'FontSize',12,...
    'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','left');

set(instStatHBox,'Widths',[110 -1]);
% 3 - END --------------------------------------------------- END - 3 %%%%%

% 3 - START - Connection Button HBox ------------------------------ 3 %%%%%
connectButtonHBox = uix.HBox('Parent',connectVBox,'Spacing',6);

% Connect Button
handles.connectInstrument = uicontrol(connectButtonHBox,...
    'String','Connect',...
    'FontSize',10,...
    'Callback',@(src,evt)connectInstrument(guidata(src)));

% Disconnect Button
handles.disconnectInstrument = uicontrol(connectButtonHBox,...
    'String','Disconnect',...
    'FontSize',10,...
    'Enable','off',...
    'Callback',@(src,evt)disconnectInstrument(guidata(src)));

set(connectButtonHBox,'Widths',[-1 -1]);
% 3 - END --------------------------------------------------- END - 3 %%%%%

% 2 - END --------------------------------------------------- END - 2 %%%%%

% 2 - START - Frequency Configuration Panel/HBox--------------------- 2 %%%
handles.frequencyPanel = uix.BoxPanel('Parent',mainVBox,...
    'Title','2 - Frequency Configuration',...
    'TitleColor',TAASKData.kinYellow,...
    'TitleTextColor',[1 1 1],...
    'MinimizeFcn',@(src,evt)minimizeObject(src,mainVBox));
frequencyHBox = uix.HBox('parent',handles.frequencyPanel,'Spacing',3,'Padding',3);

% 3 - START - Frequency List VBox ---------------------------------- 3 %%%%
freqListVBox = uix.VBox('Parent',frequencyHBox);

% Frequency List Name
handles.frequencyListText = uicontrol(freqListVBox,'Style','text',...
    'String','List of Frequencies:',...
    'ForegroundColor',[0 0 0],...
    'HorizontalAlignment','Left');

% Frequency Box
uicontrol(freqListVBox,'Style','listbox',...
    'tag','freqList',...
    'UserData',TAASKData.stringFromList,...
    'String',{});

freqListVBox.Heights = [14 -1];
% 3 - END ---------------------------------------------------- END - 3 %%%%

% 3 - START - Frequency Frequency Button VBox ---------------------- 3 %%%%
freqVBox = uix.VBox('Parent',frequencyHBox,'Spacing',4);

handles.addFreqList = {'IEC','1MHz +/- 500KHz','2MHz +/- 500KHz',...
    '3MHz +/- 500KHz','4MHz +/- 500KHz','5MHz +/- 500KHz','6MHz +/- 500KHz',...
    '7MHz +/- 500KHz','8MHz +/- 500KHz','9MHz +/- 500KHz','10MHz +/- 500KHz',...
    '11MHz +/- 500KHz','12MHz +/- 500KHz'};
handles.addFreqList=handles.addFreqList';
% handles.addFreqList = {'IEC';'1MHz +/- 500KHz';'2MHz +/- 500KHz';...
%     '3MHz +/- 500KHz';'4MHz +/- 500KHz';'5MHz +/- 500KHz';'6MHz +/- 500KHz';...
%     '7MHz +/- 500KHz';'8MHz +/- 500KHz';'9MHz +/- 500KHz';'10MHz +/- 500KHz';...
%     '11MHz +/- 500KHz''12MHz +/- 500KHz'};

% addFreqListCodes correspond to the addFreqList values
handles.addFreqListCodes = {[0.25,150],[1,500],[2,500],[3,500],[4,500],...
    [5,500],[6,500],[7,500],[8,500],[9,500],[10,500],[11,500],[12,500]};
handles.addFreqListCodes = handles.addFreqListCodes';

% freqListCodes is the list of currently added frequency codes
handles.freqListCodes={};

% Add a Freq
uicontrol(freqVBox,...
    'String','Add Standard Frequency',...
    'Callback',@(src,evt)addAFreq(guidata(src)));

% Remove a Freq
handles.removeFreqButton = uicontrol(freqVBox,...
    'String','Remove Frequency',...
    'Enable','off',...
    'Callback',@(src,evt)removeFreq(guidata(src)));

% Default Freq
uicontrol(freqVBox,...
    'String','Default Frequencies',...
    'Callback',@(src,evt)defaultFreq(guidata(src)));

% Add Custom Frequency
uicontrol(freqVBox,...
    'String','Add Custom Frequency',...
    'Callback',@(src,evt)addCustomFreq(guidata(src),'Custom Frequency','Frequency:','Bandwidth: +/-'));

freqVBox.Heights = [23 23 23 23];
% 3 - END ---------------------------------------------------- END - 3 %%%%

% Tab Group Creation
mainOptionPanel = uitabgroup(mainVBox);

% 2 - Frequency Sweep Tab VBox --------------------------------------- 2 %%
dataVBox = uix.VBox('Parent',uitab(mainOptionPanel,'Title','Frequency Sweep'));

% 3 - START - Sweep Configuration/VBox ----------------------------- 3 %%%%
handles.sweepPanel = uix.BoxPanel('parent',dataVBox,...
    'Title','3 - Sweep Configuration',...
    'TitleColor',TAASKData.kinBlue,...
    'TitleTextColor',[1 1 1],...
    'MinimizeFcn',@(src,evt)minimizeObject(src,handles.f,dataVBox,mainVBox,true));
sweepVBox = uix.VBox('parent',handles.sweepPanel,'Spacing',3,'Padding',2);

% Time Spent Per Frequency
handles.timePerFreq = generateEditField(sweepVBox,{'Time Spent Per Frequency:','s'},'timePerFreq',...
    'UnitFlag',true,...
    'UnitSize',30,...
    'Size',140,...    
    'TAASKData',TAASKData.simpleNum);

sweepVBox.Heights = [25];
% 3 - END ---------------------------------------------------- END - 3 %%%%

% 3 - START - Sweep Manager/VBox ----------------------------------- 3 %%%%
sweepPanel2 = uix.BoxPanel('parent',dataVBox,...
    'Title','4 - Sweep Manager',...
    'TitleColor',TAASKData.kinYellow,...
    'TitleTextColor',[1 1 1],...
    'MinimizeFcn',@(src,evt)minimizeObject(src,handles.f,dataVBox,mainVBox,true));
sweepVBox2 = uix.VBox('parent',sweepPanel2,'Spacing',3,'Padding',2);

% Empty Space
uix.Empty('parent',sweepVBox2);

% 4 - START - Sweep Button HBox ------------------------------------ 4 %%%%
dataButtonHBox = uix.HBox('Parent',sweepVBox2,'Spacing',7);

handles.freqPauseButton = uicontrol(dataButtonHBox,...
    'String','Resume',...
    'FontWeight','bold',...
    'FontSize',11,...
    'Enable','off',...
    'Callback',@(src,evt)stopSweep(guidata(src)));

handles.freqPauseButton = uicontrol(dataButtonHBox,...
    'String','Pause',...
    'FontWeight','bold',...
    'FontSize',11,...
    'Enable','off',...
    'Callback',@(src,evt)stopSweep(guidata(src)));

handles.freqStartButton = uicontrol(dataButtonHBox,...
    'String','Start',...
    'FontWeight','bold',...
    'FontSize',11,...
    'Enable','on',...
    'Callback',@(src,evt)startSweep(guidata(src)));

handles.freqStopButton = uicontrol(dataButtonHBox,...
    'String','Stop',...
    'FontWeight','bold',...
    'FontSize',11,...
    'Enable','off',...
    'Callback',@(src,evt)stopSweep(guidata(src)));
% 4 - END ---------------------------------------------------- END - 4 %%%%

% 4 - START - Timer HBox ------------------------------------------- 4 %%%%
timerHBox=uix.HBox('parent',sweepVBox2);

% Timer (temporarily static)
uicontrol(timerHBox,'Style','text',...
    'String','Time Remaining:',...
    'HorizontalAlignment','right');

handles.timer = uicontrol(timerHBox,'Style','text',...
    'String','00:00',...
    'HorizontalAlignment','left',...
    'FontWeight','bold',...
    'FontSize',14);

timerHBox.Widths=[90 -1];
% 4 - END ---------------------------------------------------- END - 4 %%%%

sweepVBox2.Heights = [10 30 30];
% 3 - END ---------------------------------------------------- END - 3 %%%%

dataVBox.Heights=[-1 -1];
% 2 - END ---------------------------------------------------- END - 2 %%%%

% 2 - Sensitivty Assessment Tab VBox --------------------------------- 2 %%
dataVBox2 = uix.VBox('Parent',uitab(mainOptionPanel,'Title','Sensitivity Assessment'));

% 3 - START - Assessment Configuration/VBox ------------------------ 3 %%%%
handles.sensPanel = uix.BoxPanel('parent',dataVBox2,...
    'Title','3 - Assessment Configuration',...
    'TitleColor',TAASKData.kinBlue,...
    'TitleTextColor',[1 1 1],...
    'MinimizeFcn',@(src,evt)minimizeObject(src,handles.f,dataVBox2,mainVBox,true));
sweepVBox4 = uix.VBox('parent',handles.sensPanel,'Spacing',3,'Padding',2);

generateEditField(sweepVBox4,'Cable Name (Circuit):','cableName',...    
    'Size',130);
generateEditField(sweepVBox4,'Phase:','phaseName',...    
    'Size',130);

% Injected Calibration Pulse
generateEditField(sweepVBox4,{'Injected Calibration Pulse:','nC'},'injectedPulse',...
    'UnitFlag',true,...
    'UnitSize',30,...
    'Size',130,...    
    'TAASKData',TAASKData.simpleNum);

% Empty Space
uix.Empty('parent',sweepVBox4);

% 4 - START - Channel Configuration HBox --------------------------- 4 %%%%
channelHBox = uix.HBox('parent',sweepVBox4,'Spacing',3,'Padding',2);

% 5 - START - # of Channels Selected Text VBox --------------------- 5 %%%%
channelVBox = uix.VBox('parent',channelHBox,'Spacing',1,'Padding',0);

% Channel Configuration Text
uicontrol(channelVBox,'Style','text',...
    'String','Channel Configuration:',...
    'HorizontalAlignment','right');

% # of channels selected text
handles.stationStatusText = uicontrol(channelVBox,'Style','text',...
    'String','No Channels Selected',...
    'HorizontalAlignment','right',...
    'ForegroundColor',[1 0 0],...
    'FontSize',7);

% 5 - END ---------------------------------------------------- END - 5 %%%%

uicontrol(channelHBox,...
    'String','All Channels',...
    'Callback',@(src,evt)allChannels(guidata(src)));

handles.stationList = {'HVCC','HFCT','HVCC 2','HFCT 2'};
uicontrol(channelHBox,...
    'String','More Options...',...
    'Callback',@(src,evt)moreOptions(guidata(src)));

%holds which stations are selected
handles.stationsSelected=['']

channelHBox.Widths=[130 -1 -1];
% 4 - END ---------------------------------------------------- END - 4 %%%%

% Empty Space
uix.Empty('parent',sweepVBox4);

% 4 - START - Output Path HBox ------------------------------------- 4 %%%%
outputHBox = uix.HBox('parent',sweepVBox4,'Spacing',3,'Padding',2);

% Output Path Text
uicontrol(outputHBox,'Style','text',...
    'String','Output Path:',...
    'HorizontalAlignment','left');

% folder area
handles.outputPath = uicontrol(outputHBox,'style','edit',...
    'String','',...
    'tag','outputPath',...
    'UserData',TAASKData.simpleString);

% Browse Button
uicontrol(outputHBox,...
    'String','Browse...',...
    'FontAngle','italic',...
    'Callback',@(src,evt)browseCallback(guidata(src)));

set(outputHBox,'Widths',[65 -1 70]);
% 4 - END ---------------------------------------------------- END - 4 %%%%

sweepVBox4.Heights = [25 25 25 7 30 7 25];
% 3 - END ---------------------------------------------------- END - 3 %%%%

% 3 - START - Divider Factor Calculation/VBox ------------------------ 3 %%
sweepPanel3 = uix.BoxPanel('parent',dataVBox2,...
    'Title','4 - Divider Factor Calculation',...
    'TitleColor',TAASKData.kinYellow,...
    'TitleTextColor',[1 1 1],...
    'MinimizeFcn',@(src,evt)minimizeObject(src,handles.f,dataVBox2,mainVBox,true));
sweepVBox3 = uix.VBox('parent',sweepPanel3,'Spacing',2,'Padding',2);

% 4 - START - Divider Factor Display HBox -------------------------- 4 %%%%
dividerHBox = uix.HBox('parent',sweepVBox3,'Spacing',1,'Padding',5);

uicontrol(dividerHBox,'Style','text',...
    'String','Current Divider Factor:',...
    'HorizontalAlignment','right');

handles.dividerFactorString = uicontrol(dividerHBox,'Style','text',...
    'String','0.0000',...
    'HorizontalAlignment','center', ...
    'FontSize',12,...
    'FontWeight','bold');

handles.frequencyChannel = uicontrol(dividerHBox,'Style','text',...
    'String','@ HVCC 2MHz',...
    'HorizontalAlignment','left');

dividerHBox.Widths=[-1 100 -1];
% 4 - END ---------------------------------------------------- END - 4 %%%%

% 4 - START - Divider Factor Button HBox --------------------------- 4 %%%%
dividerButtonHBox = uix.HBox('parent',sweepVBox3,'Spacing',3,'Padding',2);

handles.sensBackButton = uicontrol(dividerButtonHBox,...
    'String','Back',...
    'Enable','off',...
    'Callback',@(src,evt)removeAFreq(guidata(src)));

handles.sensNextButton = uicontrol(dividerButtonHBox,...
    'String','Next',...
    'Enable','off',...
    'Callback',@(src,evt)removeAFreq(guidata(src)));

% Empty Space
uix.Empty('parent',dividerButtonHBox);

handles.sensStartButton = uicontrol(dividerButtonHBox,...
    'String','START',...
    'Enable','on',...
    'Callback',@(src,evt)startSens(guidata(src)));

handles.sensStopButton = uicontrol(dividerButtonHBox,...
    'String','STOP',...
    'Enable','off',...
    'Callback',@(src,evt)stopSens(guidata(src)));

dividerButtonHBox.Widths=[-1 -1 10 -1 -1];
% 4 - END ---------------------------------------------------- END - 4 %%%%

% 4 - START - Assessment Status HBox ------------------------------- 4 %%%%
statusHBox=uix.HBox('parent',sweepVBox3,'Spacing',3,'Padding',2);

uicontrol(statusHBox,'Style','text',...
    'String','Status: ',...
    'HorizontalAlignment','left');

handles.sensStatus = uicontrol(statusHBox,'Style','text',...
    'String','Paused',...
    'FontWeight','bold',...
    'FontSize',10,...
    'ForegroundColor',[1 0 0],...
    'HorizontalAlignment','left');

statusHBox.Widths=[40 50];
% 4 - END ---------------------------------------------------- END - 4 %%%%

sweepVBox3.Heights=[30 30 30];
% 3 - END ---------------------------------------------------- END - 3 %%%%

dataVBox2.Heights=[-1 -1];
% 2 - END ---------------------------------------------------- END - 2 %%%%

% 2 - START - Progress Bar VBox ------------------------------------ 2 %%%%
[handles.fillBar,handles.percentText] = progressBar(mainVBox);

%progressBar(handles.fillBar,80,handles.percentText);
% 2 - END ---------------------------------------------------- END - 2 %%%%

generateCopyrightBox(mainVBox,database);

mainVBox.Heights = [30 100 135 -1 50 30];
% 1 - END ---------------------------------------------------- END - 1 %%%%

guidata(handles.f,handles)

ff=handles;

end

%%% --- Frequency Configuration Functions

%isn't saving changed value of handles.addFreqList? thus cant remove selected
%frequencies from it (cant save this change)
function addAFreq(handles)
    [index,tf]=listdlg('PromptString','Select frequency(s):','ListString',handles.addFreqList);
    if tf
        currData = saveData(handles.f);

        %Add selected frequencies to the current frequency list and remove
        %those selected frequencies from the add frequency list
        currData.freqList=[currData.freqList; handles.addFreqList(index)];
        handles.addFreqList(index)=[];

        %Do same for frequency list codes
        handles.freqListCodes=[handles.freqListCodes; handles.addFreqListCodes(index)];
        handles.addFreqListCodes(index)=[];

        %Call sortFreq to sort current freq list and add freq list
        [currData.freqList,handles.freqListCodes] = sortFreq(currData.freqList,handles.freqListCodes);
        [handles.addFreqList,handles.addFreqListCodes] = sortFreq(handles.addFreqList,handles.addFreqListCodes);

        loadData(handles.f,currData);
        set(handles.removeFreqButton,'Enable','on');
        guidata(handles.f,handles)
    end
end

function removeFreq(handles)
    currData = saveData(handles.f);
    [index,tf]=listdlg('PromptString','Remove frequency(s):','ListString',currData.freqList);
    if tf
        %Add selected frequencies back to the add frequency list and remove
        %those selected frequencies from the current frequency list
        handles.addFreqList=[handles.addFreqList;currData.freqList(index);];
        currData.freqList(index)=[];

        %Do same for frequency list codes
        handles.addFreqListCodes=[handles.addFreqListCodes;handles.freqListCodes(index);];
        handles.freqListCodes(index)=[];

        %Call sortFreq to sort current freq list and add freq list
        [currData.freqList,handles.freqListCodes] = sortFreq(currData.freqList,handles.freqListCodes);
        [handles.addFreqList,handles.addFreqListCodes] = sortFreq(handles.addFreqList,handles.addFreqListCodes);

        loadData(handles.f,currData);
        if size(currData.freqList,1)==0 || size(currData.freqList,2)==0
            set(handles.removeFreqButton,'Enable','off');
        end
        
        guidata(handles.f,handles)
    end
end

function defaultFreq(handles)
    answer=questdlg('Overwrite all existing added frequencies with default frequencies?');
    if strcmp(answer,"Yes")
        currentList = {'IEC','1MHz +/- 500KHz','2MHz +/- 500KHz','4MHz +/- 500KHz',...
            '6MHz +/- 500KHz','8MHz +/- 500KHz','12MHz +/- 500KHz'};
        currentList=currentList';
        addList = {'3MHz +/- 500KHz','5MHz +/- 500KHz','7MHz +/- 500KHz',...
            '9MHz +/- 500KHz','10MHz +/- 500KHz','11MHz +/- 500KHz'};
        addList=addList';
        currentCodes = {[0.25,150],[1,500],[2,500],[4,500],[6,500],[8,500],[12,500]};
        currentCodes = currentCodes';
        addListCodes = {[3,500],[5,500],[7,500],[9,500],[10,500],[11,500]};
        addListCodes = addListCodes';
        currData = saveData(handles.f);

        % Add default frequencies to current frequency list (same for list codes)
        currData.freqList=currentList;
        handles.freqListCodes=currentCodes;

        % Change add frequency list
        handles.addFreqList=addList;
        handles.addFreqListCodes=addListCodes;
       
        loadData(handles.f,currData);
        set(handles.removeFreqButton,'Enable','on');
        guidata(handles.f,handles)
    end
end

function addCustomFreq(handles,windowString,messageString1,messageString2)

    %freq = blankFiller_V2('Enter custom frequency','Custom Frequency');
    figureSize = positionFigOnScreen(300,85,0.5,0.75);
    f = figure('Position',figureSize,'Toolbar','none','MenuBar','none',...
    'Name',windowString,'NumberTitle','off','Visible','off',...
    'WindowStyle','modal');

    mainVBox = uix.VBox('Parent',f,'Padding',7,'Spacing',4);

    % text Box
    [~,mainEditBox] = generateEditField(mainVBox,{messageString1,'MHz'},'output',...
        'UnitFlag',true,...
        'UnitSize',30,...
        'Size',75,...
        'TAASKData',TAASKData.simpleNum);
    [~,secondEditBox] = generateEditField(mainVBox,{messageString2,'KHz'},'output',...
        'UnitFlag',true,...
        'UnitSize',30,...
        'Size',75,...
        'TAASKData',TAASKData.simpleNum);


    mainEditBox.KeyPressFcn = @getResponse;
    secondEditBox.KeyPressFcn = @getResponse;

    % START - 2 - Buttons
    buttonHBox = uix.HBox('Parent',mainVBox);
    
    uicontrol(buttonHBox,...
        'String','OK',...
        'Callback',@getResponse);
    
    uix.Empty('Parent',buttonHBox);
    
    uicontrol(buttonHBox,...
        'String','Cancel',...
        'Callback',@getResponse);
    
    set(buttonHBox,'Widths',[70 -1 70])
    %  END  - 2 - Buttons

    set(mainVBox,'Heights',[-1 -1 -1])
    %  END  - 1 - Main Box
    
    output = '';
    output2='';
    uicontrol(mainEditBox); %Focus on the box
    
    uiwait(f);
    
    % Remove the default response if it was given
%     if ~isempty(output) && strcmp(output{1},defaultString)
%         output = '';
%     end
    
    delete(f)

    %%% --- Handle Callbacks
    function getResponse(src,eventData)
        checkOutput = false;
        
        if strcmp(src.String,'OK')
            % User clicked OK            
            checkOutput = true;
            
        elseif strcmp(src.String,'Cancel')
            % User clicked Cancel
            uiresume(f); %resume without changing the output
            
        elseif strcmp(src.Style,'edit')
            % We come from a keypress           
            if strcmp(eventData.Key,'return')
                % User pressed enter, consider it a continue
                checkOutput = true;
                
            elseif strcmp(eventData.Key,'escape')
                % User pressed escape, consider it a cancel
                uiresume(f);
                
            end
            
        end
        
        if checkOutput            
            drawnow;
            
            % Check if values entered were numbers and if they are above zero
            successFlag = errorCheck(f);
            currData = saveData(handles.f);
            if ~successFlag
                uiwait(warndlg('Invalid format provided. Must enter positive numeric values above zero.','Improper Format','modal'));                
                return;
            elseif str2double(mainEditBox.String)<=0 || str2double(secondEditBox.String)<=0
                uiwait(warndlg('Must enter positive numeric values above zero.','Improper Format','modal'));                
                return;
            end

            for i=1:size(currData.freqList,1)
                %check if frequency already exists in user's frequency list
                if str2double(mainEditBox.String)==handles.freqListCodes{i}(1)
                    if str2double(secondEditBox.String)==handles.freqListCodes{i}(2)
                        uiwait(warndlg('Frequency already entered. Enter an unique frequency entry.','Frequency Duplicate','modal'));                
                        return;
                    end
                end
            end
            
            % Store the output
            output = {mainEditBox.String};
            output2={secondEditBox.String};

            %below implements that, but has some errors? idk how to solve
%             for i=1:size(handles.addFreqList,1)
%                 %check if frequency exists in standard freq list
%                 if str2double(mainEditBox.String)==handles.addFreqListCodes{i}(1)
%                     if str2double(secondEditBox.String)==handles.addFreqListCodes{i}(2)
%                         %remove freq from standard freq list
%                         handles.addFreqList(i)=[];
%                         handles.addFreqListCodes(i)=[];
%                     end
%                 end
%             end
            
            %Add frequency to current list and freq code list
            currData.freqList=[currData.freqList;append(output,'MHz +/- ',output2,'KHz')];
            handles.freqListCodes=[handles.freqListCodes;[str2double(output),str2double(output2)]];

            %Call sortFreq to sort current freq list and add freq list
            [currData.freqList,handles.freqListCodes] = sortFreq(currData.freqList,handles.freqListCodes);
            [handles.addFreqList,handles.addFreqListCodes] = sortFreq(handles.addFreqList,handles.addFreqListCodes);

            loadData(handles.f,currData);
            guidata(handles.f,handles)
            set(handles.removeFreqButton,'Enable','on');
            uiresume(f);
        end
            
    end
end

% SORTFREQ sorts a list of frequencies based off the numerical sorting of
% the frequency codes.
%
% parameters
% list: a list of frequencies (current frequency list, add frequency list,
% or remove frequency list), list must be of size [x,1]
% code: the list of internal frequency codes associated with each frequency
%
% returns
% list and codes are returned ordered in numerical order.
function [list,codes] = sortFreq(list,codes)
    numList=zeros(size(codes,1),1);
    for i=1:size(codes,1)
        numList(i)=codes{i}(1);
    end
    [numList,sortIdx]=sort(numList);
    list=list(sortIdx);
    codes=codes(sortIdx);
end

function allChannels(handles)
%     currData = saveData(handles.f);
    handles.stationsSelected=handles.stationList;
    handles.stationStatusText.String='All Channels Selected';
    handles.stationStatusText.ForegroundColor=[0 1 0];
%     loadData(handles.f,currData);
    guidata(handles.f,handles)
end

function moreOptions(handles)
    [index,tf]=listdlg('PromptString','Select channel(s):','ListString',handles.stationList);
    if tf
%         currData = saveData(handles.f);
        handles.stationsSelected=handles.stationList(index);
        handles.stationStatusText.String='Specific Channels Selected';
        handles.stationStatusText.ForegroundColor=[0 1 0];
%         loadData(handles.f,currData);
        guidata(handles.f,handles);
    end
end

function browseCallback(handles)
%%% --- Add a new output path to the field

% Get the path from the user
path = uigetdir('','Select a Location for Waveform Output');
if path == 0
    return;
end

% Set the path
handles.outputPath.String = path;
end

function startSweep(handles)
result = errorCheck(handles.sweepPanel);
if ~result
    uiwait(warndlg('A number must be entered for time spent per frequency.','modal'));        
    return;
end

currData = saveData(handles.f);

%Check if frequency list contains at least one frequency
if size(currData.freqList,1)==0 || size(currData.freqList,2)==0
    uiwait(warndlg("A mininum of one frequency needs to be selected."))
    return;  
end

% Is the time spent per frequency field empty or greater than 1?
if size(currData.timePerFreq,1)==0
    uiwait(warndlg("Time spent per frequency needs to be entered."))
    return;
elseif str2double(currData.timePerFreq) <= 1
    uiwait(warndlg("Time spent per frequency needs to be greater than 1."))
    return;
end

%set(handles.frequencyListText,"ForegroundColor",[0 0 0]);
progressBar(handles.fillBar,10,handles.percentText);

handles.freqStartButton.Enable='off';
handles.freqPauseButton.Enable='on';
handles.freqStopButton.Enable='on';

set(findall(handles.frequencyPanel,'-property','Enable'),'Enable','off');
set(findall(handles.sweepPanel,'-property','Enable'),'Enable','off');
set(findall(handles.sensPanel,'-property','Enable'),'Enable','off');
handles.sensStartButton.Enable='off';

%sets the frequency list text red if empty, black if not empty
% if size(currData.freqList,1)==0 || size(currData.freqList,2)==0
%     set(handles.frequencyListText,"ForegroundColor",[1 0 0])
% else
%     set(handles.frequencyListText,"ForegroundColor",[0 0 0])
% end

end

function stopSweep(handles)
handles.dividerFactorString.String = num2str(handles.tempValue);
end

function startSens (handles)

result = errorCheck(handles.sensPanel);
if ~result
    uiwait(warndlg('A number must be entered for injected calibration pulse.','modal'));        
    return;
end

currData = saveData(handles.f);

% Check if frequency list contains at least one frequency
if size(currData.freqList,1)==0 || size(currData.freqList,2)==0
    uiwait(warndlg("A mininum of one frequency needs to be selected."))
    return;  
end

% Check if assessment configuration tab requirements are entered
if size(currData.injectedPulse,1)==0 || size(currData.cableName,1)==0 ...
        || size(currData.phaseName,1)==0
    uiwait(warndlg("Fill in all empty fields in the assessment configuration tab."))
    return;
elseif str2double(currData.injectedPulse) <= 0.1
    uiwait(warndlg("Injected calibration pulse needs to be greater than 0.1."))
    return;
elseif size(handles.stationsSelected)==0
    uiwait(warndlg("A mininum of one station needs to be selected."))
    return;
elseif size(handles.outputPath.String)==0
    uiwait(warndlg("An output path needs to be entered."))
    return;
end

handles.sensStartButton.Enable='off';
handles.sensNextButton.Enable='on';
handles.sensStopButton.Enable='on';

% Turn off all other tabs (except connect)
set(findall(handles.frequencyPanel,'-property','Enable'),'Enable','off');
set(findall(handles.sweepPanel,'-property','Enable'),'Enable','off');
set(findall(handles.sensPanel,'-property','Enable'),'Enable','off');
handles.sweepStartButton.Enable='off';

end

function stopSens(handles)
handles.dividerFactorString.String = num2str(handles.tempValue);
end