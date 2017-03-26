function plotClassDates(Package)
% Package = SOMPackage;
pollenall = Package.pollen;
%--------------------------------------------------------------------------
%set up plot
scrsz = get(groot,'ScreenSize');
width=scrsz(3)/5;
height=scrsz(4)/5;
left=10;
bottom=10;




%--------------------------------------------------------------------------
markedDates = Package.classAllo;%this variable is the vector that, each row
n = Package.n;%n is number of classes
%showes the class number of corresponding date.
tline = markedDates(:,2:end);
clsNum = squeeze(markedDates(:,1));


[B,ind] = unique(tline(:,1));
ind(end+1) = length(tline(:,1))+1;
[l,m] = size(B);
for i=1:(l-1)
    head = ind(i);
    tail = ind(i+1)-1;
    
    cls = clsNum(head:tail);
    tl = datenum(tline(head:tail,:));%cut out the time line of that year
    pollen = pollenall(head:tail,:);%cut out pollen data of that year
    figure('Position',[left, bottom, width, height],'Renderer','painters')%plot each class%
    left=left+width;
    if left>4*width
        left=10;
        bottom=bottom+height;
        if bottom>4*height
            bottom=10;
        end
    end
%   scatter(tl,pollen)
    %barplot, different colors for different classes
    colors = distinguishable_colors(n);
    lgd = cell([1 30]);
    
    hold on
    
    %distribute classes, each loop plot a class with on color
    for j=1:n
        color = colors(j,:);%choose the color
        idx = find(~(cls-j));
        tl_p = tl(idx);%cut out the dates of that class
        pollen_p = pollen(idx);%cut out the pollen data of that class
        bar(tl_p,pollen_p,'FaceColor',color);
        lgd{j} = ['class#' num2str(j)];
    end
    %bar plot 
    hold off
    legend(lgd);
    datetick('x','keepticks','keeplimits');
    xlabel('Time of year','FontSize',30)
    ylabel('Pollen count','FontSize',30)
    title( ['year ' num2str(1983+i)],'FontSize',30)
    set(gca,'FontSize',16)
    set(gca,'LineWidth',2);
end