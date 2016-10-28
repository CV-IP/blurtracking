
% the demo code for the blur object tracking

clear all;
close all;

addpath(genpath('dependency'));
addpath(genpath('utils'));

% tracking for single video;
clip_title = 'Skater';
single_tracker(clip_title);
