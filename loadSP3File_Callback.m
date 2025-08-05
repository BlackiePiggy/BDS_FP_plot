% loadSP3File_Callback.m
function loadSP3File_Callback(hObject, ~)
    handles = guidata(hObject);
    fig = handles.fig;
    appdata = get(fig, 'UserData');
    
    [filename, pathname] = uigetfile({'*.sp3;*.SP3', 'SP3 Files (*.sp3)'}, 'Select SP3 file');
    if filename == 0, return; end
    
    fullpath = fullfile(pathname, filename);
    try
        % NOTE: This assumes a function `parse_sp3_file` exists on the MATLAB path.
        [~, sat_data] = parse_sp3_file(fullpath);
        appdata.sp3Data = sat_data;
        handles.sp3FileText.String = ['Loaded: ' filename];
        
        sat_names = fieldnames(appdata.sp3Data);
        set(handles.satelliteListBox, 'String', sat_names, 'Enable', 'on');
        set(handles.satelliteListBox, 'Value', 1:min(5, numel(sat_names))); 
        
        set(fig, 'UserData', appdata); % Save changes back to the figure
    catch ME
        errordlg(['Error loading SP3 file: ' ME.message], 'File Error');
    end
end