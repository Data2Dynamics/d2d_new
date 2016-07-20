function l1trdog

checksum_orig = 'B7367382AFBDBAE745D195ADDCAF7AA4'; % trdog.m from Mathworks
checksum_l1   = '67AF8E95E14AF615DFAB379CA542FD6C'; % Modified trdog.m

trpath = which('trdog','-all');
ar_path = fileparts(which('arInit.m'));

trd_orig = 0;
trd_l1   = 0;
for i = 1:length(trpath)
    if strcmp(md5(trpath{i}),checksum_orig)
        % found original trdog.m
        trd_orig = i;
    elseif strcmp(md5(trpath{i}),checksum_l1)
        % found modified trdog.m
        trd_l1 = i;
    end
end

if strcmp(md5(trpath{1}),checksum_l1)
    % All good
    return
end

modified = 0;
if trd_orig > 0 && trd_l1 == 0
    % Modify original trdog.m for L1
    fileID = fopen(trpath{trd_orig});
    A = fread(fileID,'*char')';
    fclose(fileID);
    
    keystart{1}  = '% Initialization';
    keyend{1}    = '      % Truncate the reflected direction?';
    keystart{2}  = '      qpval3 = qpval0 +  nrhs''*nst + (.5*nst)''*MM*nst;';
    keyend{2}    = '   %   Truncate the gradient direction?';
    keystart{3}  = '   qpval2 = rhs''*st + (.5*st)''*MM*st;';
    keyend{3}    = '% Choose the best of s, sg, ns.';
    keypos{1} = 'ss = full(alpha*ss);';
    keypos{2} = '      nss = full(alpha*nss);';
    keypos{3} = '   ssg = full(alpha*ssg);';
    
    text = {};
    text{1} = sprintf(['\n[dofit,out] = determine_dofit(x,g,H,D,delta,dv,...\n',...
    '    mtxmpy,pcmtx,pcoptions,tol,kmax,theta,l,u,Z,dnewt,preconflag,varargin);\n',...
    '\n',...
    's = zeros(size(x));\n',...
    'snod = zeros(size(x));\n',...
    '\n',...
    'if(isempty(Z))\n',...
    '    z = Z;\n',...
    '    Z = zeros(length(x),2);\n',...
    'else\n',...
    '    z = Z(dofit,:);\n',...
    '    z = z./(ones(size(z,1),1)*sum(z.^2));\n',...
    '    z(isnan(z)) = 0;\n',...
    'end\n',...
    '\n',...
    'ind_L1 = [];\n',...
    'try\n',...
    '    global ar\n',...
    '    fitted = ar.qFit == 1;\n',...
    '    l1s = find(ar.type(fitted) == 3);\n',...
    '    if ~isempty(l1s)\n',...
    '        ind_L1 = find(ismember(dofit,l1s));\n',...
    '    end\n',...
    'end\n',...
    '\n',...
    'if(size(H,1)==size(H,2))\n',...
    '    [s2,snod2,qpval,posdef,pcgit,Z2] = trdog_matlab(x(dofit),g(dofit),H(dofit,dofit),D(dofit,dofit),delta,dv(dofit),...\n',...
    '        mtxmpy,pcmtx,pcoptions,tol,kmax,theta,l(dofit),u(dofit),z,dnewt,preconflag,ind_L1,varargin{:});\n',...
    'else\n',...
    '    [s2,snod2,qpval,posdef,pcgit,Z2] = trdog_matlab(x(dofit),g(dofit),H(:,dofit),D(dofit,dofit),delta,dv(dofit),...\n',...
    '        mtxmpy,pcmtx,pcoptions,tol,kmax,theta,l(dofit),u(dofit),z,dnewt,preconflag,ind_L1,varargin{:});\n',...
    'end\n',...
    '\n',...
    's(dofit) = s2;\n',...
    'snod(dofit) = snod2;\n',...
    'Z(dofit,1:size(Z2,2)) = Z2;\n',...
    '\n',...
    '\n',...
    'function [dofit,out] = determine_dofit(x,g,H,D,delta,dv,...\n',...
    '    mtxmpy,pcmtx,pcoptions,tol,kmax,theta,l,u,Z,dnewt,preconflag,varargin)\n',...
    '\nthresh = 1e-2;\n\n']);
    
    text{2} = sprintf(['\nout = union(find(x+ssave>u & abs(u-x)<=thresh),find(x+ssave<l & abs(x-l)<=thresh));\n',...
    'if n > 1\n',...
    '    out = union(out,find(x+sg>u & abs(u-x)<=thresh));\n',...
    '    out = union(out,find(x+sg<l & abs(x-l)<=thresh));\n',...
    'end\n',...
    'if exist(''ns'')\n',...
    '    out = union(out,find(x+(ns + r)>u & abs(u-x)<=thresh));\n',...
    '    out = union(out,find(x+(ns + r)<l & abs(x-l)<=thresh));\n',...
    'end\n',...
    'dofit= setdiff(1:length(x),out);\n\n\n',...
    'function[s,snod,qpval,posdef,pcgit,Z] = trdog_matlab(x,g,H,D,delta,dv,...\n',...
    '   mtxmpy,pcmtx,pcoptions,tol,kmax,theta,l,u,Z,dnewt,preconflag,ind_L1,varargin)\n']);


    text{3} = sprintf(['\n\nif ~isempty(ind_L1)\n',...
    '    myind = zeros(size(x));\n',...
    '    myind(ind_L1) = 1;\n',...
    '    myind = logical(myind);\n',...
    '    newx = x+s;\n',...
    '    signchange = (abs(sign(newx) - sign(x)) == 2) & (abs(newx) > 1e-10) & (abs(x) > 1e-10) & (myind);\n',...
    '    if sum(signchange) > 0\n',...
    '        distzero = abs(x) ./ abs(s);\n',...
    '        alpha = min(distzero(signchange));\n',...
    '        s = alpha*s; \n',...
    '        st = alpha*st; \n',...
    '        ss = alpha*ss;\n',...
    '    end\n',...
    'end\n']);

    text{4} = sprintf(['\n\nif ~isempty(ind_L1)\n',...
    '    myind = zeros(size(x));\n',...
    '    myind(ind_L1) = 1;\n',...
    '    myind = logical(myind);\n',...
    '    newx = x+(ns + r);\n',...
    '    signchange = (abs(sign(newx) - sign(x)) == 2) & (abs(newx) > 1e-10) & (abs(x) > 1e-10) & (myind);\n',...
    '    if sum(signchange) > 0\n',...
    '        distzero = abs(x) ./ abs(ns + r);\n',...
    '        alpha = min(distzero(signchange));\n',...
    '        ns = alpha*ns;\n',...
    '        nst = alpha*nst;\n',...
    '        nss = full(alpha*nss);\n',...
    '    end\n',...
    'end\n']);

    text{5} = sprintf(['\n\n   if ~isempty(ind_L1)\n',...
    '        myind = zeros(size(x));\n',...
    '        myind(ind_L1) = 1;\n',...
    '        myind = logical(myind);\n',...
    '        newx = x+sg;\n',...
    '        signchange = (abs(sign(newx) - sign(x)) == 2) & (abs(newx) > 1e-10) & (abs(x) > 1e-10) & (myind);\n',...
    '        if sum(signchange) > 0\n',...
    '            distzero = abs(x) ./ abs(sg);\n',...
    '            alpha = min(distzero(signchange));\n',...
    '            sg = alpha*sg;\n',...
    '            st = alpha*st;\n',...
    '            ssg = alpha*ssg;\n',...
    '        end\n',...
    '   end\n']);

    poshead = strfind(A,'%');
    poshead = poshead(1);
    
    posstart = nan(1,length(keystart));
    posend = posstart;
    posstart(1) = strfind(A,keystart{1});
    posend(1)   = strfind(A,keyend{1});
    posstart(2) = strfind(A,keystart{2});
    posend(2)   = strfind(A,keyend{2});
    posstart(3) = strfind(A,keystart{3});
    posend(3)   = strfind(A,keyend{3});
    
    poskey = nan(1,length(keypos));
    poskey(1) = strfind(A,keypos{1});
    poskey(2) = strfind(A,keypos{2});
    poskey(3) = strfind(A,keypos{3});
    
    A_new = [A(1:poshead-1) text{1} A(poshead:end)];
    A_new = [A_new(1:poshead+length(text{1})-1) A(posstart(1):posend(1)-1) A(posstart(2)+length(keystart{2}):posend(2)-1) A(posstart(3)+length(keystart{3}):posend(3)-1) text{2} A_new(poshead+length(text{1}):end)];
    
    Ninsert = length(text{1})+sum(posend-posstart)-length(keystart{2})-length(keystart{3})+length(text{2})+length(keypos{1});
    A_new = [A_new(1:poskey(1)+Ninsert-1) text{3} A_new(poskey(1)+Ninsert:end)];
    Ninsert = Ninsert + length(text{3}) + length(keypos{2}) - length(keypos{1});
    A_new = [A_new(1:poskey(2)+Ninsert-1) text{4} A_new(poskey(2)+Ninsert:end)];
    Ninsert = Ninsert + length(text{4}) + length(keypos{3}) - length(keypos{2});
    A_new = [A_new(1:poskey(3)+Ninsert-1) text{5} A_new(poskey(3)+Ninsert:end)];
    
    if ~isequal(exist([ar_path '/l1/trdog'], 'dir'),7)
        mkdir([ar_path '/l1'],'trdog')
    end
    fileID = fopen([ar_path '/l1/trdog/trdog.m'],'w');
    fwrite(fileID,A_new,'char');
    fclose(fileID);
    
    modified = 1;
end

if trd_l1 > 0;
    % L1 trdog.m is shadowed by some other trdog.m
    warning('Please remove file %s.\n',trpath{1})
    return
end

if modified == 0;
    warning('No trdog.m file found.')
end


function md5hash = md5(filename)

mddigest   = java.security.MessageDigest.getInstance('MD5'); 
filestream = java.io.FileInputStream(java.io.File(filename)); 
digestream = java.security.DigestInputStream(filestream,mddigest);

while(digestream.read() ~= -1) end

md5hash=reshape(dec2hex(typecast(mddigest.digest(),'uint8'))',1,[]);