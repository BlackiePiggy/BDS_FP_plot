% ecef2aer.m
function [az, el, rng] = ecef2aer(sat_ecef, station_ecef, lat, lon)
% 将卫星和测站的ECEF坐标转换为从测站观测的方位角、仰角和距离。
%
% 输入:
%   sat_ecef     - 卫星的ECEF坐标 [x; y; z] (米)，3x1列向量
%   station_ecef - 测站的ECEF坐标 [x; y; z] (米)，3x1列向量
%   lat          - 测站的大地纬度 (度)
%   lon          - 测站的大地经度 (度)
%
% 输出:
%   az           - 方位角 (度)，0-360，正北为0度
%   el           - 仰角 (度)，-90-90
%   rng          - 从测站到卫星的斜距 (米)

    % 将角度单位从度转换为弧度，用于三角函数计算
    lat_rad = deg2rad(lat);
    lon_rad = deg2rad(lon);

    % 步骤1: 计算从测站指向卫星的视线矢量 (在ECEF坐标系下)
    vec_ecef = sat_ecef - station_ecef;

    % 步骤2: 计算从 ECEF 坐标系到本地 ENU (East-North-Up) 坐标系的旋转矩阵
    sin_lat = sin(lat_rad);
    cos_lat = cos(lat_rad);
    sin_lon = sin(lon_rad);
    cos_lon = cos(lon_rad);
    
    R = [-sin_lon,          cos_lon,           0;
         -sin_lat*cos_lon, -sin_lat*sin_lon,  cos_lat;
          cos_lat*cos_lon,  cos_lat*sin_lon,  sin_lat];

    % 步骤3: 将视线矢量旋转到本地ENU坐标系
    vec_enu = R * vec_ecef;
    e = vec_enu(1); % East
    n = vec_enu(2); % North
    u = vec_enu(3); % Up

    % 步骤4: 计算仰角(el)和方位角(az)
    
    % 计算地平面上的距离分量
    rng_xy = sqrt(e^2 + n^2);
    
    % 计算从测站到卫星的总距离（斜距）
    rng = sqrt(rng_xy^2 + u^2);
    
    % 计算仰角（弧度），并转换为度
    el = rad2deg(atan2(u, rng_xy));
    
    % 计算方位角（弧度），并转换为度
    az = rad2deg(atan2(e, n));
    
    % 将方位角归化到 0-360 度范围
    if az < 0
        az = az + 360;
    end
end