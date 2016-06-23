function [categories values overlap_truecolor] = process_herbivory(im, filename, damage_types, dpi)
    % outputs areas in cm^2 assuming an input image with square pixels at
    % resolution dpi pixels per inch
    pixels_per_cm = dpi / 2.54;
 
    warningState = warning('off','Images:initSize:adjustingMag');
    
    figure;
    g1 = subplot(1,2,1); imshow(im);
    done = false;
    mask = ones(size(im(:,:,1)));
    while (~done)
        lr = questdlg('Add polygon to lamina?','Trace unherbivorized lamina outline','Yes','No','Yes');
        done = strcmp(lr,'No');
        
        if ~done
        
            roi = impoly(g1);
            mask = ~(~mask | createMask(roi));

            g2 = subplot(1,2,2); plot_dt(mask, zeros(size(mask)), {}, 1);



            delete(roi);
        end
    end

     % threshold the lamina
    thresholdval = graythresh(im);
    done = false;
    while (~done)                
        thresholdedimage = im2bw(im, thresholdval);
        g2 = subplot(1,2,2); plot_dt(mask, thresholdedimage, {}, 1);
        
        % determine where is the original lamina and the amount remaining
        resp = inputdlg(sprintf('Current herbivory threshold: %.2f. New value? (Leave empty to accept, cancel to abort)', thresholdval), 'Choose threshold');
       
        if (length(resp) == 0)
            error(sprintf('Giving up on image %s', filename));
        end
        
        done = isempty(resp{1});
        thresholdval = str2num(resp{1});
        
        if thresholdval > 1
            thresholdval = 1;
        end
        
        if thresholdval < 0
            thresholdval = 0;
        end       
    end
    
    
    % assay all specialized damage types
    dt_masks = cell(size(damage_types));
    
    [overlap overlap_truecolor] = plot_dt(mask, thresholdedimage, dt_masks, 0);
    for i=1:numel(damage_types)
        dt_masks{i} = ones(size(mask));
        donewithdt = false;
        while (~donewithdt)
            dtexists = questdlg(sprintf('Does damage type %s exist?',damage_types{i}),'Highlight specialized damage','Yes','No','No');
            
            if (strcmp(dtexists, 'Yes'))
                nomorepolygons = false;
                
                while(~nomorepolygons)

                    roi_dt = impoly(g1);
                    lr = questdlg('Polygon OK?','Check ROI','Yes','No','Yes');
                    polyok = strcmp(lr,'Yes');
                    if (polyok)
                        thismask = ~(createMask(roi_dt) & ~mask & ~thresholdedimage);
                        
                        dt_masks{i} = ~(~thismask | ~dt_masks{i}); % FIX
                    end
                    
                    delete(roi_dt);
                    g2 = subplot(1,2,2); 
                    [overlap overlap_truecolor] = plot_dt(mask, thresholdedimage, dt_masks, 1);
                    
                    lr2 = questdlg('Add damage polygon?','Add polygon','Yes','No','No');
                    nomorepolygons = ~strcmp(lr2, 'Yes');
                end
                
                donewithdt = true;
            else
                donewithdt = true;
            end
        end

    end
    
    close;
    

    % count up all the selected areas
    lamina_area_real = nnz(overlap(:)==4);
    lamina_area_eaten = nnz(overlap(:)==3);
    lamina_area_total = lamina_area_real + lamina_area_eaten;
    
    area_dts = NaN(1, numel(damage_types));
    for i=1:numel(damage_types)
        area_dts(i) = nnz(overlap(:)==4+i);
    end
    categories = ['area_total', 'area_eaten', damage_types];
    values = [lamina_area_total, lamina_area_eaten, area_dts];

    values = values / pixels_per_cm^2; 
end
    
