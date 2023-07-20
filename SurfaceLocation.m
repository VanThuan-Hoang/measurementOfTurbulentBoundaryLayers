function surfaceLocation = SurfaceLocation(X,Y,RPM)

%%{
if strcmp(Y,'0')
    if strcmp(X,'3810')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 5.16;%4.013;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 5.16;%4.55;   % 4.35 RPM = 350
        end 
    end
    if strcmp(X,'3660')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 4.853;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 4.853;   % 4.35 RPM = 350
        end 
    end  
    if strcmp(X,'4020')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 4.98; %4.379;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 4.98; %4.379;   % 4.35 RPM = 350
        end 
    end
    if strcmp(X,'3915')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 4.482;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 4.482;   % 4.35 RPM = 350
        end 
    end
    if strcmp(X,'3610')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 4.971;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 4.971;   % 4.35 RPM = 350
        end 
    end
    if strcmp(X,'3570')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 5.53;% 5.30; %5.197;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 5.53;%5.30; %5.197;   % RPM = 350
        end 
    end

   
end
%}

%{
if strcmp(Y,'0')
    if strcmp(X,'2910')                                       % X = 2910 mm
        if strcmp(RPM,'350'),       surfaceLocation = 4.31;   % RPM = 350
        end
    elseif strcmp(X,'3480')                                   % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 3.78;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 3.93;   % RPM = 350
        elseif strcmp(RPM,'525'),   surfaceLocation = 4.20;   % RPM = 525
        end
    elseif strcmp(X,'3810')                                   % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = 1.90;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 2.00;   % RPM = 350
        elseif strcmp(RPM,'525'),   surfaceLocation = 2.30;   % RPM = 525
        end 
    elseif strcmp(X,'4110')
        if strcmp(RPM,'200'),   	surfaceLocation = 1.38;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = 1.58;   % RMP = 350
        elseif strcmp(RPM,'525'),   surfaceLocation = 1.83;   % RPM = 525
        end
    end

elseif strcmp(Y,'260')
    if strcmp(X,'3810')                                       % X = 3480 mm
        if strcmp(RPM,'200'),   	surfaceLocation = -0.4;   % RPM = 200
        elseif strcmp(RPM,'350'),   surfaceLocation = -0.3;   % RPM = 350
        elseif strcmp(RPM,'525'),   surfaceLocation = -0.4;   % RPM = 525
        end
    end
end
%}

end