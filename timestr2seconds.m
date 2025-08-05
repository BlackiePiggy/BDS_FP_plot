% timestr2seconds.m
function seconds_of_day = timestr2seconds(timestr)
    try
        if iscell(timestr), timestr = timestr{1}; end
        timestr = strtrim(char(timestr));
        parts = sscanf(timestr, '%d:%d:%d');
        seconds_of_day = parts(1)*3600 + parts(2)*60 + parts(3);
    catch
        seconds_of_day = -999; % Return an invalid value on error
    end
end