================================================================================
OGTT SIMULATION - FILES FOR LAB REPORT
================================================================================

This folder contains all the files you need for the Oral Glucose Tolerance Test
(OGTT) simulation section of your lab report.

================================================================================
FILES TO USE IN YOUR LAB REPORT:
================================================================================

1. Code_OGTT_for_Lab_Report.m
   - Clean, well-formatted MATLAB code ready to copy and paste into your report
   - Includes all simulation parameters and plotting code
   - Properly commented and organized
   - Calculates return times to 2.0 mg/ml and 1.4 mg/ml

2. OGTT_Results.txt (will be generated after running simulation)
   - Complete analysis and answers to questions
   - Simulation parameters
   - Results and statistics
   - Answers to specific questions:
     * How long for glucose to return to 2.0 mg/ml?
     * How long for glucose to return to 1.4 mg/ml?
   - Interpretation and conclusions
   - Ready to copy into your lab report

3. GLUINSMODEL_OGTT.png (will be generated after running simulation)
   - High-quality plot showing:
     * Blood glucose vs time
     * Plasma insulin vs time
     * Urine glucose vs time (if available)
   - Markers showing return times to 2.0 mg/ml and 1.4 mg/ml
   - Properly labeled axes and titles
   - Ready to insert into your lab report

================================================================================
HOW TO GENERATE THE OUTPUT FILES:
================================================================================

In MATLAB, run:
   >> run_OGTT_simulation
   
This will generate:
   - GLUINSMODEL_OGTT.png (plot with all three graphs)
   - GLUINSMODEL_OGTT_data.mat (data file)
   - OGTT_Results.txt (analysis and answers)

================================================================================
SIMULATION PARAMETERS USED:
================================================================================

- Simulation Time: 10 hours
- Initial Blood Glucose: 0.81 mg/ml (81 mg/dL)
- Initial Insulin Level: 0.057 IU/ml
- Type 1 Severity Gain: 1 (normal insulin production)
- Type 2 Severity Gain: 1 (normal insulin sensitivity)
- QL (Liver Glucose Production): 8400 mg/hr
- OGTT Glucose Dose: 75 gm (7.5E4 mg)
- Pulse Generator Settings:
  * Period: 10 hours
  * Amplitude: 7.5E4 mg
  * Pulse Width: 5% (30 minutes)
  * Phase Delay: 0 (starts immediately)

================================================================================
QUESTIONS ANSWERED:
================================================================================

1. How long did it take for blood glucose to return to 2.0 mg/ml?
   Answer: See OGTT_Results.txt for the calculated time

2. How long did it take for blood glucose to return to 1.4 mg/ml?
   Answer: See OGTT_Results.txt for the calculated time

These answers are calculated automatically and marked on the plot.

================================================================================
INSTRUCTIONS FOR LAB REPORT:
================================================================================

1. Copy the code from "Code_OGTT_for_Lab_Report.m" into your Methods/Procedure section

2. Insert the plot "GLUINSMODEL_OGTT.png" into your Results section
   - The plot shows glucose, insulin, and urine glucose responses
   - Markers indicate when glucose returns to 2.0 mg/ml and 1.4 mg/ml

3. Copy relevant sections from "OGTT_Results.txt" into your:
   - Results section (numerical values and answers)
   - Discussion section (analysis and interpretation)
   - Conclusion section (conclusions)

4. Make sure to explain:
   - The OGTT protocol (75 gm glucose, rapid absorption)
   - The glucose response curve
   - The insulin response
   - The time to return to baseline levels

================================================================================
NOTES:
================================================================================

- The pulse generator simulates rapid glucose absorption over 30 minutes
- Return times are calculated from the peak glucose value
- If glucose doesn't return to the target level within 10 hours, this is noted
- Urine glucose may not be available in all model versions

================================================================================

