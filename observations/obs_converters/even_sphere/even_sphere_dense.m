% Generate approximately evenly distributed points on sphere using
% Golden Section spiral algorithm 
%    http://www.softimageblog.com/archives/115

%% DART software - Copyright UCAR. This open source software is provided
% by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

close all; clear;

% this differs from the original in that it quits at 150 mb (since
% we rarely assimilate obs above this level), and it's more dense
% than the original 600 points to generate more obs to assimilate.
% i would like to do something about the 1000mb level since with
% any topography it will be below the lowest pressure level in the
% model.  as a compromise, i am generating several extra levels near
% the bottom which are NOT MANDATORY levels.

% Generate obs_sequence input for this problem
% levels used here are : 1000 mb, 950mb, 900mb, 850mb, 800 mb, 750 mb, 
% 700mb, 650mb, 600mb, 550mb, 500mb, 400 mb, 300 mb, 200 mb, 150 mb

% For diagnostic test need a null data value and a null qc value
diagnostic_test = false;

% Input is in hectopascals
levels = [1000 950 900 850 800 750 700 650 600 550 500 400 300 200 150];

% Date information is overwritten by create_fixed_network_sequence
year = 2008;
month = 10;
day = 1;
hour = 0;

% Number of roughly evenly distributed points in horizontal
n = 2500;
x(1:n) = 0;
y(1:n) = 0;
z(1:n) = 0;

% Total number of observations at single time is levels*n*3
num_obs = size(levels, 2) * n * 3;
 
inc = pi * (3 - sqrt(5));
off = 2 / n;
for k = 1:n
   y(k) = (k-1) * off - 1 + (off / 2);
   r = sqrt(1 - y(k)*y(k));
   phi = (k-1) * inc; 
   x(k) = cos(phi) * r;
   z(k) = sin(phi) * r;
end 

% Now convert to latitude and longitude
for k = 1:n
   lon(k) = atan2(y(k), x(k)) + pi;
   lat(k) = asin(z(k));
   % Input is in degrees of lat and longitude
   dlon(k) = rad2deg(lon(k));
   dlat(k) = rad2deg(lat(k));
end

% Need to generate output for driving create_obs_sequence
fid = fopen('even_create_input', 'w');

% Output the total number of observations
fprintf(fid, '%6i\n', num_obs);
% 0 copies of data
if(diagnostic_test) 
   fprintf(fid, '%2i\n', 1);
else
   fprintf(fid, '%2i\n', 0);
end

% 0 QC fields
if(diagnostic_test) 
   fprintf(fid, '%2i\n', 1);
else
   fprintf(fid, '%2i\n', 0);
end

% Metadata for data copy
if(diagnostic_test)
   fprintf(fid, '"observations"\n');
end
% Metadata for qc
if(diagnostic_test)
   fprintf(fid, '"Quality Control"\n');
end


% Loop to create each observation
for hloc = 1:n
   for vloc = 1:size(levels, 2)
      for field = 1:3
         % 0 indicates that there is another observation; 
         fprintf(fid, '%2i\n', 0);
         % Specify obs kind by string
         if(field == 1)
            fprintf(fid, 'RADIOSONDE_TEMPERATURE\n');
         elseif(field == 2)
            fprintf(fid, 'RADIOSONDE_U_WIND_COMPONENT\n');
         elseif(field == 3)
            fprintf(fid, 'RADIOSONDE_V_WIND_COMPONENT\n');
         end
         % Select pressure as the vertical coordinate
         fprintf(fid, '%2i\n', 2);
         % The vertical pressure level
         fprintf(fid, '%5i\n', levels(vloc));
         % Lon and lat in degrees next
         fprintf(fid, '%6.2f\n', dlon(hloc));
         fprintf(fid, '%6.2f\n', dlat(hloc));
         % Now the date and time
         fprintf(fid, '%5i %3i %3i %3i %2i %2i \n', year, month, day, hour, 0, 0);
         % Finally, the error variance, 1 for temperature, 4 for winds
         if(field == 1)
            fprintf(fid, '%2i\n', 1);
         else
            fprintf(fid, '%2i\n', 4);
         end
     
         % Need value and qc for testing
         if(diagnostic_test)
            fprintf(fid, '%2i\n', 1);
            fprintf(fid, '%2i\n', 0);
         end
      end   
   end
end

% File name
fprintf(fid, 'set_def.out\n');

% Done with output, close file
fclose(fid);



% Some plotting to visualize this observation set
plot(lon, lat, '*');
hold on

% Plot an approximate CAM T85 grid for comparison
% 256x128 points on A-grid
% Plot latitude lines first
del_lat = pi / 128;
for i = 1:128
   glat = del_lat * i - pi/2;
   a = [0 2*pi];
   b = [glat glat];
   plot(a, b, 'k');
end

del_lon = 2*pi / 256;
for i = 1:256
   glon = del_lon*i;
   a = [glon glon];
   b = [-pi/2,  pi/2];
   plot(a, b, 'k');
end

% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$
