function [number] = GetScreenNumber(windowPtr,msg,x,y,textColor,bgColor)
% [number] = GetScreenNumber(windowPtr,msg,x,y,textColor,bgColor)
%% Input Control

if ~exist('x', 'var'); x = []; end
if isempty(x); x = 0; end
if ~exist('y', 'var'); y = []; end
if isempty(y); y = 0; end
if ~exist('textColor', 'var'); textColor = []; end
if isempty(textColor); textColor = BlackIndex(windowPtr); end
if ~exist('bgColor', 'var'); bgColor = []; end
if isempty(bgColor); bgColor = GrayIndex(windowPtr); end

%% Draw Text onto Psychtoolbox Screen

% Enable user defined alpha blending if a text background color is
% specified. This makes text background colors actually work, e.g., on OSX:
if ~isempty(bgColor)
    if Screen('Preference', 'TextRenderer') >= 1
        oldalpha = Screen('Preference', 'TextAlphaBlending', 0);
    else
        oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux);
    end
end

% Clear keyboard event queues
FlushEvents();

string = ''; % initialize string
output = [msg, ' ', string];

% Write the initial message:
Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
Screen('Flip', windowPtr, 0, 1);

while true
    char = GetKbChar(-3); % get key press on all devices (i.e., -3)

    switch abs(char)
        case {13, 3, 10, 27}
            % ctrl-C, enter, return, or escape
            break;
        case 8 % backspace
            if ~isempty(string)
                % Redraw text string, but with textColor == bgColor, so
                % that the old string gets completely erased:
                oldTextColor = Screen('TextColor', windowPtr);
                Screen('DrawText', windowPtr, output, x, y, bgColor, bgColor);
                Screen('TextColor', windowPtr, oldTextColor);
                
                % Remove last character from string:
                string = string(1:length(string)-1);
            end
        otherwise % add character to string
            string = [string, char]; 
    end
    
    output = [msg, ' ', string];
    Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
    Screen('Flip', windowPtr, 0, 1);
end

% Restore text alpha blending state if it was altered:
if ~isempty(bgColor)
    Screen('Preference', 'TextAlphaBlending', oldalpha);
end

number = str2double(string);