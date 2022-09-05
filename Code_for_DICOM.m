%%
clc
clear

folder0 = ''
directory_name = folder0 + 'HOMEWORK1';
files=dir('C:\Users\marti\Desktop\2019-2020\2 cuatri\Advanced topics in medical image\Homeworks\Homework1_DICOM\HOMEWORK1');
filename=[];
len=length(files);
series_num=0;

if exist([folder0 'TCGA-34-5240'],'dir')
    rmdir ([folder0 'TCGA-34-5240'],'s');
end

for i=3:len
    
    filename{i-2}=files(i).name;
    info=dicominfo([folder0 'HOMEWORK1\' filename{i-2}]);
    patientID{i-2}=info.PatientID;
    studyID{i-2}=info.StudyInstanceUID;
    seriesID{i-2}=info.SeriesInstanceUID;
    
    
    %
    if ~exist([ folder0 patientID{i-2} ],'dir')
        mkdir([ folder0 patientID{i-2} ]);
    end
    if ~exist([ folder0 patientID{i-2} '\' studyID{i-2} ],'dir')
        mkdir([ folder0 patientID{i-2} '\' studyID{i-2}]);
    end
    if ~exist([ folder0 patientID{i-2} '\' studyID{i-2} '\' seriesID{i-2}],'dir')
        mkdir([ folder0 patientID{i-2} '\' studyID{i-2} '\' seriesID{i-2}]);
        series_num=series_num+1;
        series_path{series_num}=[ folder0 patientID{i-2} '\' studyID{i-2} '\' seriesID{i-2}];
    end
    %
    copyfile([folder0 'HOMEWORK1\' filename{i-2}],[ folder0 patientID{i-2} '\' studyID{i-2} '\' seriesID{i-2}]);
    i
end

%%

for j=1:series_num

    images=[];
    z_pat=[];
    Pat_pos=[];
    img_name=[];
    sag_view0=[];
    pixmatrix=[];
    images=dir(series_path{j});
    len=length(images);
    
    for p=3:len
    
        img_info=[];
        img_name{p-2}=images(p).name;
        img_info=dicominfo([series_path{j} '\' img_name{p-2}]);
        Pat_pos{p-2}=img_info.ImagePositionPatient;
        z_pat(p-2)=Pat_pos{p-2}(3);
        pixmatrix{p-2}=dicomread(img_info);
        
    end
     [order,index]=sort(z_pat,'descend');
     count0=0;
     for k=index
         count0=count0+1;
        final_image{j}(:,:,count0)=pixmatrix{k};
     end
     
     figure(j);
     final_image{j}=final_image{j}*img_info.RescaleSlope;
     final_image{j}=final_image{j}-img_info.RescaleIntercept;
     [x,y,z]=size(final_image{j});
     
     % Axial
     imshow(final_image{j}(:,:,floor(z/2)),[min(final_image{j},[],'all') max(final_image{j},[],'all')]);
     
     % Sagittal
     sag_view0=final_image{j}(:,floor(y/2),:);
     sag_view0=reshape(sag_view0,[x,z]);
     R2 = makeresampler({'cubic','nearest'},'fill');
     T0 = maketfom('affine',[0 -2.5 0; 1 0 0; 0 0 0]);
     sag_view{j} = imtransform(sag_view0,T0,R2);  
     imshow(sag_view{j},[min(sag_view{j},[],'all') max(sag_view{j},[],'all')]);
     
     % Coronal
     cor_view0=final_image{j}(floor(x/2),:,:);
     cor_view{j}=reshape(cor_view0,[y z]);
     imshow(cor_view{j},[min(cor_view{j},[],'all') max(cor_view{j},[],'all')]);
end
