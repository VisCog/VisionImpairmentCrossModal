% Script written by Kelly Chang 

clear all; close all;

KbName('UnifyKeyNames')

try
    white = WhiteIndex(0);
    black = BlackIndex(0);
    
    
    gray = GrayIndex(0);
    
  
    fullRect = Screen('Rect', 0);
    [window,rect] = Screen('OpenWindow', 0, gray, floor(fullRect/4));
    
    number = GetScreenNumber(window, 'Enter Number: ', ...
        rect(3)*0.1, rect(4)*0.1, black, gray);
    
    Screen('CloseAll');
catch ME
    Screen('CloseAll');
    rethrow(ME);
end
