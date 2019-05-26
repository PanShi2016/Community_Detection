mex -largeArrayDims -O triangleclusters_mex.cc
mex -O CXXFLAGS="\$CXXFLAGS -std=c++0x" -largeArrayDims pprgrow_mex.cc
mex -O CXXFLAGS="\$CXXFLAGS -std=c++0x" -largeArrayDims cutcond_mex.cc % conductance
%mex -O CXXFLAGS="\$CXXFLAGS -std=c++0x" -largeArrayDims cutcond_degnorm_mex.cc % normalized cut
%mex -O CXXFLAGS="\$CXXFLAGS -std=c++0x" -largeArrayDims cutcondnew_degnorm_mex.cc % confidence/hybrid cut