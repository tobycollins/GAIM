# GAIM
This is the Matlab implementation of Graph-based Affine Invariant keypoint Matching (GAIM) from the peer reviwered paper "An Analysis of Errors in Graph-based Keypoint Matching and Proposed Solutions" by Toby Collins, Pablo Mesejo and Adrien Bartoli, published in the European Conference on Computer Vision, September 2014. This is the author's implementation. Please cite this paper if you use any part of this code in your work. Above all, we hope that you will find this code useful.

GAIM tackles the general keypoint-based graph matching problem for two images. It does not require prior knowledge about the number of objects in the scene, the amount of occlusion, the amount of background clutter, and object topology (which changes 
between the images if e.g. an object tears). In our original paper we were using SIFT features as the default keypoint detector. We have included support for SURF, which is now the default. This is considerably faster than SIFT and is recommended to considerably reduce the time needed to simulate keypoints.

The entry-level function is GAIM_matcher. Please call GAIM_example() to run GAIM on three example image pairs, given in ./examples ('cardboard', 'desktop' and 'tear').

Setting dependencies and compilation has been made as easy as possible. We include a function to automatically download and compile the necessary dependencies (setGAIMDependencies()). This gets called automatically when you run GAIM_example(). This has been tested on Linux (Ubuntu 14.04 b4bit) and windows (version 10 64bit).

If you already have local copies of the dependency libraries, you can set the paths accordingly in setGAIMDependencies. If not, they will be downloaded from the web. The dependencies are as follows:


 FLANN: http://www.cs.ubc.ca/research/flann/#download
           Tested with version 1.8.0.
           Requires compiling.

 UGM: http://www.cs.ubc.ca/~schmidtm/Software/UGM.html
           Tested with 2011 version.
           Does not require compiling.

 FBDSD (included) by Daniel Pizarro (http://isit.u-clermont1.fr/en/content/Daniel-Pizarro): Library included in ./dep.
           Tested with version FBDSDv1.0. If you use FBDSD please refer to Daniel's webpage and
           software section to correctly cite his work and for licence terms.
           Does not require compiling.

 QPBO (included) by Vladimir Kolmogorov (http://pub.ist.ac.at/~vnk/). Library included in ./dep. Using mex
           wrapper by Oxford university's VGG libraries (http://www.robots.ox.ac.uk/~vgg/software/).
           If you use QPBO please refer to Vladimir's webpage and software section to correctly cite his
           work and for licence terms.
           Requires compiling

 VLFEAT:   http://www.vlfeat.org
           Tested with version 0.9.20
           Requires compiling (pre-built binaries available).
