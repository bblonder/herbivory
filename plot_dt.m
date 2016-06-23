function [overlap overlap_truecolor] = plot_dt(mask, thresholdedimage, damagemasks, doplot)
    overlap = zeros(size(thresholdedimage));
    overlap((thresholdedimage == 0) & (mask == 0)) = 4; % inferred lamina and real lamina (remaining leaf - blue)
    overlap((thresholdedimage == 1) & (mask == 0)) = 3; % inferred lamina and no real lamina (herbivory - green)
    overlap((thresholdedimage == 0) & (mask == 1)) = 2; % no inferred lamina and real lamina (outline delineation problem - red)
    overlap((thresholdedimage == 1) & (mask == 1)) = 1; % no inferred lamina or real lamina (background - black)

    for i=1:numel(damagemasks)
        overlap((damagemasks{i}==0)) = 4+i;
    end

    colormap = [copper(4); lines(numel(damagemasks))];

    if (doplot)
        imshow(overlap, colormap);
    end
    
    overlap_truecolor = ind2rgb(overlap, colormap);
end