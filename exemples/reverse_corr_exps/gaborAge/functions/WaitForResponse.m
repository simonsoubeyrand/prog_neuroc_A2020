function WaitForResponse(respKey)

% WAIT FOR THEM TO PRESS respKey
waiting = 1;
while(waiting)
    [~, secs, keyCode]= KbCheck;
    % PRESSED SPACEBAR
    if keyCode(1, respKey)
        waiting = 0;
    end
end

return