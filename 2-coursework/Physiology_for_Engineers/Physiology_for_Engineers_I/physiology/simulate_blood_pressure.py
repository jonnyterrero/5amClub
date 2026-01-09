#!/usr/bin/env python3
"""
Blood Pressure Simulation - Python implementation of the MATLAB code
This simulates the cardiovascular dynamics and generates results
"""

import numpy as np
import matplotlib.pyplot as plt
import math

def qao_now(t, T, TS, TMAX, QMAX):
    """Calculate aortic flow at time t (equivalent to QAo_now.m)"""
    tc = t % T  # Time elapsed since beginning of current cycle
    
    if tc < TS:  # SYSTOLE
        if tc < TMAX:  # BEFORE TIME OF MAXIMUM FLOW
            return QMAX * tc / TMAX
        else:  # AFTER TIME OF PEAK FLOW
            return QMAX * (TS - tc) / (TS - TMAX)
    else:  # DIASTOLE
        return 0

def psa_new(psa_old, qao, Rs, Csa, dt):
    """Update blood pressure using Euler's method (equivalent to Psa_new.m)"""
    return (psa_old + dt * qao / Csa) / (1 + dt / (Rs * Csa))

def run_simulation():
    """Run the blood pressure simulation"""
    
    # Simulation parameters (from in_sa.m)
    T = 0.0125  # Duration of heartbeat (minutes) -> 80 beats/min
    TS = 0.4 * T  # Duration of systole (minutes)
    TMAX = 0.16 * T  # Time at which flow is max (minutes)
    QMAX = 28  # Max flow through aortic valve (liters/minute)
    Rs = 17.86  # Systemic resistance (mmHg/(liter/minute))
    Csa = 0.0012  # Systemic arterial compliance (liters/mmHg) - adjusted for 120/80
    
    dt = 0.01 * T  # Time step duration (minutes)
    klokmax = math.ceil(16 * T / dt)  # Total number of timesteps (16 cardiac cycles)
    Psa = 80  # Starting (diastolic) value of arterial pressure (mmHg)
    
    # Initialize arrays
    t_plot = np.zeros(klokmax)
    QAo_plot = np.zeros(klokmax)
    Psa_plot = np.zeros(klokmax)
    
    # Run simulation
    print("Running blood pressure simulation...")
    print("=" * 40)
    
    for klok in range(klokmax):
        t = (klok + 1) * dt
        QAo = qao_now(t, T, TS, TMAX, QMAX)
        Psa = psa_new(Psa, QAo, Rs, Csa, dt)
        
        # Store values
        t_plot[klok] = t
        QAo_plot[klok] = QAo
        Psa_plot[klok] = Psa
    
    # Calculate cardiac output
    cycles_to_use = 4
    cycle_length = round(T / dt)
    start_idx = klokmax - cycles_to_use * cycle_length
    cardiac_output = np.mean(QAo_plot[start_idx:])
    
    # Calculate blood pressure statistics
    max_pressure = np.max(Psa_plot)
    min_pressure = np.min(Psa_plot)
    mean_pressure = np.mean(Psa_plot)
    pulse_pressure = max_pressure - min_pressure
    
    # Create plots
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
    
    # Aortic flow plot
    ax1.plot(t_plot, QAo_plot, 'b-', linewidth=2)
    ax1.set_xlabel('TIME - minutes')
    ax1.set_ylabel('Aortic Flow (L/min)')
    ax1.set_title('Aortic Flow')
    ax1.grid(True)
    
    # Blood pressure plot
    ax2.plot(t_plot, Psa_plot, 'r-', linewidth=2)
    ax2.set_xlabel('TIME - Minutes')
    ax2.set_ylabel('Blood Pressure - mmHg')
    ax2.set_title('Arterial Blood Pressure')
    ax2.grid(True)
    ax2.set_ylim([min_pressure - 10, max_pressure + 10])
    
    plt.tight_layout()
    plt.savefig('simulation_results.png', dpi=300, bbox_inches='tight')
    plt.show()
    
    # Generate results text file
    with open('simulation_summary.txt', 'w') as f:
        f.write('BLOOD PRESSURE SIMULATION RESULTS\n')
        f.write('=' * 35 + '\n\n')
        
        f.write('SIMULATION PARAMETERS:\n')
        f.write(f'Heart Rate: {1/T:.1f} beats/min\n')
        f.write(f'Systolic Duration: {TS:.4f} minutes ({TS/T*100:.1f}% of cycle)\n')
        f.write(f'Max Flow Time: {TMAX:.4f} minutes\n')
        f.write(f'Max Aortic Flow: {QMAX:.1f} L/min\n')
        f.write(f'Systemic Resistance: {Rs:.2f} mmHg/(L/min)\n')
        f.write(f'Arterial Compliance: {Csa:.4f} L/mmHg\n')
        f.write(f'Time Step: {dt:.6f} minutes\n')
        f.write(f'Total Simulation Time: {max(t_plot):.3f} minutes\n')
        f.write(f'Number of Cardiac Cycles: {max(t_plot)/T:.1f}\n\n')
        
        f.write('BLOOD PRESSURE RESULTS:\n')
        f.write(f'Systolic Pressure: {max_pressure:.1f} mmHg\n')
        f.write(f'Diastolic Pressure: {min_pressure:.1f} mmHg\n')
        f.write(f'Mean Arterial Pressure: {mean_pressure:.1f} mmHg\n')
        f.write(f'Pulse Pressure: {pulse_pressure:.1f} mmHg\n\n')
        
        # Check if target achieved
        if abs(max_pressure - 120) < 5 and abs(min_pressure - 80) < 5:
            f.write('TARGET ACHIEVED: Blood pressure is close to 120/80 mmHg!\n')
        else:
            f.write('NOTE: Blood pressure is not exactly 120/80 mmHg\n')
            f.write('Consider adjusting compliance (Csa) in in_sa.m\n')
        f.write('\n')
        
        f.write('CARDIAC OUTPUT:\n')
        f.write(f'Cardiac Output: {cardiac_output:.2f} L/min\n\n')
        
        f.write('COMPLIANCE ADJUSTMENT NOTES:\n')
        f.write(f'Current compliance: {Csa:.4f} L/mmHg\n')
        f.write('To increase blood pressure: DECREASE compliance (make arteries stiffer)\n')
        f.write('To decrease blood pressure: INCREASE compliance (make arteries more flexible)\n\n')
        
        f.write('SIMULATION COMPLETED SUCCESSFULLY\n')
        f.write('Results saved to: simulation_results.png\n')
    
    # Print results to console
    print(f"\nSIMULATION RESULTS:")
    print(f"==================")
    print(f"Systolic Pressure: {max_pressure:.1f} mmHg")
    print(f"Diastolic Pressure: {min_pressure:.1f} mmHg")
    print(f"Mean Arterial Pressure: {mean_pressure:.1f} mmHg")
    print(f"Pulse Pressure: {pulse_pressure:.1f} mmHg")
    print(f"Cardiac Output: {cardiac_output:.2f} L/min")
    print(f"\nTarget: 120/80 mmHg")
    if abs(max_pressure - 120) < 5 and abs(min_pressure - 80) < 5:
        print("✅ TARGET ACHIEVED!")
    else:
        print("⚠️  Consider adjusting compliance for exact target")
    
    print(f"\nResults saved to:")
    print(f"- simulation_summary.txt")
    print(f"- simulation_results.png")
    
    return {
        'systolic': max_pressure,
        'diastolic': min_pressure,
        'mean_pressure': mean_pressure,
        'pulse_pressure': pulse_pressure,
        'cardiac_output': cardiac_output,
        'compliance': Csa
    }

if __name__ == "__main__":
    results = run_simulation()
