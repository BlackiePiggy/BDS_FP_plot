% SatelliteTrackingGUI.m
function SatelliteTrackingGUI
    % 1. 创建主窗口
    fig = figure('Name', 'Satellite Tracking GUI', ...
        'Position', [100, 100, 1000, 750], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'figure', ...
        'Toolbar', 'figure');
        
    % 2. 初始化并存储共享数据结构
    appdata = struct();
    appdata.sp3Data = [];
    appdata.timeTableData = [];
    appdata.stationData = [];
    set(fig, 'UserData', appdata);
    set(fig, 'defaultLegendAutoUpdate', 'off');

    % 3. 调用函数创建UI布局并获取句柄
    handles = createLayout(fig);
    
    % 将句柄结构体保存到figure中，以便所有回调函数都能访问
    guidata(fig, handles);
end