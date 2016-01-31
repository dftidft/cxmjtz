function H = hof( M, O, binSize, nOrients, clip, crop )

if( nargin<3 ), binSize=8; end
if( nargin<4 ), nOrients=9; end
if( nargin<5 ), clip=.2; end
if( nargin<6 ), crop=0; end

softBin = -1; useHog = 2; b = binSize;

H = gradientMex('gradientHist',M,O,binSize,nOrients,softBin,useHog,clip);

if( crop ), e=mod(size(M),b)<b/2; H=H(2:end-e(1),2:end-e(2),:); end
end