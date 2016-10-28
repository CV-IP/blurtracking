clc;clear;close all;

path = '/Users/chris/Documents/materials/data/OTB/';

titles = { 
         'basketball', 'bolt', 'boy', 'car4', 'carDark', 'carScale',...
         'coke', 'couple', 'crossing', 'david', 'david2', 'david3',...
         'deer', 'dog1', 'doll', 'dudek', 'faceocc1', 'faceocc2',...
         'fish', 'fleetface', 'football', 'football1', 'freeman1', 'freeman3',...
         'freeman4', 'girl', 'ironman', 'jogging-1', 'jogging-2', 'jumping',...
         'lemming', 'liquor', 'matrix', 'mhyang', 'motorRolling', 'mountainBike',...
         'shaking', 'singer1', 'singer2', 'skating1', 'skiing', 'soccer',...
         'subway', 'suv', 'sylvester', 'tiger1', 'tiger2', 'trellis',...
         'walking', 'walking2', 'woman'
        }; %51 sequences
    
for i = 1:length(titles)
    title = titles{i};
    disp(title);
    
    dpath = ['./data/' title '/'];
    dpath_img = [dpath 'img/'];
    if ~exist(dpath_img,'dir'); mkdir(dpath_img); end
    
    spath = [path title '/'];
    spath_img = [spath 'img/'];
    copyfile([spath '*.txt'], dpath);
    
    files = dir([spath_img '*.jpg']);
    
    for f = 1:length(files)
        if mod(f,50)==0; disp(files(f).name); end
        frame = imread([spath_img files(f).name]);
        
        if f > 11
            r = randi(40);
            a = randi(180);
            h = fspecial('motion', r, a);
            frame = imfilter(frame, h, 'replicate');
        end
        
        imwrite(frame, [dpath_img files(f).name]);
    end
end