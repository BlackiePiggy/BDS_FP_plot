% exportSettings_Callback.m
function exportSettings_Callback(hObject, ~)
    handles = guidata(hObject);
    fig = handles.fig;

    d = dialog('Position', [300 300 250 150], 'Name', '导出设置');
    uicontrol('Parent', d, 'Style', 'text', 'Position', [20 100 210 20], 'String', '选择导出分辨率 (DPI):');
    resPopup = uicontrol('Parent', d, 'Style', 'popupmenu', 'Position', [20 70 210 25], 'String', {'150', '300', '600'}, 'Value', 2);
    uicontrol('Parent', d, 'Position', [85 20 70 25], 'String', '确定', 'Callback', @export_callback);

    % Nested function to handle the dialog's OK button
    function export_callback(~, ~)
        val = get(resPopup, 'Value');
        str = get(resPopup, 'String');
        setappdata(fig, 'ExportResolution', str2double(str{val}));
        delete(d);
    end
end