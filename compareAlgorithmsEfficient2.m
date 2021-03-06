function [SHparam,SHparamNew,ap_all]=compareAlgorithmsEfficient2(Xtraining,Xtest,imgTrain,imgTest,loopbits,distThreshold, ...
    runSH,runLSH,runCBMF,runMDSH,runITQ,doPCA,plotImgs,dd)

  
NUM_EXAMPLES = 20;
NUM_NEIGHBORS = 10;

% compare different algorithms
addpath('./smallcode/release/');

% input: Xtraining,Xtesting,nbits,dist_threshold
% also flags for what to run
% sh,lsh,svd,mdsh,itq,kulis
% note that dist_threshold can be a vector so we evaluate
% with different thresholds






if doPCA
  
  sampleMean = mean(Xtraining,1);
  Xtraining = (Xtraining - repmat(sampleMean,size(Xtraining,1),1));
  Xtest=(Xtest - repmat(sampleMean,size(Xtest,1),1));
  %trainingPCA=Xtraining*gist_pca_params.evectors;
  % start by running PCA, needed for some algorithms and for
  % display

  [pc, l] = svd(cov(Xtraining));
  XtrainingPCA = Xtraining * pc; % no need to remove the mean
  XtestPCA=Xtest*pc;
else
  %%% data is already PCA'd
  XtrainingPCA = Xtraining;
  XtestPCA = Xtest;
  
end



Sigma=distThreshold(1)/2;

%DtrueTraining = distMat(Xtraining,Xtraining);

% try normalized affinity
%dd=sum(trueAffinity);dd=1./sqrt(dd);D=diag(dd);
%trueAffinity=D*trueAffinity*D;

Ntest=size(Xtest,1);
m = ceil(rand*Ntest); % random test sample for visualization
DtrueTestTraining = distMat(Xtest(m,:),Xtraining);
trueAffinity=exp(-DtrueTestTraining.^2/(2*Sigma^2));

