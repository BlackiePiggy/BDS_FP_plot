% searchStations_Callback.m
function searchStations_Callback(hObject, ~)
    % 获取句柄和共享数据
    handles = guidata(hObject);
    appdata = get(handles.fig, 'UserData');

    % 检查测站数据是否已加载
    if isempty(appdata.stationData)
        return;
    end
    
    % 1. 获取搜索框中的文本
    searchText = get(handles.stationSearchBox, 'String');

    % 2. 获取原始的、完整的测站列表
    % 注意这里是从结构体数组中提取 'name' 字段
    allStationNames = {appdata.stationData.name};
    
    % 3. 根据搜索文本进行过滤
    if isempty(searchText)
        % 如果搜索框为空，显示所有测站
        filteredNames = allStationNames;
    else
        % 使用 contains 函数查找包含搜索文本的测站名 (不区分大小写)
        matchIndices = contains(allStationNames, searchText, 'IgnoreCase', true);
        filteredNames = allStationNames(matchIndices);
    end
    
    % 4. 更新测站列表框的内容
    % 同时将列表框的选中值清空
    set(handles.stationListBox, 'String', filteredNames, 'Value', []);
end