% Powder magic angle spinning spectrum of a pair of dipole-coupled
% quadrupolar nuclei; this is apparently something that other simu-
% lation packages cannot do. Parameters from Jeongjae Lee.
%
% Calculation time: seconds
%
% i.kuprov@soton.ac.uk

function mas_powder_dip_nqi()

% System specification
sys.magnet=9.4;
sys.isotopes={'23Na','17O'};

% Interactions
inter.coordinates={[2.602  8.750  3.651];
                   [4.401 10.184  4.371]};                    
inter.coupling.matrix{1,1}=castep2nqi([-0.0497  0.0520 -0.0019
                                        0.0520  0.0315  0.0027
                                       -0.0019  0.0027  0.0182],+0.1040,3/2);
inter.coupling.matrix{2,2}=castep2nqi([ 0.1580  0.0340 -0.5562
                                        0.0340 -0.6005  0.0586
                                       -0.5562  0.0586  0.4425],-0.0258,5/2);

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';
bas.projections=+1;

% Enable GPU
sys.enable={'gpu'};

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Experiment setup
parameters.rate=100000;
parameters.axis=[sqrt(2/3) 0 sqrt(1/3)];
parameters.max_rank=30;
parameters.grid='rep_2ang_200pts_sph';
parameters.sweep=5e6;
parameters.npoints=1024;
parameters.zerofill=4096;
parameters.offset=0;
parameters.spins={'17O'};
parameters.decouple={};
parameters.axis_units='MHz';
parameters.invert_axis=1;
parameters.rho0=state(spin_system,'L+','17O');
parameters.coil=state(spin_system,'L+','17O');
parameters.verbose=0;

% Simulation
fid=singlerot(spin_system,@acquire,parameters,'nmr');

% Apodization
fid=apodization(fid,'exp-1d',6);

% Fourier transform
spectrum=fftshift(fft(fid,parameters.zerofill));

% Plotting
figure(); plot_1d(spin_system,real(spectrum),parameters);

end

