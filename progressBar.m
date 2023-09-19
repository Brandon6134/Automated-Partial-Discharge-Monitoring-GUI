function [fillBar,percent] = progressBar(object,progressPercent,percentText)
% PROGRESSBAR creates or updates a progress bar within an existing
% figure, and text showing the percent completion of the bar. The function
% can be called repeatededly to update the progress percent of the progress bar.
% 
% Usage: [fillBar,percent] = progressBar(object,progressPercent);
% or
% [fillBar,percent] = progressBar(object,progressPercent,percentText);
% 
% PARAMETERS
% ===========
%     object: is either the desired parent of the progress bar to be placed
%     in the existing figure or the patch of the progress bar itself. If
%     object is parent, creates a new progress bar as a child of the given
%     parent. If patch of progress bar, updates existing progress bar with
%     entered progress percent in parameters
%         
%     progressPercent: a number value of the desired percentage to be
%     updated or the bar to begin filled as for the progress bar. Optional
%     parameter when creating a new progress bar, as default value is 0 if
%     not given a value.
%     
%     percentText: a reference to the text used to display the percentage
%     of the bar. When creating a new progress bar, this parameter cannot be
%     given a value. When updating a progress bar, giving this parameter a 
%     value is neccessary to update the percentage complete text.
% 
% RETURN VALUES
% ==============
%     fillBar: the patch that controls how filled the progress bar is. save
%     this value to a variable and pass it in the parameters of this
%     function as the value 'object' when calling to update the progress bar.
%     
%     percent: a reference to the text used to display the percentage of
%     the bar. Save this value to a variable and pass in the parameters of
%     this function as the value 'percentText' when calling to  update 
%     percentage text.
%         
%  - Made by B.Kong, 17-April-2023

%Save Colour Codes
backgroundColor = [.7 .7 .7];  % Grey
foregroundColor = [0 .5 0]; % Dark Green

%If no percent is entered, default progress is 0 percent.
if nargin < 2
    progressPercent=0;
end

%If object is not progress bar patch
if ~isequal(class(object),'matlab.graphics.primitive.Patch')
% 1 - START - Progress Bar VBox ------------------------------- 1 %%%%
barVBox=uix.VBox('Parent',object,'Spacing',0,'Padding',5);
emptyBar=axes('Parent',barVBox,...
    'XLim',[0 1],'YLim',[0 1],...
    'XTick',[],'YTick',[],...
    'Color', backgroundColor,...
    'XColor', backgroundColor,'YColor', backgroundColor);
fillBar=patch([0 progressPercent/100 progressPercent/100 0], [1 1 0 0], foregroundColor,...
    'Parent', emptyBar,...
    'EdgeColor', 'none');

% 2 - START - Progress Percentage Display HBox --------------------- 2 %%%%
barHBox = uix.HBox('parent',barVBox,'Spacing',3,'Padding',2);

uicontrol(barHBox,'Style','text',...
    'String','Progress:',...
    'HorizontalAlignment','left');

percent = uicontrol(barHBox,'Style','text',...
    'String',append(num2str(progressPercent),'%'),...
    'HorizontalAlignment','left',...
    'FontWeight','bold',...
    'FontSize',10);

barHBox.Widths=[50 50];
% 2 - END ---------------------------------------------------- END - 2 %%%%

barVBox.Heights=[-1 -1];
% 1 - END ---------------------------------------------------- END - 1 %%%%
end

%If object is a progress bar's patch
if isequal(class(object),'matlab.graphics.primitive.Patch')
    set(object,'XData',[0 progressPercent/100 progressPercent/100 0]);
    fillBar=object;
    set(percentText,'String',append(num2str(progressPercent),'%'))
end

end