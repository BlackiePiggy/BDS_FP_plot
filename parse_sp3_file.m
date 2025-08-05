function [epochs, sat_data] = parse_sp3_file(filename)
    % Open the file
    fid = fopen(filename, 'r');
    
    % Initialize variables
    epochs = [];
    sat_data = struct();
    
    % Read the file line by line
    while ~feof(fid)
        line = fgetl(fid);
        
        % Check if it's an epoch line
        if line(1) == '*'
            % Parse epoch
            year = str2double(line(4:7));
            month = str2double(line(9:10));
            day = str2double(line(12:13));
            hour = str2double(line(15:16));
            minute = str2double(line(18:19));
            second = str2double(line(21:31));
            
            current_epoch = datenum(year, month, day, hour, minute, second);
            epochs = [epochs; current_epoch];
        
        % Check if it's a satellite position line
        elseif line(1) == 'P'
            % Parse satellite data
            sat_id = line(2:4);
            x = str2double(line(5:18));
            y = str2double(line(19:32));
            z = str2double(line(33:46));
            clock_bias = str2double(line(47:60));
            
            % Store the data
            if ~isfield(sat_data, sat_id)
                sat_data.(sat_id) = struct('x', [], 'y', [], 'z', [], 'clock_bias', []);
            end
            sat_data.(sat_id).x = [sat_data.(sat_id).x; x];
            sat_data.(sat_id).y = [sat_data.(sat_id).y; y];
            sat_data.(sat_id).z = [sat_data.(sat_id).z; z];
            sat_data.(sat_id).clock_bias = [sat_data.(sat_id).clock_bias; clock_bias];
        end
    end
    
    % Close the file
    fclose(fid);
end