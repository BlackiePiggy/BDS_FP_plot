function lla = ecef2lla(X,Y,Z)
    % Constants
    a = 6378137.0;          % WGS84 Earth semi-major axis (m)
    f = 1/298.257223563;    % WGS84 Flattening
    b = a * (1 - f);        % WGS84 Earth semi-minor axis (m)
    e2 = 1 - (b/a)^2;       % WGS84 Square of 1st eccentricity

    % Extract ECEF coordinates
    % X = ecef(:, 1);
    % Y = ecef(:, 2);
    % Z = ecef(:, 3);

    % Compute longitude
    lon = atan2(Y, X);

    % Compute latitude
    p = sqrt(X.^2 + Y.^2);
    theta = atan2(Z.*a, p.*b);
    lat = atan2(Z + e2.*b.*sin(theta).^3, p - e2.*a.*cos(theta).^3);

    % Compute altitude
    N = a ./ sqrt(1 - e2.*sin(lat).^2);
    alt = p ./ cos(lat) - N;

    % Convert latitude and longitude to degrees
    lat = lat * 180/pi;
    lon = lon * 180/pi;

    % Combine latitude, longitude, and altitude into output array
    lla = [lat, lon, alt];
end