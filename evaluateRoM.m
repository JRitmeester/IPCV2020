function [horRange, verRange, depRange] = evaluateRoM(path, horBasis, verBasis, depBasis)
%EVALUATEROM decomposes the 3D path into a range of motion.
%   Detailed explanation goes here
    n = size(path,2);
    for p = 1:n        
        horRange(p) = dot(path(p,:), horBasis);
        verRange(p) = dot(path(p,:), verBasis);
        depRange(p) = dot(path(p,:), depBasis);
    end
end

