% toggleTimeTableControls_Callback.m
function toggleTimeTableControls_Callback(hObject, ~)
    handles = guidata(hObject);
    if get(hObject, 'Value') == 1 % Checked
        set(handles.loadTimeTableBtn, 'Enable', 'on');
    else % Unchecked
        set(handles.loadTimeTableBtn, 'Enable', 'off');
    end
end