% loadTimeTable_Callback.m
function loadTimeTable_Callback(hObject, ~)
    handles = guidata(hObject);
    fig = handles.fig;
    appdata = get(fig, 'UserData');

    [filename, pathname] = uigetfile('*.csv', 'Select time table CSV file');
    if filename == 0, return; end
    
    fullpath = fullfile(pathname, filename);
    try
        data = readtable(fullpath, 'Format', '%s%s%s');
        raw_data = table2cell(data);
        for i = 1:size(raw_data, 1)
            for j = 2:3
                time_str = strtrim(char(raw_data{i,j}));
                parts = sscanf(time_str, '%d:%d:%d');
                if numel(parts) == 3
                    raw_data{i,j} = sprintf('%02d:%02d:%02d', parts(1), parts(2), parts(3));
                else
                    error('Invalid time format at row %d col %d: %s', i, j, time_str);
                end
            end
        end
        appdata.timeTableData = raw_data;
        handles.timeTableText.String = ['Loaded: ' filename];
        set(fig, 'UserData', appdata);
    catch ME
        errordlg(['Error loading time table file: ' ME.message], 'File Error');
    end
end