function [t, y, ystd, tExp, yExp, yExpStd, lb, ub, ...
    yExpHl, dydt, y_ssa, y_ssa_lb, y_ssa_ub, qFit] = arGetData(jm, jd, jtype)

global ar

% SSA
if(jtype==1)
    if(isfield(ar.model(jm).data(jd),'yFineSSA'))
        y_ssa = ar.model(jm).data(jd).yFineSSA;
    else
        y_ssa = nan;
    end
    if(isfield(ar.model(jm).data(jd),'yFineSSA_lb'))
        y_ssa_lb = ar.model(jm).data(jd).yFineSSA_lb;
    else
        y_ssa_lb = nan;
    end
    if(isfield(ar.model(jm).data(jd),'yFineSSA_ub'))
        y_ssa_ub = ar.model(jm).data(jd).yFineSSA_ub;
    else
        y_ssa_ub = nan;
    end
    
elseif(jtype==2)
    % TODO implement x and z SSA
    y_ssa = nan;
    y_ssa_lb = nan;
    y_ssa_ub = nan;
    
elseif(jtype==3)
    y_ssa = nan;
    y_ssa_lb = nan;
    y_ssa_ub = nan;
    
end

jc = ar.model(jm).data(jd).cLink;

% trajectories and error bands
if(isfield(ar.model(jm).data(jd),'tFine'))
    if(jtype==1)
        t = ar.model(jm).data(jd).tFine;
        y = ar.model(jm).data(jd).yFineSimu;
        ystd = ar.model(jm).data(jd).ystdFineSimu;
        
    elseif(jtype==2)
        t = ar.model(jm).condition(jc).tFine;
        y = [ar.model(jm).condition(jc).uFineSimu ar.model(jm).condition(jc).xFineSimu ...
            ar.model(jm).condition(jc).zFineSimu];
        ystd = [];
        
    elseif(jtype==3)
        t = ar.model(jm).condition(jc).tFine;
        y = ar.model(jm).condition(jc).vFineSimu;
        ystd = [];
        
    end
else
    t = nan;
    y = nan;
    ystd = nan;
end

% data
if(jtype==1 && isfield(ar.model(jm).data(jd), 'yExp') && ~isempty(ar.model(jm).data(jd).yExp))
    tExp = ar.model(jm).data(jd).tExp;
    yExp = ar.model(jm).data(jd).yExp;
    if(ar.config.fiterrors == -1)
        yExpStd = ar.model(jm).data(jd).yExpStd;
    else
        if(isfield(ar.model(jm).data(jd),'ystdExpSimu'))
            yExpStd = ar.model(jm).data(jd).ystdExpSimu;
        else
            yExpStd = nan;
        end
    end
    if(isfield(ar.model(jm).data(jd),'highlight'))
        hl = ar.model(jm).data(jd).highlight;
    else
        hl = zeros(size(yExp));
    end
    yExpHl = yExp;
    yExpHl(hl==0) = NaN;
    qFit = ~isfield(ar.model(jm).data(jd),'qFit') | ...
        ar.model(jm).data(jd).qFit;
else
    tExp = [];
    yExp = [];
    yExpStd = [];
    yExpHl = [];
    qFit = [];
end

% confidence bands
lb = [];
ub = [];
if(jtype==1)
    if(isfield(ar.model(jm).data(jd), 'yFineLB'))
        lb = ar.model(jm).data(jd).yFineLB;
        ub = ar.model(jm).data(jd).yFineUB;
    end
    
elseif(jtype==2)
    if(isfield(ar.model(jm).data(jd), 'xFineLB'))
        lb = [ar.model(jm).condition(jc).uFineLB ar.model(jm).condition(jc).xFineLB ...
            ar.model(jm).condition(jc).zFineLB];
        ub = [ar.model(jm).condition(jc).uFineUB ar.model(jm).condition(jc).xFineUB ...
            ar.model(jm).condition(jc).zFineUB];
    end
    
elseif(jtype==3)
    if(isfield(ar.model(jm).data(jd), 'vFineLB'))
        lb = ar.model(jm).condition(jc).vFineLB;
        ub = ar.model(jm).condition(jc).vFineUB;
    end
    
end

% steady state
if(jtype==2)
    dydt = ar.model(jm).condition(jc).dxdt;
    dydt(ar.model(jm).condition(jc).qSteadyState==0) = nan;
    dydt = [nan(size(ar.model(jm).u)) dydt nan(size(ar.model(jm).z))];
else
    dydt = [];
end
    
