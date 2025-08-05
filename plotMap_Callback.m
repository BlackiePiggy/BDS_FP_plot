% plotMap_Callback.m
function plotMap_Callback(hObject, ~)
    handles = guidata(hObject);
    fig = handles.fig;
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
    
    % --- Plot Selected Station Visibility Areas ---
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
        % NOTE: This assumes a function `xyz2lla` exists on the MATLAB path.
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
                set(h_track, 'UserData', struct('type','satellite','sat',sat,'times',{times_str_map(indices)}));
            end
        else
            % --- FULL TRACK LOGIC ---
            h_track = plotm(lat_raw, lon_raw, '.', 'Color', colors(i,:), 'MarkerSize', 8, 'DisplayName', sat);
            legendHandles(end+1) = h_track;
            legendLabels{end+1} = sat;
            full_times = arrayfun(@seconds2timestr, linspace(0,86400,length(lat_raw)), 'UniformOutput', false);
            set(h_track, 'UserData', struct('type','satellite','sat',sat,'times',{full_times}));
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