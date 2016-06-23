Instructions for herbivory code usage

This program measures herbivory on the leaves collected for the CHAMBASA project. After analysis it produces a CSV file that includes estimates of:

- total leaf area before herbivory (cm^2)
- leaf area consumed (cm^2)
- leaf area allocated to various damage types (e.g. galls, mines)

The program requires input of an image of one to several leaves scanned against a white background. The leaves may be simple, compound, and/or be cut into multiple pieces. To set up the program, follow these instructions:

1) Copy the 'herbivory_MATLAB' folder to your computer
2) Add the 'herbivory_MATLAB' directory to your MATLAB path (under File > Save Path in the MATLAB interface)
3) Open the 'log_herbivory.m' file. On line 2, confirm the resolution of the scanned image (default, 300 dpi) and the types of specialized damage to be assayed (default, mining and galls).

The program is now ready to use. To begin analyzing images,

1) set the working directory to where your images are found (e.g. by running 'cd ~/Desktop/myimages/' from the MATLAB command line
2) run the log_herbivory command, e.g. 'log_herbivory('WAY01-T831-B2S-HA-5-A1.jpg','out.csv',1)' - this command will analyze an image called WAY01-T831-B2S-HA-5-A1.jpg in the current directory and save the analysis output to a file called out.csv.

The program proceeds through the following steps:
1) The selected image is shown to the user. The user uses the polygon tool to select a non-rectangular region that includes one of the leaves and any areas that have been eaten. The intent is to crop the overall image to include only one leaf. The user does NOT need to exactly trace the lamina and in fact should not.
2) The cropped leaf is then shown to the user, alone, and surrounded by a padded white background. The user uses the polygon tool to draw a polygon that exactly traces the uneaten lamina of the leaf (i.e. including empty areas that have been eaten). After drawing one polygon, the user is permitted to draw further polygons. This allows for the leaf to be composed of multiple disjunct sections, e.g. a large leaf cut into pieces or a compound leaf with leaflets that have been pulled off.
3) The inferred leaf lamina is shown to the user in the right panel of the window.
4) The computer then thresholds the image using an automatic Otsu (variance-maximizing) threshold to determine the area of leaf that is observed to still exist. This thresholded image is overlaid on the inferred leaf lamina. Light-colored regions are areas that were not herbivorized; medium-colored regions are areas that were herbivorized, and dark regions are areas of error (where the inferred lamina is smaller than the thresholded image).
5) the user is allowed to change the auto-threshold to include more or less of the leaf in the analysis. When the user is satisfied, they press 'OK". If the image cannot be thresholded easily (i.e. needs hand-adjustment of contrast, for example very reflective leaves) the user presses cancel and the analysis is aborted and the logfile receives 'NaN' measurements.
6) Once the threshold is determined, the computer automatically calculates the total leaf area and herbivorized area. 
7) The user is then asked to determine any specialized damage types (as defined in the header of the analysis code). If the user says that the damage type exists, they are allowed to draw multiple polygons on the leaf image which reflect the areas of damage. 
8) After delineating all areas of damage, the program calculates automatically the area allocated to each damage type.
9) The program returns to the original multi-leaf image and erases the leaf that has already been analyzed. The program then repeats from the beginning allowing the user to select the next leaf.
10) After all leaves have been analyzed, the program completes. A logfile is created with the areas allocated to each kind of damage, and the segmented images for each leaf (indicating each damage type) are also saved in the same directory as the original images.