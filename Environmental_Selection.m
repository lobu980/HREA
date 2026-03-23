function Population = Environmental_Selection(Union, N, delta)
%ENVIRONMENTAL_SELECTION Compatibility wrapper for MMOEA-DC selection.
    Population = Environmental_Selection_C(Union, N, delta, 1);
end
