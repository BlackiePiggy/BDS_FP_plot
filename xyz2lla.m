function [lat, lon] = ecef2latlon(X, Y, Z)
    % ECEF2LATLON 将ECEF坐标转换为经纬度
    %   输入:
    %       X, Y, Z: ECEF坐标 (单位: 米), 可以是1xn维向量
    %   输出:
    %       lat: 纬度 (单位: 度)
    %       lon: 经度 (单位: 度)
    
    % WGS84椭球体参数
    a = 6378137.0;  % 椭球体长半轴 (米)
    f = 1/298.257223563;  % 扁率
    b = a * (1 - f);  % 椭球体短半轴 (米)
    e2 = 1 - (b/a)^2;  % 偏心率的平方
    
    % 计算经度
    lon = atan2(Y, X);
    
    % 计算纬度
    p = sqrt(X.^2 + Y.^2);
    theta = atan2(Z .* a, p .* b);
    lat = atan2(Z + e2 * b * sin(theta).^3, p - e2 * a * cos(theta).^3);
    
    % 将弧度转换为度
    lat = rad2deg(lat);
    lon = rad2deg(lon);
    
    % 确保经度在 -180 到 180 度之间
    lon = mod(lon + 180, 360) - 180;
end