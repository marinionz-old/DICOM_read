%%
clc
clear

% Transform into into a function in the way that the DICOM_READ will have
% as inputs the original path and the new one.
original_path='C:\Users\marti\Desktop\2019-2020\2 cuatri\Advanced topics in medical image\Homeworks\Homework1_DICOM\HOMEWORK1\';
% path_final=input('Please introduce image final path: ','s');
new_path='C:\Users\marti\Desktop\2019-2020\2 cuatri\Advanced topics in medical image\Homeworks\Homework1_DICOM\';

files = dir([original_path '*.dcm']);
filename=[];
len=length(files);
series_num=0;

for i=1:len
    
    filename{i}=files(i).name;
    info=dicominfo([original_path  filename{i}]);
    
    % Get DICOM info
    patientID{i}=info.PatientID;
    studyID{i}=info.StudyInstanceUID;
    seriesID{i}=info.SeriesDescription;
    
    %
    if ~exist([ new_path patientID{i} ],'dir')
        mkdir([ new_path patientID{i} ]);
    end
    if ~exist([ new_path patientID{i} '\' studyID{i} ],'dir')
        mkdir([ new_path patientID{i} '\' studyID{i}]);
    end
    if ~exist([ new_path patientID{i} '\' studyID{i} '\' seriesID{i}],'dir')
        mkdir([ new_path patientID{i} '\' studyID{i} '\' seriesID{i}]);
        series_num=series_num+1;
        series_path{series_num}=[ new_path patientID{i} '\' studyID{i} '\' seriesID{i}];
    end
    %
    copyfile([original_path filename{i}],[ new_path patientID{i} '\' studyID{i} '\' seriesID{i}]);
    
end

%%

volume=[];

for j=1:series_num
    
    % Resetting auxiliary variables
    z_pat=[];
    Pat_pos=[];
    img_name=[];
    pixmatrix=[];
    
    % Resetting images used for image acquisition and acquiring them from
    % each series path.
    images=[];
    images=dir([series_path{j} '\*.dcm']);
    len=length(images);
    
    for p=1:len
        
        img_info=[];
        img_name{p}=images(p).name;
        img_info=dicominfo([series_path{j} '\' img_name{p}]);
        Pat_pos{p}=img_info.ImagePositionPatient;
        
        z_pat(p)=Pat_pos{p}(3);
        pixmatrix{p}=dicomread(img_info);
        pixmatrix{p}=pixmatrix{p}*img_info.RescaleSlope-img_info.RescaleIntercept;
        
    end
    
    [order,index]=sort(z_pat,'descend');
    count0=0;
    
    for k=index
        count0=count0+1;
        final_image{j}(:,:,count0)=pixmatrix{k};
    end
    
    [x,y,z]=size(final_image{j});
    
    % 3D volume slices
    axial{j}=reshape(final_image{j}(:,:,floor(z/2)),x,y);
    
    sagit=squeeze(final_image{j}(:,floor(y/2),:));
    tform1 = affine2d([  0 -img_info.SliceThickness/img_info.PixelSpacing(1); 1 0; 0 0]);
    sagittal{j}=imwarp(sagit,tform1);
    sagittal{j}=flipud(sagittal{j});
    
    coron=squeeze(final_image{j}(floor(x/2),:,:));
    tform2 = affine2d([ 0 img_info.SliceThickness/img_info.PixelSpacing(2); -1 0; 0 0]);
    coronal{j}=imwarp(coron,tform2);
    coronal{j}=fliplr(coronal{j});
    
    matrix_size{j}=[x,y,z];
    
    % We will present it in m^3
    volume(j).size=img_info.PixelSpacing(1)*x*img_info.PixelSpacing(1)*y*img_info.SliceThickness*z/(1000^3);
    volume(j).series=img_info.SeriesDescription;
end
