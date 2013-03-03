% Benjamin Shih
% 16722S13 HW4LH
% Due: 2/28/2013
% Shot Noise Simulation

clear
close all
clc

% Read the input image.
img = imread('20130214-16722-gates.jpg');

% Split the image into three RGB channels.
numChannels = 3;

% Determine the size of the image.
[m, n] = size(img(:,:,1));

% Electron levels for shot noise. Electrons generated on average in one
% frame time at a pixel that sees a nearly-white scene region.
sn = [1e5, 1e3, 1e1];

% Baseline noise level in number of electrons per pixel per frame time.
bln = 10;

% Array to hold multiple images.
imgs = cell(1,3);

%% Image Generation using Poisson Distributions
% Scaling based on the number of electrons obtained in a nearly-white scene
% region on average in one frame time. In the below cases, a pixel value of
% 255 correponds to the electron levels specified from the shot noise. If
% instead the pixel value of 255 corresponded to the saturation of the CCD,
% or 200k electrons, then you would require 200k/255 electrons per pixel
% value. The images corresponding to 1e3 and 1e1 electrons per frame time
% at a pixel would essentially result in black images, because there are an
% insufficient number of electrons to make a change in the pixel value.
% This is why photos taken at night are more noisy despite requiring longer
% exposure times - the number of electrons picked up by the CCD are
% insufficient to make a difference in the pixel value. The 1e5 image
% contains nearly no noise, the 1e3 is hard to see the noise (requires
% zooming into the image), and the 1e1 has a lot of noise. This is because
% the SNR of shot noise scales as sqrt(number of events), so when the
% signal contains fewer electons, the noise has a much larger effect. 
for i = 1:length(sn)
    imgs{i} = poissrnd(sn(i)/255*double(img));
    imgs{i} = imgs{i} + poissrnd(bln, m, n, numChannels);
    imgs{i} = imgs{i} * 255/(sn(i) + bln);
    imgs{i} = uint8(imgs{i});
end

% Display all the images.
figure;
imshow(img);
for i = 1:length(sn)
    figure;
    imshow(imgs{i})
end

%% Extra Credit: Gaussian Approximation
% Generate the image using a poissrnd. This is the same as above.
figure;
imshow(imgs{3});

% Generate the approximate image using its Gaussian approximation.
img = (sn(3)/255) .* double(img); % Translate the 
stdev = sqrt(img);
gauss_approx = img + (stdev .* randn(m, n, numChannels, 'double'));
gauss_approx = gauss_approx + (bln + sqrt(bln) * randn(m, n, numChannels, 'double'));
gauss_approx = gauss_approx * 255/(sn(3) + bln);
gauss_approx = uint8(gauss_approx);
figure;
imshow(gauss_approx);

% The Poisson distribution begins to look like a Gaussian when lambda >=
% 10. Because our lambdas are chosen based on each pixel value, the values
% in the original image that will appear to be not Gaussian are the darkest
% ones - pixels with a value less than 10. Thus, in our reconstructed image
% using Gaussians, the only significant differences we would expect in the
% appearance would be in the darkest areas. Considering only the shot
% noise using the pixel values for lambdas, the differences in the
% generated images are hard to spot by eye. However, in addition to the
% shot noise from the image, there is also a poisson-distributed baseline
% noise with a lambda value of 10, which looks like a Gaussian. For all
% shot noise lambdas, the summation of the shot noise and baseline noise 
% is essentially adding two distributions, either one Gaussian and one
% Poisson or two Gaussians, which by the central limit theorem, begins to
% approach a Gaussian. So, both visually and mathematically, it is very
% hard to tell the difference between the image generated using poisson
% distributions and its Gaussian approximation.

