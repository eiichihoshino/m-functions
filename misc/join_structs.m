function joined = join_structs(Ss, params)
%
% JOIN_STRUCT: join an array of structues regarding each field data.
% v.1.0.0 Init. 2016.10.20 Hoshino, E.
%
% INPUT
% 	Ss: an array of structures.
%   params: a structre to define way of join for each field.
%           Example:
%           params.field1 = {@condition, @true, @false}
%           params.field2 + {@condition, @true, @false}
%           @condition, @true, @false are function handles
%
% OUTPUT
% 	joined: joined structure.
%
if numel(Ss) == 1
    warning('MyComponent:debug', 'Nothing to join.');
    joined = Ss;
    return;
end
flds = fieldnames(Ss)';
if isempty(params) ||  isempty(fieldnames(params))
    for fld = flds
        params.(fld{1}) = {[] [] []};
    end
    param_flds = flds;
else
    param_flds = fieldnames(params)';
    if ~all(ismember(param_flds, flds))
        error('params:%s were not found.',strjoin(param_flds(~ismember(param_flds, flds)), ', '));
    end
end
for param_fld = param_flds
    if isempty(params.(param_fld{1}))
        params.(param_fld{1}) = {[] [] []};
    end
end

for fld_i = 1:numel(param_flds)
    %condition
    if isempty(params.(param_flds{fld_i}){1})
        condition = @(x) isequal(x{:});
    else
        condition = params.(param_flds{fld_i}){1};
    end
    %if true
    if isempty(params.(param_flds{fld_i}){2})
        case_true = @(x) x{1};
    else
        case_true = params.(param_flds{fld_i}){2};
    end
    %if false
    if isempty(params.(param_flds{fld_i}){3})
        case_false = @(x) cat(2, x{:});
    else
        case_false = params.(param_flds{fld_i}){3};
    end
    x = eval(sprintf('{Ss.%s}', param_flds{fld_i}));
    try
        if condition(x)
            joined.(param_flds{fld_i}) = case_true(x);
        else
            joined.(param_flds{fld_i}) = case_false(x);
        end
    catch ME
        if (strcmp(ME.identifier,'MATLAB:catenate:dimensionMismatch'))
            warning('MyComponent:debug', 'Join structs was canceled due to dimension mismatch at field: %s.', param_flds{fld_i});
            joined = Ss;
            return;
        else
            rethrow(ME)
        end
    end
end