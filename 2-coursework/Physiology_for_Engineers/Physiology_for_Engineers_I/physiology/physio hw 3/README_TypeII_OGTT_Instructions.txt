================================================================================
TYPE II DIABETES OGTT SIMULATION - FILES FOR LAB REPORT
================================================================================

This folder contains all the files you need for the Type II diabetes OGTT
simulation section of your lab report.

================================================================================
FILES TO USE IN YOUR LAB REPORT:
================================================================================

1. Code_TypeII_OGTT_for_Lab_Report.m
   - Clean, well-formatted MATLAB code ready to copy and paste into your report
   - Includes all simulation parameters and plotting code
   - Properly commented and organized
   - Calculates return times to 2.0 mg/ml and 1.4 mg/ml

2. TypeII_OGTT_Results.txt (will be generated after running simulation)
   - Complete analysis and answers to questions
   - Simulation parameters
   - Results and statistics
   - Answers to specific questions:
     * How long for glucose to return to 2.0 mg/ml?
     * How long for glucose to return to 1.4 mg/ml?
   - Analysis comparing Type II diabetes OGTT to normal OGTT
   - Interpretation and conclusions
   - Ready to copy into your lab report

3. GLUINSMODEL_TypeII_OGTT.png (will be generated after running simulation)
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
   >> run_TypeII_OGTT
   
This will:
   1. First determine the fasting glucose and insulin levels for Type II diabetes
   2. Use those fasting levels as initial conditions for the OGTT
   3. Configure the pulse generator for OGTT (75 gm glucose, 30 min)
   4. Run the 10-hour simulation
   5. Calculate return times to 2.0 mg/ml and 1.4 mg/ml
   6. Generate plots and results file

Generated files:
   - GLUINSMODEL_TypeII_OGTT.png (plot with all graphs)
   - GLUINSMODEL_TypeII_OGTT_data.mat (data file)
   - TypeII_OGTT_Results.txt (analysis and answers)

================================================================================
SIMULATION PARAMETERS USED:
================================================================================

Step 1: Determine Fasting Levels
- Initial Glucose: 0.8 mg/ml (80 mg/dL)
- Initial Insulin: 0.057 IU/ml
- Type 1 Severity Gain: 0.6 (reduced insulin production)
- Type 2 Severity Gain: 0.4 (insulin resistance)
- QL: 8400 mg/hr
- Pulse Amplitude: 0 (fasting)
- Result: Fasting glucose and insulin levels are calculated

Step 2: OGTT Configuration
- Initial Glucose: [Fasting level from Step 1] mg/ml
- Initial Insulin: [Fasting level from Step 1] IU/ml
- Type 1 Severity Gain: 0.6 (reduced insulin production)
- Type 2 Severity Gain: 0.4 (insulin resistance)
- QL: 8400 mg/hr
- OGTT Glucose Dose: 75 gm (7.5E4 mg)
- Pulse Period: 10 hours
- Pulse Amplitude: 7.5E4 mg
- Pulse Width: 5% (30 minutes)

================================================================================
QUESTIONS ANSWERED:
================================================================================

c. How long did it take for the blood sugar to return to 2.0 mg/ml?
   Answer: See TypeII_OGTT_Results.txt for the calculated time

c. How long did it take for the blood sugar to return to 1.4 mg/ml?
   Answer: See TypeII_OGTT_Results.txt for the calculated time

These answers are calculated automatically from the peak glucose value and
marked on the plot.

================================================================================
INSTRUCTIONS FOR LAB REPORT:
================================================================================

1. Copy the code from "Code_TypeII_OGTT_for_Lab_Report.m" into your 
   Methods/Procedure section
   - Note that the code first determines fasting levels, then uses them
     as initial conditions for the OGTT

2. Insert the plot "GLUINSMODEL_TypeII_OGTT.png" into your Results section
   - The plot shows glucose, insulin, and urine glucose responses
   - Markers indicate when glucose returns to 2.0 mg/ml and 1.4 mg/ml

3. Copy relevant sections from "TypeII_OGTT_Results.txt" into your:
   - Results section (numerical values and answers)
   - Discussion section (analysis and interpretation)
   - Conclusion section (conclusions)

4. Make sure to explain:
   - How fasting levels were determined first
   - The OGTT protocol (75 gm glucose, rapid absorption)
   - The impaired glucose tolerance in Type II diabetes
   - Comparison with normal OGTT results
   - The time to return to baseline levels

================================================================================
KEY DIFFERENCES FROM NORMAL OGTT:
================================================================================

- Higher peak glucose due to reduced insulin production and insulin resistance
- Slower glucose clearance
- Longer time to return to baseline levels
- Impaired glucose tolerance characteristic of Type II diabetes
- May not return to baseline within 10 hours (persistent hyperglycemia)

================================================================================
NOTES:
================================================================================

- The script automatically determines fasting levels first, then uses them
  as initial conditions for the OGTT
- Return times are calculated from the peak glucose value
- If glucose doesn't return to the target level within 10 hours, this is noted
- Times are reported in both hours and minutes for convenience
- The answers will be automatically calculated and formatted for your report

================================================================================

