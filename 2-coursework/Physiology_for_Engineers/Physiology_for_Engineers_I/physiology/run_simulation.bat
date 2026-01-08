@echo off
echo Running Blood Pressure Simulation...
echo ====================================

cd "Blood Pressure"
matlab -nosplash -nodesktop -r "run_and_save_results; exit"

echo.
echo Simulation completed!
echo Check the following files for results:
echo - simulation_plots.png
echo - simulation_plots.pdf  
echo - detailed_results.txt
echo.
pause
