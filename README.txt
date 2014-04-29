This directory contains code for the algorithm described in:
Multidimensional Spectral Hashing
Yair Weiss, Rob Fergus, and Antonio Torralba
European Conference on Computer Vision (ECCV), 2012.

The script demoMDSH.m can be used to compare different
algorithms and to recreate some of the figures in our paper. 
In order to compare to ITQ and BRE, you will need
to download the relavant code from the authors' web page.

The script smallDemo.m can be used just to run MDSH. It creates
synthetic data, compresses it using MDSH and also shows two ways
to use the codes to retrieve similar datapoints. The first one
(which was used in our paper) is to linearly scan all the database
and sort the datapoints by their weighted Hamming distance from the
query. The second method is to use "semantic hashing": to retrieve all
datapoints that have the same code as the query as well as datapoints
that have similar codes. This method is a bit more tricky in MDSH
compared to other hashing methods and the pdf file
hashingWithKernelTrick.pdf discusses it.  
