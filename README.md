# drishti
Real time eye tracking for embedded and mobile devices in C++ (>= C++11).

[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/BSD-3-Clause)
[![HUNTER](https://img.shields.io/badge/hunter-v0.18.28-blue.svg)](http://github.com/ruslo/hunter)

Goal: SDK size <= 1 MB and combined resources (object detection + regression models) <= 4 MB.

| Linux/OSX/Android/iOS                           | Windows                                             |
|-------------------------------------------------|-----------------------------------------------------|
| [![Build Status][travis_status]][travis_builds] | [![Build Status][appveyor_status]][appveyor_builds] |


[travis_status]: https://travis-ci.com/elucideye/drishti.svg?token=2fYtPs8x4ziLvxfp2emx&branch=master
[travis_builds]: https://travis-ci.com/elucideye/drishti

[appveyor_status]: https://ci.appveyor.com/api/projects/status/m1ourfgbmmbp4p0o?svg=true
[appveyor_builds]: https://ci.appveyor.com/api/projects/elucideye/drishti

* [Hunter](https://github.com/ruslo/hunter) package management and CMake build system by Ruslan Baratov, as well as much of the cross platform Qt work: "Organized Freedom!" :)
* A C++ and OpenGL ES 2.0 implementation of [Fast Feature Pyramids for Object Detection](https://pdollar.github.io/files/papers/DollarPAMI14pyramids.pdf) (see [Piotr's Matlab Toolbox](https://pdollar.github.io/toolbox)) for face and eye detection
* Iris ellipse fitting via [Cascaded Pose Regression](https://pdollar.github.io/files/papers/DollarCVPR10pose.pdf) (Piotr Dollar, et al) + [XGBoost](https://github.com/dmlc/xgboost) regression (Tianqi Chen, et al) 
* Face landmarks and eye contours provided by ["One Millisecond Face Alignment with an Ensemble of Regression Trees"](http://www.cv-foundation.org/openaccess/content_cvpr_2014/papers/Kazemi_One_Millisecond_Face_2014_CVPR_paper.pdf) (Kazemi, et al) using a modified implementation of [Dlib](https://github.com/davisking/dlib) (Davis King) (normalized pixel differences, line indexed features, PCA size reductions)
* OpenGL ES friendly GPGPU shader processing and efficient iOS + Android texture handling using a modified version of [ogles_gpgpu](https://github.com/hunter-packages/ogles_gpgpu) (Markus Kondrad) with a number of shader implementations taken directly from [GPUImage](https://github.com/BradLarson/GPUImage) (Brad Larson)

[![Eyes of Hitchcock](https://cloud.githubusercontent.com/assets/554720/26555220/0eba528c-4462-11e7-8ae9-bbed8445a3c6.jpg)](https://vimeo.com/219386623)

*source: Koganada's "Eyes of Hitchcock"*
