% seconds2timestr.m
function timestr = seconds2timestr(seconds)
    hours = floor(seconds/3600);
    minutes = floor(mod(seconds,3600)/60);
    secs = floor(mod(seconds,60));
    timestr = sprintf('%02d:%02d:%02d', hours, minutes, secs);
end