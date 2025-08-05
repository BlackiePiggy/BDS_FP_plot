% createLayout.m
% 负责创建和布局所有的UI组件，并设置它们的回调函数。
function handles = createLayout(fig)
    % --- Menu setup ---
    fileMenu = uimenu(fig, 'Label', '文件');
    uimenu(fileMenu, 'Label', '保存图像...', 'Callback', @savePlot_Callback);
    uimenu(fileMenu, 'Label', '导出设置...', 'Callback', @exportSettings_Callback);
    uimenu(fileMenu, 'Label', '退出', 'Callback', 'close(gcf)', 'Separator', 'on');
    viewMenu = uimenu(fig, 'Label', '视图');
    uimenu(viewMenu, 'Label', '网格线', 'Callback', @toggleGrid_Callback, 'Checked', 'on');
    uimenu(viewMenu, 'Label', '图例', 'Callback', @toggleLegend_Callback, 'Checked', 'on');

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
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @loadSP3File_Callback);
    currentY = currentY - fileStatusHeight;
    sp3FileText = uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'No SP3 file loaded', ...
        'Position', [20, currentY, buttonWidth+50, fileStatusHeight], 'HorizontalAlignment', 'left');
    
    currentY = currentY - buttonHeight - 10;
    useTimeTableCheck = uicontrol('Parent', controlPanel, 'Style', 'checkbox', ...
        'String', 'Use Time Table Filter', 'Value', 1, ...
        'Position', [20, currentY, buttonWidth, labelHeight], ...
        'Callback', @toggleTimeTableControls_Callback, 'Tag', 'useTimeTableCheck');
    currentY = currentY - buttonHeight - 5;
    loadTimeTableBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', 'Load Time Table', ...
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @loadTimeTable_Callback, 'Tag', 'loadTimeTableBtn');
    currentY = currentY - fileStatusHeight;
    timeTableText = uicontrol('Parent', controlPanel, 'Style', 'text', 'String', 'No time table loaded', ...
        'Position', [20, currentY, buttonWidth+50, fileStatusHeight], 'HorizontalAlignment', 'left');

    currentY = currentY - buttonHeight - 5;
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', 'Load Station File (.json)', ...
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @loadStationFile_Callback);
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
        'Position', [20, currentY, buttonWidth, buttonHeight], 'Callback', @plotMap_Callback);
    
    set(findall(controlPanel, '-property', 'Units'), 'Units', 'normalized');

    % --- Map Axes ---
    mapAxes = axes('Parent', fig, 'Position', [0.3, 0.05, 0.68, 0.9]);

    % --- Store handles ---
    handles = guihandles(fig); % Collect all handles with tags
    handles.fig = fig;
    handles.mapAxes = mapAxes;
    handles.sp3FileText = sp3FileText;
    handles.timeTableText = timeTableText;
    handles.stationFileText = stationFileText;
    handles.gpsCheck = gpsCheck;
    handles.bdsCheck = bdsCheck;
end