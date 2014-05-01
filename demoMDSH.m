
    ndim=128; %number of input bits
    Ntrain=10000; %number of training images
    Ntest=300; %number of testing images
    dd=(1:ndim).^(2);
    aspectMat=diag(1./dd); %can be deleted
    Xtraining=randn(Ntrain,ndim)*aspectMat; %replace with real training matrix
    Xtest=randn(Ntest,ndim)*aspectMat; %replace with real testing matrix
    loopbits=[8]; %number of output bits
    
    imgTrain = zeros(32,32,3,Ntrain,'uint8');
    imgTest = zeros(32,32,3,Ntest,'uint8');
    
 
    [dd,W]=averageDistance(Xtraining);
    distThreshold=[dd/4 dd];
    doPCA = 0;
    plotImgs = 0;
    
    %which methods are being tested
    runSH=1;
    runLSH=1;
    runCBMF=1;
    runMDSH=1;
    runITQ=1;
  
    [SHparam,SHparamNew]=compareAlgorithmsEfficient2(Xtraining,Xtest,imgTrain,imgTest,loopbits,distThreshold, ...
        runSH,runLSH,runCBMF,runMDSH,runITQ,doPCA,plotImgs,dd);
  

