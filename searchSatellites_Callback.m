% searchSatellites_Callback.m
function searchSatellites_Callback(hObject, ~)
    % 获取句柄和共享数据
    handles = guidata(hObject);
    appdata = get(handles.fig, 'UserData');

    % 检查SP3数据是否已加载
    if isempty(appdata.sp3Data)
        return;
    end

    % 1. 获取搜索框中的文本
    searchText = get(handles.satelliteSearchBox, 'String');
    
    % 2. 获取原始的、完整的卫星列表
    allSatNames = fieldnames(appdata.sp3Data);
    
    % 3. 根据搜索文本进行过滤
    if isempty(searchText)
        % 如果搜索框为空，显示所有卫星
        filteredNames = allSatNames;
    else
        % 使用 contains 函数查找包含搜索文本的卫星名 (不区分大小写)
        matchIndices = contains(allSatNames, searchText, 'IgnoreCase', true);
        filteredNames = allSatNames(matchIndices);
    end
    
    % 4. 更新卫星列表框的内容
    % 同时将列表框的选中值清空，以防因列表项变化导致索引错误
    set(handles.satelliteListBox, 'String', filteredNames, 'Value', []);
end