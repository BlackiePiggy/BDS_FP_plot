% customDataTipFunction.m
function txt = customDataTipFunction(hObject, event_obj)
    handles = guidata(hObject);
    pos = get(event_obj, 'Position');
    target = get(event_obj, 'Target');
    userdata = get(target, 'UserData'); % 现在 userdata 可能是卫星信息，也可能是完整的测站对象

    if ~isempty(userdata) && isfield(userdata, 'type')
        switch userdata.type
            case 'satellite'
                % --- 卫星信息处理部分 ---
                dataIndex = get(event_obj, 'DataIndex');
                
                % 从 UserData 获取信息
                times = userdata.times;
                sat_name = userdata.sat;
                sat_ecef_m = userdata.ecef(:, dataIndex); % 获取当前点的卫星ECEF坐标(米)
                
                if iscell(times) && numel(times) >= dataIndex
                    time_str = times{dataIndex};
                else
                    time_str = 'N/A';
                end

                % --- 仰角计算开始 ---
                elevation_info = {};
                appdata = get(handles.fig, 'UserData');
                selected_station_indices = get(handles.stationListBox, 'Value');
                
                if ~isempty(appdata.stationData) && ~isempty(selected_station_indices)
                    all_stations = appdata.stationData;
                    
                    for i = 1:length(selected_station_indices)
                        station = all_stations(selected_station_indices(i));
                        
                        % 确保测站有 xyz 和 llh 字段
                        if isfield(station, 'xyz') && isfield(station, 'llh') && numel(station.xyz) == 3
                            lat_st = station.llh(1);
                            lon_st = station.llh(2);
                            
                            % 直接使用JSON中提供的XYZ坐标 (单位：米)
                            station_ecef_m = [station.xyz(1); station.xyz(2); station.xyz(3)];
                            
                            % 计算仰角 (ecef2aer.m 仍然需要)
                            [~, el, ~] = ecef2aer(sat_ecef_m, station_ecef_m, lat_st, lon_st);
                            
                            if el > 0
                                elevation_info{end+1} = sprintf('  %s: %.1f°', station.name, el);
                            end
                        end
                    end
                end
                
                % --- 格式化最终输出 ---
                txt = {['Satellite: ', sat_name], ...
                       ['UTC Time: ', time_str], ...
                       ['Lat: ', num2str(pos(1), '%.4f'), '°'], ...
                       ['Lon: ', num2str(pos(2), '%.4f'), '°']};
                
                if ~isempty(elevation_info)
                    txt{end+1} = '--- Elevation Angles ---';
                    txt = [txt; elevation_info'];
                end

            case 'station'
                % --- 测站信息处理部分 (新功能) ---
                % userdata 现在就是完整的 station 对象
                txt = {['Station: ', userdata.name]}; % 第一行显示名称
                
                % 添加坐标信息
                txt{end+1} = ['Lat: ', num2str(userdata.llh(1), '%.4f'), '°, Lon: ', num2str(userdata.llh(2), '%.4f'), '°'];
                txt{end+1} = ['Height: ', num2str(userdata.llh(3), '%.2f'), ' m'];
                
                % 添加分隔符
                txt{end+1} = '--- Details ---';

                % 安全地提取并添加详细信息 (使用 isfield 检查以防数据缺失)
                if isfield(userdata, 'domes_number') && ~isempty(userdata.domes_number)
                    txt{end+1} = ['DOMES: ', userdata.domes_number];
                end
                if isfield(userdata, 'receiver_type') && ~isempty(userdata.receiver_type)
                    txt{end+1} = ['Receiver: ', userdata.receiver_type];
                end
                if isfield(userdata, 'antenna_type') && ~isempty(userdata.antenna_type)
                    txt{end+1} = ['Antenna: ', userdata.antenna_type];
                end
                if isfield(userdata, 'agencies') && ~isempty(userdata.agencies)
                    txt{end+1} = ['Agency: ', userdata.agencies(1).name];
                end
        end
    else
        % 默认情况保持不变
        txt = {['Lat: ', num2str(pos(1), '%.4f'), '°'], ...
               ['Lon: ', num2str(pos(2), '%.4f'), '°']};
    end
end