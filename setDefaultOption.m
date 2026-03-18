function options = setDefaultOption(options, name, value)
%SETDEFAULTOPTION Set a default option if the field is missing or empty.

    if ~isfield(options, name) || isempty(options.(name))
        options.(name) = value;
    end
end
