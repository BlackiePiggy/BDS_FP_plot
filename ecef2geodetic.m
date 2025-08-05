function [lat, lon, h] = ecef2geodetic(x, y, z)
    % WGS84椭球体参数
    a = 6378137.0;  % 长半轴
    f = 1/298.257223563;  % 扁率
    b = a * (1 - f);  % 短半轴
    e2 = 1 - (b/a)^2;  % 第一偏心率的平方
    
    % 计算经度
    lon = atan2(y, x);
    
    % 计算纬度和高度
    p = sqrt(x^2 + y^2);
    lat = atan2(z, p * (1 - e2));
    
    for i = 1:10
        N = a / sqrt(1 - e2 * sin(lat)^2);
        h = p / cos(lat) - N;
        lat = atan2(z, p * (1 - e2 * N / (N + h)));
    end
    
    % 转换为度
    lat = rad2deg(lat);
    lon = rad2deg(lon);
end