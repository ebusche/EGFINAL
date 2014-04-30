
    ndim=128;
    Ntrain=10000;
    Ntest=300;
    dd=(1:ndim).^(2);
    aspectMat=diag(1./dd);
    Xtraining=randn(Ntrain,ndim)*aspectMat;
    Xtest=randn(Ntest,ndim)*aspectMat;
    loopbits=[32 8 16 24 64 128];
    
    imgTrain = zeros(32,32,3,Ntrain,'uint8');
    imgTest = zeros(32,32,3,Ntest,'uint8');
    
 
    [dd,W]=averageDistance(Xtraining);
    distThreshold=[dd/4 dd];
    
    doPCA = 0;
    plotImgs = 0;
    runSH=1;
    runLSH=1;
    runSVD=0;
    runMDSH=1;
    runITQ=0;
    runKulis=0;
    [SHparam,SHparamNew]=compareAlgorithmsEfficient(Xtraining,Xtest,imgTrain,imgTest,loopbits,distThreshold, ...
        runSH,runLSH,runSVD,runMDSH,runITQ,runKulis,doPCA,plotImgs,dd);
  

