# Real-time Stokes Polarimetry using a Polarisation Camera

## Authors

**Mitchell A. Cox**  
_School of Electrical and Information Engineering, University of the Witwatersrand, Johannesburg, South Africa_  
Email: [mitchell.cox@wits.ac.za](mailto:mitchell.cox@wits.ac.za)  
Homepage: [https://www.wits.ac.za/oclab](https://www.wits.ac.za/oclab)

**Carmelo Rosales-Guzmán**  
_Centro de Investigaciones en Óptica, A. C., Loma del Bosque 115, Col. Lomas del Campestre, 37150, León, Gto., México_

---

## Abstract

This lab note introduces the "Stokes Camera," a simple and novel experimental arrangement for real-time measurement of spatial amplitude and polarisation, leading to spatially resolved Stokes parameters. This setup uses a polarisation sensitive camera combined with a fixed quarter-wave plate. This offers a one-shot, digital solution for polarisation measurement that mainly depends on the camera's frame rate and the computation speed of the associated code. Moreover, this document provides background information on relevant polarisation theory and vector vortex beams, employed as an exemplification of the device's capabilities.

---

## Table of Contents

- [Getting Started](#getting-started)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Getting Started

Some instructions and details are provided in the associated journal paper (citation TBD).

1. Create a video object using the MATLAB Image Acquisition Toolbox. Make note of the important line of code, which is something like v = videoinput("gige", 1, "Mono12Packed");
2. While you have a preview window open (with the toolbox, or call preview(v); after creating the video object), make sure the two halves of the beam are visible on the camera.
3. Simply call CameraPreviewStokes(v); 

**Note:** The first run will take a few minutes while the code finds the overlap between the halves of the beam. Don't change the alignment from the beamsplitter onwards after this point.

Please feel free the check out the code. It's quite straight forward. There are additional options to use, such as a moving average of a number of frames. This helps with alignment with a moving beam (such as in turbulence).

If you make enhancements, changes, etc. that will benefit the community, please fork this repository, commit your changes to your own repo and then send us a pull request!

### Creating "Stokes Plots"

Please see the file StokesPlot.m. When viewing the CameraPreviewStokes, hit 'p' on your keyboard and it will dump a timestamped .mat file with the various polaristion and stokes matrices. These can be input and plot as you desire.

---

## License

This project is licensed under the MIT License. For more details, see the LICENSE file.

---

## Acknowledgements

Thanks to Cade Ribiero from the Wits Structured Light Lab for initial testing and feedback.

