
    ndim=4096; %number of input bits (625, 1296, 4096)
    Ntrain=10000; %number of training images 50000
    Ntest=2000; %number of testing images 10000
    dd=(1:ndim).^(2);
    aspectMat=diag(1./dd); %can be deleted
    [Xtraining, Xtest] = getCIFAR10(ndim);
    loopbits=[32]; %number of output bits (16, 32, 64)
    
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
  

