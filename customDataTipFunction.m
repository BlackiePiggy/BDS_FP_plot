% customDataTipFunction.m
function txt = customDataTipFunction(~, event_obj)
    pos = get(event_obj, 'Position');
    target = get(event_obj, 'Target');
    userdata = get(target, 'UserData');
    
    if ~isempty(userdata) && isfield(userdata, 'type')
        switch userdata.type
            case 'satellite'
                dataIndex = get(event_obj, 'DataIndex');
                times = userdata.times;
                if iscell(times) && numel(times) >= dataIndex
                    time_str = times{dataIndex};
                else
                    time_str = 'N/A';
                end
                txt = {['Satellite: ', userdata.sat], ...
                       ['UTC Time: ', time_str], ...
                       ['Lat: ', num2str(pos(1), '%.4f'), '°'], ...
                       ['Lon: ', num2str(pos(2), '%.4f'), '°']};
            case 'station'
                txt = {['Station: ', userdata.name], ...
                       ['Lat: ', num2str(pos(1), '%.4f'), '°'], ...
                       ['Lon: ', num2str(pos(2), '%.4f'), '°']};
        end
    else
        txt = {['Lat: ', num2str(pos(1), '%.4f'), '°'], ...
               ['Lon: ', num2str(pos(2), '%.4f'), '°']};
    end
end