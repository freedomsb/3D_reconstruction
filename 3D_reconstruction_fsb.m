clc;
clear all;
clean all;
%%%%%%%%%%%%%%%%%%%%%%%%%%% calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imageDir = fullfile(toolboxdir('vision'),'visiondata','calibration','stereo');
leftImages = imageDatastore(fullfile(imageDir,'left'));
rightImages = imageDatastore(fullfile(imageDir,'right'));
images1 = leftImages.Files;
images2 = rightImages.Files;
[imagePoints, boardSize] = detectCheckerboardPoints(images1,images2);
squareSizeInMM = 108;
worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMM);
im = readimage(leftImages,1);
params = estimateCameraParameters(imagePoints,worldPoints);
showReprojectionErrors(params);
%%%%%%%%%%%%%%%%%%%%%%%%%%% triangulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('webcamsSceneReconstruction.mat');
I1 = imread('sceneReconstructionLeft.jpg');
I2 = imread('sceneReconstructionRight.jpg');
I1 = undistortImage(I1,stereoParams.CameraParameters1);
I2 = undistortImage(I2,stereoParams.CameraParameters2);

faceDetector = vision.CascadeObjectDetector;
face1 = faceDetector(I1);
face2 = faceDetector(I2);
center1 = face1(1:2) + face1(3:4)/2;
center2 = face2(1:2) + face2(3:4)/2;

point3d = triangulate(center1, center2, stereoParams);
distanceInMeters = norm(point3d)/1000;