@echo off
set xv_path=D:\\vivado\\Vivado\\2017.1\\bin
call %xv_path%/xsim single_cycle_cpu_sim_behav -key {Behavioral:sim_1:Functional:single_cycle_cpu_sim} -tclbatch single_cycle_cpu_sim.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