bit_idx = 0;
for nb = loopbits
  
    bit_idx = bit_idx + 1;
  
   
    if (runSH)
        SHparam.nbits = nb; % number of bits to code each sample
        SHparam.sigma=2*Sigma;
        SHparam.doPCA = doPCA;
        SHparam = trainSH(Xtraining, SHparam);
        [B1,U1] = compressSH(Xtraining, SHparam);
        [B2,U2] = compressSH(Xtest, SHparam);
        Utraining_sh = sign(U1);
        Utest_sh = sign(U2);
        Wold=Utest_sh(m,:)*Utraining_sh';
        
    end
    if (runMDSH)
        SHparamNew.nbits = nb; % number of bits to code each sample
        SHparamNew.sigma=2*Sigma;
        SHparamNew.min_weight=0.1;
        SHparamNew.doPCA=doPCA;
        SHparamNew = trainMDSH(Xtraining, SHparamNew);
        [B1,U1] = compressMDSH(Xtraining, SHparamNew);
        [B2,U2] = compressMDSH(Xtest, SHparamNew);
        
        %Utraining_mdsh = sign(U1);
        %Utest_mdsh = sign(U2);
        %[Whamm]=hammingDistEfficientNew(Utest_mdsh(m,:), Utraining_mdsh, SHparamNew);
        
        Utraining_mdsh = sign(U1);
        Utest_mdsh = sign(U2);
        Whamm = hammingDistEfficientNew(Utest_mdsh(m,:),Utraining_mdsh,SHparamNew);
    end
    
    if (runLSH)
        ndim=size(Xtraining,2);
        R=randn(ndim,nb);
        Utraining_lsh= sign(Xtraining*R);
        Utest_lsh= sign(Xtest*R);
        Wlsh=Utest_lsh(m,:)*Utraining_lsh';   
       
    end
    if (runITQ)
        [Yitq, Ritq] = ITQ(XtrainingPCA(:,1:nb),50);
        Utraining_Lana=sign(XtrainingPCA(:,1:nb)*Ritq);
        Utest_Lana=sign(XtestPCA(:,1:nb)*Ritq);
        
        Wlana=Utest_Lana(m,:)*Utraining_Lana';
    end
    if (runCBMF)
        
        SHparamN.nbits = nb; % number of bits to code each sample
        SHparamN.sigma=5*Sigma;% Sigma for the affinity. Different codes for different sigmas!
        
        % create code on training matrix
        Utraining_CBMF = trainCBMF(Xtraining, SHparamN);
        
        % train classifiers to generate new code
        % create LR classifiers
        classifiers = LRClassifiers(Xtraining, Utraining_CBMF, SHparamN.nbits);
        [testItems c] = size(Xtest);
        Utest_CBMF = zeros(testItems, SHparamN.nbits);
        for x = 1:testItems
            newItem = Xtest(x,:);
            newCode = LRGenCode(classifiers, newItem, SHparamN.nbits);
            Utest_CBMF(x,:) = newCode;
        end
        W1 = Utest_CBMF(m,:);
        W1(W1==0) = -1;
        W2 = Utraining_CBMF';
        W2(W2==0) = -1;
        % Whamm_CBMF = Utest_CBMF(m,:)*Utraining_CBMF';
        Whamm_CBMF = W1 * W2;
    end
    
    
    if (1)
        % Visualization
        figure
        if (runMDSH)
            subplot(331)
            %show2dfun(Xtraining, -double(hammingDist(B2(m,:), B1)'));
            showNdfun(XtrainingPCA(:,1:2),double(Whamm)');
            title('MDSH affinity');
        end
        subplot(332)
        showNdfun(XtrainingPCA(:,1:2), trueAffinity');
        title('Ground truth affinity')
        subplot(333)
        if (runLSH)
            showNdfun(XtrainingPCA(:,1:2), Wlsh');
            title('LSH affinity')
        end
        if (runSH)
            subplot(334)
            showNdfun(XtrainingPCA(:,1:2), Wold');
            title('SH affinity')
        end
        
        if (runITQ)
            subplot(337);
            showNdfun(XtrainingPCA(:,1:2), Wlana');
            title('ITQ affinity');
        end
        
        if (runCBMF)
            subplot(337);
            showNdfun(XtrainingPCA(:,1:2), Whamm_CBMF');
            title('CBMF affinity');
        end
        
    end

    
    
    for ii=1:length(distThreshold)
        T=distThreshold(ii); % normal neighborhood
        hh=figure;
        ll='';
        all_img = cell(1,NUM_EXAMPLES);
        
            
            
        for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,imgTest(:,:,:,jj),zeros(32,32,3,NUM_NEIGHBORS-1,'uint8')); end
        
        
        if (runMDSH)
            [PMD,recallMD,apMDSH(bit_idx,ii),trueMD,hamMD]=evaluationAffinityEfficient(Xtraining, Xtest, Utraining_mdsh, Utest_mdsh, SHparamNew,T,hh,'bo-','linewidth',2.0);
            ll{end+1}='MDSH';
            %%% true nearest neighbors 
            % a = evaluationAffinityEfficient2(Xtraining, Xtest, Utraining_mdsh, Utest_mdsh, SHparamNew, T)
                       
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,trueMD{1}(jj,1:NUM_NEIGHBORS)),trueMD{2}(jj,1:NUM_NEIGHBORS))); end
            %%% MDSH nearest neighbors
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,hamMD{1}(jj,1:NUM_NEIGHBORS)),hamMD{2}(jj,1:NUM_NEIGHBORS))); end           
        end
        
        if (runLSH)
            [PLSH,recallLSH,apLSH(bit_idx,ii),trueLSH,hamLSH]=evaluationAffinityEfficient(Xtraining, Xtest, Utraining_lsh, Utest_lsh,[], T,hh,'co-','linewidth',2.0);
            ll{end+1}='LSH';
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,hamLSH{1}(jj,1:NUM_NEIGHBORS)),hamLSH{2}(jj,1:NUM_NEIGHBORS))); end           
        end

        if (runSH)
            [score,recall,apSH(bit_idx,ii),trueSH,hamSH]=evaluationAffinityEfficient(Xtraining, Xtest, Utraining_sh, Utest_sh,[], T,hh,'ro-','linewidth',2.0);
            ll{end+1}='SH';
            apSH(bit_idx,ii)
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,hamSH{1}(jj,1:NUM_NEIGHBORS)),hamSH{2}(jj,1:NUM_NEIGHBORS))); end           
        end
        if (runITQ)
            [score,recall,apITQ(bit_idx,ii),trueITQ,hamITQ]=evaluationAffinityEfficient(Xtraining, Xtest, Utraining_Lana, Utest_Lana,[], T,hh,'ko-','linewidth',2.0);
            ll{end+1}='ITQ';
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,hamITQ{1}(jj,1:NUM_NEIGHBORS)),hamITQ{2}(jj,1:NUM_NEIGHBORS))); end           
        end
        
        if (runCBMF)
            [PCBMF,recallCBMF,apCBMF(bit_idx,ii),trueCBMF,hamCBMF]=evaluationAffinityEfficient(Xtraining, Xtest, Utraining_CBMF, Utest_CBMF, [],T,hh,'yo-','linewidth',2.0);
            % a = evaluationAffinityEfficient2(Xtraining, Xtest, Utraining_CBMF, Utest_CBMF, [],T)
            ll{end+1}='CBMF';
            apCBMF(bit_idx,ii)
            %%% true neapCBMF(bit_idx,ii)arest neighbors 
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,trueCBMF{1}(jj,1:NUM_NEIGHBORS)),trueCBMF{2}(jj,1:NUM_NEIGHBORS))); end
            %%% CBMF nearest neighbors
            for jj=1:NUM_EXAMPLES, all_img{jj} = cat(4,all_img{jj},labelimg(imgTrain(:,:,:,hamCBMF{1}(jj,1:NUM_NEIGHBORS)),hamCBMF{2}(jj,1:NUM_NEIGHBORS))); end           
        end
        set(gca,'fontsize',16);
        legend(ll);
        xlabel('recall');
        ylabel('precision');
        axis auto;
        title(sprintf('evaluation using neighborhood=%3.2f',T));
       
    end
    
    
    if 0 
      hh=figure;
      ll='';
      if (runMDSH)
        [er] = expectedRankEfficient(Xtraining, Xtest, Utraining_mdsh, Utest_mdsh, SHparamNew, T, hh,'b-','linewidth',2.0);
        ll{end+1}='MDSH';
      end
      
      if (runLSH)
        [er] = expectedRankEfficient(Xtraining, Xtest, Utraining_lsh, Utest_lsh, [], T, hh,'c-','linewidth',2.0);
        ll{end+1}='LSH';
      end
      
      if (runSH)
        [er] = expectedRankEfficient(Xtraining, Xtest, Utraining_sh, Utest_sh, [], T, hh,'r-','linewidth',2.0);
        ll{end+1}='SH';
      end
      
      if (runITQ)
        [er] = expectedRankEfficient(Xtraining, Xtest, Utraining_Lana, Utest_Lana, [], T, hh,'k-','linewidth',2.0);
        ll{end+1}='ITQ';
      end
      
      if (runCBMF)
        [er] = expectedRankEfficient(Xtraining, Xtest, Utraining_CBMF, Utest_CBMF,[], T, hh,'y-','linewidth',2.0);
        ll{end+1}='CBMF';
      end
      
      set(gca,'fontsize',16);
      legend(ll);
      xlabel('rank');
      ylabel('expected rank');
      axis auto;
      title(sprintf('evaluation using neighborhood=%3.2f',T));
    end
    
    
    if plotImgs
      
      ll2=fliplr(ll);
      ll2{end+1} = 'Real NN'; ll2{end+1}='Query';
      
      for jj=1:NUM_EXAMPLES
        figure(hh+jj);
        montage(all_img{jj},'Size',[floor(size(all_img{jj},4)/NUM_NEIGHBORS) NUM_NEIGHBORS])
        axis on;
        set(gca,'YTick',[1:floor(size(all_img{jj},4)/NUM_NEIGHBORS)]*32-16); set(gca,'YTickLabel',fliplr(ll2));
        set(gca,'XTick',[1:NUM_NEIGHBORS]*32-16); set(gca,'XTickLabel',[1:NUM_NEIGHBORS]);
        title(sprintf('Example: %d',jj));
        xlabel('Nearest Neighbors');
        %ylabel('Method'); 
        %colorbar off;
      end
    end
    
     
