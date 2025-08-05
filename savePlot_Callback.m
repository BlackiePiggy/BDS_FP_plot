% savePlot_Callback.m
function savePlot_Callback(hObject, ~)
    handles = guidata(hObject);
    fig = handles.fig;

    try
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
        
        if filterindex < 4 % Raster or PDF formats that support resolution
            print(h_temp, fullpath, formats{filterindex}, ['-r' num2str(resolution)]);
        else % Vector formats where resolution is less meaningful
            print(h_temp, fullpath, formats{filterindex});
        end
        
        close(h_temp);
        msgbox('图像保存成功！', '成功');
    catch ME
        errordlg(['保存图像时出错: ' ME.message], '错误');
    end
end