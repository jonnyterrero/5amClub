================================================================================
TYPE II DIABETES SIMULATION - FILES FOR LAB REPORT
================================================================================

This folder contains all the files you need for the Type II diabetes simulation
section of your lab report.

================================================================================
FILES TO USE IN YOUR LAB REPORT:
================================================================================

1. Code_TypeII_Diabetes_for_Lab_Report.m
   - Clean, well-formatted MATLAB code ready to copy and paste into your report
   - Includes all simulation parameters and plotting code
   - Properly commented and organized
   - Displays final fasting glucose and insulin levels

2. TypeII_Diabetes_Results.txt (will be generated after running simulation)
   - Complete analysis and results
   - Simulation parameters
   - Results and statistics
   - Final fasting glucose and insulin levels (key findings)
   - Analysis and interpretation
   - Comparison with normal adult
   - Clinical significance
   - Ready to copy into your lab report

3. GLUINSMODEL_TypeII_Diabetes.png (will be generated after running simulation)
   - High-quality plot showing:
     * Blood glucose vs time
     * Plasma insulin vs time
   - Markers showing initial and final values
   - Properly labeled axes and titles
   - Ready to insert into your lab report

================================================================================
HOW TO GENERATE THE OUTPUT FILES:
================================================================================

In MATLAB, run:
   >> run_TypeII_Diabetes
   
This will generate:
   - GLUINSMODEL_TypeII_Diabetes.png (plot)
   - GLUINSMODEL_TypeII_Diabetes_data.mat (data file)
   - TypeII_Diabetes_Results.txt (analysis and results)

================================================================================
SIMULATION PARAMETERS USED:
================================================================================

- Simulation Time: 10 hours
- Initial Blood Glucose: 0.8 mg/ml (80 mg/dL)
- Initial Insulin Level: 0.057 IU/ml
- Type 1 Severity Gain (Insulin Production): 0.6 (reduced - 60% of normal)
- Type 2 Severity Gain (Insulin Sensitivity): 0.4 (insulin resistance - 40% of normal)
- QL (Liver Glucose Production): 8400 mg/hr
- Pulsed Glucose Injection Amplitude: 0 (fasting conditions)

================================================================================
KEY FINDINGS:
================================================================================

The final glucose and insulin levels after 10 hours of fasting represent good
approximations of the fasting levels for this Type II diabetic patient:

- Final Glucose (Fasting): [Calculated value] mg/ml
- Final Insulin (Fasting): [Calculated value] IU/ml

These values are automatically calculated and displayed in:
- The MATLAB command window
- The TypeII_Diabetes_Results.txt file
- Marked on the plot

================================================================================
INSTRUCTIONS FOR LAB REPORT:
================================================================================

1. Copy the code from "Code_TypeII_Diabetes_for_Lab_Report.m" into your 
   Methods/Procedure section

2. Insert the plot "GLUINSMODEL_TypeII_Diabetes.png" into your Results section
   - The plot shows glucose and insulin responses over 10 hours
   - Initial and final values are marked

3. Copy relevant sections from "TypeII_Diabetes_Results.txt" into your:
   - Results section (numerical values, especially final fasting levels)
   - Discussion section (analysis and interpretation)
   - Conclusion section (conclusions)

4. Make sure to highlight:
   - The final fasting glucose and insulin levels
   - How these differ from normal adult values
   - The effects of reduced insulin production (0.6) and insulin resistance (0.4)
   - Clinical significance of elevated fasting glucose

================================================================================
NOTES:
================================================================================

- Type II diabetes is characterized by:
  * Reduced insulin production (Type 1 gain = 0.6 = 60% of normal)
  * Insulin resistance (Type 2 gain = 0.4 = 40% sensitivity)
  
- The simulation runs under fasting conditions (no glucose injection)

- The final values represent the steady-state fasting metabolic state

- Elevated fasting glucose is a key diagnostic criterion for diabetes

================================================================================