end

   if 1
      
      hh = figure;
      ll='';
      %%% two plots: (i) region size vs mAp for fixed bits; (ii) bits vs
      %mAp for fixed region size. 
      subplot(1,2,1)
      [sort_distThreshold,ind] = sort(distThreshold);
      sort_distThreshold = sort_distThreshold/dd;
      if runMDSH, plot(sort_distThreshold,apMDSH(1,ind),'bo-','linewidth',2.0); hold on; ll{end+1}='MDSH'; end
      if runSH, plot(sort_distThreshold,apSH(1,ind),'ro-','linewidth',2.0); hold on; ll{end+1}='SH';  end
      if runLSH, plot(sort_distThreshold,apLSH(1,ind),'co-','linewidth',2.0); hold on; ll{end+1}='LSH';  end
      if runITQ, plot(sort_distThreshold,apITQ(1,ind),'ko-','linewidth',2.0); hold on; ll{end+1}='ITQ';  end
      if runCBMF, plot(sort_distThreshold,apCBMF(1,ind),'yo-','linewidth',2.0); hold on; ll{end+1}='CBMF';  end
      set(gca,'fontsize',16);
      legend(ll,'Location','NorthWest');
      xlabel('Distance Threshold (Fraction of \delta)');
      ylabel('Mean Precision'); set(gca,'XTick',sort_distThreshold); set(gca,'XTickLabel',num2cell(sort_distThreshold));
      axis auto; q=axis; axis([q(1) q(2) 0 1]); grid on;
      title(sprintf('Evaluation using %d bits',loopbits(1)));
      
      
      subplot(1,2,2)
      [sort_loopbits,ind] = sort(loopbits);
      if runMDSH, plot(sort_loopbits,apMDSH(ind,1)','bo-','linewidth',2.0); hold on; end
      if runSH, plot(sort_loopbits,apSH(ind,1)','ro-','linewidth',2.0); hold on;  end
      if runLSH, plot(sort_loopbits,apLSH(ind,1)','co-','linewidth',2.0); hold on; end
      if runITQ, plot(sort_loopbits,apITQ(ind,1)','ko-','linewidth',2.0); hold on;  end
      if runCBMF, plot(sort_loopbits,apCBMF(ind,1)','yo-','linewidth',2.0); hold on; end
      set(gca,'fontsize',16); set(gca,'XTick',sort_loopbits); set(gca,'XTickLabel',num2cell(sort_loopbits));
      legend(ll,'Location','NorthWest');
      xlabel('Number of bits'); 
      ylabel('Mean Precision');
      axis auto; q=axis; axis([q(1) q(2) 0 1]); grid on;
      title(sprintf('Evaluation using distance threshold \\delta/%d',round(dd/distThreshold(1))));
      
    end
  
