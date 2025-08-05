function SatelliteTrackingGUI
    % Create the main figure with proper menu and toolbar
    fig = figure('Name', 'Satellite Tracking GUI', ...
        'Position', [100, 100, 1000, 750], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'figure', ...
        'Toolbar', 'figure');
        
    % --- Data storage ---
    appdata = struct();
    appdata.sp3Data = [];
    appdata.timeTableData = [];
    appdata.stationData = [];
    set(fig, 'UserData', appdata);
    set(fig,'defaultLegendAutoUpdate','off')


    % --- Menu setup ---
    fileMenu = uimenu(fig, 'Label', '文件');
    uimenu(fileMenu, 'Label', '保存图像...', 'Callback', @savePlot);
    uimenu(fileMenu, 'Label', '导出设置...', 'Callback', @exportSettings);
    uimenu(fileMenu, 'Label', '退出', 'Callback', 'close(gcf)', 'Separator', 'on');
    viewMenu = uimenu(fig, 'Label', '视图');
    uimenu(viewMenu, 'Label', '网格线', 'Callback', @toggleGrid, 'Checked', 'on');
    uimenu(viewMenu, 'Label', '图例', 'Callback', @toggleLegend, 'Checked', 'on');

    % --- Control Panel ---
    controlPanel = uipanel('Parent', fig, 'Title', 'Control Panel', ...
        'Position', [0.01, 0.01, 0.25, 0.98], 'Units', 'normalized');
    set(controlPanel, 'Units', 'pixels');
    panelPos = get(controlPanel, 'Position');
    panelWidth = panelPos(3); panelHeight = panelPos(4);
    
    % --- UI Element Sizing ---
    buttonWidth = min(150, panelWidth * 0.8); buttonHeight = 25;
    labelHeight = 20; fileStatusHeight = 30; verticalSpacing = 25;
    
    currentY = panelHeight - 35;

    % --- File loading section ---
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', 'Load SP3 File', ...
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @loadSP3File);
    currentY = currentY - fileStatusHeight;
    sp3FileText = uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'No SP3 file loaded', ...
        'Position', [20, currentY, buttonWidth+50, fileStatusHeight], 'HorizontalAlignment', 'left');
    
    currentY = currentY - buttonHeight - 10;
    useTimeTableCheck = uicontrol('Parent', controlPanel, 'Style', 'checkbox', ...
        'String', 'Use Time Table Filter', 'Value', 1, ...
        'Position', [20, currentY, buttonWidth, labelHeight], ...
        'Callback', @toggleTimeTableControls, 'Tag', 'useTimeTableCheck');
    currentY = currentY - buttonHeight - 5;
    loadTimeTableBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', 'Load Time Table', ...
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @loadTimeTable, 'Tag', 'loadTimeTableBtn');
    currentY = currentY - fileStatusHeight;
    timeTableText = uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'No time table loaded', ...
        'Position', [20, currentY, buttonWidth+50, fileStatusHeight], 'HorizontalAlignment', 'left');

    currentY = currentY - buttonHeight - 5;
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', 'Load Station File (.json)', ...
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @loadStationFile);
    currentY = currentY - fileStatusHeight;
    stationFileText = uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'No station file loaded', ...
        'Position', [20, currentY, buttonWidth+50, fileStatusHeight], 'HorizontalAlignment', 'left');
    
    % --- Satellite System Selection ---
    currentY = currentY - verticalSpacing;
    uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'Display Satellite Systems:', ...
        'Position', [20, currentY, buttonWidth, labelHeight], 'HorizontalAlignment', 'left');
    currentY = currentY - labelHeight;
    gpsCheck = uicontrol('Parent', controlPanel, 'Style', 'checkbox', 'String', 'GPS (G)', ...
        'Position', [30, currentY, 80, labelHeight], 'Value', 1);
    bdsCheck = uicontrol('Parent', controlPanel, 'Style', 'checkbox', 'String', 'BDS (C)', ...
        'Position', [120, currentY, 80, labelHeight], 'Value', 1);

    % --- Satellite and Station Selection Listboxes ---
    listboxHeight = 120;
    currentY = currentY - verticalSpacing - listboxHeight;
    uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'Select Satellites to Plot:',...
        'Position', [20, currentY + listboxHeight, buttonWidth, labelHeight], 'HorizontalAlignment', 'left');
    satelliteListBox = uicontrol('Parent', controlPanel, 'Style', 'listbox', 'String', {'Load SP3 File first'},...
        'Position', [20, currentY, buttonWidth, listboxHeight], 'Max', 2, 'Enable', 'off', 'Tag', 'satelliteListBox');

    currentY = currentY - verticalSpacing - listboxHeight;
    uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'Select Stations to Plot:',...
        'Position', [20, currentY + listboxHeight, buttonWidth, labelHeight], 'HorizontalAlignment', 'left');
    stationListBox = uicontrol('Parent', controlPanel, 'Style', 'listbox', 'String', {'Load Station File first'},...
        'Position', [20, currentY, buttonWidth, listboxHeight], 'Max', 2, 'Enable', 'off', 'Tag', 'stationListBox');

    % --- Plotting Controls ---
    currentY = currentY - verticalSpacing * 1.5;
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', 'Plot Map', ...
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @plotMap);
    
    set(findall(controlPanel, '-property', 'Units'), 'Units', 'normalized');

    % --- Map Axes ---
    mapAxes = axes('Parent', fig, 'Position', [0.3, 0.05, 0.68, 0.9]);

    % --- Store handles ---
    handles = guihandles(fig);
    handles.fig = fig;
    handles.mapAxes = mapAxes;
    handles.sp3FileText = sp3FileText;
    handles.timeTableText = timeTableText;
    handles.stationFileText = stationFileText;
    handles.gpsCheck = gpsCheck;
    handles.bdsCheck = bdsCheck;
    guidata(fig, handles);


    % --------------------------------------------------------------------
    % CALLBACK FUNCTIONS
    % --------------------------------------------------------------------

    function toggleTimeTableControls(hObject, ~)
        handles = guidata(hObject);
        if get(hObject, 'Value') == 1 % Checked
            set(handles.loadTimeTableBtn, 'Enable', 'on');
        else % Unchecked
            set(handles.loadTimeTableBtn, 'Enable', 'off');
        end
    end

    function loadSP3File(~, ~)
        [filename, pathname] = uigetfile({'*.sp3;*.SP3', 'SP3 Files (*.sp3)'}, 'Select SP3 file');
        if filename == 0, return; end
        handles = guidata(fig);
        appdata = get(fig, 'UserData');
        fullpath = fullfile(pathname, filename);
        try
            [~, sat_data] = parse_sp3_file(fullpath);
            appdata.sp3Data = sat_data;
            handles.sp3FileText.String = ['Loaded: ' filename];
            
            % **MODIFIED: Populate satellite listbox**
            sat_names = fieldnames(appdata.sp3Data);
            set(handles.satelliteListBox, 'String', sat_names, 'Enable', 'on');
            % Select first 5 satellites by default for convenience
            set(handles.satelliteListBox, 'Value', 1:min(5, numel(sat_names))); 
            
            set(fig, 'UserData', appdata);
            guidata(fig, handles);
        catch ME
            errordlg(['Error loading SP3 file: ' ME.message], 'File Error');
        end
    end

    function loadTimeTable(~, ~)
        [filename, pathname] = uigetfile('*.csv', 'Select time table CSV file');
        if filename == 0, return; end
        handles = guidata(fig);
        appdata = get(fig, 'UserData');
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
            guidata(fig, handles);
        catch ME
            errordlg(['Error loading time table file: ' ME.message], 'File Error');
        end
    end

    function loadStationFile(~, ~)
        [filename, pathname] = uigetfile('*.json', 'Select station JSON file');
        if filename == 0, return; end
        handles = guidata(fig);
        appdata = get(fig, 'UserData');
        fullpath = fullfile(pathname, filename);
        try
            json_text = fileread(fullpath);
            station_data = jsondecode(json_text);
            appdata.stationData = station_data;
            handles.stationFileText.String = ['Loaded: ' filename];
            station_names = {station_data.name};
            set(handles.stationListBox, 'String', station_names, 'Enable', 'on', 'Value', []);
            set(fig, 'UserData', appdata);
            guidata(fig, handles);
        catch ME
            errordlg(['Error loading station file: ' ME.message], 'File Error');
        end
    end

    % --- Helper & Menu Functions (timestr2seconds, etc.) ---
    % ... (此处粘贴您已有的其他辅助函数, 无需修改)
    function seconds_of_day = timestr2seconds(timestr)
        try
            if iscell(timestr), timestr = timestr{1}; end
            timestr = strtrim(char(timestr));
            parts = sscanf(timestr, '%d:%d:%d');
            seconds_of_day = parts(1)*3600 + parts(2)*60 + parts(3);
        catch
            seconds_of_day = -999;
        end
    end
    function timestr = seconds2timestr(seconds)
        hours = floor(seconds/3600);
        minutes = floor(mod(seconds,3600)/60);
        secs = floor(mod(seconds,60));
        timestr = sprintf('%02d:%02d:%02d', hours, minutes, secs);
    end
    function txt = customDataTipFunction(~, event_obj)
        pos = get(event_obj, 'Position');
        target = get(event_obj, 'Target');
        userdata = get(target, 'UserData');
        if ~isempty(userdata) && isfield(userdata, 'type')
            switch userdata.type
                case 'satellite'
                    dataIndex = get(event_obj, 'DataIndex');
                    txt = {['Satellite: ', userdata.sat], ...
                           ['UTC Time: ', userdata.times{dataIndex}], ...
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
    function exportSettings(~, ~)
        d = dialog('Position', [300 300 250 150], 'Name', '导出设置');
        uicontrol('Parent', d, 'Style', 'text', 'Position', [20 100 210 20], 'String', '选择导出分辨率 (DPI):');
        resPopup = uicontrol('Parent', d, 'Style', 'popupmenu', 'Position', [20 70 210 25], 'String', {'150', '300', '600'}, 'Value', 2);
        uicontrol('Parent', d, 'Position', [85 20 70 25], 'String', '确定', 'Callback', @export_callback);
        function export_callback
            val = get(resPopup, 'Value');
            str = get(resPopup, 'String');
            setappdata(fig, 'ExportResolution', str2double(str{val}));
            delete(d);
        end
    end
    function toggleGrid(~, ~)
        grid(handles.mapAxes);
    end
    function toggleLegend(~, ~)
        lg = findobj(fig, 'Type', 'legend');
        if ~isempty(lg), set(lg, 'Visible', 'toggle'); end
    end
    function savePlot(~, ~)
        try
            handles = guidata(gcf);
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            defaultName = sprintf('satellite_track_%s.png', timestamp);
            resolution = getappdata(fig, 'ExportResolution');
            if isempty(resolution), resolution = 300; end
            [filename, pathname, filterindex] = uiputfile(...
                {'*.png','PNG';'*.jpg','JPEG';'*.pdf','PDF';'*.eps','EPS';'*.svg','SVG'}, ...
                '保存图像为', defaultName);
            if filename == 0, return; end
            [~, ~, ext] = fileparts(filename);
            if isempty(ext)
                exts = {'.png', '.jpg', '.pdf', '.eps', '.svg'};
                filename = [filename, exts{filterindex}];
            end
            h_temp = figure('Visible', 'off', 'Units', 'pixels', 'Position', [100 100 1200 800]);
            axNew = copyobj(handles.mapAxes, h_temp);
            set(axNew, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
            set(findall(h_temp, '-property', 'FontSize'), 'FontSize', 11);
            fullpath = fullfile(pathname, filename);
            formats = {'-dpng', '-djpeg', '-dpdf', '-depsc2', '-dsvg'};
            if filterindex < 4
                print(h_temp, fullpath, formats{filterindex}, ['-r' num2str(resolution)]);
            else
                print(h_temp, fullpath, formats{filterindex});
            end
            close(h_temp);
            msgbox('图像保存成功！', '成功');
        catch ME
            errordlg(['保存图像时出错: ' ME.message], '错误');
        end
    end

    % --------------------------------------------------------------------
    % ---                  MODIFIED PLOTMAP FUNCTION                   ---
    % --------------------------------------------------------------------
    function plotMap(~, ~)
        handles = guidata(fig);
        appdata = get(fig, 'UserData');
        
        % --- Data and UI State Checks ---
        if isempty(appdata.sp3Data)
            errordlg('Please load SP3 file first', 'Data Missing');
            return;
        end
        
        use_time_filter = get(handles.useTimeTableCheck, 'Value');
        
        if use_time_filter && isempty(appdata.timeTableData)
            errordlg('Time Table filter is enabled. Please load a time table file.', 'Data Missing');
            return;
        end
        
        % --- Get selections from UI ---
        systems_to_show = {};
        if handles.gpsCheck.Value, systems_to_show{end+1} = 'G'; end
        if handles.bdsCheck.Value, systems_to_show{end+1} = 'C'; end
        
        selected_sat_indices = get(handles.satelliteListBox, 'Value');
        if isempty(selected_sat_indices)
            errordlg('Please select at least one satellite to plot from the list.', 'Selection Missing');
            return;
        end
        all_sats_in_list = get(handles.satelliteListBox, 'String');
        sats_to_plot = all_sats_in_list(selected_sat_indices);

        selected_station_indices = get(handles.stationListBox, 'Value');
        selected_stations = [];
        if ~isempty(appdata.stationData) && ~isempty(selected_station_indices)
            all_stations = appdata.stationData;
            all_station_names_in_list = get(handles.stationListBox, 'String');
            [~, ia] = ismember(all_station_names_in_list(selected_station_indices), {all_stations.name});
            selected_stations = all_stations(ia);
        end
        
        % --- Plotting Setup ---
        cla(handles.mapAxes);
        axes(handles.mapAxes);
        ax = axesm('MapProjection', 'pcarree', 'Frame', 'on', 'Grid', 'on');
        set(ax, 'FontSize', 11);
        geoshow(ax, 'landareas.shp', 'FaceColor', [0.5 0.7 0.5]);
        hold(handles.mapAxes, 'on');
        
        legendHandles = [];
        legendLabels = {};
        
        % --- **MODIFIED: Plot Selected Station Visibility Areas** ---
        if ~isempty(selected_stations)
            for i = 1:length(selected_stations)
                station = selected_stations(i);
                
                % Plot station marker
                h_st = plotm(station.llh(1), station.llh(2), 'mp', 'MarkerSize', 12, 'MarkerFaceColor', 'm', 'DisplayName', station.name);
                legendHandles(end+1) = h_st;
                legendLabels{end+1} = station.name;
                set(h_st, 'UserData', struct('type', 'station', 'name', station.name));
                
                % Plot visibility as a dark, semi-transparent filled circle
                [lat_c, lon_c] = scircle1(station.llh(1), station.llh(2), 75);
                h_fill = fillm(lat_c, lon_c, 'k', 'FaceAlpha', 0.35, 'EdgeColor', 'none');
                
                % Add legend for the visibility area only once
                if i == 1
                    set(h_fill, 'DisplayName', 'Station Visibility');
                    legendHandles(end+1) = h_fill;
                    legendLabels{end+1} = 'Station Visibility';
                else
                    set(h_fill, 'HandleVisibility', 'off');
                end
            end
        end

        % --- Plot Satellite Tracks ---
        sat_data = appdata.sp3Data;
        colors = jet(numel(sats_to_plot));
        t_points = linspace(0, 24*3600, 2440);
        times_str_map = arrayfun(@seconds2timestr, t_points, 'UniformOutput', false);

        for i = 1:numel(sats_to_plot)
            sat = sats_to_plot{i};
            if ~isfield(sat_data, sat) || ~any(strncmp(sat, systems_to_show, 1))
                continue;
            end
            
            sat_pos = sat_data.(sat);
            [lat_raw, lon_raw] = xyz2lla(sat_pos.x*1000, sat_pos.y*1000, sat_pos.z*1000);
            
            if use_time_filter
                % --- TIME-FILTERED LOGIC ---
                act_time_table = appdata.timeTableData;
                sat_rows = find(strcmp(act_time_table(:,1), sat));
                if isempty(sat_rows), continue; end
                
                t_original = linspace(0, 24*3600, length(lat_raw));
                lon_unwrapped = unwrap(lon_raw*pi/180)*180/pi;
                lat_interp = interp1(t_original, lat_raw, t_points, 'linear', 'extrap');
                lon_interp = interp1(t_original, lon_unwrapped, t_points, 'linear', 'extrap');
                
                for k = 1:length(sat_rows)
                    start_time = timestr2seconds(act_time_table{sat_rows(k), 2});
                    end_time = timestr2seconds(act_time_table{sat_rows(k), 3});
                    if start_time < 0 || end_time < 0, continue; end
                    
                    start_idx = max(1, round(start_time / 86400 * 2440));
                    end_idx = min(2440, round(end_time / 86400 * 2440));
                    
                    indices = [];
                    if start_time <= end_time
                        indices = start_idx:end_idx;
                    else % Midnight crossing
                        indices = [start_idx:2440, 1:end_idx];
                    end
                    if isempty(indices), continue; end
                    
                    h_track = plotm(lat_interp(indices), lon_interp(indices), '.', 'Color', colors(i,:), 'MarkerSize', 8);
                    if k == 1
                        set(h_track, 'DisplayName', sat);
                        legendHandles(end+1) = h_track; legendLabels{end+1} = sat;
                    else
                        set(h_track, 'HandleVisibility', 'off');
                    end
                    set(h_track, 'UserData', struct('type','satellite','sat',sat,'times',times_str_map(indices)));
                end
            else
                % --- FULL TRACK LOGIC ---
                h_track = plotm(lat_raw, lon_raw, '.', 'Color', colors(i,:), 'MarkerSize', 8, 'DisplayName', sat);
                legendHandles(end+1) = h_track;
                legendLabels{end+1} = sat;
                full_times = arrayfun(@seconds2timestr, linspace(0,86400,length(lat_raw)), 'UniformOutput', false);
                set(h_track, 'UserData', struct('type','satellite','sat',sat,'times',full_times));
            end
        end
        
        % --- Final Touches ---
        if ~isempty(legendHandles)
            delete(findobj(handles.mapAxes, 'Type', 'legend'));
            legend(handles.mapAxes, legendHandles, legendLabels, 'Location', 'southeast', 'FontSize', 10, 'Interpreter', 'none');
        end
        
        mlabel on; plabel on;
        setm(ax, 'MLabelLocation', 30, 'PLabelLocation', 30, 'MLabelParallel', 'south');
        
        dcm = datacursormode(fig);
        set(dcm, 'UpdateFcn', @customDataTipFunction, 'Enable', 'on');
    end
end