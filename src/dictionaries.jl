function incsert!(d::AbstractDictionary, ind, val = 1)
    return set!(d, ind, isassigned(d, ind) ? d[ind] + val : val)
end

function incsert!(d::AbstractDict, ind, val = 1)
    return d[ind] = haskey(d, ind) ? d[ind] + val : val
end
