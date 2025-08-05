% loadStationFile_Callback.m
function loadStationFile_Callback(hObject, ~)
    handles = guidata(hObject);
    fig = handles.fig;
    appdata = get(fig, 'UserData');

    [filename, pathname] = uigetfile('*.json', 'Select station JSON file');
    if filename == 0, return; end

    fullpath = fullfile(pathname, filename);
    try
        json_text = fileread(fullpath);
        station_data = jsondecode(json_text);
        appdata.stationData = station_data;
        handles.stationFileText.String = ['Loaded: ' filename];
        
        station_names = {station_data.name};
        set(handles.stationListBox, 'String', station_names, 'Enable', 'on', 'Value', []);
        
        set(fig, 'UserData', appdata);
    catch ME
        errordlg(['Error loading station file: ' ME.message], 'File Error');
    end
end