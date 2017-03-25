%function plotClassDates(Package)
Package = SOMPackage;
pollenall = DataPackage.OutAll;
%--------------------------------------------------------------------------
%set up plot
scrsz = get(groot,'ScreenSize');
width=scrsz(3)/5;
height=scrsz(4)/5;
left=10;
bottom=10;




%--------------------------------------------------------------------------
markedDates = Package.classAllo;%this variable is the vector that, each row
%showes the class number of corresponding date.
tline = markedDates(:,2:end);
clsNum = markedDates(:,1);

[B,ind] = unique(tline(:,1));
ind(end+1) = length(tline(:,1))+1;
[l,m] = size(B);
for i=1:(l-1)
    head = ind(i);
    tail = ind(i+1)-1;
    
    tl = datenum(tline(head:tail,:));
    pollen = pollenall(head:tail,:);
    figure('Position',[left, bottom, width, height],'Renderer','painters')%plot each class%
    left=left+width;
    if left>4*width
        left=10;
        bottom=bottom+height;
        if bottom>4*height
            bottom=10;
        end
    end
    scatter(tl,pollen)
    datetick('x','keepticks','keeplimits');
    xlabel('Time of year','FontSize',30)
    ylabel('Pollen count','FontSize',30)
    title( ['year #' num2str(i)],'FontSize',30)
    set(gca,'FontSize',16)
    set(gca,'LineWidth',2);
end