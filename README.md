[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20210715.svg)](https://doi.org/10.5281/zenodo.20210715)

# Webcam-Based Saccade and Anti-Saccade Eye Tracking in MATLAB

MATLAB implementation of **Saccade** and **Anti-Saccade** eye movement tasks using a standard webcam and computer vision algorithms.

This repository provides a simple framework for conducting **eye-movement behavioral experiments** without specialized eye-tracking hardware.

The system detects gaze direction (left, right, center) using face and eye detection and measures **reaction time** and **response accuracy** during visual stimulus tasks.

---

# Author

**Negar Rahimi**

---

# Overview

This project implements two classical oculomotor tasks widely used in neuroscience and psychology.

### Saccade Task
Participants move their gaze **toward** a visual target appearing on the screen.

### Anti-Saccade Task
Participants must **look in the opposite direction** of the visual target.

These tasks are commonly used to study:

- Cognitive control  
- Attention  
- Executive function  
- Oculomotor control  
- Neurological disorders  

---

# Features

- Webcam-based eye tracking  
- Face detection using MATLAB Computer Vision Toolbox  
- Eye region extraction  
- Gaze direction classification  
- Reaction time measurement  
- Response accuracy calculation  
- MATLAB GUI interface  
- Calibration procedure for gaze directions  

---

# Calibration Procedure

Before running the tasks, the system captures calibration images for three gaze directions:

- Left gaze  
- Right gaze  
- Center gaze  

These calibration images are used as **templates for gaze direction detection** during the experiment.

---

# Participant Instructions

Participants should:

1. Sit approximately **50–70 cm from the webcam**
2. Keep their **head relatively stable**
3. Maintain a **steady distance from the webcam**
4. **Follow the visual markers displayed on the screen**

Good lighting and a clearly visible face improve detection accuracy.

---

# Requirements

MATLAB **R2020 or newer** is recommended.

Required toolboxes:

- Computer Vision Toolbox
- Image Processing Toolbox
- MATLAB Support Package for USB Webcams

---

# Repository Structure
