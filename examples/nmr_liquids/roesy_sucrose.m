% ROESY spectrum of sucrose (magnetic parameters computed with DFT).
%
% Calculation time: minutes
%
% i.kuprov@soton.ac.uk

function roesy_sucrose()

% Spin system properties (vacuum DFT calculation)
options.min_j=1.0;
[sys,inter]=g2spinach(gparse('../standard_systems/sucrose.log'),...
                                     {{'H','1H'}},31.8,options);
% Magnet field
sys.magnet=5.9;

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='IK-2';
bas.connectivity='scalar_couplings';
bas.space_level=3;

% Relaxation theory parameters
inter.relaxation={'redfield'};
inter.equilibrium='zero';
inter.rlx_keep='secular';
inter.tau_c={200e-12};

% Algorithmic options
sys.enable={'greedy'};
sys.disable={'krylov'};
sys.tols.prox_cutoff=4.0;

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Sequence parameters
parameters.tmix=0.5;
parameters.offset=800;
parameters.sweep=[1700 1700];
parameters.npoints=[512 512];
parameters.zerofill=[2048 2048];
parameters.spins={'1H'};
parameters.axis_units='ppm';
parameters.rho0=state(spin_system,'Lz','1H');

% Simulation
fid=liquid(spin_system,@roesy,parameters,'nmr');

% Apodization
fid.cos=apodization(fid.cos,'sqcosbell-2d');
fid.sin=apodization(fid.sin,'sqcosbell-2d');

% F2 Fourier transform
f1_cos=imag(fftshift(fft(fid.cos,parameters.zerofill(2),1),1));
f1_sin=real(fftshift(fft(fid.sin,parameters.zerofill(2),1),1));

% States signal
f1_states=f1_cos-1i*f1_sin;

% F1 Fourier transform
spectrum=fftshift(fft(f1_states,parameters.zerofill(1),2),2);

% Plotting
figure(); scale_figure([1.5 2.0]);
plot_2d(spin_system,real(spectrum),parameters,...
        20,[0.01 0.1 0.01 0.1],2,256,6,'both');

end

