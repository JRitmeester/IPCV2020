function out = chrom_adapt(I, l_e, opt, CAT, pixelwise)
%Input: 
% - I: input image (double) in sRGB*
% - l_e: estimated illuminant (normalized)
% - opt: 1 for Matlab rgb2xyz function (Ebner, Marc. "Color Constancy") or
%2 for Matthew Anderson "Proposal for a Standard Default Color Space for the Internet�sRGB"
% - CAT: 'xyzscalling', 'bradford', 'von', 'sharp', or 'cat2000' (default =
% 'bradford')
% - pixelwise: if you provide in I_e a normalized estimated illuminant per
% pixel, use pixelwise = 1; otherwise, use pixelwise = 0 (default = 0)
%Output:
% - out: corrected image in sRGB*
%* note: we assume that the input image in the standard RGB without
%applying tone mapping or any camera picture style (i.e., after applying
%the color correction matrix to get the XYZ values, we assume there is only
%gamma curve applied according to the standard RGB in ref[1,2].
%Author: Mahmoud Afifi - York University, mafifi@eecs.yorku.ca -
%m.3afifi@gmail.com
if nargin == 2 
    opt =1;
    CAT = 'bradford';
    pixelwise = 0;
elseif nargin == 3
    CAT = 'bradford';
    pixelwise = 0;
elseif nargin == 4
    pixelwise = 0;
end
sz = size(I);
I = im2double(I);
l_e = im2double(l_e);
l_e(l_e == 0) = eps;
switch CAT
    case 'xyzscalling' %Ref: [3]
        E = [1 0 0
            0 1 0
            0 0 1];
        
    case 'bradford' %Ref: [4]
        E = [0.8951    0.2664   -0.1614
            -0.7502    1.7135    0.0367
            0.0389   -0.0685    1.0296];
        
    case 'von' %Ref: [5]
        E = [0.40024    0.70760   -0.08081
            -0.22630    1.16532    0.04570
            0.0000   0.0000    0.91822];
        
    case 'sharp' %Ref: [6]
        E = [1.26940    -0.09880   -0.17060
            -0.83640    1.80060    0.03570
            0.02970     -0.03150   1.00180];
        
    case 'cat2000' %Ref: [7]
       E = [ 0.79820    0.33890  -0.13710
           -0.59180  1.55120  0.04060
           0.00080  0.23900  0.97530];
       
end
l_r = whitepoint('d65');
l_e_XYZ = srgb2xyz(l_e,opt);
l_e_RGB = (l_e_XYZ./l_e_XYZ(2)) * E';
l_r_RGB = l_r * E';
if pixelwise == 1
    l_r_RGB = l_r_RGB./norm(l_r_RGB);
    l_e_RGB = l_e_RGB./sqrt(l_e_RGB(:,1).^2 + l_e_RGB(:,2).^2 + l_e_RGB(:,3).^2);
end
l_br = l_r_RGB./l_e_RGB;
I = reshape(I,[],3);
I_XYZ = srgb2xyz(I,opt);
if pixelwise == 1
    factor = zeros(size(l_br,1),3,3);
    for i = 1: size(factor,1)
            factor(i,:,:) = reshape((E\diag(l_br(i,:))*E)',1,3,3);
    end
    out = xyz2srgb(I_XYZ*reshape(factor(i,:),3,3),opt);
else
    out = xyz2srgb(I_XYZ*(E\diag(l_br)*E)',opt);
end
out = uint8(reshape(out,[sz(1),sz(2),sz(3)])*255);
end
function XYZ=srgb2xyz(sRGB, opt)
if nargin == 1
    opt = 1;
end
switch opt
    case 1 %[1] Matlab rgb2xyz function (Ebner, Marc. "Color Constancy")
        T = [0.4125   0.3576    0.1804
            0.2127    0.7151    0.0722
            0.0193    0.1192    0.9503];
        threshold = 0.04045;
        
    case 2 %[2] Matthew Anderson "Proposal for a Standard Default Color Space for the Internet�sRGB"
        
        T = [0.4127    0.3586    0.1808
            0.2132    0.7172    0.0724
            0.0195    0.1197    0.9517];
        threshold =  0.03928;
end
RGB = sRGB;
RGB(sRGB<threshold) = sRGB(sRGB<threshold)/12.92;
RGB(sRGB>threshold) = ((sRGB(sRGB>threshold) + 0.055)./1.055).^(2.4);
XYZ = RGB*T';
end
function sRGB=xyz2srgb(XYZ, opt)
if nargin == 1
    opt = 1;
end
switch opt
    case 1 %[1] Matlab xyz2rgb function (Ebner, Marc. "Color Constancy")
        T = [0.4125   0.3576    0.1804
            0.2127    0.7151    0.0722
            0.0193    0.1192    0.9503];
        threshold = 0.0031308;
    case 2 %[2] Matthew Anderson "Proposal for a Standard Default Color Space for the Internet�sRGB"
        T = [0.4127    0.3586    0.1808
            0.2132    0.7172    0.0724
            0.0195    0.1197    0.9517];
        threshold = 0.00304;
end
RGB=XYZ/(T');
sRGB = RGB;
sRGB(RGB<=threshold) = RGB(RGB<=threshold)*12.92;
sRGB(RGB>threshold) = (RGB(RGB>threshold)*1.055).^(1/2.4)-0.055;
end
%% References
%[1] Anderson, Matthew, et al. "Proposal for a standard default color space for the internet�srgb." Color and imaging conference. Vol. 1996. No. 1. Society for Imaging Science and Technology, 1996.
%[2] Ebner, Marc. "Color Constancy". Chichester, West Sussex: John Wiley & Sons, 2007.
%[3] Johannes von Kries. Beitrag zur physiologie der gesichtsempfindung. Arch. Anat. Physiol, 2:505�524, 1878.
%[4] King Man Lam. Metamerism and Colour Constancy. Ph. D. Thesis, University of Bradford, 1985.
%[5] H Helson. Object-color changes from daylight to incandescent filament illumination. Illum. Engng., 47:35�42, 1957.
%[6] Graham D Finlayson and Sabine S�sstrunk. Performance of a chromatic adaptation transform based on spectral sharpening. In Color and Imaging Conference, volume 2000, pages 49�55, 2000.
%[7] Changjun Li, M Ronnier Luo, Bryan Rigg, and Robert WG Hunt. Cmc 2000 chromatic adaptation transform: Cmccat2000. Color Research & Application, 27(1):49�58, 2002.