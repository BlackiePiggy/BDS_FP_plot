% toggleLegend_Callback.m
function toggleLegend_Callback(hObject, ~)
    handles = guidata(hObject);
    lg = findobj(handles.fig, 'Type', 'legend');
    if ~isempty(lg)
        if strcmp(get(lg, 'Visible'), 'on')
            set(lg, 'Visible', 'off');
        else
            set(lg, 'Visible', 'on');
        end
    end
end