================================================================================
OGTT DIAGNOSTIC ANALYSIS - INSTRUCTIONS
================================================================================

This analysis answers questions about sensitivity, specificity, and diagnostic
criteria for diabetes testing.

================================================================================
FILES:
================================================================================

1. analyze_OGTT_diagnosis.m
   - Script that runs both normal and Type II diabetes OGTT simulations
   - Extracts glucose values at 1 hour and 2 hours
   - Compares results to diagnostic criteria
   - Generates comprehensive written answers to all questions

2. OGTT_Diagnostic_Analysis_Answers.txt (generated after running script)
   - Complete written answers to all questions:
     * Question 5a: Glucose values at 1 hour and 2 hours for normal vs diabetic
     * Question 5b: Whether OGTT indicates diabetes
     * Question 5c: Definitions of sensitivity and specificity
     * Question 5d: Which test is more sensitive (fasting vs OGTT)
     * Question 5e: Which test has more false negatives
   - Ready to copy into your lab report

================================================================================
HOW TO RUN:
================================================================================

In MATLAB, run:
   >> analyze_OGTT_diagnosis

This will:
   1. Run normal adult OGTT simulation
   2. Run Type II diabetes fasting simulation to get baseline
   3. Run Type II diabetes OGTT simulation
   4. Extract glucose values at 1 hour and 2 hours
   5. Compare to diagnostic criteria
   6. Generate comprehensive written answers
   7. Save all answers to OGTT_Diagnostic_Analysis_Answers.txt

================================================================================
QUESTIONS ANSWERED:
================================================================================

5a. What were the glucose values at 1 hour and 2 hours for normal vs diabetic OGTT?
    - Provides exact values from simulations
    - Compares to diagnostic criteria (2.0 mg/ml at 1 hr, 1.4 mg/ml at 2 hr)
    - Indicates whether each test is positive or negative

5b. Do the OGTT results indicate diabetes?
    - Analyzes fasting glucose vs OGTT results
    - Determines if OGTT detects diabetes when fasting test does not
    - Explains clinical significance

5c. Review definitions of sensitivity and specificity
    - Comprehensive definitions with formulas
    - Examples and clinical significance
    - Relationship between sensitivity/specificity and false positives/negatives

5d. Which test is more sensitive (fasting vs OGTT)?
    - Compares test results from simulations
    - Explains why OGTT is more sensitive
    - Provides evidence from simulation data

5e. Which test has more false negatives?
    - Explains relationship between sensitivity and false negatives
    - Applies to fasting vs OGTT comparison
    - Discusses clinical implications

================================================================================
DIAGNOSTIC CRITERIA USED:
================================================================================

OGTT Positive Criteria:
  - 1 hour glucose >= 2.0 mg/ml (200 mg/dL), OR
  - 2 hour glucose >= 1.4 mg/ml (140 mg/dL)

ADA Fasting Blood Sugar Criteria:
  - Fasting glucose >= 1.26 mg/ml (126 mg/dL) on two separate mornings

================================================================================
KEY CONCEPTS:
================================================================================

Sensitivity:
  - Ability to correctly identify people WITH the disease
  - High sensitivity = Few false negatives
  - Formula: TP / (TP + FN)

Specificity:
  - Ability to correctly identify people WITHOUT the disease
  - High specificity = Few false positives
  - Formula: TN / (TN + FP)

False Negatives:
  - More common in LESS sensitive tests
  - Less common in MORE sensitive tests

================================================================================

