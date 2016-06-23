function [] = log_herbivory(filename, logfilename, addheader)
    % e.g. log_herbivory('WAY01-T831-B2S-HA-5-A1.jpg','out.csv',1);

    damagetypes = {'mining', 'galls', 'feeding'};
    dpi = 300;
    
    timenow = datestr(now);
  
    lf = fopen(logfilename, 'a');

    im = imread(filename);

    all_leaves = false;
    numleaves = 0;

    while ~all_leaves
        figure; g = subplot(1,1,1);
        imshow(im);
        response = questdlg('Any more leaves to analyze?', filename, 'Yes','No','Yes');
        if (strcmp(response, 'No'))
            all_leaves = true;
            close;
        else
            try
                numleaves = numleaves + 1;

                questdlg('Select region of interest around non-herbivorized leaf.', filename, 'OK','OK');
                roi_full = impoly(g);

                roi_minvals = min(getPosition(roi_full));
                roi_range = range(getPosition(roi_full));
                brect = [roi_minvals roi_range];

                % crop and pad
                tm = createMask(roi_full);
                themask = uint16(tm);
                themask(themask==0) = 999;
                im2 = immultiply(uint16(im), repmat(themask,[1 1 3]));
                im2(im2 > 255) = 255;
                im2 = uint8(im2);
                im2 = imcrop(im2, brect);
                im2 = padarray(im2, [50 50], 255);
                close;

                [cats vals image] = process_herbivory(im2, sprintf('%s - leaf %d', filename, numleaves), damagetypes, dpi);

                if (addheader)
                    fprintf(lf, 'Date,Filename,Leaf,');
                    for i=1:numel(cats)
                        fprintf(lf, '%s,',cats{i});
                    end
                    fprintf(lf,'\n');
                end


                fprintf(lf, '%s,%s,%d,', timenow, filename, numleaves);
                for i=1:numel(vals)
                    fprintf(lf, '%f,',vals(i));
                end
                fprintf(lf,'\n');    

                imwrite(image, sprintf('SEGMENTED_%s - leaf %d_%s.png',filename, numleaves, timenow),'PNG');

                % erase the image
                tmfull = uint16(tm);
                tmfull(tmfull==1) = 999;
                tmfull(tmfull==0) = 1;
                im = immultiply(uint16(im), repmat(tmfull,[1 1 3]));
                im(im > 255) = 255;
                im = uint8(im);
            catch
                errstr = sprintf('%s,%s,%d,',timenow, filename, numleaves);
                for i=1:(2+numel(damagetypes))
                    errstr = [errstr 'NaN,'];
                end
                errstr = [errstr, '\n'];
                
                fprintf(errstr);
                fprintf(lf, errstr);
            end  
        end
    end

    fclose(lf);
end