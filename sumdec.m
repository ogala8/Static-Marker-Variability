function s = sumdec(n)
    if n < 1
        s = 0;
    else
        s = n + sumdec(n-1);
    end
end