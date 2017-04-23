function dSVdt = PorousCatComb_func(~,SV,params,phases,ptr)
%
%...Initialize time derivative of solution vector:
dSVdt = zeros(size(SV));
%
surf = phases.surf;
gas = phases.gas;
%
%...Step through each grid point and calculate net production rates and
%       species fluxes:
for i = 1:params.n_grid
    offset = (i-1)*params.nVars;
    
    X_gas = SV(offset+ptr.X_gas);
    Theta = SV(offset+ptr.theta_surf);
    set(gas,'T',params.T_reactor,'P',params.p,'X',X_gas);
    C_g = molarDensity(gas);
    setTemperature(surf,params.T_reactor);
    setCoverages(surf,Theta)
    %
    %...Heterogeneous surface reaction rates:
    sdot_surf = netProdRates(surf);
    %
    %...Homogeneous gas-phase reaction rates:
    sdot_gas = netProdRates(gas);
    %
    omega_surf_k = sdot_surf(params.nsp_gas+1:end);
    omega_gas_k = sdot_surf(1:params.nsp_gas);
    %    
    dSVdt(offset+ptr.theta_surf) = omega_surf_k/molarDensity(surf);
    dSVdt(offset+ptr.X_gas) = (sdot_gas + ...
        omega_gas_k*params.a_surf/params.phi_g)/C_g;
end