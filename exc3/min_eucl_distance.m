function center = min_eucl_distance(feature, words)
    

    distances = [];
    n = size(words,1);
    for i = 1:n
        dist = sum((feature - words(i,:)).^2);
        distances = [distances dist];
    end
    
    [~,center] = min ( distances) ;
end