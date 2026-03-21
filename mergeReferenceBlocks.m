function merged = mergeReferenceBlocks(varargin)
%MERGEREFERENCEBLOCKS Concatenate non-empty PF/PS reference blocks.
%   MERGED = MERGEREFERENCEBLOCKS(A, B, C, ...) vertically concatenates all
%   numeric, non-empty inputs. Empty inputs are ignored.

    merged = [];
    for i = 1:nargin
        block = varargin{i};
        if isempty(block)
            continue;
        end
        if ~isnumeric(block)
            error('mergeReferenceBlocks:InvalidInput', 'All reference blocks must be numeric matrices.');
        end
        if isempty(merged)
            merged = block;
        else
            merged = [merged; block]; %#ok<AGROW>
        end
    end
end
