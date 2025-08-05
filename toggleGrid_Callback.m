% toggleGrid_Callback.m
function toggleGrid_Callback(hObject, ~)
    handles = guidata(hObject);
    grid(handles.mapAxes); % Toggles grid state
end